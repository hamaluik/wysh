package views;

import react.React;
import react.ReactComponent;
import stores.Authenticate;
import stores.UserProfile;
import react.ReactMacro.jsx;

typedef NavBarState = {
    var avatarURL:Null<String>;
};

class NavBar extends ReactComponentOfState<NavBarState> {
    public function new(props:Dynamic) {
        super(props);
        state = {
            avatarURL: null
        };
    }

    private function update():Void {
        setState({
            avatarURL: UserProfile.profile != null ? UserProfile.profile.picture : null
        });
    }

    override public function componentWillMount():Void {
        UserProfile.changed.listen(update);
    }

    private function upgradeComponent():Void {
        var e:js.html.Element = react.ReactDOM.findDOMNode(this);
        upgrade(e);
    }

    private function upgrade(e:js.html.Element):Void {
        if(e == null) return;
        try {
            untyped componentHandler.upgradeElement(e);
        }
        catch(e:Dynamic) {}
        for(c in e.children) {
            upgrade(c);
        }
    }

    override public function componentDidMount() {
        upgradeComponent();
        untyped $(".button-collapse").sideNav({
            draggable: true
        });
    }

    override function componentDidUpdate(prevProps:Dynamic, prevState:NavBarState):Void {
        upgradeComponent();
    }

    override public function componentWillUnmount():Void {
        UserProfile.changed.unlisten(update);
        untyped $(".button-collapse").sideNav('hide');
    }

    public override function render():ReactElement {
        return
            React.createElement("nav", { className: "z-depth-3" },
                React.createElement("div", { className: "nav-wrapper container"},
                    React.createElement("a", { href: "#", className: "brand-logo" }, "wysh"),
                    jsx('<a className="button-collapse" data-activates="main-side-nav"><i className="material-icons">menu</i></a>'),
                    React.createElement("ul", { className: "right hide-on-med-and-down" },
                        React.createElement("li", {},
                            React.createElement("a", { href: "#", onClick: logout },
                                React.createElement("i", { className: "material-icons left" }, "exit_to_app"),
                                "Log Out"
                            )
                        )
                    ),
                    React.createElement("ul", { className: "side-nav", id: "main-side-nav" },
                        React.createElement("li", {},
                            React.createElement("a", { href: "#", onClick: logout },
                                React.createElement("i", { className: "material-icons left" }, "exit_to_app"),
                                "Log Out"
                            )
                        )
                    )
                )
            );
    }

    private function renderAvatar():Array<ReactElement> {
        if(state.avatarURL != null) {
            return [
                React.createElement("li", {},
                    React.createElement("a", {},
                        React.createElement("img", { className: "circle navbar-avatar", src: state.avatarURL })
                    )
                )
            ];
        }
        return [];
    }

    private function logout():Void {
        Authenticate.logout();
    }
}