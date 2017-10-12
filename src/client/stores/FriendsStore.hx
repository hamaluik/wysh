package stores;

import tink.state.State;
import tink.state.Promised;
import haxe.ds.StringMap;
import mithril.M;
import api.Profile;
import api.Profiles;

class FriendsStore {
    @:allow(Store)
    private function new(){}

    public var friendsUpdate:State<Promised<Date>> = Failed(null);
    public var friends:StringMap<api.Profile> = new StringMap<api.Profile>();

    public var friendRequestsUpdate:State<Promised<Date>> = Failed(null);
    public var friendRequests:StringMap<api.Profile> = new StringMap<api.Profile>();

    public var userSearch:State<Promised<Array<api.Profile>>> = Failed(null);

    public var pendingFriendRequestsUpdate:State<Promised<Date>> = Failed(null);
    public var pendingFriendRequests:StringMap<api.Profile> = new StringMap<api.Profile>();

    public function fetchFriends():Void {
        friendsUpdate.set(Loading);
        M.request(WebRequest.endpoint('/friends'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(response:Profiles) {
            // TODO: better way to remove old data?
            for(fk in friends.keys()) friends.remove(fk);
            for(friend in response.profiles) {
                friends.set(friend.id, friend);
            }
            friendsUpdate.set(Done(Date.now()));
        })
        .catchError(function(error) {
            friendsUpdate.set(Failed(error));
        });
    }

    public function fetchFriendRequests():Void {
        friendRequestsUpdate.set(Loading);
        M.request(WebRequest.endpoint('/friends/requests'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(response:Profiles) {
            // TODO: better way to remove old data?
            for(fk in friendRequests.keys()) friendRequests.remove(fk);
            for(user in response.profiles) {
                friendRequests.set(user.id, user);
            }

            friendRequestsUpdate.set(Done(Date.now()));
        })
        .catchError(function(error) {
            friendRequestsUpdate.set(Failed(error));
        });
    }

    public function fetchPendingRequests():Void {
        pendingFriendRequestsUpdate.set(Loading);
        M.request(WebRequest.endpoint('/friends/sentrequests'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(response:Profiles) {
            // TODO: better way to remove old data?
            for(fk in pendingFriendRequests.keys()) pendingFriendRequests.remove(fk);
            for(user in response.profiles) {
                pendingFriendRequests.set(user.id, user);
            }

            pendingFriendRequestsUpdate.set(Done(Date.now()));
        })
        .catchError(function(error) {
            pendingFriendRequestsUpdate.set(Failed(error));
        });
    }

    public function searchForUsers(name:String):Void {
        userSearch.set(Loading);
        M.request(WebRequest.endpoint('/user/search'), {
            method: 'GET',
            extract: WebRequest.extract,
            data: {
                name: name
            },
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(response:Profiles) {
            userSearch.set(Done(response.profiles));
        })
        .catchError(function(error) {
            userSearch.set(Failed(error));
        });
    }

    public function requestFriend(user:Profile):Void {
        pendingFriendRequestsUpdate.set(Loading);
        M.request(WebRequest.endpoint('/friends/request'), {
            method: 'POST',
            extract: WebRequest.extract,
            data: {
                id: user.id
            },
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(resp:Dynamic) {
            var response:api.Message = cast(resp);
            pendingFriendRequests.set(user.id, user);
            pendingFriendRequestsUpdate.set(Done(Date.now()));
        })
        .catchError(function(error) {
            pendingFriendRequestsUpdate.set(Failed(error));
        });
    }

    public function acceptRequest(user:Profile):Void {
        friendRequestsUpdate.set(Loading);
        M.request(WebRequest.endpoint('/friends/accept'), {
            method: 'POST',
            extract: WebRequest.extract,
            data: {
                id: user.id
            },
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(response:Dynamic) {
            friendRequests.remove(user.id);
            friends.set(user.id, user);
            friendRequestsUpdate.set(Done(Date.now()));
        })
        .catchError(function(error) {
            friendRequestsUpdate.set(Failed(error));
        });
    }
}