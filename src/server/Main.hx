import tink.http.containers.TcpContainer;
import sys.db.Manager;
import sys.db.Sqlite;
import sys.db.Connection;
import sys.db.TableCreate;

import models.User;
import models.Group;
import models.UserGroup;
import models.Invitation;

class Main {
    static function ensureTablesExist():Void {
        if(!TableCreate.exists(User.manager)) {
            Log.trace('creating user table');
            TableCreate.create(User.manager);
        }

        if(!TableCreate.exists(Group.manager)) {
            Log.trace('creating group table');
            TableCreate.create(Group.manager);
        }

        if(!TableCreate.exists(UserGroup.manager)) {
            Log.trace('creating usergroup table');
            TableCreate.create(UserGroup.manager);
        }

        if(!TableCreate.exists(Invitation.manager)) {
            Log.trace('creating invitation table');
            TableCreate.create(Invitation.manager);
        }
    }

    static function main() {
        // prepare the database
        Log.info('initializing database');
        Manager.initialize();
        var c:Connection = Sqlite.open("wysh.db");
        Manager.cnx = c;

        // create tables!
        ensureTablesExist();

        // spin up the server
        var container = new TcpContainer(8080);
        var router:Router = new Router('/api/v0');

        Log.info('listening on port 8080!');
        container.run(router.handle);
    }
}