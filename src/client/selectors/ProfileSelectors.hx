package selectors;

import State;
import api.Profile;

class ProfileSelectors {
    public static var uidSelector = function(s:RootState):String { return s.auth.uid; };
    public static var profilesSelector = function(s:RootState):ProfilesState { return s.profiles; };

    public static var getProfile:RootState->Profile = {
        Selectors.create2(uidSelector, profilesSelector, function(uid:String, profiles:ProfilesState):Profile {
            return Reflect.field(profiles, uid);
        });
    };
}