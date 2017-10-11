package stores;

import tink.state.State;
import tink.state.Promised;
import mithril.M;
import api.Profile;

class ProfileStore {
    @:allow(Store)
    private function new(){}

    public var profile:State<Promised<Profile>> = new State<Promised<Profile>>(Failed(null));

    public function fetchProfile():Void {
        profile.set(Loading);
        M.request(WebRequest.endpoint('/user/profile'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(data:Dynamic):Void {
            profile.set(Done(data));
        })
        .catchError(function(error) {
            profile.set(Failed(error));
        });
    }
}