package stores;

import types.TPrivacy;
import State.APIState;
import Actions;
import js.Promise;
import js.Error;
import api.Item;
import api.Items;

class ListsStore {
    public static function fetchItems(listid:String):Promise<Array<Item>> {
        Client.store.dispatch(APIActions.GetItems(Loading));
        return WebRequest.request(GET, '/list/${userid}/items', true)
        .then(function(items:Items):Promise<Array<Item>> {
            Client.store.dispatch(APIActions.GetItems(Idle(Date.now())));
            Client.store.dispatch(ItemsActions.Set(items.items));
            Client.store.dispatch(RelationsActions.RelateListItems(listid, items.items));
            return Promise.resolve(items.items);
        })
        .catchError(function(error:Error):Promise<Array<List>> {
            Client.console.error('Failed to request items', error);
            Client.store.dispatch(APIActions.GetItems(Failed(error)));
            return Promise.reject(error);
        });
    }
}