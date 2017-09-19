package;

typedef Config = {
    public var siteroot:String;

    public var oauth2:{
        public var google:{
            public var id:String;
            public var secret:String;
        };
        public var facebook:{
            public var id:String;
            public var secret:String;
        };
    };

    public var hid:{
        public var minlength:Int;
        public var alphabet:String;
        public var salts:{
            public var list:String;
            public var item:String;
        }
    };

    public var jwt:{
        public var secret:String;
    };
};
