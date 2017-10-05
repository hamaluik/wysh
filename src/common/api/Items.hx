package api;

import api.APIResponse;

@:allow(api.Items)
class ItemsObject implements APIResponseObject {
    public var items:Array<Item>;

    private function new(items:Array<Item>) {
        this.items = items;
    }
}

abstract Items(ItemsObject) from ItemsObject to APIResponse {
    public function new(items:Array<Item>)
        this = new ItemsObject(items);

    @:from
    public static inline function fromDBItems(items:Iterable<models.Item>):Items
        return new Items([for(item in items) item]);

    
    public inline function hideReservedStatus():ItemsObject {
        for(item in this.items) item.hideReservedStatus();
        return this;
    }
}
