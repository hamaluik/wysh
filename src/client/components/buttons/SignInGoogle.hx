package components.buttons;

import mithril.M;

class SignInGoogle implements Mithril {
    public static function view(vnode:Vnode<SignInGoogle>):Vnodes {
        return m('a.google-auth', { href: vnode.attrs.get('uri') }, [
            m('span.google-icon'),
            m('span.google-text', 'Sign in with Google')
        ]);
    }
}