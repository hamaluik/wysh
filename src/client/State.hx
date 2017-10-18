enum APIState {
    Idle(lastUpdated:Date);
    Loading;
    Failed(error:js.Error);
}

typedef RootState = {
    var auth:AuthState;
    var apiCalls:APICallsState;

    var profiles:ProfilesState;
    var friends:FriendsState;
    var lists:ListsState;
    var items:ItemsState;

    var profileLists:ProfileListsState;
    var listItems:ListItemsState;
}

typedef AuthState = {
    var token:String;
    var uid:String;
}

typedef APICallsState = {
    var getSelfProfile:APIState;

    var getProfiles:APIState;

    var searchFriends:APIState;
    var getFriends:APIState;
    var getIncomingRequests:APIState;
    var getSentRequests:APIState;
    var requestFriend:APIState;
    var acceptFriendRequest:APIState;

    var getLists:APIState;
    var createList:APIState;
    var editList:APIState;
    var deleteList:APIState;

    var getItems:APIState;
    var createItem:APIState;
    var editItem:APIState;
    var deleteItem:APIState;
}

typedef ProfilesState = {

}

typedef FriendsState = {
    var searchResults:Array<String>;
    var friends:Array<String>;
    var incomingRequests:Array<String>;
    var sentRequests:Array<String>;
}

typedef ListsState = {
    
}

typedef ItemsState = {

}

typedef ProfileListsState = {

}

typedef ListItemsState = {

}
