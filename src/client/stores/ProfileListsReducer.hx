package stores;

import js.Object;
import Actions;
import State;
import redux.IReducer;

class ProfileListsReducer implements IReducer<ProfileListsActions, ProfileListsState> {
    public function new(){}
    
    public var initState:ProfileListsState = {};

    public function reduce(state:ProfileListsState, action:ProfileListsActions):ProfileListsState {
        return switch(action) {
            case Relate(profileid, lists): {
                var existingLists:Array<String> = Reflect.field(state, profileid);
                if(existingLists == null) existingLists = [];
                var newLists = existingLists.concat([for(list in lists) list.id].filter(function(id:String):Bool {
                    return existingLists.indexOf(id) == -1;
                }));

                var newState = {};
                Reflect.setField(newState, profileid, newLists);
                Object.assign(cast({}), state, newState);
            };

            case DeleteProfile(profileid): {
                var newState = Object.assign(cast({}), state);
                if(Reflect.hasField(newState, profileid)) {
                    Reflect.deleteField(newState, profileid);
                }
                newState;
            }

            case DeleteList(listid): {
                var newState = Object.assign(cast({}), state);
                var profileIDs:Array<String> = Reflect.fields(newState);
                for(profileid in profileIDs) {
                    var lists:Array<String> = Reflect.field(newState, profileid);
                    if(lists == null) lists = [];
                    var newLists:Array<String> = lists.filter(function(lid) {
                        return lid != listid;
                    });
                    Reflect.setField(newState, profileid, newLists);
                }
                newState;
            }
        }
    }
}
