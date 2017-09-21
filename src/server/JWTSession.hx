package;

import tink.CoreApi.Option;
import tink.CoreApi.Promise;
import tink.http.Request.IncomingRequestHeader;

import jwt.JWT;

typedef JWTPayload = {
    var id:Int;
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
                        Some(new User(payload.id));
                    }

                    case _: None;
                }
            }

            case Failure(e): e;
        }
    }
}