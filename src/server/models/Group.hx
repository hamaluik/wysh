package models;

import sys.db.Object;
import sys.db.Types;

@:table("groups")
class Group extends Object {
    public var id:SId;
    public var name:SString<255>;
}