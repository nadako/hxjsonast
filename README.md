[![Build Status](https://travis-ci.org/nadako/hxjson.svg?branch=master)](https://travis-ci.org/nadako/hxjson)

# hxjson - typed position aware JSON parsing for Haxe

This library contains a JSON parser that parses JSON (sic!) into a position-aware typed
value objects. It also contains a printer for those objects, supporting pretty-printing.

This is useful for writing all kinds of JSON validation and processing software.

The parsing and printing code comes from standard `haxe.format.JsonParser/JsonPrinter` classes,
adapted to work with custom data structures.

**Status**: ALPHA. Works, but not yet "officially" released and there's some minor stuff to change.

## Installation

Currently requires current development version of Haxe.

```
haxelib git hxjson https://github.com/nadako/hxjson
```

## Usage

Generated API documentation is here: <https://nadako.github.io/hxjson/>,
but a code snippet is worth a thousand words:
```haxe
class Main {
    static function main() {
        var filename = 'person.json';
        var contents = '{"name": "Dan", "age": 29, "married": true}';

        // parsing is easy!
        var json = hxjson.Parser.parse(contents, filename);

        // `pos` store the filename, start and end characters
        trace(json.pos); // {file: 'person.json', min: 0, max: 43}

        // `value` is an enum, easy to work with pattern matching
        switch (json.value) {
            case JNull: trace('null!');
            case JString(string): trace('string!');
            case JBool(bool): trace('boolean!');
            case JNumber(number): trace('number!');
            case JArray(values): trace('array!');
            case JObject(fields): trace('object!');
        }

        // constructing Json is easy too, we can use both
        // the classic `new` operator or a new fancy @:structInit syntax
        var myJson:hxjson.Json = {
            pos: {file: "some.json", min: 0, max: 42},
            value: JArray([
                new hxjson.Json(JString("hello"), new hxjson.Position("some.json", 3, 10)),
                {
                    pos: {file: "other.json", min: 11, max: 30},
                    value: JString("world")
                }
            ])
        };

        // printing is easy as well (you can also pretty-print by specifying the second argument)
        var out = hxjson.Printer.print(myJson);
        trace(out); // ["hello","world"]

        // there's a tool to convert Json values into "normal" objects and arrays
        var value = hxjson.Tools.getValue(myJson);
        trace(Std.is(value, Array)); // true
    }
}
```
