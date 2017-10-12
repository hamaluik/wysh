package actions;

import tink.core.Error;
import tink.core.Outcome;
import tink.core.Promise;
import tink.state.Observable;
import types.IDList;
import tink.state.ObservableArray;
import tink.core.Future;
import tink.core.Noise;
import mithril.M;
import api.List;
import types.TPrivacy;

using Lambda;

class ListActions {
    @:allow(Actions)
    private function new() {
    }

    public function createList(name:String, privacy:TPrivacy):Future<Noise> {
        var ft:FutureTrigger<Noise> = new FutureTrigger<Noise>();

        //myListsUpdate.set(Loading);
        M.request(WebRequest.endpoint('/lists'), {
            method: 'POST',
            extract: WebRequest.extract,
            data: {
                name: name,
                privacy: privacy
            },
            headers: {
                Authorization: 'Bearer ' + Store.token.value
            }
        })
        .then(function(resp:Dynamic) {
            var list:api.List = cast(resp);
            Store.lists.set(list.id, list);
            switch(Store.profile.value) {
                case Done(pid): {
                    if(!Store.profileLists.exists(pid))
                        Store.profileLists.set(pid, new ObservableArray<IDList>());
                    var arr:ObservableArray<IDList> = Store.profileLists.get(pid);
                    if(!arr.exists(function(id:Observable<IDList>):Bool {
                        return id.value == list.id;
                    })) {
                        arr.push(list.id);
                    }
                }
                case _: {}
            }
            //myListsUpdate.set(Done(Date.now()));
            ft.trigger(null);
        })
        .catchError(function(error) {
            //myListsUpdate.set(Failed(error));
            ft.trigger(null);
        });

        return ft.asFuture();
    }

    public function downloadList(id:IDList):Promise<Noise> {
        var ft:FutureTrigger<Outcome<Noise, Error>> = new FutureTrigger<Outcome<Noise, Error>>();

        return ft.asFuture();
    }
}