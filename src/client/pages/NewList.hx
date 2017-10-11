package pages;

import js.html.Event;
import tink.state.State;
import mithril.M;
import components.ListSelector;
import components.form.TextField;
import components.form.SubmitButton;

class NewList implements Mithril {
    private var newListName:State<String> = "";
    private var addButtonEnabled:Bool = false;

    public function new() {
        newListName.observe().bind(function(v:String):Void {
            addButtonEnabled = v != null && StringTools.trim(v).length > 0;
            M.redraw();
        });
    }

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.auth.token.value == null) M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
                    m('.columns', [
                        m(ListSelector, { type: Self }),
                        m('.column.content', [
                            m('h1', 'New List'),
                            m('form', { onsubmit: createList }, [
                                m(TextField, { label: 'List Name', placeholder: 'Christmas List', store: newListName }),
                                m(SubmitButton, { disabled: !addButtonEnabled }, [
                                    m('span.icon', m('i.fa.fa-plus')),
                                    m('span', 'Create List')
                                ])
                            ])
                        ]),
                    ])
                ])
            )
        ];
    }

    function createList(e:Event):Void {
        if(e != null) e.preventDefault();
        Client.console.info('Creating list: ' + newListName.value);
    }
}