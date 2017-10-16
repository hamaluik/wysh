package components;

import mithril.M;
import store.factories.AuthFactory;

class NavBar implements Mithril {
    var menuShowing:Bool = false;

    public static function view(vnode:Vnode<NavBar>):Vnodes {
        var notifications:Int = 0;
        notifications += 0;//Store.incomingFriendRequests.length;

        var profileImage:Vnodes = switch(Client.store.state.profiles.api) {
            case Loading: m(Icon, { name: 'spinner-third', spin: true } );
            case Idle(lastUpdated): {
                var profile:api.Profile = Reflect.field(Client.store.state.profiles, Client.store.state.auth.uid);
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
            case Failed(error): null;
        }

        var friendRequests:Vnodes = [
            /*switch(Store.incomingFriendRequests.length) {
                case 0: m('span.navbar-item', 'No friend requests');
                case count: m('a.navbar-item', { href: '#!/friends' }, 'You have ${count} friend request${count == 1 ? '' : 's'}!');
            },
            Store.incomingFriendRequests.state.value.match(Loading) ? m('span.navbar-item.has-text-centered', m(Icon, { name: 'spinner-third', spin: true })) : null,
            m('hr.navbar-divider')*/
        ];

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
                            m('a.navbar-item', { href: '#!/friends', onclick: function() { vnode.state.menuShowing = false; } }, [m(Icon, { name: 'users' }), m('span', 'Friends')]),
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
        AuthFactory.signOut();
        M.routeSet('/');
    }
}