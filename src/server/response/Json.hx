package response;

import tink.web.routing.Response;

abstract Json(Response) from Response to Response {
    public function new(d:Dynamic)
        this = Json.ofDynamic(d);

    @:from static function ofDynamic(d:Dynamic):Json
        return Response.textual('application/json', haxe.Json.stringify(d));
}