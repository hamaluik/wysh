import js.html.Console;
import mithril.M;

class Example implements Mithril {
    public function new(){}

    public function view() [
        m("main", [
            m("h1", { className: "title" }, "My first app"),
            m("button", {
                onclick: function() { Main.clicks++; }
            }, '${Main.clicks} clicks')
        ])
    ];
}

class Main {
    public static var console:Console;
    public static var clicks:Int = 0;

    public static function main():Void {
        M.mount(js.Browser.document.body, new Example());
    }
}