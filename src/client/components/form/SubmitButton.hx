package components.form;

import mithril.M;

class SubmitButton implements Mithril {
    public static function view(vnode) {
        var onclick:Void->Void = vnode.attrs.get('onclick');
        if(onclick == null) onclick = function(){};

        var isHorizontal:Bool = vnode.attrs.exists('horizontal') && cast(vnode.attrs.get('horizontal'), Bool);
        var body:Vnodes = 
            m(".field", [
                m("p.control", [
                    m("button.button.is-primary" + (vnode.attrs.get('loading') ? '.is-loading' : ''), {
                        type: "submit",
                        disabled: vnode.attrs.get('disabled')
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