package actions;

import tink.core.Future;
import tink.core.Noise;
import tink.core.Promise;
import tink.core.Outcome;
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

    public function fetchProfile():Promise<Profile> {
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
            ft.trigger(Success(profile));
        })
        .catchError(function(error) {
            Store.profile.set(Failed(error));
            ft.trigger(Failure(error));
        });
        return ft.asFuture();
        /*Store.profile.set(Loading);
        return WebRequest.request('GET', '/user/${Store.uid.value}/profile', true)
        .next(function(resp:Dynamic):Promise<Profile> {
            var profile:Profile = cast(resp);
            Store.profiles.set(profile.id, profile);
            Store.profile.set(Done(profile.id));
            return Future.sync(profile);
        });*/
    }

    public function searchProfiles(query:String):Promise<Array<Profile>> {
        if(query.length < 3) {
            return Future.sync([]);
        }
        
        return WebRequest.request('GET', '/search/users', true, {
            name: query
        })
        .next(function(resp:Dynamic):Promise<Array<Profile>> {
            var profiles:api.Profiles = cast(resp);
            return Future.sync(profiles.profiles);
        });
    }
}