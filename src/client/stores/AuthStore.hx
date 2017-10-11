package stores;

import tink.state.State;

class AuthStore {
    public var token:State<String> = new State<String>(null);

    @:allow(Store)
    private function new() {
        token.observe().bind(function(token:String):Void {
            if(token != null) {
                js.Browser.getLocalStorage().setItem('token', token);

                // TODO: refresh the token periodically!
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

        this.token.set(token);
    }

    public function clearStoredToken():Void {
        js.Browser.getLocalStorage().removeItem('token');
        token.set(null);
    }
}