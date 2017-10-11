package components.form;

import tink.state.State;
import mithril.M;

class TextField implements Mithril {
    var value:String = null;

    public static function view(vnode:Vnode<TextField>):Vnodes {
        var store:State<String> = vnode.attrs.get('store');
        vnode.state.value = store.value;

        var options:Dynamic = {
            className: "input",
            type: vnode.attrs.exists('type') ? vnode.attrs.get('type') : 'text',
            placeholder: (vnode.attrs.exists('placeholder') && vnode.attrs.get('placeholder') != null) ? vnode.attrs.get('placeholder') : '',
            oninput: M.withAttr("value", function(value:String):Void {
                vnode.state.value = value;
                store.set(value);
            }),
            value: vnode.state.value,
            readonly: vnode.attrs.exists('readonly') && cast(vnode.attrs.get('readonly'), Bool),
            disabled: vnode.attrs.exists('disabled') && cast(vnode.attrs.get('disabled'), Bool)
        };

        if(options.type == 'number') {
            options.step = 'any';
        }

        var hasIcon:Bool = vnode.attrs.exists('icon');
        var isHorizontal:Bool = vnode.attrs.exists('horizontal') && cast(vnode.attrs.get('horizontal'), Bool);

        var label:Vnodes = vnode.attrs.exists('label') ? m("label.label", vnode.attrs.get('label')) : null;
        var body:Vnodes =
            m(".field", [
                (!isHorizontal ? label : null),
                m("p.control" + (hasIcon ? ".has-icons-left" : ""), [
                    m("input", options),
                    hasIcon
                        ? m("span.icon.is-small.is-left", [
                            m('i.fa.fa-${vnode.attrs.get('icon')}')
                        ])
                        : null
                ])
            ]);

        return
            if(isHorizontal) {
                m(".field.is-horizontal", [
                    m(".field-label.is-normal", label),
                    m(".field-body", body)
                ]);
            }
            else body;
    }
}