package pages;

import mithril.M;

class Lists implements Mithril {
    public function new() {}

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(AppState.auth.token.value == null) M.routeSet('/');
        else {
            // TODO: move this somewhere better
            // fetch the profile if we don't have it yet
            switch(AppState.profile.profile.value) {
                case Failed(e): if(e == null) AppState.profile.fetchProfile();
                case _: {}
            }
        }

        return null;
    }

    public function render(vnode) {
        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
                    m('.columns', [
                        m('.column.is-two-thirds', [
                            m('article.media', [
                                m('span.icon.media-left', m('i.fa.fa-home')),
                                m('.media-content', 'This is a news item!')
                            ])
                        ]),
                        m('.column',
                            m('nav.panel', [
                                m('p.panel-heading', 'Wishlists'),
                                m('p.panel-tabs', [
                                    m('a.is-active', 'Yours'),
                                    m('a', 'Friends')
                                ]),
                                m('a.panel-block', 'birthday list'),
                                m('a.panel-block', 'Christmas list')
                            ])
                        )
                    ])
                ])
            )
        ];
    }
}