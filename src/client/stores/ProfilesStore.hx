package stores;

import State.APIState;
import Actions;
import js.Promise;
import js.Error;
import api.Profile;

class ProfilesStore {
    public static function fetchProfile(id:String):Promise<Profile> {
        Client.store.dispatch(APIActions.GetSelfProfile(Loading));
        return WebRequest.request('GET', '/user/${id}/profile', true)
        .then(function(profile:Profile):Promise<Profile> {
            Client.store.dispatch(APIActions.GetSelfProfile(Idle(Date.now())));
            Client.store.dispatch(ProfilesActions.Set([profile]));
            return Promise.resolve(profile);
        })
        .catchError(function(error:Error):Promise<Profile> {
            Client.console.error('Failed to request profile', error);
            Client.store.dispatch(APIActions.GetSelfProfile(Failed(error)));
            return Promise.reject(error);
        });
    }
}