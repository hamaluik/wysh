package models;

import sys.db.Object;
import sys.db.Types;

@:table("invitations")
class Invitation extends Object {
    public var id:SId;
    @:relation(gid) public var group:Group;
    public var email:SString<255>;
    public var code:SString<16>;
}