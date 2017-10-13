package actions;

import types.IDProfile;
import tink.core.Error;
import tink.core.Promise;
import tink.state.Observable;
import types.IDList;
import tink.state.ObservableArray;
import tink.core.Future;
import tink.core.Noise;
import api.List;
import types.TPrivacy;

using Lambda;

class ListActions {
    @:allow(Actions)
    private function new() {
        Store.uid.observe().bind(function(uid:String):Void {
            if(uid != null) fetchLists(uid);
        });
    }

    public function fetchList(id:IDList):Promise<Noise> {
        return WebRequest.request('GET', '/list/${id}')
        .next(function(resp:Dynamic):Promise<Dynamic> {
            var list:api.List = cast(resp);
            Store.lists.set(list.id, list);

            return WebRequest.request('GET', '/list/${id}/items');
        })
        .next(function(resp:Dynamic):Promise<Noise> {
            var items:api.Items = cast(resp);
            for(item in items.items) {
                Store.items.set(item.id, item);
            }

            return Future.sync(null);
        })
        .tryRecover(function(error:Error):Promise<Noise> {
            Client.console.error('Error downloading list', error);
            return error;
        });
    }

    public function fetchLists(profile:IDProfile):Promise<Noise> {
        return WebRequest.request('GET', '/user/${profile}/lists')
        .next(function(resp:Dynamic):Promise<Noise> {
            var lists:api.Lists = cast(resp);
            for(list in lists.lists) {
                Store.lists.set(list.id, list);
                if(!Store.profileLists.exists(profile))
                    Store.profileLists.set(profile, new ObservableArray<IDList>());
                var arr:ObservableArray<IDList> = Store.profileLists.get(profile);
                if(!arr.exists(function(id:Observable<IDList>):Bool {
                    return id.value == list.id;
                })) {
                    arr.push(list.id);
                }
            }

            return Future.sync(null);
        });
    }

    public function createList(name:String, privacy:TPrivacy):Promise<api.List> {
        return WebRequest.request('POST', '/list', true, {
            name: name,
            privacy: privacy
        })
        .next(function(resp:Dynamic):Promise<api.List> {
            var list:api.List = cast(resp);
            Store.lists.set(list.id, list);

            if(!Store.profileLists.exists(Store.uid))
                Store.profileLists.set(Store.uid, new ObservableArray<IDList>());
            var arr:ObservableArray<IDList> = Store.profileLists.get(Store.uid);
            if(!arr.exists(function(id:Observable<IDList>):Bool {
                return id.value == list.id;
            })) {
                arr.push(list.id);
            }

            Client.console.info('Created list', list);

            return Future.sync(list);
        });
    }
}