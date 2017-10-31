package pages;

import js.html.Event;
import api.Item;
import api.List;
import api.Profile;
import mithril.M;
import components.Icon;
import components.ListSelector;
import components.form.Input;
import components.form.TextArea;
import components.form.Submit;
import components.form.ImageUpload;
import components.form.CheckBox;
import stores.ListsStore;
import stores.ItemsStore;
import selectors.ListSelectors;
import selectors.ItemSelectors;
import js.html.File;
import State;

using StringTools;

class ViewList implements Mithril {
    public function new() {}

    private var listID:String = null;

    private var showDelete:Bool = false;
    private var deleteName:Ref<String> = "";

    private var newItemName:Ref<String> = "";
    private var newItemFile:Ref<File> = new Ref<File>(null);
    private var maxImageSize:Int = 1024 * 1024 * 2;
    private var newItemLink:Ref<String> = "";
    private var newItemComments:Ref<String> = "";
    private var newItemReservable:Ref<Bool> = true;

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.state.auth.token == null) M.routeSet('/');
        listID = params.get('listid');
        if(!Reflect.hasField(Store.state.listItems, listID)) {
            ItemsStore.fetchItems(listID);
        }
        return null;
    }

    public function render(vnode) {
        var listSelector:RootState->List = ListSelectors.getListSelector(listID);
        var listOwnerSelector:RootState->Profile = ListSelectors.getListOwnerSelector(listID);
        var list:List = listSelector(Store.state);

        var page:Vnodes = m('.loading-bar');
        var selfOwned:Bool = true;
        if(list != null) {
            var listOwner:Profile = listOwnerSelector(Store.state);
            if(listOwner != null) selfOwned = listOwner.id == Store.state.auth.uid;

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
                        ]);
                    else
                        m('h1.title', listOwner != null
                            ? '${listOwner.name} / ${list.name}'
                            : list.name
                        );
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
                        var itemBody:Array<Vnode<Dynamic>> = [m('strong', item.name)];
                        if(item.comments != null) {
                            itemBody.push(m('br'));
                            itemBody.push(m('span', item.comments));
                        }
                        if(item.url != null) {
                            itemBody.push(m('br'));
                            itemBody.push(m('a', { href: item.url, target: '_blank' }, item.url));
                        }

                        // TODO: ??var rightSide

                        m('article.media', [
                            item.image_path == null ? null : m('figure.media-left',
                                m('p.image', m('img', { src: item.image_path }))
                            ),
                            m('.media-content',
                                m('.content', [
                                    m('p', itemBody),
                                ])
                            ),
                            m('.media-right', [
                                m('button.button.is-text.is-small', {}, m(Icon, { name: 'edit' })),
                                m('button.button.is-text.is-small', {}, m(Icon, { name: 'trash' })),
                            ])
                        ]);
                    }
                ];

            var addItem:Vnodes = null;
            if(selfOwned) {
                addItem =
                    m('.box', [
                        m('h2.is-size-4', 'Add New Item'),
                        m('form', { onsubmit: createItem }, [
                            m(Input, { label: 'Name', placeholder: 'A New Sweater', store: newItemName, required: 'This field is required!' }),
                            m(ImageUpload, { label: 'Upload Picture', accept: 'image/*', store: newItemFile, maxSize: maxImageSize }),
                            m(Input, { label: 'Link', placeholder: 'https://www.amazon.ca/', store: newItemLink }),
                            m(TextArea, { label: 'Comments', placeholder: 'Size: XL', store: newItemComments }),
                            m(CheckBox, { store: newItemReservable }, ' Allow friends to reserve this item?'),
                            m(Submit, { disabled: !canSubmitNewItem() },
                            [
                                m(Icon, { name: 'plus' }),
                                m('span', 'Add Item')
                            ])
                        ])
                    ]);
            }
            
            var deleteButtonLoading:String =
                Store.state.apiCalls.deleteList.match(Loading)
                    ? '.is-loading'
                    : '';
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
                                m(Input, { placeholder: list.name, store: deleteName }),
                                m('submit.button.is-outlined.is-danger.is-fullwidth${deleteButtonLoading}', {
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
                addItem,
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
        return function(e:Event):Void {
            if(e != null) e.preventDefault();
            if(deleteName.value != list.name) return;
            ListsStore.deleteList(list)
            .then(function(_) {
                M.routeSet('/lists/self');
            });
        }
    }

    private function canSubmitNewItem():Bool {
        return !(
               newItemName.value.trim().length < 1
            || (newItemFile.value != null && newItemFile.value.size > maxImageSize));
    }

    private function createItem(?e:Event) {
        Client.console.info('Adding item...');
        if(e != null) e.preventDefault();
        if(!canSubmitNewItem()) {
            Client.console.warn('Can\'t submit item!');
            return;
        }
        ItemsStore.newItem(listID, newItemName.value, newItemFile.value, newItemLink.value, newItemComments.value, newItemReservable.value)
        .then(function(_) {
            newItemName.set("");
            newItemFile.set(null);
            newItemLink.set("");
            newItemComments.set("");
            newItemReservable.set(true);
        })
        .catchError(function(error) {
            Client.console.error('Failed to upload new item', error);
        });
    }
}