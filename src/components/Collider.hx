package;

import luxe.Component;
import luxe.Vector;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.options.ComponentOptions;

/**
 * ...
 * @author Malody Hoe / undefinist
 */
class Collider extends Component
{

	public var enabled:Bool;
	public var trigger:Bool;
	public var tag:String;

	public var shape:Shape;

	public function new(?options:ColliderOptions)
	{
		super(options);

		enabled = true;
		trigger = false;
		tag = "";

        if(options != null) {
            if(options.shape != null) {
                shape = options.shape;
            }
            if(options.trigger != null) {
                trigger = options.trigger;
            }
            if(options.tag != null) {
                tag = options.tag;
            }
        }

		if (shape == null)
			shape = Polygon.square(0, 0, 16, false);
	}

	override public function ondestroy()
	{
		shape = null;
	}

	override public function onadded()
	{
		transform = entity.transform;
		transform.world.auto_decompose = true; // make sure world spatial values are always updated
		transform.world.decompose(true);

		World.addCollider(this);
	}

	override public function onremoved()
	{
		World.removeCollider(this);
	}

}

typedef ColliderOptions = {

	> ComponentOptions,

	@:optional var shape:Shape;
	@:optional var trigger:Bool;
	@:optional var tag:String;

}
