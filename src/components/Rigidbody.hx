package;

import luxe.Component;
import luxe.Log;
import luxe.Transform;
import luxe.Vector;
import luxe.collision.shapes.Polygon;
import luxe.options.ComponentOptions;

/**
 * ...
 * @author Malody Hoe / undefinist
 */
class Rigidbody extends Component
{

	public var enabled:Bool;

	public var collider(default, null):Collider;
	public var velocity(default, null):Vector;
	public var landed:Bool;

	public var parent:Rigidbody;

	// If true, not affected by other rigidbody forces.
	public var kinematic:Bool;
	public var affectedByGravity:Bool;

	public function new(?options:RigidbodyOptions)
	{
		super( { name: "rigidbody" } );

		enabled = true;
		velocity = new Vector(0, 0);
		landed = false;

		kinematic = false;
		affectedByGravity = true;

		if (options != null)
		{
			if (options.kinematic != null)
			{
				kinematic = options.kinematic;
			}
			if (options.affectedByGravity != null)
			{
				affectedByGravity = options.affectedByGravity;
			}
		}
	}

	override public function ondestroy()
	{
		collider = null;
		velocity = null;
		parent = null;
	}

	override public function onadded()
	{
		transform = entity.transform;
		entity_parent_change(transform.parent);

		collider = get("collider");
		Log.assertnull(collider, "Collider component not attached");

		World.addRigidbody(this);
	}

	override public function onremoved()
	{
		World.removeRigidbody(this);
	}

	override public function update(dt:Float)
	{
		if (velocity.y != 0)
			landed = false;
	}

	override public function entity_parent_change(_parent:Transform)
	{
		if (_parent == null)
		{
			parent = null;
			return;
		}

		for (c in entity.parent.components)
		{
			if (Std.is(c, Rigidbody))
				parent = cast c;
		}

	}

}

typedef RigidbodyOptions = {

	@:optional var kinematic:Bool;
	@:optional var affectedByGravity:Bool;

}
