package components;

import mithril.M;

class BadgeSpan implements Mithril {
    public static function view(vnode:Vnode<BadgeSpan>):Vnodes {
        return m('span' + vnode.attrs.get('classes') + '.badge', vnode.children);
    }

    public static function oncreate(vnode:Vnode<BadgeSpan>):Void {
        if(vnode.attrs.exists('badge'))
            vnode.dom.dataset.badge = vnode.attrs.get('badge');
        else
            vnode.dom.dataset.badge = null;
    }
}