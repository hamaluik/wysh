import types.TProfile;
import mithril.M;
import js.html.Console;

class Client implements Mithril {
    public static var console:Console = js.Browser.console;

    public static function main():Void {
        new Client();
    }

    public function new() {
        M.route(js.Browser.document.body, '/', {
            '/': this,
            '/login/:token': new pages.Login(),
            '/lists': new pages.Lists(),
            '/friends': new pages.Friends()
        });

        AppState.auth.token.observe().bind(function(token:String) {
            console.info('token', token);
        });

        // automatically fetch the profile when we log in
        AppState.auth.token.observe().bind(function(token:String) {
            if(token != null) {
                switch(AppState.profile.profile.value) {
                    case Failed(e): if(e == null) {
                        AppState.profile.fetchProfile()
                        .handle(function(noise) {
                            M.redraw();
                        });
                    }
                    case _: {}
                }
            }
            else AppState.profile.profile.set(Failed(null));
        });

        // automatically fetch friend requests when we log in
        AppState.auth.token.observe().bind(function(token:String) {
            if(token != null) {
                switch(AppState.friends.friendRequestsUpdate.value) {
                    case Failed(e): if(e == null) {
                        AppState.friends.fetchFriendRequests()
                        .handle(function(noise) {
                            M.redraw();
                        });
                    }

                    case _: {}
                }
            }
            else AppState.friends.friendRequestsUpdate.set(Failed(null));
        });

        AppState.auth.checkStoredToken();
    }

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        // if logged in, go to lists
        if(AppState.auth.token.value != null) M.routeSet('/lists');
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
                                m("p.login-button", m(components.buttons.SignInGoogle, { uri: "http://lvh.me:8080/api/oauth2/login/google" })),
                                m("p.login-button", m(components.buttons.SignInFacebook, { uri: "http://lvh.me:8080/api/oauth2/login/facebook" })),
                            ])
                        )
                    )
                )
            )
        );
    }
}