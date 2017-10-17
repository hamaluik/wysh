package selectors;

import State;
import api.List;
import api.Item;
import haxe.ds.StringMap;

class ItemSelectors {
    public static var listItemsSelector = function(s:RootState):ListItemsState { return s.relations.listItems; };
    public static var itemsSelector = function(s:RootState):ItemsState { return s.items; }

    private static var cachedItemsSelectors:StringMap<RootState->Array<Item>> = new StringMap<RootState->Array<Item>>();
    public static function getItemsSelector(listid:String):RootState->Array<Item> {
        if(!cachedItemsSelectors.exists(listid)) {
            cachedItemsSelectors.set(listid,
                Selectors.create2(listItemsSelector, itemsSelector, function(listItems:ListItemsState, items:ItemsState):Array<Item> {
                    var itemIDs:Array<String> = Reflect.field(listItems, listid);
                    if(itemIDs == null) itemIDs = [];
                    var ret:Array<Item> = [];
                    for(id in itemIDs) {
                        if(Reflect.hasField(items, id)) ret.push(Reflect.field(items, id));
                    }
                    return ret;
                }
            ));
        }
        return cachedItemsSelectors.get(listid);
    }
}