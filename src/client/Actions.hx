import State;
import api.Profile;
import api.List;
import api.Item;

enum OfflineActions {
    Load(state:RootState);
    Save;
    ForceSave;
}

enum AuthActions {
    Auth(token:String);
    SignOut;
}

enum APIActions {
    GetSelfProfile(state:APIState);
    GetProfiles(state:APIState);

    SearchFriends(state:APIState);
    GetFriends(state:APIState);
    GetIncomingRequests(state:APIState);
    GetSentRequests(state:APIState);
    RequestFriend(state:APIState);
    AcceptFriendRequest(state:APIState);

    GetLists(state:APIState);
    CreateList(state:APIState);
    EditList(state:APIState);
    DeleteList(state:APIState);

    GetItems(state:APIState);
}

enum ProfilesActions {
    Set(profiles:Array<Profile>);
}

enum FriendsActions {
    SetSearchResults(profiles:Array<Profile>);
    SetFriends(profiles:Array<Profile>);
    SetIncomingRequests(profiles:Array<Profile>);
    RemoveIncomingRequests(profiles:Array<Profile>);
    SetSentRequests(profiles:Array<Profile>);
}

enum ListsActions {
    Set(lists:Array<List>);
    Delete(listid:String);
}

enum ItemsActions {
    Set(items:Array<Item>);
    Delete(itemid:String);
}

enum ProfileListsActions {
    Relate(profileid:String, lists:Array<List>);
    DeleteProfile(profileid:String);
    DeleteList(listid:String);
}

enum ListItemsActions {
    Relate(listid:String, items:Array<Item>);
    DeleteList(listid:String);
    DeleteItem(itemid:String);
}
