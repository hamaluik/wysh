package stores;

import Actions;
import State;
import redux.IReducer;

class AuthReducer implements IReducer<AuthActions, AuthState> {
    public function new(){}
    
    public var initState:AuthState = {
        token: null,
        uid: null
    };

    public function reduce(state:AuthState, action:AuthActions):AuthState {
        return switch(action) {
            case Auth(token): {
                // parse the token to extract the uid
                var payloadEncoded:String = token.split(".")[1];
                var payload:Dynamic = haxe.Json.parse(haxe.crypto.Base64.decode(payloadEncoded).toString());

                js.Object.assign(cast({}), state, {
                    uid: payload.sub,
                    token: token
                });
            }
            case SignOut: js.Object.assign(cast({}), state, {
                token: null
            });
        }
    }
}
