package pages;

import types.IDItem;
import api.Item;
import api.List;
import mithril.M;
import components.Icon;
import components.ListSelector;
import stores.ItemsStore;
import selectors.ListSelectors;
import selectors.ItemSelectors;
import State;

using Lambda;

class ViewList implements Mithril {
    public function new() {}

    private var listID:String = null;

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
                                m('button.button.is-text.is-large', {}, m(Icon, { name: 'edit' })),
                                m('button.button.is-text.is-large', {}, m(Icon, { name: 'trash' }))
                            ])
                        ])
                    else m('h1.title', list.name);
                }

            var items:Array<Item> = ItemSelectors.getItemsSelector(list.id)(Store.state);
            var itemBlocks:Vnodes = [
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

            page = [
                title,
                itemBlocks
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
}