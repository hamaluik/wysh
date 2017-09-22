package response;

import tink.http.Response.ResponseHeader;
import tink.http.Response.OutgoingResponse;
import tink.web.routing.Response;

abstract MalformedRequest(Response) from Response to Response {
    public inline function new(?message:String) {
        this = new OutgoingResponse(
            new ResponseHeader(400, 'Bad Request', null),
            message != null ? message : 'Bad Request'
        );
    }
}