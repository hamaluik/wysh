package response;

import tink.web.routing.Response;

abstract JsonResponse(Response) from Response to Response {
    public function new(d:Dynamic)
        this = JsonResponse.ofDynamic(d);

    @:from static function ofDynamic(d:Dynamic):JsonResponse
        return Response.textual('application/json', haxe.Json.stringify(d));
}