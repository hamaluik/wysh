package stores;

import js.Promise;
import Actions;

class AuthStore {
    public static function authWithStoredToken():Promise<String> {
        var token:String = js.Browser.getLocalStorage().getItem('token');
        if(token == null || StringTools.trim(token).length == 0)
            return Promise.reject(null);

        // make sure we haven't expired
        var payloadEncoded:String = token.split(".")[1];
        var payload:Dynamic = haxe.Json.parse(haxe.crypto.Base64.decode(payloadEncoded).toString());
        var ts:Float = Date.now().getTime() / 1000;
        if(Reflect.hasField(payload, 'exp') && ts >= payload.exp) {
            return signOut().then(function(_) {
                return Promise.reject(null);
            });
        }

        Store.dispatch(AuthActions.Auth(token));
        return Promise.resolve(token);
    }

    public static function authenticate(token:String):Promise<String> {
        js.Browser.getLocalStorage().setItem('token', token);
        Store.dispatch(AuthActions.Auth(token));
        return Promise.resolve(token);
    }

    public static function signOut():Promise<Any> {
        js.Browser.getLocalStorage().removeItem('token');
        Store.dispatch(AuthActions.SignOut);
        return Promise.resolve(null);
    }
}
