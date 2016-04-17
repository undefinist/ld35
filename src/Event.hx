package;

/**
 * ...
 * @author Malody Hoe / undefinist
 */
class Event<T>
{

	public static var TRIGGER(default, never) = new Event<Collider>("trigger");
	public static var COLLIDE(default, never) = new Event<CollisionInfo>("collide");
	public static var PLAYER_END(default, never) = new Event<Bool>("player.end");
	public static var POST_UPDATE(default, never) = new Event<Float>("post_update");

	public var name(default, null):String;

	public function new(name:String)
	{
		this.name = name;
	}

	public function listen(target:luxe.Events, listener:T->Void):String
	{
		return target.listen(name, listener);
	}

	public function fire(target:luxe.Events, data:T):Bool
	{
		return target.fire(name, data);
	}

}
