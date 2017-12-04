package pages;

import mithril.M;
import components.ListSelector;

class FriendLists implements Mithril {
    public function new() {}

    var quote:Null<String> = null;
    var author:Null<String> = null;

    public function onmatch(params:haxe.DynamicAccess<String>, url:String) {
        if(Store.state.auth.token == null) { M.routeSet('/'); return null; }

        quote = null;
        M.redraw();
        M.jsonp({
            url: 'http://api.forismatic.com/api/1.0/',
            data: {
                method: 'getQuote',
                format: 'jsonp',
                lang: 'en',
                jsonp: 'callback'
            },
            callbackKey: "jsonp"
        })
        .then(function(q:Dynamic) {
            quote = q.quoteText;
            author = q.quoteAuthor;
            M.redraw();
        })
        .catchError(function(error) {
            js.Browser.console.error('quote error', error);
        });

        return null;
    }

    public function render(vnode) {
        return [
            m(components.NavBar),
            m('section.section',
                m('.container', [
                    m('.columns', [
                        m(ListSelector, { type: Friends }),
                        m('.column.content', [
                            quote == null ? m('.loading-bar') : m('blockquote', [
                                m('p', quote),
                                m('footer.has-text-right', [
                                    m('span', '— '),
                                    m('cite', (author != null && StringTools.trim(author).length > 0) ? author : 'Unknown')
                                ])
                            ])
                        ]),
                    ])
                ])
            )
        ];
    }
}
