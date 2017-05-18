package stores;

import auth0.Lock;
import auth0.NormalizedProfile;
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

	public static var token(default, null):String = null;

	private static function onAuthenticated(authResult:Dynamic):Void {
		js.Browser.getLocalStorage().setItem('idToken', authResult.idToken);
		js.Browser.getLocalStorage().setItem('accessToken', authResult.accessToken);

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
		lock.getUserInfo(accessToken, function(error, userProfile) {
			if(error != null) {
				token = null;
				authenticated = false;
				Main.console.error("Unable to get user profile: " + error.message);
				changed.trigger();
				return;
			}
			token = idToken;
			UserProfile.updateProfile(cast(userProfile));
			authenticated = true;
			changed.trigger();
		});
	}

	public static function logout() {
		js.Browser.getLocalStorage().removeItem("idToken");
		check();
	}
}