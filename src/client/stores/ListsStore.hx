package stores;

import tink.core.Noise;
import tink.core.Future;
import tink.state.State;
import tink.state.Promised;
import haxe.ds.StringMap;
import mithril.M;
import types.TPrivacy;

class ListsStore {
    public var myListsUpdate:State<Promised<Date>> = Failed(null);
    public var myLists:StringMap<api.List> = new StringMap<api.List>();

    public var friendListsUpdate:State<Promised<Date>> = Failed(null);
    public var friendLists:StringMap<api.List> = new StringMap<api.List>();

    @:allow(Store)
    private function new() {
        Store.friends.friendsUpdate.observe().bind(function(v:Promised<Date>):Void {
            switch(v) {
                case Done(_): {
                    
                }
                case _: {}
            }
        });
    }

    public function fetchMyLists():Future<Noise> {
        var ft:FutureTrigger<Noise> = new FutureTrigger<Noise>();

        myListsUpdate.set(Loading);
        M.request(WebRequest.endpoint('/user/lists'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(resp:Dynamic) {
            var response:api.Lists = cast(resp);
            myLists = new StringMap<api.List>();
            for(list in response.lists) {
                myLists.set(list.id, list);
            }
            Client.console.info('Downloaded my lists', response);
            myListsUpdate.set(Done(Date.now()));
            ft.trigger(null);
        })
        .catchError(function(error) {
            myListsUpdate.set(Failed(error));
            ft.trigger(null);
        });

        return ft.asFuture();
    }

    public function createList(name:String, privacy:TPrivacy):Future<Noise> {
        var ft:FutureTrigger<Noise> = new FutureTrigger<Noise>();

        Client.console.info('Creating list', {
            name: name,
            privacy: privacy
        });

        myListsUpdate.set(Loading);
        M.request(WebRequest.endpoint('/lists'), {
            method: 'POST',
            extract: WebRequest.extract,
            data: {
                name: name,
                privacy: privacy
            },
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(resp:Dynamic) {
            var response:api.List = cast(resp);
            myLists.set(response.id, response);
            myListsUpdate.set(Done(Date.now()));
            ft.trigger(null);
        })
        .catchError(function(error) {
            myListsUpdate.set(Failed(error));
            ft.trigger(null);
        });

        return ft.asFuture();
    }

    public function fetchFriendsList(id:String):Future<Noise> {
        var ft:FutureTrigger<Noise> = new FutureTrigger<Noise>();

        friendListsUpdate.set(Loading);
        M.request(WebRequest.endpoint('/user/${id}/lists'), {
            method: 'GET',
            extract: WebRequest.extract,
            headers: {
                Authorization: 'Bearer ' + Store.auth.token.value
            }
        })
        .then(function(resp:Dynamic) {
            var response:api.Lists = cast(resp);
            for(list in response.lists) {
                friendLists.set(list.id, list);
            }
            Client.console.info('Downloaded friends lists', response);
            friendListsUpdate.set(Done(Date.now()));
            ft.trigger(null);
        })
        .catchError(function(error) {
            friendListsUpdate.set(Failed(error));
            ft.trigger(null);
        });

        return ft.asFuture();
    }
}