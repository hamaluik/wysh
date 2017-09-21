import tink.state.State;
import tink.state.Promised;

import mithril.M;

typedef TProfile = {
    var name:String;
    var picture:String;
};

class Data {
    public static var token:State<String> = new State<String>(null);
    public static var profile:State<Promised<TProfile>> = new State<Promised<TProfile>>(Failed(null));

    public static function fetchProfile():Void {
        profile.set(Loading);
        M.request(WebRequest.endpoint('/profile'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + token.value
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