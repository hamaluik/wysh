class RefObject<T> {
    public var value:T;

    public function new(value:T) {
        this.value = value;
    }

    public function set(value:T):T {
        return this.value = value;
    }
}

@:forward abstract Ref<T>(RefObject<T>) {
    public inline function new(value:T)
        this = new RefObject<T>(value);

    @:from static function ofConstant<T>(value:T):Ref<T>
        return new Ref(value);
}