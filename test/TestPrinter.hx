import utest.Assert.*;
import hxjson.Printer;
import hxjson.Json;
import hxjson.Position;

class TestPrinter {
    public function new() {}

    public function test_print() {
        check(mk(JNull), "null");
        check(mk(JBool(true)), "true");
        check(mk(JBool(false)), "false");
        check(mk(JNumber("123")), "123");
        check(mk(JString("hello")), "\"hello\"");
        check(mk(JObject([])), "{}");
        check(mk(JArray([])), "[]");
        check(mk(JObject([
            f("hello", JNumber("16")),
            f("world", JBool(false)),
        ])), '{"hello":16,"world":false}');
        check(mk(JArray([
            mk(JBool(true)),
            mk(JNull),
            mk(JObject([]))
        ])), '[true,null,{}]');
    }

    static var nullPos:Position = {file: "", min: 0, max: 0}; // positions are unused in printer

    static inline function mk(value:JsonValue):Json {
        return {pos: nullPos, value: value};
    }

    static inline function f(name:String, value:JsonValue):JObjectField {
        return {
            name: name,
            namePos: nullPos,
            value: mk(value)
        };
    }

    static inline function check(json:Json, result:String, ?space:String) {
        equals(result, Printer.print(json, space));
    }
}
