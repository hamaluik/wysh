package stores;

import tink.state.State;
import tink.state.Promised;
import haxe.ds.StringMap;
import mithril.M;
import api.Item;

class ItemsStore {
    public var itemsUpdate:State<Promised<Date>> = Failed(null);
    public var items:StringMap<Array<Item>> = new StringMap<Array<Item>>();

    @:allow(Store)
    private function new() {}

    public function getItems(listID:String):Array<Item> {
        if(!items.exists(listID)) {
            itemsUpdate.set(Loading);
            M.request(WebRequest.endpoint('/list/${listID}'), {
                method: 'GET',
                extract: WebRequest.extract,
                headers: {
                    Authorization: 'Bearer ' + Store.auth.token.value
                }
            })
            .then(function(resp:Dynamic) {
                var response:api.Items = cast(resp);
                items.set(listID, response.items);
                itemsUpdate.set(Done(Date.now()));
            })
            .catchError(function(error) {
                itemsUpdate.set(Failed(error));
            });
            return [];
        }
        return items.get(listID);
    }
}