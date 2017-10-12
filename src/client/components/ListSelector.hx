package components;

import mithril.M;

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

            case Self: [
                m('.panel-block', 'You don\'t have any lists yet!'),
            ];
        }

        var addButton:Vnodes = switch(type) {
            case Friends: null;
            case Self:
                m('.panel-block',
                    m('a.button.is-link.is-outlined.is-fullwidth', {
                        href: '#!/lists/new'
                    }, [
                        m('span.icon', m('i.fa.fa-plus')),
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