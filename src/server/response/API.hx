package response;

import tink.web.routing.Response;

import api.APIResponse;

@:generic
abstract API<T:APIResponse>(Response) from Response to Response {
    public function new(data:T)
        this = Response.textual('application/json', haxe.Json.stringify(data));
}