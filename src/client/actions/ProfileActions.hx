package actions;

import tink.core.Future;
import tink.core.Noise;
import mithril.M;
import api.Profile;

class ProfileActions {
    @:allow(Actions)
    private function new() {
        Store.uid.observe().bind(function(uid:String) {
            if(uid == null) return;
            if(!Store.profile.value.match(Uninitialized)) return;
            fetchProfile();
        });
    }

    // TODO: overhaul to promises
    public function fetchProfile():Future<Noise> {
        var ft = Future.trigger();
        Store.profile.set(Loading);
        M.request(WebRequest.endpoint('/user/${Store.uid.value}/profile'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + Store.token.value
            }
        })
        .then(function(data:Dynamic):Void {
            var profile:Profile = cast(data);
            Store.profiles.set(profile.id, profile);
            Store.profile.set(Done(profile.id));
            ft.trigger(null);
        })
        .catchError(function(error) {
            Store.profile.set(Failed(error));
            ft.trigger(null);
        });
        return ft.asFuture();
    }

    // TODO: overhaul to promises
    public function searchProfiles(query:String):Future<Array<Profile>> {
        var ft = Future.trigger();

        if(query.length < 3) {
            ft.trigger([]);
        }
        else {
            M.request(WebRequest.endpoint('/search/users'), {
                method: 'GET',
                extract: WebRequest.extract,
                data: {
                    name: query
                },
                headers: {
                    Authorization: 'Bearer ' + Store.token.value
                }
            })
            .then(function(resp:Dynamic) {
                var profiles:api.Profiles = cast(resp);
                ft.trigger(profiles.profiles);
            })
            .catchError(function(error) {
                ft.trigger([]);
            });
        }

        return ft.asFuture();
    }
}