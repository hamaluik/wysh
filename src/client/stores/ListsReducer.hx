package stores;

import js.Object;
import Actions;
import State;
import redux.IReducer;

class ListsReducer implements IReducer<ListsActions, ListsState> {
    public function new(){}
    
    public var initState:ListsState = {};

    public function reduce(state:ListsState, action:ListsActions):ListsState {
        return switch(action) {
            case Set(lists): {
                var newState:State.ListsState = {};
                for(list in lists) {
                    Reflect.setField(newState, list.id, list);
                }

                Object.assign(cast({}), state, newState);
            };

            case Delete(listid): {
                var newState = Object.assign(cast({}), state);
                if(Reflect.hasField(newState, listid)) {
                    Reflect.deleteField(newState, listid);
                }

                newState;
            }
        }
    }
}
