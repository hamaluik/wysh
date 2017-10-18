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

        searchFriends: Idle(null),
        getFriends: Idle(null),
        getIncomingRequests: Idle(null),
        getSentRequests: Idle(null),
        requestFriend: Idle(null),
        acceptFriendRequest: Idle(null),

        getLists: Idle(null),
        createList: Idle(null),
        editList: Idle(null),
        deleteList: Idle(null),

        getItems: Idle(null),
        createItem: Idle(null),
        editItem: Idle(null),
        deleteItem: Idle(null)
    };

    public function reduce(state:APICallsState, action:APIActions):APICallsState {
        return switch(action) {
            case GetSelfProfile(apiState): Object.assign(cast({}), state, {
                getSelfProfile: apiState
            });
            case GetProfiles(apiState): Object.assign(cast({}), state, {
                getProfiles: apiState
            });

            case SearchFriends(apiState): Object.assign(cast({}), state, {
                searchFriends: apiState
            });
            case GetFriends(apiState): Object.assign(cast({}), state, {
                getFriends: apiState
            });
            case GetIncomingRequests(apiState): Object.assign(cast({}), state, {
                getIncomingRequests: apiState
            });
            case GetSentRequests(apiState): Object.assign(cast({}), state, {
                getSentRequests: apiState
            });
            case RequestFriend(apiState): Object.assign(cast({}), state, {
                requestFriend: apiState
            });
            case AcceptFriendRequest(apiState): Object.assign(cast({}), state, {
                acceptFriendRequest: apiState
            });

            case GetLists(apiState): Object.assign(cast({}), state, {
                getLists: apiState
            });
            case CreateList(apiState): Object.assign(cast({}), state, {
                createList: apiState
            });
            case EditList(apiState): Object.assign(cast({}), state, {
                editList: apiState
            });
            case DeleteList(apiState): Object.assign(cast({}), state, {
                deleteList: apiState
            });

            case GetItems(apiState): Object.assign(cast({}), state, {
                getItems: apiState
            });
            case CreateItem(apiState): Object.assign(cast({}), state, {
                createItem: apiState
            });
            case EditItem(apiState): Object.assign(cast({}), state, {
                editItem: apiState
            });
            case DeleteItem(apiState): Object.assign(cast({}), state, {
                deleteItem: apiState
            });
        }
    }
}
