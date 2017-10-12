package routes;

import tink.web.routing.*;
import jwt.JWT;

class AuthRoutes {
    public function new() {}

    public static function buildToken(id:Int):String {
        return JWT.sign({
            sub: Server.userHID.encode(id),
            iss: Server.config.root.api,
            iat: Date.now().getTime() / 1000.0,
            exp: (Date.now().getTime() / 1000.0 + Server.config.jwt.duration)
        }, Server.config.jwt.secret);
    }

    @:get public function refresh(user:JWTSession.User):Response {
        var token:String = buildToken(user.id);
        Log.info('Issued refresh token for user ${user.id}!');
        return new response.API(new api.Token(token));
    }
}