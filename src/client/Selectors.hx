typedef Selector<S, R> = S->R;

class Selectors {
    static function refCompare(a:Dynamic, b:Dynamic):Bool return untyped __js__('a === b');
    
    private static function equal<A, B>(prev:A, next:B):Bool {
        if(prev == null || next == null) {
            return false;
        }
        return refCompare(prev, next);
    }

    public static function create1<S, R, T>(a:Selector<S, R>, combiner:R->T):S->T {
        var lastA:R;
        var lastResult:T = null;

        return function(state:S):T {
            // TODO: better caching
            var newA:R = a(state);
            if(!equal(lastA, newA)) {
                lastResult = combiner(newA);
            }
            lastA = newA;
            return lastResult;
        }
    }

    public static function create2<S, R1, R2, T>(a:Selector<S, R1>, b:Selector<S, R2>, combiner:R1->R2->T):S->T {
        var lastA:R1;
        var lastB:R2;
        var lastResult:T = null;

        return function(state:S):T {
            // TODO: better caching
            var newA:R1 = a(state);
            var newB:R2 = b(state);
            if(!equal(lastA, newA) || !equal(lastB, newB)) {
                lastResult = combiner(newA, newB);
            }
            lastA = newA;
            lastB = newB;
            return lastResult;
        }
    }

    public static function create3<S, R1, R2, R3, T>(a:Selector<S, R1>, b:Selector<S, R2>, c:Selector<S, R3>, combiner:R1->R2->R3->T):S->T {
        var lastA:R1;
        var lastB:R2;
        var lastC:R3;
        var lastResult:T = null;

        return function(state:S):T {
            // TODO: better caching
            var newA:R1 = a(state);
            var newB:R2 = b(state);
            var newC:R3 = c(state);
            if(!equal(lastA, newA) || !equal(lastB, newB) || !equal(lastC, newC)) {
                lastResult = combiner(newA, newB, newC);
            }
            lastA = newA;
            lastB = newB;
            lastC = newC;
            return lastResult;
        }
    }
}