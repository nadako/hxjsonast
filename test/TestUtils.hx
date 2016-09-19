import hxjsonast.Json;
import hxjsonast.Position;

class TestUtils {
    public static var nullPos = mkPos("", 0, 0); // positions are unused in printer

    public static inline function mkPos(file, min, max) {
        return new Position(file, min, max);
    }

    public static inline function mk(value:JsonValue, ?pos:Position):Json {
        return new Json(value, pos == null ? nullPos : pos);
    }

    public static inline function f(name:String, value:JsonValue):JObjectField {
        return new JObjectField(name, nullPos, mk(value));
    }
}
