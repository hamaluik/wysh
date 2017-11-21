import tink.http.Request.IncomingRequest;
import haxe.CallStack;
import haxe.CallStack.StackItem;
import tink.http.Handler;
import tink.http.Response;
import tink.web.routing.*;

import hashids.Hashids;

import sys.db.Manager;
import sys.db.Sqlite;
import sys.db.Connection;
import sys.db.TableCreate;

import models.User;
import models.List;
import models.Item;

import routes.Root;

class Server {
    public static var userHID:Hashids;
    public static var listHID:Hashids;
    public static var itemHID:Hashids;
    public static var uploadsHID:Hashids;
    public static var config:Config;

    public static function extractID(hash:String, hid:Hashids):Int {
        if(hash == null) throw 'Hash is missing!';
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
    }

    static function main() {
        // load the config
        var configFile:String = sys.io.File.getContent("config.json");
        config = haxe.Json.parse(configFile);
        Log.setLevel(config.log.level);

        // prepare the Hashids
        userHID = new Hashids(config.hid.salts.user, config.hid.minlength, config.hid.alphabet);
        listHID = new Hashids(config.hid.salts.list, config.hid.minlength, config.hid.alphabet);
        itemHID = new Hashids(config.hid.salts.item, config.hid.minlength, config.hid.alphabet);
        uploadsHID = new Hashids(config.hid.salts.uploads, 12, config.hid.alphabet);

        // prepare the database
        Log.info('initializing database');
        Manager.initialize();
        var c:Connection = Sqlite.open("wysh.db");
        Manager.cnx = c;

        // create tables!
        ensureTablesExist();

        var root:Root = new Root();
        var router = new Router<JWTSession, Root>(root);

        var handler:Handler = function(request:IncomingRequest) {
            try {
                return router.route(Context.authed(request, JWTSession.new)).recover(OutgoingResponse.reportError);
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
        if(config.enableCORS) handler = handler.applyMiddleware(new middleware.CORS());
        if(config.serveStatic) handler = handler.applyMiddleware(new middleware.Static('public', '/'));
        if(config.log.requests) handler = handler.applyMiddleware(new middleware.RequestLogger());

        #if php
        var container = tink.http.containers.PhpContainer.inst;
        #else
        var container = new tink.http.containers.TcpContainer(config.port);
        #end
        Log.info('listening on port ${config.port}!');
        container.run(handler);
    }
}
