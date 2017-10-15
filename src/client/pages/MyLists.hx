package pages;

import mithril.M;
import components.ListSelector;

class MyLists implements Mithril {
    public function new() {}

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Client.store.state.auth.token == null) M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
                    m('.columns', [
                        m(ListSelector, { type: Self }),
                        m('.column', [
                            m('p', 'You don\'t have any lists!')
                        ]),
                    ])
                ])
            )
        ];
    }
}