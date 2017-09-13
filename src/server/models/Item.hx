package models;

import sys.db.Object;
import sys.db.Types;

@:table("items")
class Item extends Object {
    public var id:SId;
    @:relation(lid,cascade) public var list:List;
    public var name:SString<255>;
    public var url:SSmallText;
    public var comments:SSmallText;
    public var image_path:SSmallText;
}