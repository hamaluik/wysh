package models;

import sys.db.Object;
import sys.db.Types;

@:table("friend_requests")
@:id(id_requester, id_requestee)
class FriendRequests extends Object {
    @:relation(id_requester) public var requester:User;
    @:relation(id_requestee) public var requestee:User;
    public var status:SEnum<FriendRequestStatus>;

    public var createdOn:SDateTime;
    public var modifiedOn:SDateTime;
}