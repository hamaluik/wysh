package stores;

import js.Object;
import Actions;
import State;
import redux.IReducer;
//using Lambda;

class RelationsReducer implements IReducer<RelationsActions, RelationsState> {
    public function new(){}
    
    public var initState:RelationsState = {
        profileLists: {},
        listItems: {}
    };

    public function reduce(state:RelationsState, action:RelationsActions):RelationsState {
        return switch(action) {
            case RelateProfileLists(ownerid, lists): {
                var existingLists:Array<String> = Reflect.field(state.profileLists, ownerid);
                if(existingLists == null) existingLists = [];
                var newLists = existingLists.concat([for(list in lists) list.id].filter(function(id:String):Bool {
                    return existingLists.indexOf(id) == -1;
                }));

                var newRelation = {};
                Reflect.setField(newRelation, ownerid, newLists);

                var newProfileLists:ProfileListsState = Object.assign(cast({}), state.profileLists, newRelation);
                Object.assign(cast({}), state, {
                    profileLists: newProfileLists
                });
            }
            case RelateListItems(listid, items): {
                var existingItems:Array<String> = Reflect.field(state.listItems, listid);
                if(existingItems == null) existingItems = [];
                var newItems = existingItems.concat([for(item in items) item.id].filter(function(id:String):Bool {
                    return existingItems.indexOf(id) == -1;
                }));

                var newRelation = {};
                Reflect.setField(newRelation, listid, newItems);

                var newListItems:ListItemsState = Object.assign(cast({}), state.listItems, newRelation);
                Object.assign(cast({}), state, {
                    listItems: newListItems
                });
            }
        }
    }
}
