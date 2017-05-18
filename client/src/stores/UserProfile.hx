package stores;

import haxe.Json;
import auth0.NormalizedProfile;

class UserProfile {
    private function new(){}
	public static var changed(default, null):Event = new Event();

    private static var _profile:NormalizedProfile = null;
	public static var profile(get, never):NormalizedProfile;

	public static function get_profile():NormalizedProfile {
		if(_profile == null)
		    return cast(
                Json.parse(js.Browser.getLocalStorage().getItem('profile'))
            );
        return _profile;
	}

    public static function updateProfile(prof:NormalizedProfile):Void {
        _profile = prof;
		js.Browser.getLocalStorage().setItem("profile", Json.stringify(profile));
        changed.trigger();
    }
}