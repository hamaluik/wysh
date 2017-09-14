package routes;

import tink.core.Error;
import tink.http.Response.OutgoingResponse;
import tink.web.routing.*;

using Lambda;

class Lists {
    public function new() {}

    @:post('/') public function newList(body:{id:Int}):Response {
        var hid:String = Server.hids.encode(body.id);
        return 'HID: `${hid}`';
    }

    @:get('/$hash') public function list(hash:String):Response {
        var ids:Array<Int> = Server.hids.decode(hash.toLowerCase());
        if(ids.length != 1) throw 'Invalid list id: $hash!';
        var id:Int = ids[0];

        var list:models.List = models.List.manager.get(id);
        if(list == null) {
            return OutgoingResponse.reportError(new Error(404, 'List not found!'));
        }
        var items:List<models.Item> = models.Item.manager.search($lid == list.id);
        if(items == null) items = new List<models.Item>();

        return Response.textual('application/json', haxe.Json.stringify({
            name: list.name,
            items: items.map(function(item:models.Item):Dynamic {
                return {
                    name: item.name,
                    comments: item.comments
                }
            }).array()
        }));
    }
}