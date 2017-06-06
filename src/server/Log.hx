import Sys;

@:enum abstract LogLevel(String) {
    var TRACE = "t";
    var INFO = "i";
    var WARN = "w";
    var ERROR = "e";
}

class Log {
    public static function log(level:LogLevel, message:String):Void {
        var now:String = Date.now().toString();
        
        var colour:String = switch(level) {
            case TRACE: '\x1B[90m';
            case INFO: '\x1B[1;36m';
            case WARN: '\x1B[1;33m';
            case ERROR: '\x1B[1;91m';
            case _: "";
        }

        Sys.println('[$now] ($colour$level\x1B[0m) $colour$message\x1B[0m');
    }

    public static function trace(message:String):Void {
        log(LogLevel.TRACE, message);
    }

    public static function info(message:String):Void {
        log(LogLevel.INFO, message);
    }

    public static function warn(message:String):Void {
        log(LogLevel.WARN, message);
    }

    public static function error(message:String):Void {
        log(LogLevel.ERROR, message);
    }

    public static function exception(exception:Exception):Void {
        log(LogLevel.ERROR, exception.toString());
    }
}