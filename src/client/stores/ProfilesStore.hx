package stores;

import State.APIState;
import Actions;
import js.Promise;
import js.Error;
import api.Profile;

class ProfilesStore {
    public static function fetchProfile(id:String):Promise<Profile> {
        Store.dispatch(APIActions.GetSelfProfile(Loading));
        return WebRequest.request(GET, '/user/${id}/profile', true)
        .then(function(profile:Profile):Promise<Profile> {
            Store.dispatch(APIActions.GetSelfProfile(Idle(Date.now())));
            Store.dispatch(ProfilesActions.Set([profile]));
            return Promise.resolve(profile);
        })
        .catchError(function(error:Error):Promise<Profile> {
            Client.console.error('Failed to request profile', error);
            Store.dispatch(APIActions.GetSelfProfile(Failed(error)));
            return Promise.reject(error);
        });
    }
}