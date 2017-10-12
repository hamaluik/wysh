package routes;

import tink.web.routing.*;

using Lambda;

class ItemRoutes {
    public function new() {}

    @:patch('/$itemHash') public function updateItem(itemHash:String, body:{?name:String, ?url:String, ?comments:String, ?image_path:String, ?reservable:Bool, ?reserve:Bool, ?clearReserved:Bool}, user:JWTSession.User):Response {
        var iid:Int = try { Server.extractID(itemHash, Server.itemHID); } catch(e:Dynamic) return new response.NotFound();

        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        // ensure the item exists
        var item:models.Item = models.Item.manager.get(iid);
        if(item == null) {
            return new response.NotFound('item "${itemHash}"');
        }

        // see what we're allowed to do based on ownership
        if(item.list.user == u) {
            // the list's owner is making changes
            var modified:Bool = false;
            if(body.name != null) {
                item.name = body.name;
                modified = true;
            }
            if(body.url != null) {
                item.url = body.url;
                modified = true;
            }
            if(body.comments != null) {
                item.comments = body.comments;
                modified = true;
            }
            if(body.image_path != null) {
                item.image_path = body.image_path;
                modified = true;
            }
            if(body.reservable != null) {
                item.reservable = body.reservable;
                modified = true;
            }
            if(body.clearReserved != null && body.clearReserved) {
                item.reserver = null;
                item.reservedOn = null;
                modified = true;
            }

            if(modified) {
                item.modifiedOn = Date.now();
                item.update();
                Log.info('${u.name} (${u.id}) updated their wishlist! ' + haxe.Json.stringify(body));
            }
        }
        else if(body.reserve != null && body.reserve) {
            // someone else is making changes—presumably to the reservation
            if(!item.reservable) return new response.MalformedRequest('That item can\'t be reserved!');
            if(item.reserver != null) return new response.MalformedRequest('That item has already been reserved!');

            // reserve it!
            item.reserver = u;
            item.reservedOn = Date.now();
            item.update();
            Log.info('${u.name} (${u.id}) reserved item ${item.id} on ${item.list.user.name}\'s (${item.list.user.id}) list ${item.list.name} (${item.list.id})');
        }
        else return new response.MalformedRequest();

        return new response.API(api.Item.fromDB(item).hideReservedStatus());
    }

    @:delete('/$itemHash') public function deleteItem(itemHash:String, user:JWTSession.User):Response {
        var iid:Int = try { Server.extractID(itemHash, Server.itemHID); } catch(e:Dynamic) return new response.NotFound();

        // ensure the item exists
        var item:models.Item = models.Item.manager.get(iid);
        if(item == null) {
            return new response.NotFound('item "${itemHash}"');
        }

        // ensure the user owns this list
        if(item.list.user.id != user.id) {
            return new response.Unauthorized();
        }

        Log.info('${item.list.user.name} (${item.list.user.id}) deleted item ${item.id} from their wishlist "${item.list.name}" (${item.list.id})!');

        // delete it!
        item.delete();

        return new response.API<api.Message>('Item deleted!');
    }
}