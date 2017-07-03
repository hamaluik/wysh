package views;

import mithril.M;

class Nav implements Mithril {
    public function new(){}
    public function view() [
        m("nav", { className: "nav has-shadow", id: "top" }, [
            m(".nav-left", [
                m("a.nav-item", [
                    m("img", { src: "http://bulma.io/images/bulma-logo.png", alt: "Logo" })
                ])
            ]),
            m("span.nav-toggle", [
                m("span"),
                m("span"),
                m("span")
            ]),
            m("div", { className: "nav-right nav-menu" }, [
                m("a.nav-item", "Home"),
                m("a.nav-item", "Documentation"),
                m("a.nav-item", "Blog")
            ])
        ])
    ];
}