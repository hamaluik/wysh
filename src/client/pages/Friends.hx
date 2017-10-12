package pages;

import tink.state.State;
import mithril.M;
import api.Profile;
import components.Icon;

class Friends implements Mithril {
    public function new() {}

    private var searchName:State<String> = '';

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.auth.token.value == null) M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        var searchResults:Vnodes = switch(Store.friends.userSearch.value) {
            case Loading: m(Icon, { name: 'spinner-third', spin: true } );
            case Done(results): [
                for(user in results) {
                    var addLink:Vnodes =
                        if(Store.friends.pendingFriendRequests.exists(user.id))
                            m('span', [
                                m(Icon, { name: 'check' } ),
                                ' Friend request sent!'
                            ]);
                        else
                            m('a', { onclick: function() { addFriend(user); } }, [
                                m(Icon, { name: 'plus' }),
                                m('span', 'Add friend')
                            ]);

                    m('article.media', [
                        m('figure.media-left',
                            m('p.image.is-64x64', m('img', { src: user.picture }))
                        ),
                        m('.media-content', m('.content', m('p', [
                            m('strong', user.name),
                            m('br'),
                            addLink
                        ])))
                    ]);
                }
            ];
            case Failed(error): null;
        };

        var friendRequests:Vnodes = [
            for(user in Store.friends.friendRequests.iterator()) {
                m('article.media', [
                    m('figure.media-left',
                        m('p.image.is-64x64', m('img', { src: user.picture }))
                    ),
                    m('.media-content', m('.content', m('p', [
                        m('strong', user.name),
                        m('br'),
                        m('a', { onclick: function() { acceptRequest(user); } }, [
                            m(Icon, { name: 'check' } ),
                            ' Accept'
                        ])
                    ])))
                ]);
            }
        ];

        var pendingRequests:Vnodes = [
            for(user in Store.friends.pendingFriendRequests.iterator()) {
                m('article.media', [
                    m('figure.media-left',
                        m('p.image.is-64x64', m('img', { src: user.picture }))
                    ),
                    m('.media-content', m('.content', m('p', [
                        m('strong', user.name),
                        m('br'),
                        m('span', 'Invite sent!')
                    ])))
                ]);
            }
        ];

        var friendsList:Vnodes = [
            for(user in Store.friends.friends.iterator()) {
                m('article.media', [
                    m('figure.media-left',
                        m('p.image.is-64x64', m('img', { src: user.picture }))
                    ),
                    m('.media-content', m('.content', m('p', [
                        m('strong', user.name)
                    ])))
                ]);
            }
        ];

        return [
            m(components.NavBar),
            m('section.section',
                m('.columns', [
                    m('.column.is-one-third.content', [
                        m('h1', 'Search For Users'),
                        m('form', { onsubmit: search }, [
                            m(components.form.SearchBar, {
                                store: searchName,
                                placeholder: 'Search for people by name',
                                onclick: search
                            })
                        ]),
                        m('section.section',
                            m('.container', searchResults)
                        )
                    ]),
                    m('.column.is-one-third.content', [
                        m('h1', 'Friend Requests'),
                        friendRequests,
                        pendingRequests
                    ]),
                    m('.column.is-one-third.content', [
                        m('h1', 'Friends'),
                        friendsList
                    ])
                ])
            )
        ];
    }

    function search(e:js.html.Event):Void {
        if(e != null) e.preventDefault();
        Store.friends.searchForUsers(searchName.value);
    }

    function addFriend(profile:Profile):Void {
        // TODO: display loading status
        Store.friends.requestFriend(profile);
    }

    function acceptRequest(profile:Profile):Void {
        // TODO: display loading status
        Store.friends.acceptRequest(profile);
    }
}