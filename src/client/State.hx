enum APIState {
    Idle(lastUpdated:Date);
    Loading;
    Failed(error:js.Error);
}

typedef State = {
    var auth:AuthState;
    var profiles:ProfilesState;
}

typedef AuthState = {
    @:optional var token:String;
    @:optional var uid:String;
}

typedef ProfilesState = {
    @:optional var api:APIState;
}
