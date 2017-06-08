package models;

import sys.db.Object;

@:table("users_groups")
@:id(gid, uid)
class UserGroup extends Object {
    @:relation(uid) public var user:User;
    @:relation(gid) public var group:Group;
}