package models;

import sys.db.Object;

@:table("followers")
@:id(follower_id, followee_id)
class Followers extends Object {
    @:relation(follower_id) public var follower:User;
    @:relation(followee_id) public var followee:User;
}