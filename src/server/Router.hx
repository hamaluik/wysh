import tink.http.Request;
import tink.http.Response;
import tink.http.Handler;
import tink.http.Method;
import tink.core.Future;
import haxe.ds.StringMap;

class Router {
    public var mountPoint:String = '';
    public var caseSensitive:Bool = true;

    public var mounts:Map<Method, StringMap<HandlerFunction>> = new Map<Method, StringMap<HandlerFunction>>();

    public function new(?mountPoint:String) {
        if(mountPoint != null) this.mountPoint = mountPoint;

        for(method in [Method.GET, Method.POST, Method.PATCH, Method.PUT, Method.HEAD, Method.DELETE, Method.OPTIONS]) {
            mounts.set(method, new StringMap<HandlerFunction>());
        }
    }

    public function route(method:Method, path:String, handler:HandlerFunction):Void {
        mounts.get(method).set(path, handler);
    }

    public function get(path:String, handler:HandlerFunction):Void {
        route(Method.GET, path, handler);
    }

    public function post(path:String, handler:HandlerFunction):Void {
        route(Method.POST, path, handler);
    }

    public function patch(path:String, handler:HandlerFunction):Void {
        route(Method.PATCH, path, handler);
    }

    public function put(path:String, handler:HandlerFunction):Void {
        route(Method.PUT, path, handler);
    }

    public function head(path:String, handler:HandlerFunction):Void {
        route(Method.HEAD, path, handler);
    }

    public function delete(path:String, handler:HandlerFunction):Void {
        route(Method.DELETE, path, handler);
    }

    public function options(path:String, handler:HandlerFunction):Void {
        route(Method.OPTIONS, path, handler);
    }

    public function handle(req:IncomingRequest):Future<OutgoingResponse> {
        try {
            var path:Null<String> = req.header.uri.path;
            if(path == null) path = "";
            if(!caseSensitive) path = path.toLowerCase();

            Log.trace('${req.clientIp} ${req.header.method} ${path}');

            var mount:StringMap<HandlerFunction> = mounts.get(req.header.method);
            for(key in mount.keys()) {
                if(path == mountPoint + key) {
                    var handler:HandlerFunction = mount.get(key);
                    if(handler != null) {
                        return handler(req);
                    }
                }
            }

            var res:OutgoingResponse = new OutgoingResponse(
                new ResponseHeader(404, 'not found', null),
                ''
            );
            return Future.sync(res);
        }
        catch(exception:Any) {
            return onException(Exception.wrap(exception));
        }
    }

    private function onException(exception:Exception):Future<OutgoingResponse> {
        Log.exception(exception);
        var err:OutgoingResponse = new OutgoingResponse(
            new ResponseHeader(exception.code, exception.name, null),
            exception.message
        );
        return Future.sync(err);
    }
}