package views;

import react.React;
import react.ReactComponent;
import stores.Authenticate;

class Auth0Lock extends ReactComponent {
    public function new(props:Dynamic) {
        super(props);
    }
    
    override public function componentDidMount():Void {
        Authenticate.lock.show();
    }

    override public function componentWillUnmount():Void {
        Authenticate.lock.hide();
    }

    override public function render():ReactElement {
        return React.createElement("div", {
            id: Authenticate.lockContainerID,
            className: "card-panel z-depth-4 login-card"
        });
    }
}