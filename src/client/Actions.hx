import State.APIState;
import api.Profile;
import api.List;
import api.Item;

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

enum ListsActions {
    Set(lists:Array<List>);
}

enum ItemsActions {
    Set(items:Array<Item>);
}
