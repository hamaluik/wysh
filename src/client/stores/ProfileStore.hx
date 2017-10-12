package stores;

import tink.state.State;
import tink.state.Promised;
import mithril.M;
import api.Profile;

class ProfileStore {
    @:allow(Store)
    private function new() {
        // automatically fetch the profile when we log in
        Store.auth.token.observe().bind(function(token:String) {
            if(token != null) {
                switch(profile.value) {
                    case Failed(e): if(e == null) {
                        fetchProfile()
                        /*.handle(function(noise) {
                            M.redraw();
                        })*/;
                    }
                    case _: {}
                }
            }
            else profile.set(Failed(null));
        });
    }

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