package pages;

import mithril.M;
import api.Profile;
import components.Icon;
import components.ProfileBlock;
import selectors.FriendsSelectors;

class Friends implements Mithril {
    public function new() {}

    private var searchName:Ref<String> = '';

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.state.auth.token == null) M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        var searchResultsBlock:Array<Vnode<Dynamic>> = [
            for(profile in FriendsSelectors.getSearchResults(Store.state)) {
                var addLink:Vnodes =
                    if(false) // has been sent?
                        m('span', [
                            m(Icon, { name: 'check' } ),
                            ' Friend request sent!'
                        ]);
                    else
                        m('a', { onclick: function() { addFriend(profile); } }, [
                            m(Icon, { name: 'plus' }),
                            m('span', 'Add friend')
                        ]);

                m(ProfileBlock, { profile: profile }, addLink);
            }
        ];

        var friendRequests:Array<Vnode<Dynamic>> = [
            for(user in FriendsSelectors.getIncomingRequestsProfiles(Store.state)) {
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

        var pendingRequests:Array<Vnode<Dynamic>> = [
            for(user in FriendsSelectors.getSentRequestsProfiles(Store.state)) {
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

        var friendsList:Array<Vnode<Dynamic>> = [
            for(profile in FriendsSelectors.getFriendProfiles(Store.state)) {
                m('article.media', [
                    m('figure.media-left',
                        m('p.image.is-64x64', m('img', { src: profile.picture }))
                    ),
                    m('.media-content', m('.content', m('p', [
                        m('strong', profile.name)
                    ])))
                ]);
            }
        ];

        return [
            m(components.NavBar),
            m('section.section',
                m('.container',
                    m('.columns', [
                        m('.column.is-half.content',[
                            m('h1', 'Friends'),
                            friendsList
                        ]),
                        m('.column.is-half.content', [
                            m('h1', 'Friend Requests'),
                            m('form', { onsubmit: search }, [
                                m(components.form.SearchBar, {
                                    store: searchName,
                                    placeholder: 'Search for people by name',
                                    onclick: search,
                                    loading: Store.state.apiCalls.searchFriends.match(Loading)
                                })
                            ]),
                            searchResultsBlock,
                            friendRequests,
                            pendingRequests
                        ])
                    ])
                )
            )
        ];
    }

    function search(e:js.html.Event):Void {
        if(e != null) e.preventDefault();
        stores.FriendsStore.search(searchName.value);
    }

    function addFriend(profile:Profile):Void {
        // TODO: display loading status
        stores.FriendsStore.requestFriend(profile);
    }

    function acceptRequest(profile:Profile):Void {
        // TODO: display loading status
        stores.FriendsStore.acceptFriendRequest(profile);
    }
}