import middleware.OfflineMiddleware;
import mithril.M;
import js.html.Console;
import redux.Redux;
import redux.Store;
import redux.StoreBuilder.*;
import Actions;
import State;
import stores.AuthReducer;
import stores.ProfilesReducer;
import stores.APIReducer;
import stores.AuthStore;

@:forward
abstract WyshStore(Store<State>) from Store<State> to Store<State> {
    public var state(get, never):State;
    inline private function get_state():State {
        return this.getState();
    }
}

class Client implements Mithril {
    public static var console:Console = js.Browser.console;
    public static var store:WyshStore;

    public static function main():Void {
        new Client();
    }

    public function new() {
        var appReducer = Redux.combineReducers({
            auth: mapReducer(AuthActions, new AuthReducer()),
            apiCalls: mapReducer(APIActions, new APIReducer()),
            profiles: mapReducer(ProfilesActions, new ProfilesReducer())
        });
        var rootReducer = function(state:State, action:Dynamic):State {
            if(action.type == 'OfflineActions.Load') {
                state = js.Object.assign(cast({}), state, {
                    profiles: action.value.profiles
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

        OfflineMiddleware.loadStateFromStorage()
        .then(function(state:State) {
            store.dispatch(new Action({
                type: 'OfflineActions.Load',
                value: state
            }));
        })
        .catchError(function(error) {
            console.warn('Failed to load offline state', error);
        });

        AuthStore.authWithStoredToken()
        .catchError(function(error) {
            console.warn('Failed to auth with stored token!', error);
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