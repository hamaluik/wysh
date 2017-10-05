package api;

interface APIResponseObject {}

@:forward
abstract APIResponse(APIResponseObject) from APIResponseObject to APIResponseObject {}