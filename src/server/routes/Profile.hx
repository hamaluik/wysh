package routes;

import tink.web.routing.*;

import response.JsonResponse;
import response.NotFoundResponse;

class Profile {
    public function new() {}

    @:get('/') public function getMyProfile(user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new NotFoundResponse();

        return new JsonResponse({
            name: u.name,
            picture: u.picture
        });
    }
}