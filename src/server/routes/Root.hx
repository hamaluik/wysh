package routes;

import tink.http.Response.ResponseHeader;
import tink.http.Response.OutgoingResponse;
import tink.web.routing.*;

class Root {
    public function new() {}

    @:sub('/api/oauth2') public function oauth2() {
        return new OAuth2();
    }

    @:restrict(true)
    @:sub('/api/auth') public function auth() {
        return new Auth();
    }

    @:restrict(true)
    @:sub('/api/lists') public function lists() {
        return new Lists();
    }

    @:restrict(true)
    @:sub('/api/list') public function items() {
        return new Items();
    }

    @:restrict(true)
    @:sub('/api/user') public function user() {
        return new User();
    }
}