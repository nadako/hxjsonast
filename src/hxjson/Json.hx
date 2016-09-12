package hxjson;

@:structInit
class Json {
    public var pos:Position;
    public var value:JsonValue;
}

enum JsonValue {
    JString(s:String);
    JNumber(s:String);
    JObject(fields:Array<JObjectField>);
    JArray(values:Array<Json>);
    JBool(b:Bool);
    JNull;
}

@:structInit
class JObjectField {
    public var name:String;
    public var namePos:Position;
    public var value:Json;
}
