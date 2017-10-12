package middleware;

import tink.core.Future;
import tink.http.Response.OutgoingResponse;
import tink.http.Request.IncomingRequest;
import tink.http.Handler;
import tink.http.Middleware;

using StringTools;

class RequestLogger implements MiddlewareObject {
    public function new() {}

    public function apply(handler:Handler):Handler {
        return new RequestLoggerHandler(handler);
    }
}

class RequestLoggerHandler implements HandlerObject {
    private var handler:Handler;

    public function new(handler:Handler) {
        this.handler = handler;
    }

    public function process(req:IncomingRequest):Future<OutgoingResponse> {
        var res = handler.process(req);
        Log.trace('>' + req.clientIp.lpad(' ', 16) + ' ' + (req.header.method:String).rpad(' ', 8) + req.header.uri.pathWithQuery);
        return res;
    }
}