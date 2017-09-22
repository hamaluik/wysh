package;

import tink.CoreApi.Option;
import tink.CoreApi.Promise;
import tink.http.Request.IncomingRequestHeader;

import jwt.JWT;

typedef JWTPayload = {
    > jwt.JWTPayloadBase,
};

class User {
    public var id(default, null):Int;
    public function new(id:Int) {
        this.id = id;
    }
}

class JWTSession {
    var header:IncomingRequestHeader;

    public function new(header:IncomingRequestHeader) {
        this.header = header;
    }

    public function getUser():Promise<Option<User>> {
        return switch header.byName('authorization') {
            case Success(auth): {
                var parts:Array<String> = cast(auth, String).split(' ');
                if(parts.length != 2) return None;
                if(parts[0] != "Bearer") return None;

                var result:JWTResult<JWTPayload> = JWT.verify(parts[1], Server.config.jwt.secret);
                return switch(result) {
                    case Valid(payload): {
                        if(payload.iss != Server.config.root.api) return None;
                        if(payload.iat > Date.now().getTime() / 1000.0) return None;
                        if(payload.exp <= Date.now().getTime() / 1000.0) return None;
                        Some(new User(Server.extractID(payload.sub, Server.userHID)));
                    }

                    case _: None;
                }
            }

            case Failure(e): e;
        }
    }
}