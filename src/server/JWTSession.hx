package;

import tink.CoreApi.Option;
import tink.CoreApi.Promise;
import tink.http.Request.IncomingRequestHeader;

import jwt.JWT;

typedef JWTPayload = {
    var id:Int;
    var adm:Bool;
};

class User {
    public var id(default, null):Int;
    public var admin(default, null):Bool;
    public function new(id:Int, admin:Bool) {
        this.id = id;
        this.admin = admin;
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
                        Log.trace('user authed with id=`${payload.id}`, adm=`${payload.adm}`');
                        Some(new User(payload.id, payload.adm));
                    }

                    case _: None;
                }
            }

            case Failure(e): e;
        }
    }
}