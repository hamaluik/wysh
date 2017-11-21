package api;

import api.APIResponse;
#if sys
import models.User;
#end

@:allow(api.Profiles)
class ProfilesObject implements APIResponseObject {
    public var profiles:Array<Profile>;

    private function new(profiles:Array<Profile>) {
        this.profiles = profiles;
    }
}

@:forward
abstract Profiles(ProfilesObject) from ProfilesObject to ProfilesObject to APIResponse {
    public function new(profiles:Array<Profile>)
        this = new ProfilesObject(profiles);

#if sys
    @:from
    public static inline function fromDBUsers(users:Iterable<User>):Profiles
        return new Profiles([for(user in users) user]);
#end
}
