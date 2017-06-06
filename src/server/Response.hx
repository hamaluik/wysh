import tink.http.Response;

class Response {
    public var code:Int;
    public var message:String;
    public var response:Dynamic;

    public function new() {
        code = 404;
        message = "not found";
        
    }
}