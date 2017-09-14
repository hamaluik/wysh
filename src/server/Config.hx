package;

typedef Config = {
    public var oauth2:{
        public var redirecturi:String;
        public var clientid:String;
    };

    public var hid:{
        public var listsalt:String;
        public var itemsalt:String;
    };

    public var jwt:{
        public var secret:String;
    };
};
