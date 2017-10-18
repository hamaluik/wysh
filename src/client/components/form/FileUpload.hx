package components.form;

import mithril.M;
import js.html.Event;
import js.html.InputElement;
import js.html.File;

class FileUpload implements Mithril {
    private var fileName:String = "";

    public static function view(vnode:Vnode<FileUpload>):Vnodes {
        var store:Ref<File> = vnode.attrs.get('store');
        var label:Vnodes = vnode.attrs.exists('label') ? m("label.label", vnode.attrs.get('label')) : null;
        var options = {
            type: 'file',
            onchange: function(e:Event) {
                var target:InputElement = cast(e.target);
                if(target.files.length > 0) {
                    var file:File = target.files.item(0);
                    vnode.state.fileName = file.name;
                    store.set(file);
                }
            }
        };
        if(vnode.attrs.exists('accept')) Reflect.setField(options, 'accept', vnode.attrs.get('accept'));

        return
            m(".field", [
                label,
                m("p.control", [
                    m('.file.has-name.is-fullwidth',
                        m('label.file-label', [
                            m('input.file-input', options),
                            m('span.file-cta',  [
                                m('span.file-icon',
                                    m('svg.fa.fa-upload',
                                        m('use[xlink:href=fa.svg#fa-upload]')
                                    )
                                ),
                                m('span.file-label', 'Choose a file…')
                            ]),
                            m('span.file-name', vnode.state.fileName)
                        ])
                    )
                ])
            ]);
    }
}