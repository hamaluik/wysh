import tink.http.containers.TcpContainer;
import sys.db.Manager;
import sys.db.Sqlite;
import sys.db.Connection;
import sys.db.TableCreate;

import models.User;

class Main {
    static function main() {
        // prepare the database
        Log.info('initializing database');
        Manager.initialize();
        var c:Connection = Sqlite.open("wysh.db");
        Manager.cnx = c;

        // create tables!
        if(!TableCreate.exists(User.manager)) {
            Log.trace('creating user table');
            TableCreate.create(User.manager);
        }

        // spin up the server
        var container = new TcpContainer(8080);
        var router:Router = new Router('/api/v0');

        Log.info('listening on port 8080!');
        container.run(router.handle);
    }
}