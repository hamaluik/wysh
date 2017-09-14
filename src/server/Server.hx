import haxe.CallStack;
import haxe.CallStack.StackItem;
import tink.http.Handler;
import tink.http.containers.TcpContainer;
import tink.http.Response;
import tink.web.routing.*;

import yaml.Yaml;
import yaml.Parser;

import hashids.Hashids;

import sys.db.Manager;
import sys.db.Sqlite;
import sys.db.Connection;
import sys.db.TableCreate;

import models.User;
import models.List;
import models.Item;
import models.Followers;

import routes.Root;

class Server {
    public static var listHID:Hashids;
    public static var itemHID:Hashids;
    public static var config:Config;

    public static function extractID(hash:String, hid:Hashids):Int {
        var ids:Array<Int> = hid.decode(hash.toLowerCase());
        if(ids.length != 1) throw 'Invalid list id: $hash!';
        return ids[0];
    }

    static function ensureTablesExist():Void {
        if(!TableCreate.exists(User.manager)) {
            Log.trace('creating User table');
            TableCreate.create(User.manager);
        }
        if(!TableCreate.exists(List.manager)) {
            Log.trace('creating List table');
            TableCreate.create(List.manager);
        }
        if(!TableCreate.exists(Item.manager)) {
            Log.trace('creating Item table');
            TableCreate.create(Item.manager);
        }
        if(!TableCreate.exists(Followers.manager)) {
            Log.trace('creating Followers table');
            TableCreate.create(Followers.manager);
        }
    }

    static function main() {
        // load the config
        config = Yaml.read("config.yaml", Parser.options().useObjects());

        // prepare the Hashids
        listHID = new Hashids(config.hid.listsalt, 6, "abcdefghijklmnopqrstuvwxyz012345679");
        itemHID = new Hashids(config.hid.itemsalt, 6, "abcdefghijklmnopqrstuvwxyz012345679");

        // prepare the database
        Log.info('initializing database');
        Manager.initialize();
        var c:Connection = Sqlite.open("wysh.db");
        Manager.cnx = c;

        // create tables!
        ensureTablesExist();

        var root:Root = new Root();
        var router = new Router<JWTSession, Root>(root);

        var handler:Handler = function(req) {
            try {
                return router.route(Context.authed(req, JWTSession.new)).recover(OutgoingResponse.reportError);
            }
            catch(e:Dynamic) {
                var stack:Array<StackItem> = CallStack.exceptionStack();
                Log.error('Unhandled exception: ' + Std.string(e));
                Log.error(CallStack.toString(stack));

                var ft:tink.core.Future.FutureTrigger<OutgoingResponse> = new tink.core.Future.FutureTrigger<OutgoingResponse>();
                ft.trigger(new OutgoingResponse(new ResponseHeader(500, 'Internal Error', null), ''));
                return ft.asFuture();
            }
        }

        var container = new TcpContainer(8080);
        Log.info('listening on port 8080!');
        container.run(handler);
    }
}
