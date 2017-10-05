package api;

import api.APIResponse;
import types.TList;

@:allow(api.List)
class ListObject implements APIResponseObject {
    public var id:String;
    public var name:String;

    private function new(list:TList) {
        this.id = list.id;
        this.name = list.name;
    }
}

abstract List(ListObject) to APIResponse {
    public function new(list:TList)
        this = new ListObject(list);

    @:from
    public static inline function fromObj(list:TList):List
        return new List(list);

    @:from
    public static inline function fromDB(list:models.List):List
        return new List({
            id: Server.listHID.encode(list.id),
            name: list.name,
        });
}
