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

    @:allow(Store)
    private function new() {}

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
                var p:Int = cast(list.privacy);
                list.privacy = haxe.EnumTools.createByIndex(TPrivacy, p);
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

    public function createList(name:String, privacy:String):Future<Noise> {
        privacy = privacy.toLowerCase();
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
            var p:Int = cast(response.privacy);
            response.privacy = haxe.EnumTools.createByIndex(TPrivacy, p);
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
}