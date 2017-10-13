import Sys;

enum LogLevel {
    TRACE;
    INFO;
    WARN;
    ERROR;
}

class Log {
    public static var level:LogLevel = LogLevel.TRACE;
    public static function setLevel(l:String):Void {
        level = switch(l.charAt(0).toLowerCase()) {
            case 't': TRACE;
            case 'i': INFO;
            case 'w': WARN;
            case 'e': ERROR;
            case _: throw 'Unknown level ${l}, must be one of: "trace", "info", "warn", or "error"!';
        };
    }

    private static function log(logLevel:LogLevel, message:String):Void {
        if(logLevel.getIndex() < level.getIndex()) return;

        var now:String = Date.now().toString();
        
        var colour:String = switch(logLevel) {
            case TRACE: '\x1B[90m';
            case INFO: '\x1B[1;36m';
            case WARN: '\x1B[1;33m';
            case ERROR: '\x1B[1;91m';
        }

        var prefix:String = switch(logLevel) {
            case TRACE: 't';
            case INFO: 'i';
            case WARN: 'w';
            case ERROR: 'e';
        }

        Sys.println('[$now] ($colour$prefix\x1B[0m) $colour$message\x1B[0m');
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