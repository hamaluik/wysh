package routes;

import tink.web.routing.*;

import types.TPrivacy;

using Lambda;
using StringTools;

class Lists {
    public function new() {}

    @:post('/') public function newList(body:{name:String, ?privacy:TPrivacy}, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        if(body.name == null || body.name.trim().length < 1) return new response.MalformedRequest();

        var list:models.List = new models.List();
        list.name = body.name;
        list.user = u;
        list.createdOn = Date.now();
        list.modifiedOn = Date.now();
        list.privacy = switch(body.privacy) {
            case Public: Public;
            case Friends: Friends;
            case _: Private;
        };
        list.insert();

        Log.info('${u.name} (${u.id}) created a new list called "${list.name}" (privacy: ${list.privacy})!');
        return new response.API<api.List>(list);
    }

    @:patch('/$listHash') public function updateList(listHash:String, body:{?name:String, ?privacy:TPrivacy}, user:JWTSession.User):Response {
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
        if(body.privacy != null && [Public, Friends, Private].indexOf(body.privacy) != -1) {
            list.privacy = body.privacy;
            modified = true;
        }

        if(modified) {
            list.update();
            Log.info('${list.user.name} updated their list "${list.name}"! ' + haxe.Json.stringify(body));
        }

        return new response.API<api.List>(list);
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

        return new response.API<api.Message>('List deleted!');
    }
}