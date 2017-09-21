package pages;

import mithril.M;

class Dashboard implements Mithril {
    public function new() {}

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Data.token.value == null) M.routeSet('/');
        else {
            // fetch the profile if we don't have it yet
            switch(Data.profile.value) {
                case Failed(e): if(e == null) Data.fetchProfile();
                case _: {}
            }
        }

        return null;
    }

    public function render(vnode) {
        return m('p', switch(Data.profile.value) {
            case Loading: 'Loading profile...';
            case Done(p): 'Welcome to your dashboard, ${p.name}!';
            case Failed(e): 'We could not load your profile :(';
        });
    }
}