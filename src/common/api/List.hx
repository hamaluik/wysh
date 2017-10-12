package api;

import api.APIResponse;
import types.TList;
import types.TPrivacy;

@:allow(api.List)
class ListObject implements APIResponseObject {
    public var id:String;
    public var name:String;
    public var privacy:TPrivacy;

    private function new(list:TList) {
        this.id = list.id;
        this.name = list.name;
        this.privacy = list.privacy;
    }
}

@:forward
abstract List(ListObject) from ListObject to ListObject to APIResponse {
    public function new(list:TList)
        this = new ListObject(list);

    @:from
    public static inline function fromObj(list:TList):List
        return new List(list);

    @:to
    public inline function toObj():TList
        return {
            id: this.id,
            name: this.name,
            privacy: this.privacy
        };

#if sys
    @:from
    public static inline function fromDB(list:models.List):List
        return new List({
            id: Server.listHID.encode(list.id),
            name: list.name,
            privacy: cast(list.privacy)
        });
#end
}
