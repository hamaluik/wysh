import mithril.M;
import js.Promise;

@:enum abstract RequestMethod(String) to String {
    var GET = "GET";
    var POST = "POST";
    var PATCH = "PATCH";
    var DELETE = "DELETE";
}

class WebRequest {
    public inline static function endpoint(endpoint:String):String {
        // TODO: use a define
        return macros.Defines.get('apiroot') + endpoint;
    }

    public static function extract(xhr:js.html.XMLHttpRequest, options):Dynamic {
        if(xhr.status >= 200 && xhr.status < 300) return haxe.Json.parse(xhr.responseText);
        else return {
            code: xhr.status,
            message: xhr.responseText
        };
    }

    public static function request<T>(method:RequestMethod, endpoint:String, useAuth:Bool=true, ?data:Dynamic):Promise<T> {
        return M.request(WebRequest.endpoint(endpoint), {
            method: method,
            extract: WebRequest.extract,
            data: data,
            headers: useAuth ? {
                Authorization: 'Bearer ' + Client.store.state.auth.token
            } : {}
        });
    }
}