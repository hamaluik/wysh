package stores;

import Actions;
import State;
import redux.IReducer;
import js.Object;

class APIReducer implements IReducer<APIActions, APICallsState> {
    public function new(){}
    
    public var initState:APICallsState = {
        getSelfProfile: Idle(null),
        getProfiles: Idle(null),
        getFriends: Idle(null),
        getIncomingRequests: Idle(null),
        getSentRequests: Idle(null),
    };

    public function reduce(state:APICallsState, action:APIActions):APICallsState {
        return switch(action) {
            case GetSelfProfile(apiState): Object.assign({}, state, {
                getSelfProfile: apiState
            });
            case GetProfiles(apiState):  Object.assign({}, state, {
                getProfiles: apiState
            });
            case GetFriends(apiState):  Object.assign({}, state, {
                getFriends: apiState
            });
            case GetIncomingRequests(apiState):  Object.assign({}, state, {
                getIncomingRequests: apiState
            });
            case GetSentRequests(apiState):  Object.assign({}, state, {
                getSentRequests: apiState
            });
        }
    }
}
