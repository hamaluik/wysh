package routes;

import tink.web.routing.*;

class User {
    public function new() {}

    @:get('/profile') public function getMyProfile(user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        return new response.Json({
            name: u.name,
            picture: u.picture
        });
    }

    @:get('/$userHash/profile') public function getProfile(userHash:String, user:JWTSession.User):Response {
        // TODO: make sure we have permission to view this user

        var u:models.User = models.User.manager.get(Server.extractID(userHash, Server.userHID));
        if(u == null) return new response.NotFound();

        return new response.Json({
            name: u.name,
            picture: u.picture
        });
    }
    
    @:get('/lists') public function getMyLists(user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        var lists:List<models.List> = models.List.manager.search($user == u);
        return new response.Json({
            lists: [for(list in lists) {
                id: Server.listHID.encode(list.id),
                name: list.name
            }]
        });
    }
    
    @:get('/$userHash/lists') public function getLists(userHash:String, user:JWTSession.User):Response {
        // TODO: make sure we have permission to view this user's lists

        var u:models.User = models.User.manager.get(Server.extractID(userHash, Server.userHID));
        if(u == null) return new response.NotFound();

        var lists:List<models.List> = models.List.manager.search($user == u);
        return new response.Json({
            lists: [for(list in lists) {
                id: Server.listHID.encode(list.id),
                name: list.name
            }]
        });
    }

    @:get('/search') public function searchUsers(query:{name:String}):Response {
        var users:List<models.User> = models.User.manager.search($name.like(query.name));
        return new response.Json({
            users: [for(user in users) {
                id: Server.userHID.encode(user.id),
                name: user.name,
                picture: user.picture
            }]
        });
    }
}