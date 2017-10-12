package routes;

import tink.web.routing.*;

class SearchRoutes {
    public function new() {}

    @:get('/users') public function searchUsers(query:{name:String}, user:JWTSession.User):Response {
        if(query.name == null || StringTools.trim(query.name).length < 1)
            return new response.API<api.Profiles>([]);

        var users:List<models.User> = models.User.manager.search(
            $name.like('%${query.name}%')
            && $id != user.id
        );
        return new response.API<api.Profiles>(users);
    }
}