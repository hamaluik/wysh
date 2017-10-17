package middleware;

import State;
import Actions;
import haxe.Timer;
import js.html.idb.ObjectStore;
import js.html.idb.TransactionMode;
import js.Promise;
import js.Browser;
import js.html.idb.Database;
import redux.StoreMethods;
import redux.Redux;

class OfflineMiddleware {
	public static var paused:Bool = true;

	private static var debounceTimer:Timer;
	private static var pendingSave:Null<Void->Void> = null;

	private static var _db:Promise<Database> = null;
	private static var db(get, never):Promise<Database>;
	private static function get_db():Promise<Database> {
		if(_db == null) {
			_db = new Promise<Database>(function(resolve:Database->Void, reject:Dynamic->Void) {
				var openreq = Browser.window.indexedDB.open('wysh', 1);
				openreq.onerror = function() { reject(openreq.error); }
				openreq.onupgradeneeded = function() { openreq.result.createObjectStore('state'); };
				openreq.onsuccess = function() { resolve(openreq.result); }
			});
		}
		return _db;
	}

	private static function withStore(mode:TransactionMode, cb:ObjectStore->Void):Promise<Any> {
		return db.then(function(db:Database) {
			return new Promise<Any>(function(resolve:Any->Void, reject:Dynamic->Void) {
				var transaction = db.transaction('state', mode);
				transaction.oncomplete = function() resolve(null);
				transaction.onerror = function() reject(transaction.error);
				cb(transaction.objectStore('state'));
			});
		});
	}

	private static function getFromStore(key:String):Promise<Dynamic> {
		var req;
		return withStore(TransactionMode.READONLY, function(store:ObjectStore) {
			req = store.get(key);
		})
		.then(function(_) {
			return Promise.resolve(req.result);
		});
	}

	private static function setInStore(key:String, value:Dynamic):Promise<Any> {
		return withStore(TransactionMode.READWRITE, function(store:ObjectStore) {
			store.put(value, key);
		});
	}

	/* not worrking.. :(
	public static function mergeState(oldState:Dynamic, updatedState:Dynamic, depth:Int=4):Dynamic {
		if(oldState == updatedState || depth == 0) return js.Object.assign({}, oldState);

		var newState:Dynamic =
			oldState != null
				? js.Object.assign({}, oldState)
				: {};
		
		for(fname in Reflect.fields(updatedState)) {
			Client.console.info('Merging ${fname} from', updatedState, 'into', oldState);
			var oldField:Dynamic = Reflect.field(oldState, fname);
			var updatedField:Dynamic = Reflect.field(updatedState, fname);
			if(Reflect.isObject(updatedField)) {
				Reflect.setField(newState, fname, mergeState(
					oldField,
					updatedField,
					depth - 1
				));
			}
			else {
				if(updatedField != null) {
					Reflect.setField(newState, fname, updatedField);
				}
			}
		}

		return newState;
	}*/

	public static function loadStateFromStorage<T>():Promise<T> {
		return getFromStore('root')
		.then(function(stateStr:String) {
			var state:T = haxe.Json.parse(stateStr);
			return Promise.resolve(state);
		});
	}

    public static function createMiddleware<T>() {
		debounceTimer = new Timer(2000);
		debounceTimer.run = function() {
			if(pendingSave != null) {
				pendingSave();
				pendingSave = null;
			}
		};

		return function(store:StoreMethods<T>) {
			return function (next:Dispatch):Dynamic {
				return function (action:Action):Dynamic {
					var result = next(action);

					// debounce
					if(action.type == 'OfflineActions.ForceSave' || (!StringTools.startsWith(action.type, 'OfflineActions.') && !paused)) {
						pendingSave = function():Void {
							// store it!
							var state:String = haxe.Json.stringify(store.getState());
							setInStore('root', state)
							.then(function(_) {
								store.dispatch(OfflineActions.Save);
							})
							.catchError(function(error) {
								Client.console.error('Error storing state for offline!', error);
							});
						};
					}

                    return result;
				}
			}
        }
    }
}