package routes;

import tink.web.routing.*;

using Lambda;
using StringTools;

class Lists {
    public function new() {}

    @:post('/') public function newList(body:{name:String}, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        if(body.name == null || body.name.trim().length < 1) return new response.MalformedRequest();

        var list:models.List = new models.List();
        list.name = body.name;
        list.user = u;
        list.createdOn = Date.now();
        list.modifiedOn = Date.now();
        list.insert();

        return new response.Json({
            id: Server.listHID.encode(list.id),
            name: list.name
        });
    }

    @:patch('/$listHash') public function updateList(listHash:String, body:{?name:String}, user:JWTSession.User):Response {
        var lid:Int = Server.extractID(listHash, Server.listHID);

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

        if(modified) list.update();

        return new response.Json({
            id: Server.listHID.encode(list.id),
            name: list.name
        });
    }

    @:delete('/$listHash') public function deleteList(listHash:String, user:JWTSession.User):Response {
        var lid:Int = Server.extractID(listHash, Server.listHID);

        // ensure the list exists
        var list:models.List = models.List.manager.get(lid);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        // ensure the user owns this list
        if(list.user.id != user.id) {
            return new response.Unauthorized();
        }

        // delete it!
        list.delete();

        return new response.Json({});
    }
}