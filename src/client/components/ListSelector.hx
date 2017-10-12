package components;

import mithril.M;
import types.TPrivacy;
using Lambda;

enum TListType {
    Friends;
    Self;
}

class ListSelector implements Mithril {
    public static function view(vnode:Vnode<BadgeSpan>):Vnodes {
        var type:TListType = vnode.attrs.get('type');

        var listItems:Vnodes = switch(type) {
            case Friends: [
                m('a.panel-block', [
                    m('span.has-text-weight-bold', 'Dennie'),
                    m('span[style="white-space:pre"]', ' / Christmas List')
                ])
            ];

            case Self: {
                if(Store.lists.myLists.count() < 1)
                    m('.panel-block', 'You don\'t have any lists yet!');
                else [
                    for(list in Store.lists.myLists.iterator())
                        m('a.panel-block', {
                                href: '#!/list/${list.id}'
                            }, [
                            m(Icon, { name: switch(list.privacy) {
                                case Public: 'globe';
                                case Friends: 'users';
                                case Private: 'lock';
                                case _: 'question';
                            } }),
                            m('span', list.name)
                        ])
                ];
            }
        }

        var addButton:Vnodes = switch(type) {
            case Friends: null;
            case Self:
                m('.panel-block',
                    m('a.button.is-link.is-outlined.is-fullwidth', {
                        href: '#!/lists/new'
                    }, [
                        m(Icon, { name: 'plus' }),
                        m('span', 'New list')
                    ])
                );
        };

        return
        m('.column.is-one-third',
            m('nav.panel', [
                m('p.panel-heading', 'Wishlists'),
                m('p.panel-tabs', [
                    m('a' + (type.match(TListType.Friends) ? '.is-active' : ''), { href: '#!/lists/friends' }, 'Friends'),
                    m('a' + (type.match(TListType.Self) ? '.is-active' : ''), { href: '#!/lists/self' }, 'Yours'),
                ]),
                listItems,
                addButton
            ])
        );
    }
}