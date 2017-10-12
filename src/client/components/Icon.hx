package components;

import mithril.M;

class Icon implements Mithril {
    public static function view(vnode:Vnode<Icon>):Vnodes {
        var name:String = vnode.attrs.get('name');
        var spin:String =
            vnode.attrs.exists('spin')
                ? '.spin'
                : '';
        return
            m('span.icon',
                m('svg.fa.fa-${name}${spin}',
                    m('use[xlink:href=fa.svg#fa-${name}]')
                )
            );
    }
}