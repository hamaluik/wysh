package state;

import tink.state.State;
import tink.state.Promised;
import mithril.M;

typedef TProfile = {
    var name:String;
    var picture:String;
};

class Profile {
    @:allow(AppState)
    private function new(){}

    public var profile:State<Promised<TProfile>> = new State<Promised<TProfile>>(Failed(null));

    public function fetchProfile():Void {
        profile.set(Loading);
        M.request(WebRequest.endpoint('/profile'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + AppState.auth.token.value
            }
        })
        .then(function(data:Dynamic) {
            profile.set(Done(data));
        })
        .catchError(function(error) {
            profile.set(Failed(error));
        });
    }
}