package state;

import tink.CoreApi.FutureTrigger;
import tink.core.Future;
import tink.state.State;
import tink.state.Promised;
import tink.core.Noise;
import types.TProfile;
import haxe.ds.StringMap;
import mithril.M;

class Friends {
    @:allow(AppState)
    private function new(){}

    public var friendsUpdate:State<Promised<Date>> = Failed(null);
    public var friends:StringMap<TProfile> = new StringMap<TProfile>();

    public var friendRequestsUpdate:State<Promised<Date>> = Failed(null);
    public var friendRequests:StringMap<TProfile> = new StringMap<TProfile>();

    public function fetchFriends():Future<Noise> {
        var ft:FutureTrigger<Noise> = new FutureTrigger<Noise>();

        friendsUpdate.set(Loading);
        M.request(WebRequest.endpoint('/friends'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + AppState.auth.token.value
            }
        })
        .then(function(data:Dynamic) {
            var df:Array<TProfile> = data.friends;
            // TODO: better way to remove old data?
            for(fk in friends.keys()) friends.remove(fk);
            for(friend in df) {
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
                Authorization: 'Bearer ' + AppState.auth.token.value
            }
        })
        .then(function(data:Dynamic) {
            var users:Array<TProfile> = data.users;
            // TODO: better way to remove old data?
            for(fk in friendRequests.keys()) friendRequests.remove(fk);
            for(user in users) {
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
}