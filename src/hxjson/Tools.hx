package hxjson;

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
                return Std.parseFloat(s);
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
