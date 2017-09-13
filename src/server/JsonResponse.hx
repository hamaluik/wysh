package;

import tink.web.routing.Response;

abstract JsonResponse(Response) from Response to Response {
    @:from static function ofDynamic(d:Dynamic):JsonResponse
        return Response.textual('application/json', haxe.Json.stringify(d));
}