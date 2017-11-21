package routes;

import tink.web.routing.*;

class UserRoutes {
    public function new() {}

    @:get('/$userHash/profile') public function getProfile(userHash:String, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(Server.extractID(userHash, Server.userHID));
        if(u == null) return new response.NotFound();
        return new response.API<api.Profile>(u);
    }
    
    @:get('/$userHash/lists') public function getLists(userHash:String, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(Server.extractID(userHash, Server.userHID));
        if(u == null) return new response.NotFound();

        var lists:List<models.List> = models.List.manager.search($user == u);
        return new response.API<api.Lists>(lists);
    }
}