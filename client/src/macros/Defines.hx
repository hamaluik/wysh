package macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class Defines {
	public static macro function getDefine(key:String):Expr
		return macro $v{Context.definedValue(key)};

	public static macro function isDefined(key:String):Expr
		return macro $v{Context.defined(key)};
}