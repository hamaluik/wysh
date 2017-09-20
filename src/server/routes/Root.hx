package routes;

import tink.http.Response.ResponseHeader;
import tink.http.Response.OutgoingResponse;
import tink.web.routing.*;

class Root {
    public function new() {}

    @:restrict(true)
    @:sub('/api/lists') public function lists() {
        return new Lists();
    }

    @:sub('/api/oauth2') public function oauth2() {
        return new OAuth2();
    }
}