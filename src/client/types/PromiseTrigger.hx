package types;

import tink.core.Future;
import tink.core.Outcome;
import tink.core.Error;

typedef PromiseTrigger<T> = FutureTrigger<Outcome<T, Error>>;