import js.html.Console;
import mithril.M;

class Root implements Mithril {
    public function new(){}


    public function onmatch(params : haxe.DynamicAccess<String>, url : String) {
        if(!Main.authenticated) {
            M.routeSet('/login');
        }
        else {
            M.routeSet('/dashboard');
        }

        return null;
    }

    public function view() [
        m("main", "root")
    ];
}

class Main {
    public static var console:Console;
    public static var authenticated:Bool = false;

    public static function main():Void {
        M.route(js.Browser.document.body, '/', {
            '/': new Root(),
            '/login': new views.Login(),
            '/dashboard': new views.Dashboard()
        });
    }
}