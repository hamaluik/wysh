package stores;

import tink.CoreApi.Promise;
import tink.CoreApi.FutureTrigger;
import tink.core.Future;
import tink.state.State;
import tink.state.Promised;
import tink.core.Noise;
import api.Profile;
import api.Profiles;
import haxe.ds.StringMap;
import mithril.M;

class Friends {
    @:allow(Store)
    private function new(){}

    public var friendsUpdate:State<Promised<Date>> = Failed(null);
    public var friends:StringMap<Profile> = new StringMap<Profile>();

    public var friendRequestsUpdate:State<Promised<Date>> = Failed(null);
    public var friendRequests:StringMap<Profile> = new StringMap<Profile>();

    public var userSearch:State<Promised<Array<Profile>>> = Failed(null);

    public function fetchFriends():Future<Noise> {
        var ft:FutureTrigger<Noise> = new FutureTrigger<Noise>();

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
            ft.trigger(null);
        })
        .catchError(function(error) {
            friendsUpdate.set(Failed(error));
            ft.trigger(null);
        });

        return ft.asFuture();
    }

    public function fetchFriendRequests():Future<Noise> {
        var ft:FutureTrigger<Noise> = new FutureTrigger<Noise>();

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
            ft.trigger(null);
        })
        .catchError(function(error) {
            friendRequestsUpdate.set(Failed(error));
            ft.trigger(null);
        });

        return ft.asFuture();
    }

    public function searchForUsers(name:String):Future<Noise> {
        var ft:FutureTrigger<Noise> = new FutureTrigger<Noise>();

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
            ft.trigger(null);
        })
        .catchError(function(error) {
            userSearch.set(Failed(error));
            ft.trigger(null);
        });

        return ft.asFuture();
    }
}