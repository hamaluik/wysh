package store.factories;

import js.Promise;
import js.Error;
import store.Actions.ProfilesActions;
import api.Profile;

class ProfilesFactory {
    public static function fetchProfile(id:String):Promise<Profile> {
        Client.store.dispatch(ProfilesActions.StartLoading);
        return WebRequest.request('GET', '/user/${id}/profile', true)
        .then(function(profile:Profile):Promise<Profile> {
            Client.store.dispatch(ProfilesActions.Loaded([profile]));
            return Promise.resolve(profile);
        })
        .catchError(function(error:Error):Promise<Profile> {
            Client.console.error('Failed to request profile', error);
            Client.store.dispatch(ProfilesActions.Failed(error));
            return Promise.reject(error);
        });
    }
}