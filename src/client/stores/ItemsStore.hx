package stores;

import api.Message;
import js.html.FormData;
import Actions;
import js.Promise;
import js.Error;
import js.html.File;
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

    public static function newItem(listid:String, name:String, ?picture:File, ?url:String, ?comments:String, reservable:Bool):Promise<Item> {
        Store.dispatch(APIActions.CreateItem(Loading));

        var formData:FormData = new FormData();
        formData.append('name', name);
        if(url != null) formData.append('url', url);
        if(comments != null) formData.append('comments', comments);
        formData.append('reservable', Std.string(reservable));
        if(picture != null) formData.append('picture', picture, picture.name);

        return WebRequest.request(POST, '/list/${listid}', true, formData)
        .then(function(item:Item):Promise<Item> {
            Store.dispatch(APIActions.CreateItem(Idle(Date.now())));
            Store.dispatch(ItemsActions.Set([ item ]));
            Store.dispatch(ListItemsActions.Relate(listid, [ item ]));
            return Promise.resolve(item);
        })
        .catchError(function(error:Error):Promise<Item> {
            Client.console.error('Failed to create item!');
            Store.dispatch(APIActions.CreateItem(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function deleteItem(item:Item):Promise<Message> {
        Store.dispatch(APIActions.DeleteItem(Loading));
        return WebRequest.request(DELETE, '/item/${item.id}', true)
        .then(function(message:Message):Promise<Message> {
            Store.dispatch(APIActions.DeleteItem(Idle(Date.now())));
            Store.dispatch(ItemsActions.Delete(item.id));
            Store.dispatch(ListItemsActions.DeleteItem(item.id));
            return Promise.resolve(message);
        })
        .catchError(function(error:Error):Promise<Message> {
            Client.console.error('Failed to delete item', error);
            Store.dispatch(APIActions.DeleteItem(Failed(error)));
            return Promise.reject(error);
        });
    }
}