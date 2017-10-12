package types;

import tink.core.Error;

enum APIPromised<T> {
    Uninitialized;
    Loading;
    Done(result:T);
    Failed(error:Error);
}
