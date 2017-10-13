import mithril.M;
import js.html.Console;
import redux.Redux;
import redux.Store;
import redux.IMiddleware;
import redux.IReducer;
import redux.StoreBuilder.*;

typedef State = {
    var auth:AuthState;
    var profile:ProfileState;
}

typedef AuthState = {
    @:optional var token:String;
}

typedef ProfileState = {
    @:optional var uid:String;
    @:optional var name:String;
    @:optional var picture:String;
}

enum AuthActions {
    Auth(token:String);
    SignOut;
}

enum ProfileActions {
    Fetch;
}

class AuthReducer implements IReducer<AuthActions, AuthState> {
    public function new(){}
    
    public var initState:AuthState = {
        token: null
    };

    public function reduce(state:AuthState, action:AuthActions):AuthState {
        return switch(action) {
            case Auth(token): js.Object.assign({}, state, {
                token: token
            });
            case SignOut: js.Object.assign({}, state, {
                token: null
            });
        }
    }
}

class ProfileReducer implements IReducer<ProfileActions, ProfileState> {
    public function new(){}
    
    public var initState:ProfileState = {
        uid: null,
        name: null,
        picture: null,
    };

    public function reduce(state:ProfileState, action:ProfileActions):ProfileState {
        return switch(action) {
            case Fetch: js.Object.assign({
                uid: null,
                name: null,
                picture: null,
            }, state, {
                name: 'Kenton'
            });
        }
    }
}

class Client implements Mithril {
    public static var console:Console = js.Browser.console;
    public static var store:Store<State>;

    public static function main():Void {
        new Client();
    }

    public function new() {
        var rootReducer = Redux.combineReducers({
            auth: mapReducer(AuthActions, new AuthReducer()),
            profile: mapReducer(ProfileActions, new ProfileReducer())
        });
        store = createStore(rootReducer);

        console.log(store.getState());
        store.dispatch(AuthActions.Auth('my login token'));
        console.log(store.getState());
        store.dispatch(ProfileActions.Fetch);
        console.log(store.getState());
        store.dispatch(AuthActions.SignOut);
        console.log(store.getState());

        //Actions.auth.checkStoredToken();
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
        //if(Store.token.value != null) M.routeSet('/lists/friends');
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