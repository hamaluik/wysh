package stores;

import Actions;
import js.Promise;
import js.Error;

class ProfilesStore {
    public static function fetchProfile(id:String):Promise<api.Profile> {
        Store.dispatch(APIActions.GetSelfProfile(Loading));
        return WebRequest.request(GET, '/user/${id}/profile', true)
        .then(function(profile:api.Profile):Promise<api.Profile> {
            Store.dispatch(APIActions.GetSelfProfile(Idle(Date.now())));
            Store.dispatch(ProfilesActions.Set([profile]));
            return Promise.resolve(profile);
        })
        .catchError(function(error:Error):Promise<api.Profile> {
            Client.console.error('Failed to request profile', error);
            Store.dispatch(APIActions.GetSelfProfile(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function fetchProfiles():Promise<Array<api.Profile>> {
        Store.dispatch(APIActions.GetProfiles(Loading));
        return WebRequest.request(GET, '/users', true)
        .then(function(profiles:Array<api.Profile>):Promise<Array<api.Profile>> {
            Store.dispatch(APIActions.GetProfiles(Idle(Date.now())));
            Store.dispatch(ProfilesActions.Set(profiles));
            return Promise.resolve(profiles);
        })
        .catchError(function(error:Error):Promise<api.Profile> {
            Client.console.error('Failed to request profiles', error);
            Store.dispatch(APIActions.GetProfiles(Failed(error)));
            return Promise.reject(error);
        });
    }
}