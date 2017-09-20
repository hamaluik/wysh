package routes;

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

    private static function base64url_decode(s:String):Bytes {
        var s64 = s.replace('-', '+').replace('_', '/');
        s64 += switch(s64.length % 4) {
            case 0: '';
            case 1: '===';
            case 2: '==';
            case 3: '=';
            case _: throw 'Illegal base64url string!';
        }
        return Base64.decode(s64);
    }

    @:get public function redirect(query:{code:String, state:String}):Future<Response> {
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

        var ft:FutureTrigger<Response> = new FutureTrigger<Response>();

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
        req.next(function(res:IncomingResponse):Promise<Bytes> {
            return res.body.all();
        })
        .next(function(raw:Bytes):Void {
            var result:AccessResult = haxe.Json.parse(raw.toString());
            
            // parse the id_token
            // TODO: incorporate this into the JWT library
            var parts:Array<String> = result.id_token.split(".");
            if(parts.length != 3) throw 'Invalid id_token!';

            var p:String = base64url_decode(parts[1]).toString();
            var payload:GoogleIDPayload = haxe.Json.parse(p);

            // TODO: deal with account creation / issue JWT!

            ft.trigger(new response.JsonResponse(payload));
        });

        return ft.asFuture();
    }
}