package api;

import api.APIResponse;

@:allow(api.Message)
class MessageObject implements APIResponseObject {
    public var message:String;
    private function new(message:String)
        this.message = message;
}

abstract Message(MessageObject) to APIResponse {
    public function new(message:String)
        this = new MessageObject(message);

    @:from
    public static function fromString(message:String):Message
        return new Message(message);
}