package pages;

import tink.state.State;
import mithril.M;
import api.Profile;

class Friends implements Mithril {
    public function new() {}

    private var searchName:State<String> = '';

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.auth.token.value == null) M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        var searchResults:Vnodes = switch(Store.friends.userSearch.value) {
            case Loading: m('span.icon', m('i.fa.fa-spinner.fa-pulse.fa-3x'));
            case Done(results): [
                for(user in results) {
                    var addLink:Vnodes =
                        if(Store.friends.pendingFriendRequests.exists(user.id))
                            m('span', [
                                m('span.icon', m('i.fa.fa-check')),
                                ' Friend request sent!'
                            ]);
                        else
                            m('a', { onclick: function() { addFriend(user); } }, [
                                m('span.icon', m('i.fa.fa-plus')),
                                ' Add friend'
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
                            m('span.icon', m('i.fa.fa-check')),
                            ' Accept'
                        ])
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
                        friendRequests
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
        Store.friends.requestFriend(profile);
    }

    function acceptRequest(profile:Profile):Void {
        Client.console.info('Accepting request from profile', profile);
    }
}