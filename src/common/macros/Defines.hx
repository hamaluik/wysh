package macros;

class Defines {
    public static macro function get(key:String):haxe.macro.Expr.ExprOf<String> {
        return macro $v{haxe.macro.Context.definedValue(key)};
    }
}