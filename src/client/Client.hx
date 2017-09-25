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
            '/lists': new pages.Lists()
        });

        AppState.auth.token.observe().bind(function(token:String) {
            console.info('token', token);
        });

        AppState.auth.checkStoredToken();
    }

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        // if logged in, go to dashboard
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