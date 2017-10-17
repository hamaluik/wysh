package selectors;

import State;
import api.List;
import api.Profile;

typedef FriendLists = {
    profile:Profile,
    lists:Array<List>
}

class ListSelectors {
    public static var getMyLists:RootState->Array<List> = {
        var uidSelector = function(s:RootState):String { return s.auth.uid; };
        var profileListsSelector = function(s:RootState):ProfileListsState { return s.relations.profileLists; };
        var listsSelector = function(s:RootState):ListsState { return s.lists; };
        Selectors.create3(uidSelector, profileListsSelector, listsSelector, function(uid:String, profileLists:ProfileListsState, lists:ListsState):Array<List> {
            var listIDs:Array<String> = Reflect.field(profileLists, uid);
            if(listIDs == null) listIDs = [];
            var ret:Array<List> = [];
            for(id in listIDs) {
                if(Reflect.hasField(lists, id)) ret.push(Reflect.field(lists, id));
            }
            return ret;
        });
    };

    public static var getFriendLists:RootState->Array<FriendLists> = {
        var friendsSelector = FriendsSelectors.getFriendProfiles;
        var profileListsSelector = function(s:RootState):ProfileListsState { return s.relations.profileLists; };
        var listsSelector = function(s:RootState):ListsState { return s.lists; };
        Selectors.create3(friendsSelector, profileListsSelector, listsSelector, function(friends:Array<Profile>, profileLists:ProfileListsState, lists:ListsState):Array<FriendLists> {
            var ret:Array<FriendLists> = [];
            for(friend in friends) {
                var listIDs:Array<String> = Reflect.field(profileLists, friend.id);
                if(listIDs == null) listIDs = [];

                var friendLists:FriendLists = {
                    profile: friend,
                    lists: [for(id in listIDs) Reflect.field(lists, id)]
                };
                ret.push(friendLists);
            }
            return ret;
        });
    };
}