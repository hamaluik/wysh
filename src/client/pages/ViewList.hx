package pages;

import types.IDItem;
import api.Item;
import mithril.M;
import components.Icon;
import components.ListSelector;

using Lambda;

class ViewList implements Mithril {
    public function new() {}

    /*private var listID:String = null;
    private var downloadState:State<APIState> = Idle;

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.token.value == null) M.routeSet('/');
        listID = params.get('listid');
        if(!Store.lists.exists(listID)) {
            downloadState.set(Loading);
            Actions.list.fetchList(listID)
            .next(function(x) {
                downloadState.set(Idle);
                return x;
            })
            .tryRecover(function(error:Error) {
                downloadState.set(Failed(error));
                return error;
            });
        }
        return null;
    }

    public function render(vnode) {
        var profile:Null<String> = switch(Store.profile.value) {
            case Done(pid): pid;
            case _: null;
        }
        if(profile == null)
            return [
                m(components.NavBar),
                m('section.section',
                    m('.container', [
                        m('.loading-bar')
                    ])
                )
            ];

        var list:api.List = Store.lists.get(listID);
        var selfOwned:Bool = Store.getListProfile(listID) == profile;

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
            if(list == null || !Store.listItems.exists(listID)) [];
            else Store.listItems.get(listID).map(function(id:Observable<IDItem>):Item {
                return Store.items.get(id.value);
            }).array();
        var loadingBlocks:Vnodes =
            if(downloadState.value.match(Loading)) m(Icon, { name: 'spinner-third', spin: true });
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
    }*/
    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        return null;
    }

    public function render(vnode) {
        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
                    m('.columns', [
                        m(ListSelector, { type: Self }),
                        m('.column', [
                            m('box.content', [
                            ])
                        ]),
                    ])
                ])
            )
        ];
    }
}