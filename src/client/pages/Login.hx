package pages;

import mithril.M;

class Login implements Mithril {
    public function new(){}

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        Data.token.set(params.get('token'));
        M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        return m('p', 'Logged in!');
    }
}