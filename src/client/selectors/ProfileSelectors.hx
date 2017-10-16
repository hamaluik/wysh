package selectors;

import State;
import api.Profile;

class ProfileSelectors {
    public static var getProfile:RootState->Profile = {
        var uidSelector = function(s:RootState):String { return s.auth.uid; };
        var profileSelector = function(s:RootState):ProfilesState { return s.profiles; };
        Selectors.create2(uidSelector, profileSelector, function(uid:String, profiles:ProfilesState):Profile {
            return Reflect.field(profiles, uid);
        });
    };
}