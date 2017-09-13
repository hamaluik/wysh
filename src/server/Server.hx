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
    public static var hids:Hashids;

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
        var config:Dynamic = Yaml.read("config.yaml", Parser.options().useObjects());

        // prepare the Hashids
        hids = new Hashids(config.hid.salt, 6, "abcdefghijklmnopqrstuvwxyz012345679");

        // prepare the database
        Log.info('initializing database');
        Manager.initialize();
        var c:Connection = Sqlite.open("wysh.db");
        Manager.cnx = c;

        // create tables!
        ensureTablesExist();

        var container = new TcpContainer(8080);
        var router = new Router<Root>(new Root());
        Log.info('listening on port 8080!');
        container.run(function(req) {
            return router.route(Context.authed(req, Session.new)).recover(OutgoingResponse.reportError);
        });
    }
}
