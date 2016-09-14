import utest.Assert.*;
import hxjsonast.Tools;
import TestUtils.*;

class TestTools {
    public function new() {}

    public function test_getValue() {
        same({
            hello: 11,
            world: ([false, "hi", 1.5, null] : Array<Any>)
        }, Tools.getValue(mk(JObject([
            f('hello', JNumber("11")),
            f('world', JArray([
                mk(JBool(false)),
                mk(JString("hi")),
                mk(JNumber("1.5")),
                mk(JNull),
            ])),
        ]))));
    }
}
