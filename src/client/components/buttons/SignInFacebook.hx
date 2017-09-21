package components.buttons;

import mithril.M;

class SignInFacebook implements Mithril {
    public static function view(vnode:Vnode<SignInFacebook>):Vnodes {
        return m('a.facebook-auth', { href: vnode.attrs.get('uri') }, [
            m('span.facebook-icon'),
            m('span.facebook-text', 'Log in with Facebook')
        ]);
    }
}