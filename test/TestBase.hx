#if (macro || haxe_ver < "3.4.0")
class TestBase {
	public function new() {}
}
#else
typedef TestBase = utest.Test;
#end
