package state;

import tink.CoreApi.Future;
import tink.core.Outcome;
import tink.core.Error;
import tink.CoreApi.FutureTrigger;
import tink.state.State;
import tink.state.Promised;
import tink.core.Promise;
import mithril.M;

typedef TProfile = {
    var id:String;
    var name:String;
    var picture:String;
};

class Profile {
    @:allow(AppState)
    private function new(){}

    public var profile:State<Promised<TProfile>> = new State<Promised<TProfile>>(Failed(null));

    public function fetchProfile():Promise<TProfile> {
        var f:FutureTrigger<Outcome<TProfile, Error>> = Future.trigger();

        profile.set(Loading);
        M.request(WebRequest.endpoint('/user/profile'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + AppState.auth.token.value
            }
        })
        .then(function(data:Dynamic) {
            profile.set(Done(data));
            f.trigger(Success(data));
        })
        .catchError(function(error) {
            profile.set(Failed(error));
            f.trigger(Failure(error));
        });

        return f.asFuture();
    }
}