package models;

import sys.db.Object;
import sys.db.Types;

@:table("followers")
@:id(follower_id, followee_id)
class Followers extends Object {
    @:relation(follower_id) public var follower:User;
    @:relation(followee_id) public var followee:User;

    public var createdOn:SDateTime;
    public var modifiedOn:SDateTime;
}