package api;

import types.TItem;
import api.APIResponse;

@:allow(api.Item)
class ItemObject implements APIResponseObject {
    public var id:String;
    public var name:String;

    public var url:Null<String>;
    public var comments:Null<String>;
    public var image_path:Null<String>;

    public var reservable:Bool;
    public var reserver:Null<String>;
    public var reservedOn:Null<Date>;

    private function new(item:TItem) {
        this.id = item.id;
        this.name = item.name;
        this.url = item.url;
        this.comments = item.comments;
        this.image_path = item.image_path;
        this.reservable = item.reservable;
        this.reserver = item.reserver;
        this.reservedOn = item.reservedOn;
    }
}

@:forward
abstract Item(ItemObject) from ItemObject to ItemObject to APIResponse {
    public function new(item:TItem)
        this = new ItemObject(item);

#if sys
    @:from
    public static inline function fromDB(item:models.Item):Item {
        return new Item({
            id: Server.itemHID.encode(item.id),
            name: item.name,
            url: item.url,
            comments: item.comments,
            image_path: item.image_path,
            reservable: item.reservable,
            // TODO: hide info from the client when viewing self items!
            reserver: item.reserver == null ? null : Server.userHID.encode(item.reserver.id),
            reservedOn: item.reservedOn
        });
    }

    public inline function hideReservedStatus():ItemObject {
        this.reserver = null;
        this.reservedOn = null;
        return this;
    }
#end
}
