package;

typedef EventHandler = Void->Void;

class Event {
	private var changed:Array<Event.EventHandler> = new Array<Event.EventHandler>();
	public function new() {}

	public function trigger() { for(change in changed) change(); }
	public function listen(listener:Event.EventHandler) changed.push(listener);
	public function unlisten(listener:Event.EventHandler) changed.remove(listener);
}