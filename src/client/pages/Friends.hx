package pages;

import tink.core.Ref;
import mithril.M;

class Friends implements Mithril {
    public function new() {}

    private var searchName:Ref<String> = '';

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.auth.token.value == null) M.routeSet('/');
        return null;
    }

    public function render(vnode) {
        var searchResults:Vnodes = switch(Store.friends.userSearch.value) {
            case Loading: m('span.icon', m('i.fa.fa-spinner.fa-pulse.fa-3x'));
            case Done(results): [
                for(user in results)
                    m('article.media', [
                        m('figure.media-left',
                            m('p.image.is-64x64', m('img', { src: user.picture }))
                        ),
                        m('.media-content', m('.content', m('p', [
                            m('strong', user.name),
                            m('br'),
                            m('a', {}, [
                                m('span.icon', m('i.fa.fa-plus')),
                                ' Add Friend'
                            ])
                        ])))
                    ])
            ];
            case Failed(error): null;
        };

        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
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
                ])
            )
        ];
    }

    function search(e:js.html.Event):Void {
        if(e != null) e.preventDefault();
        Store.friends.searchForUsers(searchName.value);
    }
}