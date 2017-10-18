package stores;

import types.TPrivacy;
import State.APIState;
import Actions;
import js.Promise;
import js.Error;
import api.List;
import api.Lists;
import api.Message;

class ListsStore {
    public static function fetchLists(userid:String):Promise<Array<List>> {
        Store.dispatch(APIActions.GetLists(Loading));
        return WebRequest.request(GET, '/user/${userid}/lists', true)
        .then(function(lists:Lists):Promise<Array<List>> {
            Store.dispatch(APIActions.GetLists(Idle(Date.now())));
            Store.dispatch(ListsActions.Set(lists.lists));
            Store.dispatch(ProfileListsActions.Relate(userid, lists.lists));
            return Promise.resolve(lists.lists);
        })
        .catchError(function(error:Error):Promise<Array<List>> {
            Client.console.error('Failed to request lists', error);
            Store.dispatch(APIActions.GetLists(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function createList(name:String, privacy:TPrivacy):Promise<List> {
        Store.dispatch(APIActions.CreateList(Loading));
        return WebRequest.request(POST, '/list', true, {
            name: name,
            privacy: privacy
        })
        .then(function(list:List):Promise<List> {
            Store.dispatch(APIActions.CreateList(Idle(Date.now())));
            Store.dispatch(ListsActions.Set([ list ]));
            Store.dispatch(ProfileListsActions.Relate(Store.state.auth.uid, [ list ]));
            return Promise.resolve(list);
        })
        .catchError(function(error:Error):Promise<List> {
            Client.console.error('Failed to create list', error);
            Store.dispatch(APIActions.CreateList(Failed(error)));
            return Promise.reject(error);
        });
    }

    public static function deleteList(list:List):Promise<Message> {
        Store.dispatch(APIActions.DeleteList(Loading));
        return WebRequest.request(DELETE, '/list/${list.id}', true)
        .then(function(message:Message):Promise<Message> {
            Store.dispatch(APIActions.DeleteList(Idle(Date.now())));
            Store.dispatch(ListsActions.Delete(list.id));
            Store.dispatch(ProfileListsActions.DeleteList(list.id));
            Store.dispatch(ListItemsActions.DeleteList(list.id));
            return Promise.resolve(message);
        })
        .catchError(function(error:Error):Promise<Message> {
            Client.console.error('Failed to delete list', error);
            Store.dispatch(APIActions.DeleteList(Failed(error)));
            return Promise.reject(error);
        });
    }
}