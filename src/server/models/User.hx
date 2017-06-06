package models;

import sys.db.Object;
import sys.db.Types;

class User extends Object {
    public var id:SId;
    public var name:SString<255>;
    public var email:SString<255>;
}