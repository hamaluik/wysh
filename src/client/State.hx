enum APIState {
    Idle(lastUpdated:Date);
    Loading;
    Failed(error:js.Error);
}

typedef RootState = {
    var auth:AuthState;
    var apiCalls:APICallsState;

    var profiles:ProfilesState;
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

typedef ListsState = {
    
}

typedef ItemsState = {

}

typedef ProfileListsState = {

}

typedef ListItemsState = {

}
