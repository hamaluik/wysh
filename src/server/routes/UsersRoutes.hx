package routes;

import tink.web.routing.*;
using Lambda;

class UsersRoutes {
    public function new() {}

    @:get('/') public function getProfiles(user:JWTSession.User):Response {
		var users:List<models.User> = models.User.manager.all();
        return new response.API<api.Profiles>(users.filter(function(u:models.User):Bool {
			return u.id != user.id;
		}));
    }
}