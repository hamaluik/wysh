package routes;

import tink.web.routing.*;

import models.Privacy;

using Lambda;
using StringTools;

class Lists {
    public function new() {}

    @:post('/') public function newList(body:{name:String, ?privacy:String}, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        if(body.name == null || body.name.trim().length < 1) return new response.MalformedRequest();

        var list:models.List = new models.List();
        list.name = body.name;
        list.user = u;
        list.createdOn = Date.now();
        list.modifiedOn = Date.now();
        list.privacy = switch(body.privacy) {
            case 'public': Privacy.Public;
            case 'friends': Privacy.Friends;
            case _: models.Privacy.Private;
        };
        list.insert();

        Log.info('${u.name} (${u.id}) created a new list called "${list.name}"!');

        return new response.Json({
            id: Server.listHID.encode(list.id),
            name: list.name
        });
    }

    /*@:get('/friends') public function getMyLists(user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        var response:Array<Dynamic> = new Array<Dynamic>();
        var friends:List<models.Friends> = models.Friends.manager.search($friendA == u);
        for(friend in friends) {
            var lists:List<models.List> = models.List.manager.search($user == friend.friendB && ($privacy == Public || $privacy == Friends));
            response.push({
                id: Server.userHID.encode(friend.friendB.id),
                name: friend.friendB.name,
                lists: [for(list in lists) {
                    id: Server.listHID.encode(list.id),
                    name: list.name
                }]
            });
        }

        return new response.Json({
            friends: response
        });
    }*/

    @:patch('/$listHash') public function updateList(listHash:String, body:{?name:String, ?privacy:String}, user:JWTSession.User):Response {
        var lid:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();

        // ensure the list exists
        var list:models.List = models.List.manager.get(lid);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        // ensure the user owns this list
        if(list.user.id != user.id) {
            return new response.Unauthorized();
        }

        // update it!
        var modified:Bool = false;
        if(body.name != null && body.name.trim().length > 0) {
            list.name = body.name;
            modified = true;
        }
        if(body.privacy == 'public') {
            list.privacy = Privacy.Public;
            modified = true;
        }
        else if(body.privacy == 'friends') {
            list.privacy = Privacy.Friends;
            modified = true;
        }
        else if(body.privacy == 'private') {
            list.privacy = Privacy.Private;
            modified = true;
        }

        if(modified) {
            list.update();
            Log.info('${list.user.name} updated their list "${list.name}"! ' + haxe.Json.stringify(body));
        }

        return new response.Json({
            id: Server.listHID.encode(list.id),
            name: list.name
        });
    }

    @:delete('/$listHash') public function deleteList(listHash:String, user:JWTSession.User):Response {
        var lid:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();

        // ensure the list exists
        var list:models.List = models.List.manager.get(lid);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        // ensure the user owns this list
        if(list.user.id != user.id) {
            return new response.Unauthorized();
        }

        Log.info('User ${user.id} deleted list ${list.name} (${list.id})!');

        // delete it!
        list.delete();

        return new response.Json({});
    }
}