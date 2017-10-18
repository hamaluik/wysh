package stores;

import js.Object;
import Actions;
import State;
import redux.IReducer;

class ListItemsReducer implements IReducer<ListItemsActions, ListItemsState> {
    public function new(){}
    
    public var initState:ListItemsState = {};

    public function reduce(state:ListItemsState, action:ListItemsActions):ListItemsState {
        return switch(action) {
            case Relate(listid, items): {
                var existingItems:Array<String> = Reflect.field(state, listid);
                if(existingItems == null) existingItems = [];
                var newItems = existingItems.concat([for(item in items) item.id].filter(function(id:String):Bool {
                    return existingItems.indexOf(id) == -1;
                }));

                var newState = {};
                Reflect.setField(newState, listid, newItems);
                Object.assign(cast({}), state, newState);
            }

            case DeleteList(listid): {
                var newState = Object.assign(cast({}), state);
                if(Reflect.hasField(newState, listid)) {
                    Reflect.deleteField(newState, listid);
                }
                newState;
            }

            case DeleteItem(itemid): {
                var newState = Object.assign(cast({}), state);
                var listIDs:Array<String> = Reflect.fields(newState);
                for(listid in listIDs) {
                    var items:Array<String> = Reflect.field(newState, listid);
                    if(items == null) items = [];
                    var newItems:Array<String> = items.filter(function(lid) {
                        return lid != listid;
                    });
                    Reflect.setField(newState, itemid, newItems);
                }
                newState;
            }
        }
    }
}
