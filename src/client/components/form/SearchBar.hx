package components.form;

import tink.core.Ref;
import mithril.M;

class SearchBar implements Mithril {
    var value:String = null;

    public static function view(vnode:Vnode<SearchBar>):Vnodes {
        var store:Ref<String> = vnode.attrs.get('store');
        vnode.state.value = store.value;

        var options:Dynamic = {
            className: "input",
            type: 'text',
            placeholder: (vnode.attrs.exists('placeholder') && vnode.attrs.get('placeholder') != null) ? vnode.attrs.get('placeholder') : '',
            oninput: M.withAttr("value", function(value:String):Void {
                vnode.state.value = value;
                store.value = value;
            }),
            value: vnode.state.value,
            readonly: vnode.attrs.exists('readonly') && cast(vnode.attrs.get('readonly'), Bool),
            disabled: vnode.attrs.exists('disabled') && cast(vnode.attrs.get('disabled'), Bool)
        };

        var label:Vnodes = vnode.attrs.exists('label') ? m("label.label", vnode.attrs.get('label')) : null;
        /*var body:Vnodes =
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
            else body;*/
        return
            m('.field.has-addons', [
                m('.control.is-expanded',
                    m('input', options)
                ),
                m('.control',
                    m('a.button.is-info', { onclick: function() {
                        if(vnode.attrs.exists('onclick')) {
                            var clickHandler:js.html.Event->Void = vnode.attrs.get('onclick');
                            clickHandler(null);
                        }
                    }},
                        m('span.icon', m('i.fa.fa-search'))
                    )
                )
            ]);
    }
}