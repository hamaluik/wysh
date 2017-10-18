package stores;

import js.Promise;
import api.Profile;
import api.Profiles;
import api.Message;
import Actions;

class FriendsStore {
    public static function search(query:String):Promise<Array<Profile>> {
        if(query.length < 3) {
            Store.dispatch(APIActions.SearchFriends(Idle(Date.now())));
            Store.dispatch(FriendsActions.SetSearchResults([]));
            return Promise.resolve([]);
        }

        Store.dispatch(APIActions.SearchFriends(Loading));
        // TODO: abort existing requests
        // https://mithril.js.org/request.html#aborting-requests
        return WebRequest.request(GET, '/search/users', true, {
            name: query
        })
        .then(function(profiles:Profiles):Promise<Array<Profile>> {
            Store.dispatch(APIActions.SearchFriends(Idle(Date.now())));
            Store.dispatch(ProfilesActions.Set(profiles.profiles));
            Store.dispatch(FriendsActions.SetSearchResults(profiles.profiles));
            return Promise.resolve(profiles.profiles);
        })
        .catchError(function(error) {
            Store.dispatch(APIActions.SearchFriends(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function fetchFriends():Promise<Array<Profile>> {
        Store.dispatch(APIActions.GetFriends(Loading));
        return WebRequest.request(GET, '/friends', true)
        .then(function(profiles:Profiles):Promise<Array<Profile>> {
            Store.dispatch(APIActions.GetFriends(Idle(Date.now())));
            Store.dispatch(ProfilesActions.Set(profiles.profiles));
            Store.dispatch(FriendsActions.SetFriends(profiles.profiles));
            return Promise.resolve(profiles.profiles);
        })
        .catchError(function(error) {
            Store.dispatch(APIActions.GetFriends(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function fetchIncomingFriendRequests():Promise<Array<Profile>> {
        Store.dispatch(APIActions.GetIncomingRequests(Loading));
        return WebRequest.request(GET, '/friends/requests', true)
        .then(function(profiles:Profiles):Promise<Array<Profile>> {
            Store.dispatch(APIActions.GetIncomingRequests(Idle(Date.now())));
            Store.dispatch(ProfilesActions.Set(profiles.profiles));
            Store.dispatch(FriendsActions.SetIncomingRequests(profiles.profiles));
            return Promise.resolve(profiles.profiles);
        })
        .catchError(function(error) {
            Store.dispatch(APIActions.GetIncomingRequests(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function fetchSentFriendRequests():Promise<Array<Profile>> {
        Store.dispatch(APIActions.GetSentRequests(Loading));
        return WebRequest.request(GET, '/friends/sentrequests', true)
        .then(function(profiles:Profiles):Promise<Array<Profile>> {
            Store.dispatch(APIActions.GetSentRequests(Idle(Date.now())));
            Store.dispatch(ProfilesActions.Set(profiles.profiles));
            Store.dispatch(FriendsActions.SetSentRequests(profiles.profiles));
            return Promise.resolve(profiles.profiles);
        })
        .catchError(function(error) {
            Store.dispatch(APIActions.GetSentRequests(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function requestFriend(profile:Profile):Promise<Profile> {
        Store.dispatch(APIActions.RequestFriend(Loading));
        return WebRequest.request(POST, '/friends/request', true, { id: profile.id })
        .then(function(message:Message) {
            Store.dispatch(APIActions.RequestFriend(Idle(Date.now())));
            Store.dispatch(FriendsActions.SetSentRequests([ profile ]));
            return Promise.resolve(profile);
        })
        .catchError(function(error) {
            Store.dispatch(APIActions.RequestFriend(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function acceptFriendRequest(profile:Profile):Promise<Profile> {
        Store.dispatch(APIActions.AcceptFriendRequest(Loading));
        return WebRequest.request(POST, '/friends/accept', true, { id: profile.id })
        .then(function(message:Message) {
            Store.dispatch(APIActions.AcceptFriendRequest(Idle(Date.now())));
            Store.dispatch(FriendsActions.RemoveIncomingRequests([ profile ]));
            Store.dispatch(FriendsActions.SetFriends([ profile ]));
            return Promise.resolve(profile);
        })
        .catchError(function(error) {
            Store.dispatch(APIActions.AcceptFriendRequest(Failed(error)));
            return Promise.reject(error);
        });
    }
}