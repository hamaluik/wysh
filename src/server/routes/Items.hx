package routes;

import tink.web.routing.*;

using Lambda;

class Items {
    public function new() {}

    @:post('/$listHash') public function newItem(listHash:String, body:{name:String, ?url:String, ?comments:String, ?image_path:String, ?reservable:Bool}, user:JWTSession.User):Response {
        var id:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();

        // ensure the list exists
        var list:models.List = models.List.manager.get(id);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        // ensure the user owns this list
        if(list.user.id != user.id) {
            return new response.Unauthorized();
        }

        var item:models.Item = new models.Item();
        item.list = list;
        item.name = body.name;
        item.url = body.url;
        item.comments = body.comments;
        item.image_path = body.image_path;
        item.reservable = switch(body.reservable) {
            case false: false;
            case _: true;
        };
        item.createdOn = Date.now();
        item.modifiedOn = Date.now();
        item.insert();

        Log.info('Added item "${item.name}" to user ${user.id}\'s list "${list.name}" (${list.id})!');
        return new response.API<api.Item>(item);
    }

    @:get('/$listHash') public function getItems(listHash:String, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        // TODO: make sure we have permission to view this list!

        var id:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();
        var list:models.List = models.List.manager.get(id);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        var items:List<models.Item> = models.Item.manager.search($lid == list.id);
        if(items == null) items = new List<models.Item>();

        return new response.API(api.Items.fromDBItems(items).hideReservedStatus());
    }

    @:patch('/$listHash/$itemHash') public function updateItem(listHash:String, itemHash:String, body:{?name:String, ?url:String, ?comments:String, ?image_path:String, ?reservable:Bool, ?reserve:Bool, ?clearReserved:Bool}, user:JWTSession.User):Response {
        var lid:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();
        var iid:Int = try { Server.extractID(itemHash, Server.itemHID); } catch(e:Dynamic) return new response.NotFound();

        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        // ensure the list exists
        var list:models.List = models.List.manager.get(lid);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        // ensure the item exists
        var item:models.Item = models.Item.manager.get(iid);
        if(item == null) {
            return new response.NotFound('item "${itemHash}"');
        }

        // see what we're allowed to do based on ownership
        if(list.user == u) {
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
            Log.info('${u.name} (${u.id}) reserved item ${item.id} on ${list.user.name}\'s (${list.user.id}) list ${list.name} (${list.id})');
        }
        else return new response.MalformedRequest();

        return new response.API(api.Item.fromDB(item).hideReservedStatus());
    }

    @:delete('/$listHash/$itemHash') public function deleteItem(listHash:String, itemHash:String, user:JWTSession.User):Response {
        var lid:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();
        var iid:Int = try { Server.extractID(itemHash, Server.itemHID); } catch(e:Dynamic) return new response.NotFound();

        // ensure the list exists
        var list:models.List = models.List.manager.get(lid);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        // ensure the user owns this list
        if(list.user.id != user.id) {
            return new response.Unauthorized();
        }

        // ensure the item exists
        var item:models.Item = models.Item.manager.get(iid);
        if(item == null) {
            return new response.NotFound('item "${itemHash}"');
        }

        Log.info('${list.user.name} (${list.user.id}) deleted item ${item.id} from their wishlist "${list.name}" (${list.id})!');

        // delete it!
        item.delete();

        return new response.API<api.Message>('Item deleted!');
    }
}