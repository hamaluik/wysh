package response;

import tink.http.Header;
import tink.http.Response.ResponseHeader;
import tink.http.Response.OutgoingResponse;
import tink.web.routing.Response;

abstract Redirect(Response) from Response to Response {
    public inline function new(uri:String) {
        this = new OutgoingResponse(new ResponseHeader(302, 'Temporary Redirect', [new HeaderField('location', uri)]), '');
    }
}