package pages;

import js.html.Event;
import mithril.M;
import components.ListSelector;
import components.form.TextField;
import components.form.SubmitButton;
import components.form.DropDown;
import components.Icon;
import haxe.ds.StringMap;
import types.TPrivacy;

using StringTools;

class NewList implements Mithril {
    private var newListName:Ref<String> = "";
    private var newListPrivacy:Ref<TPrivacy> = TPrivacy.Friends;
    private var addButtonEnabled:Bool = false;
    private var privacyTypes:StringMap<Int> = new StringMap<Int>();
    private var loading:Bool = false;

    public function new() {
        privacyTypes.set("Private", TPrivacy.Private);
        privacyTypes.set("Friends Only", TPrivacy.Friends);
        privacyTypes.set("Public", TPrivacy.Public);

        /*newListName.observe().bind(function(v:String):Void {
            addButtonEnabled = v != null && StringTools.trim(v).length > 0;
            M.redraw();
        });*/
    }

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        //if(Store.token.value == null) M.routeSet('/');
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
                            m('h1.title', 'New List'),
                            m('form', { onsubmit: createList }, [
                                m(TextField, { label: 'List Name', placeholder: 'Christmas List', store: newListName }),
                                m(DropDown, { label: 'Privacy', store: newListPrivacy, types: privacyTypes }),
                                m(SubmitButton, { disabled: !addButtonEnabled, loading: loading }, [
                                    m(Icon, { name: 'plus' }),
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
        /*if(newListName.value.trim().length < 1) return;
        loading = true;
        M.redraw();
        Actions.list.createList(newListName.value, newListPrivacy.value)
        .next(function(list:api.List) {
            loading = false;
            M.routeSet('/lists/self');
            Client.console.info('Done with creating list', list);
            return null;
        });/*
        .tryRecover(function(error) {
            Client.console.error('Failed to create list', error);
            loading = false;
            return error;
        });*/
    }
}