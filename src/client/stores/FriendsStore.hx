package stores;

import js.Promise;
import api.Profile;
import api.Profiles;
import api.Message;
import Actions;

class FriendsStore {
    public static function search(query:String):Promise<Array<Profile>> {
        if(query.length < 3) {
            Client.store.dispatch(APIActions.SearchFriends(Idle(Date.now())));
            Client.store.dispatch(FriendsActions.SetSearchResults([]));
            return Promise.resolve([]);
        }

        Client.store.dispatch(APIActions.SearchFriends(Loading));
        return WebRequest.request(GET, '/search/users', true, {
            name: query
        })
        .then(function(profiles:Profiles):Promise<Array<Profile>> {
            Client.store.dispatch(APIActions.SearchFriends(Idle(Date.now())));
            Client.store.dispatch(ProfilesActions.Set(profiles.profiles));
            Client.store.dispatch(FriendsActions.SetSearchResults(profiles.profiles));
            return Promise.resolve(profiles.profiles);
        })
        .catchError(function(error) {
            Client.store.dispatch(APIActions.SearchFriends(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function fetchFriends():Promise<Array<Profile>> {
        Client.store.dispatch(APIActions.GetFriends(Loading));
        return WebRequest.request(GET, '/friends', true)
        .then(function(profiles:Profiles):Promise<Array<Profile>> {
            Client.store.dispatch(APIActions.GetFriends(Idle(Date.now())));
            Client.store.dispatch(ProfilesActions.Set(profiles.profiles));
            Client.store.dispatch(FriendsActions.SetFriends(profiles.profiles));
            return Promise.resolve(profiles.profiles);
        })
        .catchError(function(error) {
            Client.store.dispatch(APIActions.GetFriends(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function fetchIncomingFriendRequests():Promise<Array<Profile>> {
        Client.store.dispatch(APIActions.GetIncomingRequests(Loading));
        return WebRequest.request(GET, '/friends/requests', true)
        .then(function(profiles:Profiles):Promise<Array<Profile>> {
            Client.store.dispatch(APIActions.GetIncomingRequests(Idle(Date.now())));
            Client.store.dispatch(ProfilesActions.Set(profiles.profiles));
            Client.store.dispatch(FriendsActions.SetIncomingRequests(profiles.profiles));
            return Promise.resolve(profiles.profiles);
        })
        .catchError(function(error) {
            Client.store.dispatch(APIActions.GetIncomingRequests(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function fetchSentFriendRequests():Promise<Array<Profile>> {
        Client.store.dispatch(APIActions.GetSentRequests(Loading));
        return WebRequest.request(GET, '/friends/sentrequests', true)
        .then(function(profiles:Profiles):Promise<Array<Profile>> {
            Client.store.dispatch(APIActions.GetSentRequests(Idle(Date.now())));
            Client.store.dispatch(ProfilesActions.Set(profiles.profiles));
            Client.store.dispatch(FriendsActions.SetSentRequests(profiles.profiles));
            return Promise.resolve(profiles.profiles);
        })
        .catchError(function(error) {
            Client.store.dispatch(APIActions.GetSentRequests(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function requestFriend(profile:Profile):Promise<Profile> {
        Client.store.dispatch(APIActions.RequestFriend(Loading));
        return WebRequest.request(POST, '/friends/request', true, { id: profile.id })
        .then(function(message:Message) {
            Client.store.dispatch(APIActions.RequestFriend(Idle(Date.now())));
            Client.store.dispatch(FriendsActions.SetSentRequests([ profile ]));
            return Promise.resolve(profile);
        })
        .catchError(function(error) {
            Client.store.dispatch(APIActions.RequestFriend(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function acceptFriendRequest(profile:Profile):Promise<Profile> {
        Client.store.dispatch(APIActions.AcceptFriendRequest(Loading));
        return WebRequest.request(POST, '/friends/accept', true, { id: profile.id })
        .then(function(message:Message) {
            Client.store.dispatch(APIActions.AcceptFriendRequest(Idle(Date.now())));
            Client.store.dispatch(FriendsActions.RemoveIncomingRequests([ profile ]));
            Client.store.dispatch(FriendsActions.SetFriends([ profile ]));
            return Promise.resolve(profile);
        })
        .catchError(function(error) {
            Client.store.dispatch(APIActions.AcceptFriendRequest(Failed(error)));
            return Promise.reject(error);
        });
    }
}