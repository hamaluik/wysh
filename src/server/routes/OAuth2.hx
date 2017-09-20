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

import response.NotFoundResponse;

using StringTools;

typedef AccessResult = {
    var access_token:String;
    var token_type:String;
    var expires_in:Int;
    var id_token:String;
};

typedef GoogleIDPayload = {
    var email:String;
    var given_name:String;
    var family_name:String;
    var picture:String;
};

class OAuth2 {
    public function new() {}
    
    @:get('/login/$service') public function login(service:String):Response {
        var redirectURI:String = Server.config.siteroot + '/oauth2/redirect';

        var urlString:String = null;
        var clientID:String = null;
        var scope:String = null;
        var state:String = null;
        switch(service.toLowerCase()) {
            case 'google': {
                urlString = 'https://accounts.google.com/o/oauth2/v2/auth';
                clientID = Server.config.oauth2.google.id;
                scope = 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email';
                state = 'auth-google';
            }

            case _: return new NotFoundResponse(service);
        }

        urlString += '?client_id=${clientID.urlEncode()}';
        urlString += '&redirect_uri=${redirectURI.urlEncode()}';
        urlString += '&response_type=code';
        urlString += '&scope=${scope.urlEncode()}';
        urlString += '&access_type=offline';
        urlString += '&state=${state.urlEncode()}';
        var url:tink.Url = urlString;
        return url;
    }

    @:get public function redirect(query:{code:String, state:String}):Promise<Response> {
        var headers:Array<HeaderField> = new Array<HeaderField>();
        headers.push(new HeaderField(HeaderName.ContentType, 'application/x-www-form-urlencoded'));

        var redirectURI:String = Server.config.siteroot + '/oauth2/redirect';
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

            case _: return Future.sync(new NotFoundResponse(query.state));
        }

        var body:String = 'code=${query.code.urlEncode()}';
        body += '&client_id=${clientID.urlEncode()}';
        body += '&client_secret=${clientSecret.urlEncode()}';
        body += '&redirect_uri=${redirectURI.urlEncode()}';
        body += '&grant_type=authorization_code';

        headers.push(new HeaderField(HeaderName.ContentLength, body.length));

        var client = new SecureSocketClient();
        var req:Promise<IncomingResponse> = client.request(new OutgoingRequest(
            new OutgoingRequestHeader(POST, new tink.url.Host(host), uri, headers),
            body
        ));
        return req.next(function(res:IncomingResponse):Promise<Bytes> {
            return res.body.all();
        })
        .next(function(raw:Bytes) {
            var result:AccessResult = haxe.Json.parse(raw.toString());
            var payload:GoogleIDPayload = JWT.extract(result.id_token);

            var users:List<models.User> = models.User.manager.search($email == payload.email);
            var user:models.User = if(users.length < 1) {
                // create a new user!
                var u:models.User = new models.User();
                u.name = payload.given_name + ' ' + payload.family_name;
                u.email = payload.email;
                u.insert();
                Log.info('Created new user: ${u.name} <${u.email}>');
                u;
            }
            else {
                var u:models.User = users.first();
                Log.info('Google user logged in: ${u.name} <${u.email}>');
                u;
            }

            // TODO: some sort of redirect a la Auth0
            var token:String = JWT.sign({
                id: user.id
            }, Server.config.jwt.secret);

            return new response.JsonResponse({
                token: token
            });
        });
    }
}