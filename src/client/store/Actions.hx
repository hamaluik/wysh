package store;

import js.Error;
import api.Profile;

enum AuthActions {
    Auth(token:String);
    SignOut;
}

enum ProfilesActions {
    StartLoading;
    Loaded(profiles:Array<Profile>);
    Failed(error:Error);
}
