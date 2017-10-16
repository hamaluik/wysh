package stores;

import js.Object;
import Actions;
import State;
import redux.IReducer;

class ProfilesReducer implements IReducer<ProfilesActions, ProfilesState> {
    public function new(){}
    
    public var initState:ProfilesState = {};

    public function reduce(state:ProfilesState, action:ProfilesActions):ProfilesState {
        return switch(action) {
            case Set(profiles): {
                var newState:State.ProfilesState = {};
                for(profile in profiles) {
                    Reflect.setField(newState, profile.id, profile);
                }

                Object.assign({}, state, newState);
            };
        }
    }
}
