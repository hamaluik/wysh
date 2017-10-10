package pages;

import mithril.M;

class MyLists implements Mithril {
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
                                    m('a', { href: '#!/lists/friends' }, 'Friends'),
                                    m('a.is-active', { href: '#!/lists/self' }, 'Yours'),
                                ]),
                                m('a.panel-block', 'Christmas List'),
                                m('a.panel-block', 'Birthday List'),
                            ])
                        ),
                        m('.column', [
                            m('p', 'You don\'t have any lists!')
                        ]),
                    ])
                ])
            )
        ];
    }
}