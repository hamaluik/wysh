package components;

import mithril.M;
import api.Profile;

class ProfileBlock implements Mithril {
    public static function view(vnode:Vnode<ProfileBlock>):Vnodes {
        var profile:Profile = vnode.attrs.get('profile');
        return
        m('article.media', [
            m('figure.media-left',
                m('p.image.is-64x64', m('img', { src: profile.picture }))
            ),
            m('.media-content', m('.content', [
                m('p', [
                    m('strong', profile.name),
                    vnode.children != null ? m('br') : null,
                    vnode.children != null ? vnode.children : null
                ]),
            ]))
        ]);
    }
}