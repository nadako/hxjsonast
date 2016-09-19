package hxjsonast;

/**
    Tools for working with `Json` values.

    This class is designed to be used as static extension (via `using` statement).
**/
class Tools {
    /**
        Convert a given `json` object into a run-time value.

        `JString`, `JNull` and `JBool` values are simply extracted.

        `JNumber` value is parsed with `Std.parseFloat`.

        `JArray` becomes `Array<Any>` with its elements recursively converted.

        `JObject` becomes a dynamic anonymous structure with its fields recursively converted.

        NOTE: On Haxe 3.2, `Dynamic` is used instead of `Any`.
    **/
    public static function getValue(json:Json):Any {
        return switch (json.value) {
            case JNull:
                null;
            case JString(string):
                string;
            case JBool(bool):
                bool;
            case JNumber(s):
                Std.parseFloat(s);
            case JObject(fields):
                var result = {};
                for (field in fields)
                    Reflect.setField(result, field.name, getValue(field.value));
                result;
            case JArray(values):
                [for (json in values) getValue(json)];
        }
    }
}

#if (haxe_ver < 3.3)
// this is not exactly the same, but it's the best we can offer for 3.2.1
private typedef Any = Dynamic;
#end
