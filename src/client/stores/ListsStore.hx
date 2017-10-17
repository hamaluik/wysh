package stores;

import types.TPrivacy;
import State.APIState;
import Actions;
import js.Promise;
import js.Error;
import api.List;
import api.Lists;

class ListsStore {
    public static function fetchLists(userid:String):Promise<Array<List>> {
        Client.store.dispatch(APIActions.GetLists(Loading));
        return WebRequest.request(GET, '/user/${userid}/lists', true)
        .then(function(lists:Lists):Promise<Array<List>> {
            Client.store.dispatch(APIActions.GetLists(Idle(Date.now())));
            Client.store.dispatch(ListsActions.Set(lists.lists));
            Client.store.dispatch(RelationsActions.RelateProfileLists(userid, lists.lists));
            return Promise.resolve(lists.lists);
        })
        .catchError(function(error:Error):Promise<Array<List>> {
            Client.console.error('Failed to request lists', error);
            Client.store.dispatch(APIActions.GetLists(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function createList(name:String, privacy:TPrivacy):Promise<List> {
        Client.store.dispatch(APIActions.CreateList(Loading));
        return WebRequest.request(POST, '/list', true, {
            name: name,
            privacy: privacy
        })
        .then(function(list:List):Promise<List> {
            Client.store.dispatch(APIActions.CreateList(Idle(Date.now())));
            Client.store.dispatch(ListsActions.Set([ list ]));
            Client.store.dispatch(RelationsActions.RelateProfileLists(Client.store.state.auth.uid, [ list ]));
            return Promise.resolve(list);
        })
        .catchError(function(error:Error):Promise<List> {
            Client.console.error('Failed to create list', error);
            Client.store.dispatch(APIActions.CreateList(Failed(error)));
            return Promise.reject(error);
        });
    }
}