package components.form;

import mithril.M;

class Input implements Mithril {
    var value:String = null;

    public static function view(vnode:Vnode<Input>):Vnodes {
        var store:Ref<String> = vnode.attrs.get('store');
        vnode.state.value = store.value;

        var required:Bool = vnode.attrs.exists('required');
        var requiredText:String = vnode.attrs.get('required');
        var showRequired:Bool = required && StringTools.trim(vnode.state.value).length < 1;
        var requiredHelper:Vnodes =
            if(showRequired) m('p.help.is-danger', requiredText);
            else null;

        var options:Dynamic = {
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
                m(".control" + (hasIcon ? ".has-icons-left" : ""), [
                    m("input.input" + (showRequired ? '.is-danger' : ''), options),
                    hasIcon
                        ? m(Icon, { name: vnode.attrs.get('icon') })
                        : null
                ]),
                requiredHelper
            ]);

        return
            if(isHorizontal) {
                m(".field.is-horizontal", [
                    m(".field-label.is-normal", label),
                    m(".field-body", body),
                    requiredHelper
                ]);
            }
            else body;
    }
}