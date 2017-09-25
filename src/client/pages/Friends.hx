package pages;

import mithril.M;

// TODO: rename to wishlists page
class Friends implements Mithril {
    public function new() {}

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(AppState.auth.token.value == null) M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
                    m('.columns', [
                        m('.column.is-full', [
                            m('p', 'Friends page!')
                        ])
                    ])
                ])
            )
        ];
    }
}