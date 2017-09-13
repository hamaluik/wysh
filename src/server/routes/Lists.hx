package routes;

import tink.core.Future;
import tink.http.Response.ResponseHeader;
import tink.http.Response.OutgoingResponse;
import tink.http.Request.IncomingRequest;

class Lists {
    private function new(){}

    public static function newList(req:IncomingRequest):Future<OutgoingResponse> {
        return switch(req.body) {
            case Plain(source): {
                var ft:FutureTrigger<OutgoingResponse> = new FutureTrigger<OutgoingResponse>();
                ft.trigger(new OutgoingResponse(new ResponseHeader(401, 'Unauthorized', null, null), null));
                ft.asFuture();
            }
            case Parsed(parts): {
                var ft:FutureTrigger<OutgoingResponse> = new FutureTrigger<OutgoingResponse>();
                ft.trigger(new OutgoingResponse(new ResponseHeader(401, 'Unauthorized', null, null), null));
                ft.asFuture();
            };
        }
    }

    public static function getList(req:IncomingRequest):Future<OutgoingResponse> {
        var ft:FutureTrigger<OutgoingResponse> = new FutureTrigger<OutgoingResponse>();
        ft.trigger(new OutgoingResponse(new ResponseHeader(200, 'OK', null), 'derp'));
        return ft.asFuture();
    }
}