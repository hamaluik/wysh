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
            '/dashboard': new pages.Dashboard()
        });

        AppState.auth.checkStoredToken();
    }

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        // if logged in, go to dashboard
        if(AppState.auth.token.value != null) M.routeSet('/dashboard');
        return null;
    }

    public function render(vnode) {
        // TODO: actual social media login buttons!
        return [
            m("section.section.login", [
                m(".container", [
                    m(".columns", [
                        m("div.column.is-half.is-offset-one-quarter.content.box", [
                            m("h1", "Log In"),
                            m("div", { className: "columns is-multiline" }, [
                                m("div", { className: "column is-full" }, [
                                    m("a.button", { href: "http://lvh.me:8080/api/oauth2/login/google" }, "Sign in with Google")
                                ]),
                                m("div", { className: "column is-full" }, [
                                    m("a.button", { href: "http://lvh.me:8080/api/oauth2/login/facebook" }, "Sign in with Facebook")
                                ])
                            ])
                        ])
                    ])
                ])
            ])
        ];
    }
}