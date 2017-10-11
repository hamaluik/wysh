package pages;

import mithril.M;
import components.ListSelector;

class FriendLists implements Mithril {
    public function new() {}

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.auth.token.value == null) M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
                    m('.columns', [
                        m(ListSelector, { type: Friends }),
                        m('.column', [
                            m('p', 'Your friends don\'t have any lists!')
                        ]),
                    ])
                ])
            )
        ];
    }
}