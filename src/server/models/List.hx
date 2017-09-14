package models;

import sys.db.Object;
import sys.db.Types;

@:keep enum Privacy {
    Private;
    Unlisted;
    Public;
}

@:table("lists")
class List extends Object {
    public var id:SId;
    @:relation(uid,cascade) public var user:User;
    public var name:SString<255>;
    public var privacy:Null<SEnum<Privacy>>;
}