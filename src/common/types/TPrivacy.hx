package types;

@:enum abstract TPrivacy(Int) from Int to Int {
    var Private = 0;
    var Public  = 2;
}