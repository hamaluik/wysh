package types;

import tink.core.Error;

enum APIState {
    Loading;
    Idle;
    Failed(error:Error);
}
