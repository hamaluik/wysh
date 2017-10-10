package routes;

import tink.web.routing.*;

class User {
    public function new() {}

    @:get('/profile') public function getMyProfile(user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();
        return new response.API<api.Profile>(u);
    }

    @:get('/$userHash/profile') public function getProfile(userHash:String, user:JWTSession.User):Response {
        // TODO: make sure we have permission to view this user

        var u:models.User = models.User.manager.get(Server.extractID(userHash, Server.userHID));
        if(u == null) return new response.NotFound();
        return new response.API<api.Profile>(u);
    }
    
    @:get('/lists') public function getMyLists(user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        var lists:List<models.List> = models.List.manager.search($user == u);
        return new response.API<api.Lists>(lists);
    }
    
    @:get('/$userHash/lists') public function getLists(userHash:String, user:JWTSession.User):Response {
        // TODO: make sure we have permission to view this user's lists

        var u:models.User = models.User.manager.get(Server.extractID(userHash, Server.userHID));
        if(u == null) return new response.NotFound();

        var lists:List<models.List> = models.List.manager.search($user == u);
        return new response.API<api.Lists>(lists);
    }

    @:get('/search') public function searchUsers(query:{name:String}, user:JWTSession.User):Response {
        if(query.name == null || StringTools.trim(query.name).length < 1)
            return new response.API<api.Profiles>([]);

        var users:List<models.User> = models.User.manager.search(
            $name.like('%${query.name}%')
            && $id != user.id
        );
        return new response.API<api.Profiles>(users);
    }
}