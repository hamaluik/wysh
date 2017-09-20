package models;

import sys.db.Object;
import sys.db.Types;

@:table("users")
class User extends Object {
    public var id:SId;
    public var name:SString<255>;
    public var googleID:Null<SString<255>>;
    public var facebookID:Null<SString<255>>;
    public var picture:Null<SSmallText>;

    public var createdOn:SDateTime;
    public var modifiedOn:SDateTime;
}