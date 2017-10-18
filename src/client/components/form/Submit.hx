package components.form;

import mithril.M;

class Submit implements Mithril {
    public static function view(vnode) {
        var onclick:Void->Void = vnode.attrs.get('onclick');

        var isHorizontal:Bool = vnode.attrs.exists('horizontal') && cast(vnode.attrs.get('horizontal'), Bool);
        var body:Vnodes = 
            m(".field.is-grouped.is-grouped-right", [
                m("p.control", [
                    m("button.button.is-primary" + (vnode.attrs.get('loading') ? '.is-loading' : ''), {
                        type: "submit",
                        disabled: vnode.attrs.get('disabled'),
                        onclick: function() {
                            if(onclick != null) onclick();
                        }
                    }, vnode.children)
                ])
            ]);

        return
            if(isHorizontal) {
                m(".field.is-horizontal", [
                    m(".field-label"),
                    m(".field-body", body)
                ]);
            }
            else body;
    }
}