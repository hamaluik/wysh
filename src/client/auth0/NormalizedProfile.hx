package auth0;

typedef Identity = {
    var connection:String;
    var isSocial:Bool;
    var provider:String;
    var user_id:String;
};

typedef NormalizedProfile = {
    var name:String;
    var nickname:String;
    var picture:String;
    var user_id:String;

    @:optional var email:String;
    @:optional var email_verified:Bool;
    @:optional var given_name:String;
    @:optional var family_name:String;
    @:optional var locale:String;
    @:optional var gender:String;

    var identities:Array<Identity>;
    var user_metadata:Dynamic;
};