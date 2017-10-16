import js.Error;
import api.Profile;
import redux.Redux;
using haxe.EnumTools.EnumValueTools;

enum OfflineActions {
    Load(state:State);
    Save;
}

enum AuthActions {
    Auth(token:String);
    SignOut;
}

enum ProfilesActions {
    StartLoading;
    Loaded(profiles:Array<Profile>);
    Failed(error:Error);
}
