package components;

import mithril.M;

class NavBar implements Mithril {
    var menuShowing:Bool = false;

    public static function view(vnode:Vnode<NavBar>):Vnodes {
        var welcome:Vnodes = switch(AppState.profile.profile.value) {
            case Loading: null;
            case Done(profile): m('span.navbar-item', 'Welcome, ${profile.name}!');
            case Failed(error): null;
        }

        return
        m('.container',
            m('nav.navbar', { role: 'navigation' }, [
                m('.navbar-brand', [
                    m('a.navbar-item', { href: '/' },
                        m('img', { src: 'res/wordmark.svg', width: 138, height: 28, alt: 'wysh' })
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
                    m('.navbar-start'),
                    m('.navbar-end', [
                        welcome,
                        m('a.navbar-item', { onclick: logout }, 'Sign Out')
                    ])
                ])
            ])
        );
    }

    static function logout() {
        AppState.auth.clearStoredToken();
        M.routeSet('/');
    }
}