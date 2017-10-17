package components;

import api.List;
import mithril.M;
import selectors.ListSelectors;

enum TListType {
    Friends;
    Self;
}

class ListSelector implements Mithril {
    public static function view(vnode:Vnode<BadgeSpan>):Vnodes {
        var type:TListType = vnode.attrs.get('type');

        var listItems:Vnodes = switch(type) {
            case Friends: {
                var friendLists:Array<FriendLists> = ListSelectors.getFriendLists(Client.store.state);
                var friendsListCount:Int = 0;
                for(friendList in friendLists) friendsListCount += friendList.lists.length;
                if(friendsListCount < 1)
                    m('.panel-block', 'Your friends don\'t have any lists yet!');
                else {
                    var blocks:Array<Vnode<Dynamic>> = [];
                    for(friendList in friendLists) {
                        for(list in friendList.lists) {
                            blocks.push(
                                m('a.panel-block', {
                                        href: '#!/list/${list.id}'
                                    }, [
                                    m(Icon, { name: switch(list.privacy) {
                                        case Public: 'globe';
                                        case Friends: 'users';
                                        case Private: 'lock';
                                        case _: 'question';
                                    } }),
                                    m('span.has-text-weight-bold', friendList.profile.name),
                                    m('span[style="white-space:pre"]', ' / ${list.name}')
                                ])
                            );
                        }
                    }
                    blocks;
                };
            };

            case Self: {
                var lists:Array<List> = ListSelectors.getMyLists(Client.store.state);
                if(lists.length < 1)
                    m('.panel-block', 'You don\'t have any lists yet!');
                else [
                    for(list in lists) {
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
                        ]);
                    }
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