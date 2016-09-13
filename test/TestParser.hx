import utest.Assert.*;
import hxjson.*;

class TestParser {
    public function new() {}

    public function test_string() {
        check('""', {
            pos: {file: file, min: 0, max: 2},
            value: JString("")
        });

        check('"hello"', {
            pos: {file: file, min: 0, max: 7},
            value: JString("hello")
        });

        check('"\\\"hi\\\\"', {
            pos: {file: file, min: 0, max: 8},
            value: JString("\"hi\\")
        });

        check('"\\/"', {
            pos: {file: file, min: 0, max: 4},
            value: JString("/")
        });

        check('"\\b"', {
            pos: {file: file, min: 0, max: 4},
            value: JString(String.fromCharCode(8))
        });

        check('"\\f"', {
            pos: {file: file, min: 0, max: 4},
            value: JString(String.fromCharCode(12))
        });

        check('"\\n"', {
            pos: {file: file, min: 0, max: 4},
            value: JString("\n")
        });

        check('"\\t"', {
            pos: {file: file, min: 0, max: 4},
            value: JString("\t")
        });

        check('"\\u1234"', {
            pos: {file: file, min: 0, max: 8},
            value: JString("\u1234")
        });

        checkError('"adad', "Unclosed string", 0, 5);
        checkError('"\\m"', "Invalid escape sequence \\m", 1, 3);
    }

    public function test_number() {
        for (s in ["123", "1.5", "1e1", "1e-1", "1e+1", "1.5e1", "1.5e-1", "1.5e+1"]) {
            function c(s:String) {
                inline function p(s:String, file:String):Position return {min: 0, max: s.length, file: file};
                check(s, {pos: p(s, file), value: JNumber(s)});
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
    }

    public function test_literals() {
        check("true", {
            pos: {file: file, min: 0, max: 4},
            value: JBool(true)
        });
        check("false", {
            pos: {file: file, min: 0, max: 5},
            value: JBool(false)
        });
        check("null", {
            pos: {file: file, min: 0, max: 4},
            value: JNull
        });

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
        check("{}", {
            pos: {file: file, min: 0, max: 2},
            value: JObject([])
        });

        check('{ "hello" : 123,\n "world": false }', {
            pos: {file: file, min: 0, max: 34},
            value: JObject([
                {
                    name: "hello",
                    namePos: {file: file, min: 2, max: 9},
                    value: {
                        pos: {file: file, min: 12, max: 15},
                        value: JNumber("123")
                    }
                },
                {
                    name: "world",
                    namePos: {file: file, min: 18, max: 25},
                    value: {
                        pos: {file: file, min: 27, max: 32},
                        value: JBool(false)
                    }
                }
            ])
        });

        checkError('{"a": 1, "a": 1}', "Duplicate field name \"a\"", 9, 12);

        checkError('{"a" }', "Invalid character: }", 5, 6);
        checkError('{"a": 1,}', "Invalid character: }", 8, 9);
        checkError('{:', "Invalid character: :", 1, 2);
        checkError('{3', "Invalid character: 3", 1, 2);
    }

    public function test_array() {
        check("[]", {
            pos: {file: file, min: 0, max: 2},
            value: JArray([])
        });

        check(" [ 1, false\n, \"hi\" ]", {
            pos: {file: file, min: 1, max: 20},
            value: JArray([
                {
                    pos: {file: file, min: 3, max: 4},
                    value: JNumber("1")
                },
                {
                    pos: {file: file, min: 6, max: 11},
                    value: JBool(false)
                },
                {
                    pos: {file: file, min: 14, max: 18},
                    value: JString("hi")
                },
            ])
        });

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
        } catch (error:hxjson.Error) {
            equals(message, error.message, posInfos);
            same(({file: "", min: min, max: max} : Position), error.pos, posInfos);
            return;
        }
        fail("Parse Error is not raised", posInfos);
    }
}
