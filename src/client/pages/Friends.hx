package pages;

import mithril.M;
import api.Profile;
import components.Icon;
import components.ProfileBlock;

class Friends implements Mithril {
    public function new() {}

    private var searchName:Ref<String> = '';
    public var searchResults:Ref<Promised<Array<Profile>>> = Done([]);

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        //if(Store.token.value == null) M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        var searchResultsBlock:Array<Vnode<Dynamic>> = switch(searchResults.value) {
            case Done(results): [
                for(profile in results) {
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
            case _: [];
        };
        /*switch(Store.friends.userSearch.value) {
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
            case _: null;
        };*/

        /*var friendRequests:Array<Vnode<Dynamic>> = [
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

        var pendingRequests:Array<Vnode<Dynamic>> = [
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

        var friendsList:Array<Vnode<Dynamic>> = [
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
        ];*/

        return [
            m(components.NavBar),
            m('section.section',
                m('.container',
                    m('.columns', [
                        m('.column.is-half.content',[
                            m('h1', 'Friends'),
                            //friendsList
                        ]),
                        m('.column.is-half.content', [
                            m('h1', 'Friend Requests'),
                            m('form', { onsubmit: search }, [
                                m(components.form.SearchBar, {
                                    store: searchName,
                                    placeholder: 'Search for people by name',
                                    onclick: search,
                                    loading: searchResults.value.match(Loading)
                                })
                            ]),
                            searchResultsBlock,
                            /*friendRequests,
                            pendingRequests*/
                        ])
                    ])
                )
            )
        ];
    }

    function search(e:js.html.Event):Void {
        if(e != null) e.preventDefault();

        /*searchResults.set(Loading);
        Actions.profile.searchProfiles(searchName.value)
        .handle(function(outcome:Outcome<Array<Profile>, Error>):Void {
            switch(outcome) {
                case Success(results): searchResults.set(Done(results));
                case Failure(error): searchResults.set(Failed(error));
            }
        });*/
    }

    function addFriend(profile:Profile):Void {
        // TODO: display loading status
        //Store.friends.requestFriend(profile);
    }

    function acceptRequest(profile:Profile):Void {
        // TODO: display loading status
        //Store.friends.acceptRequest(profile);
    }
}