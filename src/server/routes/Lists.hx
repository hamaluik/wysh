package routes;

import tink.http.Response.OutgoingResponse;
import tink.web.routing.*;

import models.List;

class Lists {
    public function new() {}

    @:post('/') public function newList(body:{id:Int}):OutgoingResponse {
        var hid:String = Server.hids.encode(body.id);
        return 'HID: `${hid}`';
    }

    @:get('/$hash') public function list(hash:String):OutgoingResponse {
        var ids:Array<Int> = Server.hids.decode(hash.toLowerCase());
        if(ids.length != 1) throw 'Invalid list id: $hash!';
        var id:Int = ids[0];

        List.manager.get(id);

        return 'List id: ${ids[0]}';
    }
}