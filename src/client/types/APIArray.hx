package types;

import tink.state.ObservableArray;
import tink.state.State;

class APIArray<T> extends ObservableArray<T> {
    public var state(default, null):State<APIState> = Idle;

    public function new(?items) {
        super(items);
    }
}
