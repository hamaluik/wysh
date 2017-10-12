package components.form;

import mithril.M;
import tink.state.State;

class DropDown implements Mithril {
    public static function view(vnode:Vnode<DropDown>):Vnodes {
        var store:State<String> = vnode.attrs.get('store');

        var types:Array<String> = vnode.attrs.get('types');
        var options = [for(type in types) {
            m("option", {
                selected: store.value == type
            }, type == null ? "" : type);
        }];

        var label:Vnodes = 
            vnode.attrs.exists('label')
                ? m('label.label', vnode.attrs.get('label'))
                : null;

        return
            m(".field", [
                label,
                m("p.control", [
                    m("span.select", [
                        m("select", {
                            oninput: M.withAttr('value', function(value:String):Void {
                                if(value == "") store.set(null)
                                else store.set(value);
                            })
                        }, options)
                    ])
                ])
            ]);
    }
}