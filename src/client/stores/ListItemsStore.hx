package stores;

import haxe.ds.StringMap;
import api.Item;

class ListItemsStore {
    public var listItems:StringMap<Array<String>> = new StringMap<Array<String>>();

    @:allow(Store)
    private function new() {}

    public function getItemsFromList(id:String):Array<Item> {
        if(!listItems.exists(id)) return [];
        var iids:Array<String> = listItems.get(id);
        return [for(iid in iids) Store.items.items.get(iid)];
    }
}