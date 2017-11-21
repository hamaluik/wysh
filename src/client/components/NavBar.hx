package components;

import mithril.M;
import stores.AuthStore;

class NavBar implements Mithril {
    var menuShowing:Bool = false;

    public static function view(vnode:Vnode<NavBar>):Vnodes {
        var notifications:Int = 0;

        var profileImage:Vnodes = switch(Store.state.apiCalls.getSelfProfile) {
            case Loading: m(Icon, { name: 'spinner-third', spin: true } );
            case Idle(_) | Failed(_): {
                var profile:api.Profile = Reflect.field(Store.state.profiles, Store.state.auth.uid);
                if(profile == null)
                    m(Icon, { name: 'user' });
                else [
                    m('img.is-1by1', { style: 'margin-right: 16px', src: profile.picture }),
                        m(BadgeSpan, {
                            classes: '.has-text-weight-bold',
                            badge: notifications > 0
                                ? Std.string(notifications)
                                : null
                        }, profile.name)
                    ];
            }
        }

        return
            m('nav.navbar.is-primary', [
                m('.container', [
                    m('.navbar-brand', [
                        m('a.navbar-item', { href: '#!/' },
                            m('img', { src: 'res/wordmark_inverted.svg', width: 138, height: 28, alt: 'wysh' })
                        ),
                        m('.navbar-burger' + (vnode.state.menuShowing ? '.is-active' : ''), {
                            onclick: function() {
                                vnode.state.menuShowing = !vnode.state.menuShowing;
                            }
                        }, [
                            m('span'),m('span'),m('span')
                        ])
                    ]),
                    m('.navbar-menu' + (vnode.state.menuShowing ? '.is-active' : ''), [
                        m('.navbar-start', [
                            m('a.navbar-item', { href: '#!/lists/friends', onclick: function() { vnode.state.menuShowing = false; } }, [m(Icon, { name: 'list' }), m('span', 'Lists')]),
                        ]),
                        m('.navbar-end', [
                            m('.navbar-item.has-dropdown.is-hoverable', [
                                m('a.navbar-link', profileImage),
                                m('.navbar-dropdown', [
                                    m('a.navbar-item', { onclick: signout }, 'Sign Out')
                                ])
                            ])
                        ])
                    ])
                ])
            ]);
    }

    static function signout() {
        AuthStore.signOut();
        M.routeSet('/');
    }
}