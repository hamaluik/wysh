package pages;

import mithril.M;

class Dashboard implements Mithril {
    public function new() {}

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        Client.console.info('matched dashboard, token:', AppState.auth.token.value);
        if(AppState.auth.token.value == null) M.routeSet('/');
        else {
            // fetch the profile if we don't have it yet
            switch(AppState.profile.profile.value) {
                case Failed(e): if(e == null) AppState.profile.fetchProfile();
                case _: {}
            }
        }

        return null;
    }

    public function render(vnode) {
        return m('p', switch(AppState.profile.profile.value) {
            case Loading: 'Loading profile...';
            case Done(p): [
                'Welcome to your dashboard, ${p.name}!',
                m("button", { onclick: logout }, "Log Out")
            ];
            case Failed(e): 'We could not load your profile :(';
        });
    }

    function logout() {
        AppState.auth.clearStoredToken();
        M.routeSet('/');
    }
}