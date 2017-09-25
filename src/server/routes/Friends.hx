package routes;

import tink.web.routing.*;
using StringTools;

class Friends {
    public function new() {}

    @:post('/request') public function requestFriendship(body:{id:String}, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        if(body.id == null || body.id.trim().length < 1) return new response.MalformedRequest();

        var requester:models.User = u;
        var requesteeID:Int = Server.extractID(body.id, Server.userHID);
        if(requester.id == requesteeID) return new response.MalformedRequest('You can\'t befriend yourself!');
        var requestee:models.User = models.User.manager.get(requesteeID);
        if(requestee == null) return new response.NotFound('User ${body.id}');

        // make sure they're not already friends
        var nFriends:Int = models.Friends.manager.count(
            ($friendA == requester && $friendB == requestee) ||
            ($friendB == requester && $friendA == requestee)
        );
        if(nFriends > 0) return new response.MalformedRequest('You are already friends!');

        // make sure there isn't already a friend request
        var nRequests:Int = models.FriendRequests.manager.count(
            $requester == requester && $requestee == requestee
        );
        if(nRequests > 0) return new response.MalformedRequest('You have already sent a friend request!');

        // ok, create the friend request
        var request:models.FriendRequests = new models.FriendRequests();
        request.requester = requester;
        request.requestee = requestee;
        request.status = models.FriendRequestStatus.Pending;
        request.createdOn = Date.now();
        request.modifiedOn = Date.now();
        request.insert();

        Log.info('${requester.name} (${requester.id}) sent friend request to ${requestee.name} (${requestee.id})!');

        return new response.Json({
            message: 'Friend request sent!'
        });
    }

    @:get('/requests') public function getFriendRequests(user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        var requests:List<models.FriendRequests> = models.FriendRequests.manager.search($requestee == u && $status == models.FriendRequestStatus.Pending, { orderBy: -createdOn });
        return new response.Json({
            users: [for(request in requests) {
                id: Server.userHID.encode(request.requester.id),
                name: request.requester.name,
                picture: request.requester.picture
            }]
        });
    }

    @:post('/accept') public function acceptRequest(body:{id:String}, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        if(body.id == null || body.id.trim().length < 1) return new response.MalformedRequest();

        var requester:models.User = models.User.manager.get(Server.extractID(body.id, Server.userHID));
        if(requester == null) return new response.NotFound('User ${body.id}');
        var requestee:models.User = u;

        // make sure they're not already friends
        var nFriends:Int = models.Friends.manager.count(
            ($friendA == requester && $friendB == requestee) ||
            ($friendB == requester && $friendA == requestee)
        );
        if(nFriends > 0) return new response.MalformedRequest('You are already friends!');

        // make sure there is an active request
        var requests:List<models.FriendRequests> = models.FriendRequests.manager.search(
            $requester == requester && $requestee == requestee && $status == models.FriendRequestStatus.Pending
        );
        if(requests.length != 1) return new response.MalformedRequest('There is no pending friend request from that person!');

        // ok, let's accept the request!
        var request:models.FriendRequests = requests.first();
        request.status = models.FriendRequestStatus.Accepted;
        request.modifiedOn = Date.now();
        request.update();

        var recordA:models.Friends = new models.Friends();
        recordA.friendA = requester;
        recordA.friendB = requestee;
        recordA.createdOn = Date.now();
        recordA.modifiedOn = Date.now();
        recordA.insert();

        var recordB:models.Friends = new models.Friends();
        recordB.friendA = requestee;
        recordB.friendB = requester;
        recordB.createdOn = Date.now();
        recordB.modifiedOn = Date.now();
        recordB.insert();

        Log.info('${requestee.name} (${requestee.id}) accepted friend request from ${requester.name} (${requester.id})!');

        return new response.Json({
            message: 'Friend request accepted!'
        });
    }

    @:post('/reject') public function rejectRequest(body:{id:String}, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        if(body.id == null || body.id.trim().length < 1) return new response.MalformedRequest();

        var requester:models.User = models.User.manager.get(Server.extractID(body.id, Server.userHID));
        if(requester == null) return new response.NotFound('User ${body.id}');
        var requestee:models.User = u;

        // make sure they're not already friends
        var nFriends:Int = models.Friends.manager.count(
            ($friendA == requester && $friendB == requestee) ||
            ($friendB == requester && $friendA == requestee)
        );
        if(nFriends > 0) return new response.MalformedRequest('You are already friends!');

        // make sure there is an active request
        var requests:List<models.FriendRequests> = models.FriendRequests.manager.search(
            $requester == requester && $requestee == requestee && $status == models.FriendRequestStatus.Pending
        );
        if(requests.length != 1) return new response.MalformedRequest('There is no pending friend request from that person!');

        // ok, let's accept the request!
        var request:models.FriendRequests = requests.first();
        request.status = models.FriendRequestStatus.Rejected;
        request.modifiedOn = Date.now();
        request.update();

        Log.info('${requestee.name} (${requestee.id}) rejected friend request from ${requester.name} (${requester.id})!');

        return new response.Json({
            message: 'Friend request denied!'
        });
    }
}