package models;

import sys.db.Object;
import sys.db.Types;

@:table("friends")
@:id(id_a, id_b)
class Friends extends Object {
    @:relation(id_a) public var friendA:User;
    @:relation(id_b) public var friendB:User;

    @:relation(pending_id) public var pendingUser:Null<User>;

    public var createdOn:SDateTime;
    public var modifiedOn:SDateTime;
}