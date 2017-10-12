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
        return new AuthRoutes();
    }

    @:restrict(true)
    @:sub('/api/list') public function list() {
        return new ListRoutes();
    }

    @:restrict(true)
    @:sub('/api/item') public function items() {
        return new ItemRoutes();
    }

    @:restrict(true)
    @:sub('/api/user') public function user() {
        return new UserRoutes();
    }

    @:restrict(true)
    @:sub('/api/friends') public function friends() {
        return new FriendRoutes();
    }
}