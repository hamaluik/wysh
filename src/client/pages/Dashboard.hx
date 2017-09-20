package pages;

import mithril.M;

class Dashboard implements Mithril {
    public function new(){}

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        return null;
    }

    public function render(vnode) {
        return m('p', 'Logged in, this is your dashboard!');
    }
}