package pages;

import mithril.M;
import components.ListSelector;

class OtherLists implements Mithril {
    public function new() {}

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.state.auth.token == null) M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
                    m('.columns', [
                        m(ListSelector, { type: Others }),
                        m('.column', [
                            m('p', '???')
                        ]),
                    ])
                ])
            )
        ];
    }
}