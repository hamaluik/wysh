package selectors;

import State;
import api.List;
import api.Profile;
import haxe.ds.StringMap;

typedef OtherLists = {
    profile:Profile,
    lists:Array<List>
}

class ListSelectors {
    public static var listsSelector = function(s:RootState):ListsState { return s.lists; };
    public static var profileListsSelector = function(s:RootState):ProfileListsState { return s.profileLists; };

    private static var cachedListSelectors:StringMap<RootState->List> = new StringMap<RootState->List>();
    public static function getListSelector(listid:String):RootState->List {
        if(!cachedListSelectors.exists(listid)) {
            cachedListSelectors.set(listid, Selectors.create1(listsSelector, function(lists:ListsState):List {
                return Reflect.field(lists, listid);
            }));
        }
        return cachedListSelectors.get(listid);
    }

    private static var cachedListOwnerSelectors:StringMap<RootState->Profile> = new StringMap<RootState->Profile>();
    public static function getListOwnerSelector(listid:String):RootState->Profile {
        if(!cachedListOwnerSelectors.exists(listid)) {
            cachedListOwnerSelectors.set(listid,
                Selectors.create2(ProfileSelectors.profilesSelector, profileListsSelector, function(profiles:ProfilesState, profileLists:ProfileListsState):Profile {
                    var profileIDs:Array<String> = Reflect.fields(profileLists);
                    for(id in profileIDs) {
                        var listIDs:Array<String> = Reflect.field(profileLists, id);
                        if(listIDs.indexOf(listid) != -1) {
                            return Reflect.field(profiles, id);
                        }
                    }
                    return null;
                })
            );
        }
        return cachedListOwnerSelectors.get(listid);
    }

    public static var getMyLists:RootState->Array<List> = {
        Selectors.create3(ProfileSelectors.uidSelector, profileListsSelector, listsSelector, function(uid:String, profileLists:ProfileListsState, lists:ListsState):Array<List> {
            var listIDs:Array<String> = Reflect.field(profileLists, uid);
            if(listIDs == null) listIDs = [];
            var ret:Array<List> = [];
            for(id in listIDs) {
                if(Reflect.hasField(lists, id)) ret.push(Reflect.field(lists, id));
            }
            return ret;
        });
    };

    public static var getOtherLists:RootState->Array<OtherLists> = {
        Selectors.create3(FriendsSelectors.getFriendProfiles, profileListsSelector, listsSelector, function(friends:Array<Profile>, profileLists:ProfileListsState, lists:ListsState):Array<OtherLists> {
            var ret:Array<OtherLists> = [];
            for(friend in friends) {
                var listIDs:Array<String> = Reflect.field(profileLists, friend.id);
                if(listIDs == null) listIDs = [];

                var otherLists:OtherLists = {
                    profile: friend,
                    lists: [for(id in listIDs) Reflect.field(lists, id)]
                };
                ret.push(otherLists);
            }
            return ret;
        });
    };
}