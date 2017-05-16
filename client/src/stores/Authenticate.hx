package stores;

import auth0.WebAuth;
import macros.Defines;

class Authenticate {
	private function new(){}
	public static var changed(default, null):Event = new Event();

    private static var webAuth:WebAuth;

	public static var authenticated(default, set):Bool = false;
	private static function set_authenticated(a:Bool):Bool {
		var didChange:Bool = authenticated != a;
		authenticated = a;
		if(didChange)
			changed.trigger();
		return authenticated;
	}

    public static function initialize():Void {
        webAuth = new WebAuth({
            domain: Defines.getDefine("AUTH0_DOMAIN"),
            clientID: Defines.getDefine("AUTH0_CLIENT_ID"),
            responseType: WebAuthResponseType.Token
        });
    }

    public static function login(connection:SocialConnection):Void {
        webAuth.authorize({
            redirectUri: 'http://localhost:8080/',
            connection: connection
        });
    }
}