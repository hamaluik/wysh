package components;

import mithril.M;

class NavBar implements Mithril {
    var menuShowing:Bool = false;

    public static function view(vnode:Vnode<NavBar>):Vnodes {
        var profileImage:Vnodes = switch(AppState.profile.profile.value) {
            case Loading: m('span.icon', m('i.fa.fa-home'));
            case Done(profile): [m('img.is-1by1', { style: 'margin-right: 16px', src: profile.picture }), m('span.has-text-weight-bold', profile.name)];
            case Failed(error): null;
        }

        var friendRequests:Vnodes = switch(AppState.friends.friendRequestsUpdate.value) {
            case Loading: [m('span.navbar-item.icon', m('i.fa.fa-spinner.fa-pulse.fa-3x')), m('hr.navbar-divider')];
            case Done(updated): {
                var count:Int = Lambda.count(AppState.friends.friendRequests);
                [
                    m('span.navbar-item', count == 0 ? 'No friend requests' : 'You have ${count} friend request${count == 1 ? '' : 's'}!'),
                    m('hr.navbar-divider')
                ];
            }
            case Failed(error): null;
        }

        return
            m('nav.navbar.is-dark', [
                m('.container', [
                    m('.navbar-brand', [
                        m('a.navbar-item', { href: '#!/' },
                            m('img', { src: 'res/wordmark_inverted.svg', width: 138, height: 28, alt: 'wysh' })
                        ),
                        m('button.button.navbar-burger' + (vnode.state.menuShowing ? '.is-active' : ''), {
                            onclick: function() {
                                vnode.state.menuShowing = !vnode.state.menuShowing;
                            }
                        }, [
                            m('span'),m('span'),m('span')
                        ])
                    ]),
                    m('.navbar-menu' + (vnode.state.menuShowing ? '.is-active' : ''), [
                        m('.navbar-start', [
                            m('a.navbar-item', { href: '#!/lists' }, [m('span.icon', m('i.fa.fa-list')), 'Lists']),
                            m('a.navbar-item', { href: '#!/friends' }, [m('span.icon', m('i.fa.fa-users')), 'Friends'])
                        ]),
                        m('.navbar-end', [
                            m('.navbar-item.has-dropdown.is-hoverable', [
                                m('a.navbar-link', profileImage),
                                m('.navbar-dropdown', [
                                    friendRequests,
                                    m('a.navbar-item', { onclick: signout }, 'Sign Out')
                                ])
                            ])
                        ])
                    ])
                ])
            ]);
    }

    static function signout() {
        AppState.auth.clearStoredToken();
        M.routeSet('/');
    }
}