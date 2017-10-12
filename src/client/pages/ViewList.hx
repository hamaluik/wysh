package pages;

import api.Item;
import mithril.M;
import components.Icon;
import components.ListSelector;

class ViewList implements Mithril {
    public function new() {}

    private var listID:String = null;

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.auth.token.value == null) M.routeSet('/');
        listID = params.get('listid');
        return null;
    }

    public function render(vnode) {
        var selfOwned:Bool = false;
        var list:api.List = switch([
            Store.lists.myLists.exists(listID),
            Store.lists.friendLists.exists(listID)
        ]) {
            case [true, false] | [true, true]: {
                selfOwned = true;
                Store.lists.myLists.get(listID);
            }
            case [false, true]: Store.lists.friendLists.get(listID);
            case _: null;
        };

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

        var items:Array<Item> =
            if(list == null) [];
            else Store.items.getItems(list.id);
        var loadingBlocks:Vnodes =
            if(Store.items.itemsUpdate.value.match(Loading)) m(Icon, { name: 'spinner-third', spin: true });
            else null;
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

        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
                    m('.columns', [
                        m(ListSelector, { type: selfOwned ? Self : Friends }),
                        m('.column', [
                            m('box.content', [
                                title,
                                loadingBlocks,
                                itemBlocks
                            ])
                        ]),
                    ])
                ])
            )
        ];
    }
}