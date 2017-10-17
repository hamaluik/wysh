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

@:forward
abstract WyshStore(Store<RootState>) from Store<RootState> to Store<RootState> {
    public var state(get, never):RootState;
    inline private function get_state():RootState {
        return this.getState();
    }
}

class Client implements Mithril {
    public static var console:Console = js.Browser.console;
    public static var store:WyshStore;

    public static function main():Void {
        new Client();
    }

    public static function initialLoad():Promise<Dynamic> {
        return Promise.all([
            ProfilesStore.fetchProfile(store.state.auth.uid),
            FriendsStore.fetchFriends(),
            FriendsStore.fetchIncomingFriendRequests(),
            FriendsStore.fetchSentFriendRequests()
        ]);
    }

    public function new() {
        var appReducer = Redux.combineReducers({
            auth: mapReducer(AuthActions, new AuthReducer()),
            apiCalls: mapReducer(APIActions, new APIReducer()),
            profiles: mapReducer(ProfilesActions, new ProfilesReducer()),
            friends: mapReducer(FriendsActions, new FriendsReducer()),
            lists: mapReducer(ListsActions, new ListsReducer()),
            items: mapReducer(ItemsActions, new ItemsReducer())
        });
        var rootReducer = function(state:RootState, action:Dynamic):RootState {
            if(action.type == 'OfflineActions.Load') {
                state = js.Object.assign(cast({}), state, {
                    profiles: action.value.profiles,
                    friends: action.value.friends,
                    lists: action.value.lists,
                    items: action.value.items
                });
                js.Browser.window.requestAnimationFrame(function(_):Void {
                    M.redraw();
                });
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

        // TODO: load state from storage only if
        // our request for initial data fails to load
        /*OfflineMiddleware.loadStateFromStorage()
        .then(function(state:RootState) {
            store.dispatch(new Action({
                type: 'OfflineActions.Load',
                value: state
            }));
        })
        .catchError(function(error) {
            console.warn('Failed to load offline state', error);
        });*/

        // TODO: this is getting called even when we're on the /login/:token
        // page, which messes things up!
        AuthStore.authWithStoredToken()
        .then(function(_) {
            return initialLoad();
        })
        .catchError(function(error) {
            console.warn('Failed to auth with stored token!', error);

            // load state from storage only if
            // our request for initial data fails to load
            OfflineMiddleware.loadStateFromStorage()
            .then(function(state:RootState) {
                store.dispatch(new Action({
                    type: 'OfflineActions.Load',
                    value: state
                }));
            })
            .catchError(function(error) {
                console.error('Failed to load offline state', error);
            });
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