package models;

import sys.db.Object;
import sys.db.Types;

@:table("items")
class Item extends Object {
    public var id:SId;
    @:relation(lid,cascade) public var list:List;
    public var name:SString<255>;
    public var url:Null<SSmallText>;
    public var comments:Null<SSmallText>;
    public var image_path:Null<SSmallText>;
    
    public var reservable:SBool;
    @:relation(rid) public var reserver:Null<User>;
    public var reservedOn:Null<SDateTime>;

    public var createdOn:SDateTime;
    public var modifiedOn:SDateTime;
}
