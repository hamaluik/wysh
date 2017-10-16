package stores;

import js.Object;
import Actions;
import State;
import redux.IReducer;

class ItemsReducer implements IReducer<ItemsActions, ItemsState> {
    public function new(){}
    
    public var initState:ItemsState = {};

    public function reduce(state:ItemsState, action:ItemsActions):ItemsState {
        return switch(action) {
            case Set(items): {
                var newState:State.ItemsState = {};
                for(item in items) {
                    Reflect.setField(newState, item.id, item);
                }

                Object.assign({}, state, newState);
            };
        }
    }
}