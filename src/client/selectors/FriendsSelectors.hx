package selectors;

import State;
import api.Profile;

class FriendsSelectors {
    public static var getSearchResults:RootState->Array<Profile> = {
        var searchSelector = function(s:RootState):Array<String> { return s.friends.searchResults; };
        var profilesSelector = function(s:RootState):ProfilesState { return s.profiles; };
        Selectors.create2(searchSelector, profilesSelector, function(ids:Array<String>, profiles:ProfilesState):Array<Profile> {
            return [
                for(id in ids) Reflect.field(profiles, id)
            ];
        });
    };

    public static var getFriendProfiles:RootState->Array<Profile> = {
        var friendsSelector = function(s:RootState):Array<String> { return s.friends.friends; };
        var profilesSelector = function(s:RootState):ProfilesState { return s.profiles; };
        Selectors.create2(friendsSelector, profilesSelector, function(ids:Array<String>, profiles:ProfilesState):Array<Profile> {
            return [
                for(id in ids) Reflect.field(profiles, id)
            ];
        });
    };

    public static var getIncomingRequestsProfiles:RootState->Array<Profile> = {
        var requestsSelector = function(s:RootState):Array<String> { return s.friends.incomingRequests; };
        var profilesSelector = function(s:RootState):ProfilesState { return s.profiles; };
        Selectors.create2(requestsSelector, profilesSelector, function(ids:Array<String>, profiles:ProfilesState):Array<Profile> {
            return [
                for(id in ids) Reflect.field(profiles, id)
            ];
        });
    };

    public static var getSentRequestsProfiles:RootState->Array<Profile> = {
        var requestsSelector = function(s:RootState):Array<String> { return s.friends.sentRequests; };
        var profilesSelector = function(s:RootState):ProfilesState { return s.profiles; };
        Selectors.create2(requestsSelector, profilesSelector, function(ids:Array<String>, profiles:ProfilesState):Array<Profile> {
            return [
                for(id in ids) Reflect.field(profiles, id)
            ];
        });
    };
}