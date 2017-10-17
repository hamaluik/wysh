import stores.FriendsStore;
import stores.ProfilesStore;
import js.Promise;
import middleware.OfflineMiddleware;
import mithril.M;
import js.html.Console;
import redux.Redux;
import redux.Store;
import redux.StoreBuilder.*;
import Actions;
import State;
import stores.APIReducer;
import stores.AuthStore;
import stores.AuthReducer;
import stores.ProfilesReducer;
import stores.FriendsReducer;
import stores.ListsReducer;
import stores.ItemsReducer;
import stores.ListsStore;
import stores.RelationsReducer;

@:forward
abstract WyshStore(Store<RootState>) from Store<RootState> to Store<RootState> {
    public var state(get, never):RootState;
    inline private function get_state():RootState {
        return this.getState();
    }
}

class Client implements Mithril {
    public static var console:Console = js.Browser.console;
    @:allow(Store)
    private static var store:WyshStore;

    public static function main():Void {
        new Client();
    }

    public static function initialLoad():Promise<Dynamic> {
        return Promise.all([
            ProfilesStore.fetchProfile(store.state.auth.uid),
            FriendsStore.fetchFriends(),
            FriendsStore.fetchIncomingFriendRequests(),
            FriendsStore.fetchSentFriendRequests(),
            ListsStore.fetchLists(store.state.auth.uid)
        ]);
    }

    public function new() {
        OfflineMiddleware.paused = true;

        var appReducer = Redux.combineReducers({
            auth: mapReducer(AuthActions, new AuthReducer()),
            apiCalls: mapReducer(APIActions, new APIReducer()),
            profiles: mapReducer(ProfilesActions, new ProfilesReducer()),
            friends: mapReducer(FriendsActions, new FriendsReducer()),
            lists: mapReducer(ListsActions, new ListsReducer()),
            items: mapReducer(ItemsActions, new ItemsReducer()),
            relations: mapReducer(RelationsActions, new RelationsReducer())
        });
        var rootReducer = function(state:RootState, action:Dynamic):RootState {
            if(action.type == 'OfflineActions.Load') {
                var newState:RootState = js.Object.assign(cast({}), state, {
                    profiles: action.value.profiles,
                    friends: action.value.friends,
                    lists: action.value.lists,
                    items: action.value.items,
                    relations: action.value.relations
                });
                js.Browser.window.requestAnimationFrame(function(_):Void {
                    M.redraw();
                });
                return newState;
            }

            return appReducer(state, action);
        };
        store = createStore(
            rootReducer,
            null,
            Redux.applyMiddleware(
                OfflineMiddleware.createMiddleware()
            )
        );
        
        // if we have a stored token, use that
        // otherwise, go to the auth page
        AuthStore.authWithStoredToken()
        .then(function(_) {
            return initialLoad()
            .then(function(_) {
                OfflineMiddleware.paused = false;
                store.dispatch(OfflineActions.ForceSave);
            })
            .catchError(function(error) {
                console.warn('Server not available!');
                // load state from storage only if
                // our request for initial data fails to load
                OfflineMiddleware.loadStateFromStorage()
                .then(function(state:RootState) {
                    console.warn('Loaded state from offline storage, may be out of date!');
                    store.dispatch(new Action({
                        type: 'OfflineActions.Load',
                        value: state
                    }));
                    OfflineMiddleware.paused = false;
                })
                .catchError(function(error) {
                    console.error('Failed to load offline storage!', error);
                    OfflineMiddleware.paused = false;
                });
            });
        })
        .catchError(function(error) {
            console.warn('Failed to auth with stored token!', error);
            OfflineMiddleware.paused = false;
        });

        M.route(js.Browser.document.body, '/', {
            '/': this,
            '/login/:token': new pages.Login(),
            '/lists/friends': new pages.FriendLists(),
            '/lists/self': new pages.MyLists(),
            '/lists/new': new pages.NewList(),
            '/list/:listid': new pages.ViewList(),
            '/friends': new pages.Friends()
        });
    }

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        // if logged in, go to lists
        if(store.state.auth.token != null) M.routeSet('/lists/friends');
        return null;
    }

    public function render(vnode) {
        return
        m("section.hero.is-fullheight.is-medium.is-primary.is-bold",
            m(".hero-body",
                m(".container",
                    m(".columns.is-centered",
                        m("article.card",
                            m(".card-content", [
                                m("h1.title",
                                    m("figure.image.is-2by1", m("img", { src: "res/wordmark.svg" }))
                                ),
                                m("p.login-button", m(components.buttons.SignInGoogle, { uri: WebRequest.endpoint('/oauth2/login/google') })),
                                m("p.login-button", m(components.buttons.SignInFacebook, { uri: WebRequest.endpoint('/oauth2/login/facebook') })),
                            ])
                        )
                    )
                )
            )
        );
    }
}