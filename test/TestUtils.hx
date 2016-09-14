import hxjsonast.Json;
import hxjsonast.Position;

class TestUtils {
    public static var nullPos:Position = {file: "", min: 0, max: 0}; // positions are unused in printer

    public static inline function mk(value:JsonValue):Json {
        return {pos: nullPos, value: value};
    }

    public static inline function f(name:String, value:JsonValue):JObjectField {
        return {
            name: name,
            namePos: nullPos,
            value: mk(value)
        };
    }
}
