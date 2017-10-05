package types;

typedef TItem = {
    var id:String;
    var name:String;

    var url:Null<String>;
    var comments:Null<String>;
    var image_path:Null<String>;

    var reservable:Bool;
    var reserver:Null<String>;
    var reservedOn:Null<Date>;
};