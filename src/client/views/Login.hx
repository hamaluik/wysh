package views;

import mithril.M;

class Login implements Mithril {
    public function new(){}
    public function view() [
        m("form", [
            m("button[type=button]", {
                onclick: function() {
                    Main.authenticated = true;
                    M.routeSet('/');
                }
            }, "Login")
        ])
    ];
}