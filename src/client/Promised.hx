import js.Error;

enum Promised<T> {
    Loading;
    Done(result:T);
    Failed(error:Error);
}