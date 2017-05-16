import react.ReactDOM;
import js.Browser;
import js.html.Console;
import views.App;

class Main {
    public static var serverRoot:String = "";
    public static var apiRoot:String = serverRoot + "/api";

    public static var console:Console = Browser.console;

    public static function main() {
        stores.Authenticate.initialize();
        ReactDOM.render(react.React.createElement(App, {}), Browser.document.body);
    }
}