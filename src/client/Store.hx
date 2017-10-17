import redux.Redux;
import js.Promise;
import Client;
import State;

class Store {
    /*public static var store(get, never):WyshStore;
    inline private static function get_store():WyshStore {
        return Client.store;
    }*/

    public static var state(get, never):RootState;
    inline private static function get_state():RootState {
        return Client.store.state;
    }

    public static var dispatch(get, never):Action->Promise<Dynamic>;
    inline private static function get_dispatch():Action->Promise<Dynamic> {
        return Client.store.dispatch;
    }

}