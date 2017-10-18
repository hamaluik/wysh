package components.form;

import mithril.M;
import js.html.Event;
import js.html.InputElement;
import js.html.File;

class ImageUpload implements Mithril {
    private var fileURI:String = null;
    private var fileSize:Int = 0;
    private var fileName:String = "";

    public static function view(vnode:Vnode<ImageUpload>):Vnodes {
        var store:Ref<File> = vnode.attrs.get('store');
        var label:Vnodes = vnode.attrs.exists('label') ? m("label.label", vnode.attrs.get('label')) : null;
        var maxSize:Int = vnode.attrs.exists('maxSize') ? vnode.attrs.get('maxSize') : Std.int(Math.POSITIVE_INFINITY);

        var display:Array<Vnode<Dynamic>> =
            if(store.value == null || vnode.state.fileURI == null) [
                m('span.file-icon',
                    m('svg.fa.fa-upload',
                        m('use[xlink:href=fa.svg#fa-upload]')
                    )
                ),
                m('span.file-label.has-text-centered', 'Choose a file…')
            ];
            else [
                m('img', { src: vnode.state.fileURI, style: 'max-height: 5rem;' }),
                m('span.has-text-centered', vnode.state.fileName)
            ];

        var tooLargeHelper:Vnodes =
            if(vnode.state.fileSize > maxSize) m('p.help.is-danger', 'File size is too large!');
            else null;

        return
        m(".field", [
            label,
            m('.control',
                m('.file.is-large.is-boxed.is-fullwidth' + (vnode.state.fileSize > maxSize ? '.is-danger' : ''),
                    m('label.file-label', [
                        m('input.file-input', {
                            type: 'file',
                            accept: 'image/*',
                            onchange: function(e:Event) {
                                var target:InputElement = cast(e.target);
                                if(target.files.length > 0) {
                                    var file:File = target.files.item(0);
                                    vnode.state.fileName = file.name;
                                    vnode.state.fileSize = file.size;
                                    store.set(file);

                                    var reader:js.html.FileReader = new js.html.FileReader();
                                    reader.onload = function() {
                                        vnode.state.fileURI = reader.result;
                                        M.redraw();
                                    }
                                    reader.readAsDataURL(file);
                                }
                            }
                        }),
                        m('span.file-cta', display)
                    ])
                )
            ),
            tooLargeHelper
        ]);
    }
}