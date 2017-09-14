package routes;

import tink.http.Response.ResponseHeader;
import tink.http.Response.OutgoingResponse;
import tink.web.routing.*;

class Root {
    public function new() {}

    @:restrict(true)
    @:sub public function lists() {
        return new Lists();
    }
}