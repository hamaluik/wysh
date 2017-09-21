class WebRequest {
    public inline static function endpoint(endpoint:String):String {
        return 'http://lvh.me:8080/api' + endpoint;
    }

    public static function extract(xhr:js.html.XMLHttpRequest, options):Dynamic {
        if(xhr.status >= 200 && xhr.status < 300) return haxe.Json.parse(xhr.responseText);
        else return {
            code: xhr.status,
            message: xhr.responseText
        };
    }
}