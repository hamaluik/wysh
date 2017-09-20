package routes;

import tink.web.routing.*;

import response.JsonResponse;
import response.NotFoundResponse;
import response.UnauthorizedResponse;

using Lambda;

class Lists {
    public function new() {}

    // TODO: create list!
    @:post('/') public function newList(body:{}):Response {
        return new UnauthorizedResponse();
    }

    @:get('/$hash') public function list(hash:String):Response {
        var id:Int = Server.extractID(hash, Server.listHID);
        var list:models.List = models.List.manager.get(id);
        if(list == null) {
            return new NotFoundResponse('list "${hash}"');
        }

        var items:List<models.Item> = models.Item.manager.search($lid == list.id);
        if(items == null) items = new List<models.Item>();

        return new JsonResponse({
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

    @:post('/$hash') public function newItem(hash:String, body:{name:String, ?url:String, ?comments:String, ?image_path:String}, user:JWTSession.User):Response {
        var id:Int = Server.extractID(hash, Server.listHID);

        // ensure the list exists
        var list:models.List = models.List.manager.get(id);
        if(list == null) {
            return new NotFoundResponse('list "${hash}"');
        }

        // ensure the user owns this list
        if(list.user.id != user.id) {
            return new UnauthorizedResponse();
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

        return new JsonResponse({
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
            return new NotFoundResponse('list "${listHash}"');
        }

        // ensure the user owns this list
        if(list.user.id != user.id) {
            return new UnauthorizedResponse();
        }

        // ensure the item exists
        var item:models.Item = models.Item.manager.get(iid);
        if(item == null) {
            return new NotFoundResponse('item "${itemHash}"');
        }

        // delete it!
        item.delete();

        return new JsonResponse({});
    }
}