import utest.Assert.*;
import hxjsonast.*;
import hxjsonast.Json;
import TestUtils.*;

class TestParser extends TestBase {
    public function test_string() {
        check('""', mk(JString(""), mkPos(file, 0, 2)));

        check('"hello"', mk(JString("hello"), mkPos(file, 0, 7)));
        check('"\\\"hi\\\\"', mk(JString("\"hi\\"), mkPos(file, 0, 8)));
        check('{} ', mk(JObject([]), mkPos(file, 0, 2)));

        check('"\\/"', mk(JString("/"), mkPos(file, 0, 4)));
        check('"\\b"', mk(JString(String.fromCharCode(8)), mkPos(file, 0, 4)));
        check('"\\f"', mk(JString(String.fromCharCode(12)), mkPos(file, 0, 4)));
        check('"\\n"', mk(JString("\n"), mkPos(file, 0, 4)));
        check('"\\t"', mk(JString("\t"), mkPos(file, 0, 4)));
        check('"\\u1234"', mk(JString("\u1234"), mkPos(file, 0, 8)));

        checkError('"adad', "Unclosed string", 0, 5);
        checkError('"\\m"', "Invalid escape sequence \\m", 1, 3);
        checkError('{"""a": 1}', "Invalid character: \"", 3, 4);
        checkError('{}a', "Invalid character: a", 2, 3);
    }

    public function test_number() {
        for (s in ["123", "1.5", "1e1", "1e-1", "1e+1", "1.5e1", "1.5e-1", "1.5e+1"]) {
            function c(s:String) {
                inline function p(s:String, file:String):Position return mkPos(file, 0, s.length);
                check(s, mk(JNumber(s), p(s, file)));
            }
            c(s);
            c('-$s');
            s = s.toUpperCase(); // for uppercase E in scientific float
            c(s);
            c('-$s');
        }

        // TODO: more tests
        checkError("1-", "Invalid number: 1-", 0, 2);
        checkError(" 00", "Invalid number: 00", 1, 3);
        checkError("1.a", "Invalid number: 1.a", 0, 3);
        checkError("1e1.5", "Invalid number: 1e1.", 0, 4);
    }

    public function test_literals() {
        check("true", mk(JBool(true), mkPos(file, 0, 4)));
        check("false", mk(JBool(false), mkPos(file, 0, 5)));
        check("null", mk(JNull, mkPos(file, 0, 4)));

        checkError("a", "Invalid character: a", 0, 1);
        checkError("ta", "Invalid character: t", 0, 1);
        checkError("tra", "Invalid character: t", 0, 1);
        checkError("trua", "Invalid character: t", 0, 1);
        // checkError("truea", "Invalid character: t", 0, 1);
        checkError("fa", "Invalid character: f", 0, 1);
        checkError("fala", "Invalid character: f", 0, 1);
        checkError("falsa", "Invalid character: f", 0, 1);
        // checkError("falsea", "Invalid character: f", 0, 1);
        checkError("na", "Invalid character: n", 0, 1);
        checkError("nua", "Invalid character: n", 0, 1);
        checkError("nula", "Invalid character: n", 0, 1);
        // checkError("nulla", "Invalid character: n", 0, 1);
    }

    public function test_object() {
        check("{}", mk(JObject([]), mkPos(file, 0, 2)));

        check('{ "hello" : 123,\n "world": false }', mk(
            JObject([
                new JObjectField("hello", mkPos(file, 2, 9), mk(JNumber("123"), mkPos(file, 12, 15))),
                new JObjectField("world", mkPos(file, 18, 25), mk(JBool(false), mkPos(file, 27, 32))),
            ]),
            mkPos(file, 0, 34)
        ));

        checkError('{"a": 1, "a": 1}', "Duplicate field name \"a\"", 9, 12);

        checkError('{"a" }', "Invalid character: }", 5, 6);
        checkError('{"a": 1,}', "Invalid character: }", 8, 9);
        checkError('{:', "Invalid character: :", 1, 2);
        checkError('{3', "Invalid character: 3", 1, 2);
    }

    public function test_array() {
        check("[]", mk(JArray([]), mkPos(file, 0, 2)));

        check(" [ 1, false\n, \"hi\" ]", mk(
            JArray([
                mk(JNumber("1"), mkPos(file, 3, 4)),
                mk(JBool(false), mkPos(file, 6, 11)),
                mk(JString("hi"), mkPos(file, 14, 18)),
            ]),
            mkPos(file, 1, 20)
        ));

        checkError('[1,]', "Invalid character: ]", 3, 4);
        checkError('[,', "Invalid character: ,", 1, 2);
        checkError('[1 2', "Invalid character: 2", 3, 4);
    }

    static macro function check(source, expr) {
        return macro @:pos(haxe.macro.Context.currentPos()) {
            var file = "some.json";
            same(($expr : Json), Parser.parse($source, file));
        };
    }

    static function checkError(source:String, message:String, min:Int, max:Int, ?posInfos:haxe.PosInfos) {
        try {
            trace(Parser.parse(source, ""));
        } catch (error:Error) {
            equals(message, error.message, posInfos);
            same(new Position("", min, max), error.pos, posInfos);
            return;
        }
        fail("Parse Error is not raised", posInfos);
    }
}
