package selectors;

import State;
import api.Profile;

class FriendsSelectors {
    public static var searchSelector = function(s:RootState):Array<String> { return s.friends.searchResults; };
    public static var friendsSelector = function(s:RootState):Array<String> { return s.friends.friends; };
    public static var incomingRequestsSelector = function(s:RootState):Array<String> { return s.friends.incomingRequests; };
    public static var sentRequestsSelector = function(s:RootState):Array<String> { return s.friends.sentRequests; };

    public static var getSearchResults:RootState->Array<Profile> = {
        Selectors.create2(searchSelector, ProfileSelectors.profilesSelector, function(ids:Array<String>, profiles:ProfilesState):Array<Profile> {
            return [
                for(id in ids) Reflect.field(profiles, id)
            ];
        });
    };

    public static var getFriendProfiles:RootState->Array<Profile> = {
        Selectors.create2(friendsSelector, ProfileSelectors.profilesSelector, function(ids:Array<String>, profiles:ProfilesState):Array<Profile> {
            return [
                for(id in ids) Reflect.field(profiles, id)
            ];
        });
    };

    public static var getIncomingRequestsProfiles:RootState->Array<Profile> = {
        Selectors.create2(incomingRequestsSelector, ProfileSelectors.profilesSelector, function(ids:Array<String>, profiles:ProfilesState):Array<Profile> {
            return [
                for(id in ids) Reflect.field(profiles, id)
            ];
        });
    };

    public static var getSentRequestsProfiles:RootState->Array<Profile> = {
        Selectors.create2(sentRequestsSelector, ProfileSelectors.profilesSelector, function(ids:Array<String>, profiles:ProfilesState):Array<Profile> {
            return [
                for(id in ids) Reflect.field(profiles, id)
            ];
        });
    };
}
