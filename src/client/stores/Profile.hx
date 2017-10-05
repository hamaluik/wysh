package stores;

import tink.CoreApi.Noise;
import tink.CoreApi.Future;
import tink.core.Outcome;
import tink.core.Error;
import tink.CoreApi.FutureTrigger;
import tink.state.State;
import tink.state.Promised;
import tink.core.Promise;
import mithril.M;
//import types.TProfile;

class Profile {
    @:allow(Store)
    private function new(){}

    public var profile:State<Promised<api.Profile>> = new State<Promised<api.Profile>>(Failed(null));

    public function fetchProfile():Future<Noise> {
        var ft:FutureTrigger<Noise> = new FutureTrigger<Noise>();

        profile.set(Loading);
        M.request(WebRequest.endpoint('/user/profile'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(data:api.Profile):Void {
            profile.set(Done(data));
            ft.trigger(null);
        })
        .catchError(function(error) {
            profile.set(Failed(error));
            ft.trigger(null);
        });

        return ft.asFuture();
    }
}