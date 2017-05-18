package auth0;

/*typedef Auth0LockCallback = Dynamic->String->Void;

typedef LockAvatarOptions = {
    var url:String->Auth0LockCallback->Void;
    var displayName:String->Auth0LockCallback->Void;
};

typedef Auth0LockOptions = {
    @:optional var allowedConnections:Array<String>;
    @:optional var autoclose:Bool;
    @:optional var autofocus:Bool;
    @:optional var closable:Bool;
    @:optional var container:String;
    @:optional var language:String;
    @:optional var languageDictionary:Dynamic;
    // TODO: so many options!
};*/

@:native('Auth0Lock')
extern class Lock {
	public function new(clientID:String, domain:String, ?options:Dynamic);
	public function getProfile(idToken:String, callback:Dynamic->Dynamic->Void):Void;
	public function getUserInfo(accessToken:String, callback:Dynamic->Dynamic->Void):Void;
	public function show(?options:Dynamic):Void;
	public function hide():Void;
	public function on(event:String, callback:Dynamic->Void):Void;
}