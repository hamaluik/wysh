package pages;

import mithril.M;

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
                        m('.column.is-one-third',
                            m('nav.panel', [
                                m('p.panel-heading', 'Wishlists'),
                                m('p.panel-tabs', [
                                    m('a.is-active', { href: '#!/lists/friends' }, 'Friends'),
                                    m('a', { href: '#!/lists/self' }, 'Yours'),
                                ]),
                                m('a.panel-block', [
                                    m('span.has-text-weight-bold', 'Dennie'),
                                    m('span[style="white-space:pre"]', ' / Christmas List')
                                ])
                            ])
                        ),
                        m('.column', [
                            m('p', 'Your friends don\'t have any lists!')
                        ]),
                    ])
                ])
            )
        ];
    }
}