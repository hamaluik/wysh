package components.form;

import mithril.M;
import haxe.ds.StringMap;

class DropDown implements Mithril {
    public static function view(vnode:Vnode<DropDown>):Vnodes {
        var store:Ref<Int> = vnode.attrs.get('store');

        var types:StringMap<Int> = vnode.attrs.get('types');
        var options = [for(label in types.keys()) {
            m("option", {
                selected: store.value == types.get(label),
                value: Std.string(types.get(label))
            }, label == null ? "" : label);
        }];

        var label:Vnodes = 
            vnode.attrs.exists('label')
                ? m('label.label', vnode.attrs.get('label'))
                : null;

        return
            m(".field", [
                label,
                m(".control", [
                    m("span.select", [
                        m("select", {
                            oninput: M.withAttr('value', function(value:String):Void {
                                if(value == "") store.set(null)
                                else store.set(Std.parseInt(value));
                            })
                        }, options)
                    ])
                ])
            ]);
    }
}