package pages;

import types.IDItem;
import api.Item;
import api.List;
import mithril.M;
import components.Icon;
import components.ListSelector;
import components.form.TextField;
import stores.ItemsStore;
import selectors.ListSelectors;
import selectors.ItemSelectors;
import State;

using Lambda;

class ViewList implements Mithril {
    public function new() {}

    private var listID:String = null;
    private var showDelete:Bool = false;
    private var deleteName:Ref<String> = "";

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.state.auth.token == null) M.routeSet('/');
        listID = params.get('listid');
        if(!Reflect.hasField(Store.state.relations.listItems, listID)) {
            ItemsStore.fetchItems(listID);
        }
        return null;
    }

    public function render(vnode) {
        var listSelector:RootState->List = ListSelectors.getListSelector(listID);
        var list:List = listSelector(Store.state);

        var page:Vnodes = m('.loading-bar');
        var selfOwned:Bool = true;
        if(list != null) {
            var myLists:Array<List> = ListSelectors.getMyLists(Store.state);
            selfOwned = myLists.exists(function(l) { return l.id == list.id; });

            var title:Vnodes =
                if(list == null) m('h1.title', m(Icon, { name: 'spinner-third', spin: true }));
                else {
                    if(selfOwned)
                        m('.level', [
                            m('.level-left', m('h1.title', list.name)),
                            m('.level-right', [
                                /*m('button.button.is-text.is-large', {}, m(Icon, { name: 'edit' })),*/
                                m('button.button.is-text.is-large', { onclick: function() { showDelete = true; deleteName.set(""); } }, m(Icon, { name: 'trash' }))
                            ])
                        ])
                    else m('h1.title', list.name);
                }

            var items:Array<Item> = ItemSelectors.getItemsSelector(list.id)(Store.state);
            var itemBlocks:Vnodes = 
                if(items.length == 0)
                    m('.level',
                        m('.level-item', {
                            if(selfOwned)
                                m('p', [
                                    'It looks like you don\'t have any items on this list! Why not ',
                                    m('a', 'add one'),
                                    ' to get started?'
                                ]);
                            else
                                m('p', 'It looks like this list is empty!');
                        })
                    );
                else [
                    for(item in items) {
                        var comments:Vnodes =
                            if(item.comments != null) m('p', item.comments);
                            else null;
                        m('article.media', [
                            m('figure.media-left',
                                m('p.image.is-64x64', m('img', { src: item.image_path }))
                            ),
                            m('.media-content',
                                m('.content', [
                                    m('p', m('strong', item.name)),
                                    comments
                                ])
                            )
                        ]);
                    }
                ];
            
            var deleteModal:Vnodes =
                if(showDelete)
                    m('.modal.is-active', [
                        m('.modal-background', { onclick: function() { deleteName.set(""); showDelete = false; } }),
                        m('.modal-content.box.content', [
                            m('h1.is-size-4', 'Are you ABSOLUTELY sure you want to delete this list?'),
                            m('p.modal-warning-band', 'Unexpected bad things will happen if you don\'t read this!'),
                            m('p', [
                                m('span', 'This action '),
                                m('span.has-text-weight-bold', 'CANNOT'),
                                m('span', ' be undone. This will permanently delete your "'),
                                m('span.has-text-weight-bold', list.name),
                                m('span', '" list!')
                            ]),
                            m('p', 'Please type in the name of the list to confirm:'),
                            m('form', { onsubmit: deleteList(list) }, [
                                m(TextField, { placeholder: list.name, store: deleteName }),
                                m('submit.button.is-outlined.is-danger.is-fullwidth', {
                                    disabled: deleteName.value != list.name,
                                    onclick: deleteList(list)
                                }, 'I understand the consequences, delete this list')
                            ])
                        ]),
                        m('button.modal-close.is-large', { onclick: function() { deleteName.set(""); showDelete = false; } })
                    ]);
                else null;

            page = [
                title,
                itemBlocks,
                deleteModal
            ];
        }

        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
                    m('.columns', [
                        m(ListSelector, { type: selfOwned ? Self : Friends }),
                        m('.column', [
                            m('box.content', page)
                        ]),
                    ])
                ])
            )
        ];
    }

    private function deleteList(list:List) {
        return function(e:js.html.Event):Void {
            if(e != null) e.preventDefault();
            if(deleteName.value != list.name) return;
            Client.console.info('Deleting list', list.name);
        }
    }
}