package api;

import api.APIResponse;
#if sys
import models.User;
import models.Friends;
import models.FriendRequests;
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

    @:from
    public static inline function fromDBFriends(friends:Iterable<Friends>):Profiles
        return new Profiles([for(friend in friends) friend]);

    @:from
    public static inline function fromDBFriendRequests(requests:Iterable<FriendRequests>):Profiles
        return new Profiles([for(request in requests) request]);
#end
}
