import tink.http.Method;
import tink.core.Future;
import tink.http.Response.OutgoingResponse;
import tink.http.Request.IncomingRequest;
import tink.http.Handler;
import tink.http.Middleware;
import tink.http.Header;

class CORS implements MiddlewareObject {
    private var origins:Array<String> = ['*'];
    private var methods:Array<String> = ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE'];

    public function new(?origins:Array<String>, ?methods:Array<String>) {
        if(origins != null) this.origins = origins;
        if(methods != null) this.methods = methods;
    }

    public function apply(handler:Handler):Handler {
        return new CORSHandler(origins, methods, handler);
    }
}

class CORSHandler implements HandlerObject {
    private var origins:String;
    private var methods:String;
    private var handler:Handler;

    public function new(origins:Array<String>, methods:Array<String>, handler:Handler) {
        this.origins = origins.join(' ');
        this.methods = methods.join(',');
        this.handler = handler;
    }

    public function process(req:IncomingRequest):Future<OutgoingResponse> {
        if(req.header.method == Method.OPTIONS) {
            return Future.sync(tink.http.Response.OutgoingResponse.blob(200, haxe.io.Bytes.ofString(''), 'text/html; charset=utf-8', [
                new tink.http.Header.HeaderField('Access-Control-Allow-Origin', origins),
                new tink.http.Header.HeaderField('Access-Control-Allow-Methods', methods),
                new tink.http.Header.HeaderField('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization')
            ]));
        }

        var res = handler.process(req);
        res.handle(function(response:OutgoingResponse):Void {
            response.header.fields.push(new HeaderField('Access-Control-Allow-Origin', origins));
            response.header.fields.push(new HeaderField('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization'));
        });
        return res;
    }
}