enum APIState {
    Idle(lastUpdated:Date);
    Loading;
    Failed(error:js.Error);
}

typedef State = {
    var auth:AuthState;
    var apiCalls:APICallsState;

    var profiles:ProfilesState;
    var friends:FriendsState;
    var lists:ListsState;
    var items:ItemsState;
}

typedef AuthState = {
    @:optional var token:String;
    @:optional var uid:String;
}

typedef APICallsState = {
    @:optional var getSelfProfile:APIState;

    @:optional var getProfiles:APIState;

    @:optional var getFriends:APIState;
    @:optional var getIncomingRequests:APIState;
    @:optional var getSentRequests:APIState;
}

typedef ProfilesState = {

}

typedef FriendsState = {
    @:optional var friends:Dynamic;
    @:optional var incomingRequests:Dynamic;
    @:optional var sentRequests:Dynamic;
}

typedef ListsState = {
    
}

typedef ItemsState = {

}
