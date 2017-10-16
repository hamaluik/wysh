import State.APIState;
import js.Error;
import api.Profile;

enum OfflineActions {
    Load(state:State);
    Save;
}

enum AuthActions {
    Auth(token:String);
    SignOut;
}

enum APIActions {
    GetSelfProfile(state:APIState);
    GetProfiles(state:APIState);
    GetFriends(state:APIState);
    GetIncomingRequests(state:APIState);
    GetSentRequests(state:APIState);
}

enum ProfilesActions {
    Set(profiles:Array<Profile>);
}
