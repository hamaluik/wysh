package views;

import stores.Authenticate;
import react.React;
import react.ReactComponent;

typedef AppState = {
    var authenticated:Bool;
}

class App extends ReactComponentOfState<AppState> {
    public function new(props:Dynamic) {
        super(props);
        state = {
            authenticated: Authenticate.authenticated
        }
    }

    private function update():Void {
        setState({
            authenticated: Authenticate.authenticated
        });
    }

    override public function componentWillMount():Void {
        Authenticate.changed.listen(update);
        updateBackground();
    }

    override public function componentWillUnmount():Void {
        Authenticate.changed.unlisten(update);
        updateBackground();
    }

    private function updateBackground():Void {
        if(!state.authenticated) {
            if(!js.Browser.document.body.classList.contains('cyan')) {
                js.Browser.document.body.classList.add('cyan');
            }
        }
        else {
            if(js.Browser.document.body.classList.contains('cyan')) {
                js.Browser.document.body.classList.remove('cyan');
            }
        }
    }

    override public function componentDidUpdate(prevProps:Dynamic, prevState:AppState):Void {
        updateBackground();
    }

    override public function render():ReactElement {
        return
            React.createElement("div", {},
                renderNav(),
                React.createElement("div", { className: "container" },
                    renderContents()
                )
            );
    }

    private function renderNav():Array<ReactElement> {
        var nav:Array<ReactElement> = new Array<ReactElement>();

        if(state.authenticated) {
            nav.push(React.createElement(NavBar));
        }

        return nav;
    }

    private function renderContents():Array<ReactElement> {
        var contents:Array<ReactElement> = new Array<ReactElement>();

        if(!state.authenticated) {
            contents.push(React.createElement(Auth0Lock));
        }
        else {
            contents.push(React.createElement("p", {}, "Logged in!"));
        }

        return contents;
    }
}