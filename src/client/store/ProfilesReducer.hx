package store;

import js.Object;
import Actions;
import State;
import redux.IReducer;

class ProfilesReducer implements IReducer<ProfilesActions, ProfilesState> {
    public function new(){}
    
    public var initState:ProfilesState = {
        api: Loading
    };

    public function reduce(state:ProfilesState, action:ProfilesActions):ProfilesState {
        return switch(action) {
            case StartLoading: Object.assign({}, state, {
                api: Loading
            });

            case Loaded(profiles): {
                var newState:State.ProfilesState = {
                    api: Idle(Date.now())
                };
                for(profile in profiles) {
                    Reflect.setField(newState, profile.id, profile);
                }

                Object.assign({}, state, newState);
            };

            case Failed(error): Object.assign({}, state, {
                api: Failed(error)
            });
        }
    }
}
