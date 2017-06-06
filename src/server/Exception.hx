import haxe.CallStack;
import haxe.PosInfos;
using Type;
//using StringTools;

class Exception {
    public var code(default, null):Int;
    public var name(default, null):String;
    public var message(default, null):String;
    public var logMessage(default, null):String;
    public var position(default, null):PosInfos;
    public var stack(default, null):Array<StackItem>;

    public function new(?code:Int, ?name:String, ?message:String, ?logMessage:String, ?pos:PosInfos) {
        this.stack = CallStack.callStack();
        this.code = code == null ? 500 : code;
        this.name = name == null ? "Internal Server Error" : name;
        this.message = message == null ? "" : message;
        this.logMessage = logMessage == null ? this.message : logMessage;
        this.position = pos;
    }

    public static function wrap(e:Dynamic, ?pos:PosInfos):Exception {
        if(Std.is(e, Exception)) return e;

        var eStack:Array<StackItem> = CallStack.exceptionStack();
        var exception:Exception = new Exception(null, null, null, Std.string(e), pos);
        exception.stack = eStack;
        return exception;
    }

    public function toString():String {
        var className:String = this.getClass().getClassName();
        var pos:String = (position == null ? 'unknown position' : position.fileName + ":" + position.lineNumber);

        var msg:String = '${className}: ${logMessage}\n\tCreated at $pos';
        //msg += CallStack.toString(stack).replace('\n', '\n\t');

        return msg;
    }
}