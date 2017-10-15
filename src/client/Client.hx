import mithril.M;
import js.html.Console;
import redux.Redux;
import redux.Store;
import redux.StoreBuilder.*;
import store.AuthReducer;
import store.ProfilesReducer;
import store.Actions;
import store.State;
import store.factories.AuthFactory;
import store.factories.ProfilesFactory;

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
        var rootReducer = Redux.combineReducers({
            auth: mapReducer(AuthActions, new AuthReducer()),
            profiles: mapReducer(ProfilesActions, new ProfilesReducer())
        });
        store = createStore(rootReducer);

        AuthFactory.authWithStoredToken()
        .then(function(token:String) {
            ProfilesFactory.fetchProfile(store.state.auth.uid);
        })
        .catchError(function(_) {});

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