package stores;

import js.Object;
import Actions;
import State;
import redux.IReducer;

class FriendsReducer implements IReducer<FriendsActions, FriendsState> {
    public function new(){}
    
    public var initState:FriendsState = {
        searchResults: [],
        friends: [],
        incomingRequests: [],
        sentRequests: [],
    };

    public function reduce(state:FriendsState, action:FriendsActions):FriendsState {
        return switch(action) {
            case SetSearchResults(profiles): {
                Object.assign(cast({}), state, {
                    searchResults: [for(profile in profiles) profile.id]
                });
            }

            case SetFriends(profiles): {
                Object.assign(cast({}), state, {
                    friends: [for(profile in profiles) profile.id]
                });
            }

            case SetIncomingRequests(profiles): {
                Object.assign(cast({}), state, {
                    incomingRequests: [for(profile in profiles) profile.id]
                });
            }

            case RemoveIncomingRequests(profiles): {
                Object.assign(cast({}), state, {
                    // TODO: is filter pure?
                    incomingRequests: state.incomingRequests.filter(function(id:String):Bool {
                        return !Lambda.exists(profiles, function(p) { return p.id == id; });
                    })
                });
            }

            case SetSentRequests(profiles): {
                Object.assign(cast({}), state, {
                    sentRequests: [for(profile in profiles) profile.id]
                });
            }
        }
    }
}
