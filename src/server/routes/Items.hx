package routes;

import tink.web.routing.*;

using Lambda;

class Items {
    public function new() {}

    @:post('/$listHash') public function newItem(listHash:String, body:{name:String, ?url:String, ?comments:String, ?image_path:String}, user:JWTSession.User):Response {
        var id:Int = Server.extractID(listHash, Server.listHID);

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
        item.createdOn = Date.now();
        item.modifiedOn = Date.now();
        item.insert();

        return new response.Json({
            id: Server.itemHID.encode(item.id),
            name: item.name,
            url: item.url,
            comments: item.comments,
            image_path: item.image_path
        });
    }

    @:get('/$listHash') public function getItems(listHash:String):Response {
        var id:Int = Server.extractID(listHash, Server.listHID);
        var list:models.List = models.List.manager.get(id);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        var items:List<models.Item> = models.Item.manager.search($lid == list.id);
        if(items == null) items = new List<models.Item>();

        return new response.Json({
            id: Server.listHID.encode(list.id),
            name: list.name,
            items: items.map(function(item:models.Item):Dynamic {
                return {
                    id: Server.itemHID.encode(item.id),
                    name: item.name,
                    url: item.url,
                    comments: item.comments,
                    image_path: item.image_path
                }
            }).array()
        });
    }

    @:patch('/$listHash/$itemHash') public function updateItem(listHash:String, itemHash:String, body:{?name:String, ?url:String, ?comments:String, ?image_path:String}, user:JWTSession.User):Response {
        var lid:Int = Server.extractID(listHash, Server.listHID);
        var iid:Int = Server.extractID(itemHash, Server.itemHID);

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

        // update the properties
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

        if(modified) {
            item.modifiedOn = Date.now();
            item.update();
        }

        return new response.Json({
            id: Server.itemHID.encode(item.id),
            name: item.name,
            url: item.url,
            comments: item.comments,
            image_path: item.image_path
        });
    }

    @:delete('/$listHash/$itemHash') public function deleteItem(listHash:String, itemHash:String, user:JWTSession.User):Response {
        var lid:Int = Server.extractID(listHash, Server.listHID);
        var iid:Int = Server.extractID(itemHash, Server.itemHID);

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

        // delete it!
        item.delete();

        return new response.Json({});
    }
}