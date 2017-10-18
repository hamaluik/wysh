package components.form;

import mithril.M;

class CheckBox implements Mithril {
    public static function view(vnode:Vnode<DropDown>):Vnodes {
        var store:Ref<Bool> = vnode.attrs.get('store');

        return
        m(".field", [
            m(".control", [
                m('label.checkbox', [
                    m('input', {
                        type: 'checkbox',
                        checked: store.value,
                        onchange: M.withAttr('checked', function(value:Bool):Void {
                            store.set(value);
                        })
                    }),
                    vnode.children
                ])
            ])
        ]);
    }
}