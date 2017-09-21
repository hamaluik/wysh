package response;

import tink.http.Response.ResponseHeader;
import tink.http.Response.OutgoingResponse;
import tink.web.routing.Response;

abstract NotFoundResponse(Response) from Response to Response {
    public inline function new(?resource:String) {
        this = new OutgoingResponse(
            new ResponseHeader(404, 'Not Found', null),
            resource != null ? '${resource} could not be found!' : 'Not Found'
        );
    }
}