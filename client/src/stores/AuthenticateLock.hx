package stores;

import auth0.Lock;
import macros.Defines;

using StringTools;

class AuthenticateLock {
	private function new(){}
	private static var lock:Lock = {
		var l:Lock = new Lock(Defines.getDefine("AUTH0_CLIENT_ID"), Defines.getDefine("AUTH0_DOMAIN"), {
			theme: {
				logo: "/logo.png",
				primaryColor: "#00BCD4"
			},
			languageDictionary: {
				title: "Log in to wysh"
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

	public static var changed(default, null):Event = new Event();

	public static var authenticated(default, set):Bool = false;
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
	}

	public static var token(default, null):String = null;
	public static var profile(default, null):Dynamic = null;

	public static function getName():String {
		if(profile.given_name != null)
			return profile.given_name;
		return profile.nickname;
	}

	private static function onAuthenticated(authResult:Dynamic):Void {
		js.Browser.getLocalStorage().setItem('idToken', authResult.idToken);
		check();
	}

	private static function onUnauthorized(message:String):Void {
		Main.console.log("Unauthorized: " + message);
		unauthorized = true;
	}

	public static function check():Void {
		var idToken:String = js.Browser.getLocalStorage().getItem('idToken');
		if(idToken == null || idToken.trim() == "") {
			token = null;
			authenticated = false;
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
			return;
		}

		lock.getProfile(idToken, function(error, userProfile) {
			if(error != null) {
				token = null;
				authenticated = false;
				Main.console.error("Unable to get user profile: " + error.message);
				return;
			}
			js.Browser.getLocalStorage().setItem("profile", haxe.Json.stringify(userProfile));
			token = idToken;
			profile = userProfile;
			authenticated = true;
		});
	}

	public static function startLogin() {
		if(!authenticated) lock.show();
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