package auth0;

@:enum
abstract WebAuthResponseType(String) {
    var Token = 'token';
    var Code = 'code';
}

@:enum
abstract WebAuthResponseMode(String) {
    var Post = 'form_post';
}

typedef WebAuthOptions = {
    var domain:String;
    var clientID:String;
    @:optional var redirectUri:String;
    @:optional var scope:String;
    @:optional var audience:String;
    @:optional var responseType:WebAuthResponseType;
    @:optional var responseMode:WebAuthResponseMode;
    @:optional var _disableDeprecationWarnings:Bool;
};

@:enum
abstract SocialConnection(String) {
    var Twitter = 'twitter';
    var Facebook = 'facebook';
    var Google = 'google-oauth2';
}

typedef AuthorizeOptions = {
    @:optional var audience:String;
    @:optional var scope:String;
    @:optional var responseType:WebAuthResponseType;
    @:optional var clientID:String;
    @:optional var state:String;
    @:optional var redirectUri:String;
    @:optional var connection:SocialConnection;
};

@:native('auth0.WebAuth')
extern class WebAuth {
    public function new(options:WebAuthOptions);
    public function authorize(options:AuthorizeOptions):Void;
}