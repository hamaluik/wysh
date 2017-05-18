package stores;

import auth0.Lock;
import macros.Defines;

using StringTools;

class Authenticate {
	private function new(){}
	public static var changed(default, null):Event = new Event();

	public static var lockContainerID(get, never):String;
	private static function get_lockContainerID():String return "auth0lockcontainer";

	public static var lock:Lock = {
		var l:Lock = new Lock(Defines.getDefine("AUTH0_CLIENT_ID"), Defines.getDefine("AUTH0_DOMAIN"), {
			allowSignUp: true,
			container: lockContainerID,
			theme: {
				logo: "/logo.png",
				primaryColor: "#e91e63"
			},
			languageDictionary: {
				title: "wysh"
			},
			auth: {
				params: {
					scope: "openid email"
				}
			}
		});
		l.on("authenticated", onAuthenticated);
		l.on("authorization_error", onUnauthorized);
		l;
	};

	public static var authenticated:Bool = false;
	public static var unauthorized:Bool = false;

	/*public static var authenticated(default, set):Bool = false;
	private static function set_authenticated(a:Bool):Bool {
		var didChange:Bool = authenticated != a;
		authenticated = a;
		if(didChange)
			changed.trigger();
		if(unauthorized && authenticated)
			unauthorized = false;
		return authenticated;
	}

	public static var unauthorized(default, set):Bool = false;
	private static function set_unauthorized(a:Bool):Bool {
		var didChange:Bool = unauthorized != a;
		unauthorized = a;
		if(didChange) changed.trigger();
		return unauthorized;
	}*/

	public static var token(default, null):String = null;
	public static var profile(default, null):Dynamic = null;

	public static function getName():String {
		if(profile.given_name != null)
			return profile.given_name;
		return profile.nickname;
	}

	private static function onAuthenticated(authResult:Dynamic):Void {
		js.Browser.getLocalStorage().setItem('idToken', authResult.idToken);
		js.Browser.getLocalStorage().setItem('accessToken', authResult.accessToken);

		lock.getUserInfo(authResult.accessToken, function(error, userProfile) {
			Main.console.log(userProfile);
		});

		check();
	}

	private static function onUnauthorized(message:String):Void {
		Main.console.log("Unauthorized: " + message);
		unauthorized = true;
		changed.trigger();
	}

	public static function check():Void {
		var idToken:String = js.Browser.getLocalStorage().getItem('idToken');
		if(idToken == null || idToken.trim() == "") {
			token = null;
			authenticated = false;
			changed.trigger();
			return;
		}

		// make sure we haven't expired
		var payloadEncoded:String = idToken.split(".")[1];
		var payload:Dynamic = haxe.Json.parse(haxe.crypto.Base64.decode(payloadEncoded).toString());
		var ts:Float = Date.now().getTime() / 1000;
		if(ts >= payload.exp) {
			Main.console.warn("Authentication failed: token expired", {
				expiry: payload.exp,
				now: ts
			});
			token = null;
			authenticated = false;
			changed.trigger();
			return;
		}

		authenticated = true;
		changed.trigger();

		var accessToken:String = js.Browser.getLocalStorage().getItem('accessToken');
		Main.console.log('accessToken', accessToken);
		/*lock.getUserInfo(accessToken, function(error, userProfile) {
			Main.console.log('user profile');
			Main.console.log(userProfile);
			if(error != null) {
				token = null;
				authenticated = false;
				Main.console.error("Unable to get user profile: " + error.message);
				changed.trigger();
				return;
			}
			js.Browser.getLocalStorage().setItem("profile", haxe.Json.stringify(userProfile));
			token = idToken;
			profile = userProfile;
			authenticated = true;
			changed.trigger();
		});*/
	}

	public static function logout() {
		js.Browser.getLocalStorage().removeItem("idToken");
		js.Browser.getLocalStorage().removeItem("profile");
		check();
	}

	public static function getProfile():Dynamic {
		if(!authenticated) return null;
		return js.Browser.getLocalStorage().getItem('profile');
	}
}