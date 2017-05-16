package views;

import react.React;
import react.ReactComponent;
import stores.Authenticate;

import views.logins.GoogleBtn;

class Login extends ReactComponent {
    public function new(props:Dynamic) {
        super(props);
    }

    override public function render():ReactElement {
        return
            React.createElement("div", { className: "row" },
                React.createElement("div", { className: "col s12 m6 offset-m3 l4 offset-l4" },
                    React.createElement("div", { className: "card-panel z-depth-4" },
                        React.createElement("div", { className: "row" },
                            React.createElement("div", { className: "col s12 center" },
                                React.createElement("div", { className: "row"},
                                    React.createElement("div", { className: "col s8 offset-s2"},
                                        React.createElement("img", { className: "responsive-img valign login-logo", src: "/logo.png" })
                                    )
                                ),
                                React.createElement("h4", { className: "center" }, "wysh"),
                                React.createElement("p", { className: "center" }, "You must log in before proceeding!")
                            ),
                            React.createElement("div", { className: "row" },
                                React.createElement("div", { className: "col s12 center"},
                                    React.createElement(GoogleBtn, { onClicked: loginGoogle })
                                )
                            )
                        )
                    )
                )
            );
    }

    private function loginGoogle():Void {
        Main.console.log("logging in with Google...");
        Authenticate.login(auth0.WebAuth.SocialConnection.Google);
    }

    private function loginFacebook():Void {
        Authenticate.login(auth0.WebAuth.SocialConnection.Facebook);
    }
}