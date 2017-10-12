package stores;

import tink.state.State;
import tink.state.Promised;
import haxe.ds.StringMap;
import api.Item;

class ItemsStore {
    public var itemsUpdate:State<Promised<Date>> = Failed(null);
    public var items:StringMap<Item> = new StringMap<Item>();

    @:allow(Store)
    private function new() {}
}