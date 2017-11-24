package routes;

import tink.core.Error;
import haxe.crypto.Base64;
import haxe.io.Bytes;

import tink.CoreApi.FutureTrigger;
import tink.http.Response.IncomingResponse;
import tink.CoreApi.Future;
import tink.CoreApi.Promise;
import tink.http.Header.HeaderName;
import tink.http.Header.HeaderField;
import tink.web.routing.*;
import tink.http.clients.SecureSocketClient;
import tink.http.Request;

import jwt.JWT;

using StringTools;

class OAuth2 {
    public function new() {}
    
    @:get('/login/$service') public function login(service:String):Response {
        var redirectURI:String = Server.config.root.api + '/api/oauth2/redirect';

        var urlString:String = null;
        var clientID:String = null;
        var scope:String = null;
        var state:String = null;
        switch(service.toLowerCase()) {
            case 'google': {
                urlString = 'https://accounts.google.com/o/oauth2/v2/auth';
                clientID = Server.config.oauth2.google.id;
                scope = 'openid profile';
                state = 'auth-google';
            }

            case 'facebook': {
                urlString = 'https://www.facebook.com/v2.10/dialog/oauth';
                clientID = Server.config.oauth2.facebook.id;
                scope = 'public_profile';
                state = 'auth-facebook';
            }

            case _: return new response.NotFound(service);
        }

        urlString += '?client_id=${clientID.urlEncode()}';
        urlString += '&redirect_uri=${redirectURI.urlEncode()}';
        urlString += '&response_type=code';
        urlString += '&scope=${scope.urlEncode()}';
        urlString += '&access_type=offline';
        urlString += '&state=${state.urlEncode()}';
        urlString += '&nonce=${Math.random()}';
        var url:tink.Url = urlString;
        return url;
    }

    @:get public function redirect(query:{code:String, state:String}):Promise<Response> {
        var headers:Array<HeaderField> = new Array<HeaderField>();
        headers.push(new HeaderField(HeaderName.ContentType, 'application/x-www-form-urlencoded'));

        var redirectURI:String = Server.config.root.api + '/api/oauth2/redirect';
        var host:String = null;
        var uri:String = null;
        var clientID:String = null;
        var clientSecret:String = null;

        switch(query.state.toLowerCase()) {
            case 'auth-google': {
                host = 'www.googleapis.com';
                uri = '/oauth2/v4/token';
                clientID = Server.config.oauth2.google.id;
                clientSecret = Server.config.oauth2.google.secret;
            }

            case 'auth-facebook': {
                host = 'graph.facebook.com';
                uri = '/v2.10/oauth/access_token';
                clientID = Server.config.oauth2.facebook.id;
                clientSecret = Server.config.oauth2.facebook.secret;
            }

            case _: return Future.sync(new response.NotFound(query.state));
        }

        var body:String = 'code=${query.code.urlEncode()}';
        body += '&client_id=${clientID.urlEncode()}';
        body += '&client_secret=${clientSecret.urlEncode()}';
        body += '&redirect_uri=${redirectURI.urlEncode()}';
        body += '&grant_type=authorization_code';

        headers.push(new HeaderField(HeaderName.ContentLength, body.length));

        var client = new SecureSocketClient();
        var req:Promise<Bytes> = client.request(new OutgoingRequest(
            new OutgoingRequestHeader(POST, new tink.url.Host(host), uri, headers),
            body
        )).next(function(res:IncomingResponse):Promise<Bytes> {
            return res.body.all();
        });

        return switch(query.state.toLowerCase()) {
            case 'auth-google':
                req.next(function(raw:Bytes):Promise<Response> {
                    var result:Dynamic = haxe.Json.parse(raw.toString());
                    var payload:Dynamic = JWT.extract(result.id_token);
                    var sub:String = payload.sub;

                    // verify the claims of the token
                    if(payload.iss != 'https://accounts.google.com' || payload.aud != Server.config.oauth2.google.id)
                        return new response.Unauthorized();

                    // TODO: verify using Google's publickey

                    var users:List<models.User> = models.User.manager.search($googleID == sub);
                    var user:models.User = if(users.length < 1) {
                        // create a new user!
                        var u:models.User = new models.User();
                        u.name = payload.name;
                        u.googleID = payload.sub;
                        u.picture = payload.picture;
                        u.createdOn = Date.now();
                        u.modifiedOn = Date.now();
                        u.insert();
                        Log.info('Created new Google user: ${u.name}');
                        autoFriend(u);
                        u;
                    }
                    else {
                        var u:models.User = users.first();
                        if(u.name != payload.name || u.picture != payload.picture) {
                            u.name = payload.name;
                            u.picture = payload.picture;
                            u.modifiedOn = Date.now();
                            u.update();
                        }
                        Log.info('Google user logged in: ${u.name}');
                        u;
                    }

                    var token:String = AuthRoutes.buildToken(user.id);
                    return new response.Redirect(Server.config.root.client + '#!/login/${token.urlEncode()}');
                });

            case 'auth-facebook':
                req.next(function(raw:Bytes):Promise<IncomingResponse> {
                    var result:Dynamic = haxe.Json.parse(raw.toString());
                    var accessToken:String = result.access_token;

                    return client.request(new OutgoingRequest(
                        new OutgoingRequestHeader(
                            GET,
                            new tink.url.Host('graph.facebook.com'),
                            '/v2.5/me?fields=id,name,picture&access_token=${accessToken.urlEncode()}'
                        ), ''
                    ));
                }).next(function(res:IncomingResponse):Promise<Bytes> {
                    return res.body.all();
                }).next(function(raw:Bytes):Promise<Response> {
                    var result:Dynamic = haxe.Json.parse(raw.toString());
                    var fbID:String = result.id;

                    var users:List<models.User> = models.User.manager.search($facebookID == fbID);
                    var user:models.User = if(users.length < 1) {
                        // create a new user!
                        var u:models.User = new models.User();
                        u.name = result.name;
                        u.facebookID = fbID;
                        u.picture = result.picture.data.url;
                        u.createdOn = Date.now();
                        u.modifiedOn = Date.now();
                        u.insert();
                        Log.info('Created new Facebook user: ${u.name}');
                        autoFriend(u);
                        u;
                    }
                    else {
                        var u:models.User = users.first();
                        if(u.name != result.name || (!result.picture.data.is_silhouette && u.picture != result.picture.data.url)) {
                            u.name = result.name;
                            if(!result.picture.data.is_silhouette)
                                u.picture = result.picture.data.url;
                            u.modifiedOn = Date.now();
                            u.update();
                        }
                        Log.info('Facebook user logged in: ${u.name}');
                        u;
                    }

                    var token:String = AuthRoutes.buildToken(user.id);
                    return new response.Redirect(Server.config.root.client + '#!/login/${token.urlEncode()}');
                });

            case _: Future.sync(new response.NotFound(query.state));
        }
    }

    function autoFriend(u:models.User):Void {
        var allUsers:List<models.User> = models.User.manager.all();
        for(user in allUsers) {
            if(u.id == user.id) continue;
            var friend1:models.Friends = new models.Friends();
            friend1.friendA = u;
            friend1.friendB = user;
            friend1.createdOn = Date.now();
            friend1.modifiedOn = Date.now();
            friend1.insert();
            var friend2:models.Friends = new models.Friends();
            friend2.friendA = user;
            friend2.friendB = u;
            friend2.createdOn = Date.now();
            friend2.modifiedOn = Date.now();
            friend2.insert();
        }
    }
}