package components.form;

import mithril.M;

class SearchBar implements Mithril {
    var value:String = null;

    public static function view(vnode:Vnode<SearchBar>):Vnodes {
        var clickHandler:js.html.Event->Void = vnode.attrs.get('onclick');
        var store:Ref<String> = vnode.attrs.get('store');
        vnode.state.value = store.value;

        var loading:Bool = vnode.attrs.exists('loading') && vnode.attrs.get('loading') == true;
        var isLoading:String = if(loading) '.is-loading'; else '';

        var options:Dynamic = {
            className: "input",
            type: 'text',
            placeholder: (vnode.attrs.exists('placeholder') && vnode.attrs.get('placeholder') != null) ? vnode.attrs.get('placeholder') : '',
            oninput: M.withAttr("value", function(value:String):Void {
                vnode.state.value = value;
                store.set(value);
                clickHandler(null);
            }),
            value: vnode.state.value,
            readonly: vnode.attrs.exists('readonly') && cast(vnode.attrs.get('readonly'), Bool),
            disabled: vnode.attrs.exists('disabled') && cast(vnode.attrs.get('disabled'), Bool)
        };

        var label:Vnodes = vnode.attrs.exists('label') ? m("label.label", vnode.attrs.get('label')) : null;
        return
            m('.field.has-addons', [
                m('.control.is-expanded',
                    m('input', options)
                ),
                m('.control',
                    m('button.button.is-primary${isLoading}', { onclick: function() {
                        if(vnode.attrs.exists('onclick')) {
                            clickHandler(null);
                        }
                    }},
                        m(Icon, { name: 'search' })
                    )
                )
            ]);
    }
}