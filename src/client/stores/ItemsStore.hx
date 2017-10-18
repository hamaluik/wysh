package stores;

import types.TPrivacy;
import State.APIState;
import Actions;
import js.Promise;
import js.Error;
import api.Item;
import api.Items;

class ItemsStore {
    public static function fetchItems(listid:String):Promise<Array<Item>> {
        Store.dispatch(APIActions.GetItems(Loading));
        return WebRequest.request(GET, '/list/${listid}/items', true)
        .then(function(items:Items):Promise<Array<Item>> {
            Store.dispatch(APIActions.GetItems(Idle(Date.now())));
            Store.dispatch(ItemsActions.Set(items.items));
            Store.dispatch(ListItemsActions.Relate(listid, items.items));
            return Promise.resolve(items.items);
        })
        .catchError(function(error:Error):Promise<Array<Item>> {
            Client.console.error('Failed to request items', error);
            Store.dispatch(APIActions.GetItems(Failed(error)));
            return Promise.reject(error);
        });
    }
}