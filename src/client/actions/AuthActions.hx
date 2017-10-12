package actions;

import tink.core.Future;
import tink.core.Noise;
import mithril.M;

class AuthActions {
    @:allow(Actions)
    private function new() {
        Store.token.observe().bind(function(token:String):Void {
            if(token != null) {
                js.Browser.getLocalStorage().setItem('token', token);
                
                var payloadEncoded:String = token.split(".")[1];
                var payload:Dynamic = haxe.Json.parse(haxe.crypto.Base64.decode(payloadEncoded).toString());
                Store.uid.set(payload.sub);

                // auto-refresh
                haxe.Timer.delay(function():Void {
                    refreshToken();
                }, 5 * 60 * 1000);
            }
        });
    }

    public function checkStoredToken():Void {
        var token:String = js.Browser.getLocalStorage().getItem('token');
        if(token == null || StringTools.trim(token).length == 0) return;

        // make sure we haven't expired
        var payloadEncoded:String = token.split(".")[1];
        var payload:Dynamic = haxe.Json.parse(haxe.crypto.Base64.decode(payloadEncoded).toString());
        var ts:Float = Date.now().getTime() / 1000;
        if(Reflect.hasField(payload, 'exp') && ts >= payload.exp) {
            clearStoredToken();
            return;
        }

        Store.token.set(token);
    }

    public function clearStoredToken():Void {
        js.Browser.getLocalStorage().removeItem('token');
        Store.token.set(null);
    }

    public function refreshToken():Future<Noise> {
        var ft = Future.trigger();
        M.request(WebRequest.endpoint('/user/profile'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + Store.token.value
            }
        })
        .then(function(data:Dynamic):Void {
            Store.token.set(data.token);
            ft.trigger(null);
        })
        .catchError(function(error) {
            Store.token.set(null);
            ft.trigger(null);
        });
        return ft.asFuture();
    }
}