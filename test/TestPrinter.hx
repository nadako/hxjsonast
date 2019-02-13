import utest.Assert.*;
import hxjsonast.Printer;
import hxjsonast.Json;
import TestUtils.*;

class TestPrinter extends TestBase {
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

    public function test_print_pretty() {
        check(mk(JObject([
            f("hello", JNumber("16")),
            f("world", JBool(false)),
        ])), '{\n\t"hello": 16,\n\t"world": false\n}', "\t");
        check(mk(JArray([
            mk(JBool(true)),
            mk(JNull),
            mk(JObject([
                f("what", JArray([
                    mk(JString("hi"))
                ]))
            ]))
        ])), '[\n\ttrue,\n\tnull,\n\t{\n\t\t"what": [\n\t\t\t"hi"\n\t\t]\n\t}\n]', "\t");
    }

    static inline function check(json:Json, result:String, ?space:String) {
        equals(result, Printer.print(json, space));
    }
}
