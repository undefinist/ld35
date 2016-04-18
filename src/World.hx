package;

import luxe.Physics;
import luxe.Vector;
import luxe.collision.Collision;
import luxe.collision.data.ShapeCollision;
import luxe.collision.shapes.Polygon;
import luxe.utils.Maths;

/**
 * ...
 * @author Malody Hoe / undefinist
 */
class World extends PhysicsEngine
{

	private static var instance:World;

	@:allow(Rigidbody)
	private static function addRigidbody(rb:Rigidbody):Void
	{
		instance.rigidbodies.push(rb);
	}

	@:allow(Rigidbody)
	private static function removeRigidbody(rb:Rigidbody):Void
	{
		instance.rigidbodies.remove(rb);
	}

	public static function addCollider(c:Collider):Void
	{
		instance.colliders.push(c);
	}

	public static function removeCollider(c:Collider):Void
	{
		instance.colliders.remove(c);
	}



	private var rigidbodies:Array<Rigidbody>;
	private var colliders:Array<Collider>;

	public function new()
	{
		super();

		instance = this;

		paused = true;
		draw = false;

		rigidbodies = new Array<Rigidbody>();
		colliders = new Array<Collider>();
	}

	override public function init()
	{
        gravity.set_xyz(0, 680, 0);
	}

	override public function update()
	{
		if (paused)
			return;

		handlePhysics();
		updateTransforms();
		handleOverlaps();
		updateTransforms();
		handleOverlaps();
	}

	public function handlePhysics()
	{
		for (rb in rigidbodies)
		{
			if (!rb.enabled || !rb.affectedByGravity)
				continue;
			rb.velocity.x += gravity.x * Luxe.physics.step_delta;
			rb.velocity.y += gravity.y * Luxe.physics.step_delta;
		}
	}

	public function updateTransforms()
	{
		for (rb in rigidbodies)
		{
			if (!rb.enabled)
				continue;
			rb.transform.pos.x += rb.velocity.x * Luxe.physics.step_delta * 0.5;
			rb.transform.pos.y += rb.velocity.y * Luxe.physics.step_delta * 0.5;
		}
	}

	public function handleOverlaps()
	{
		for (rb in rigidbodies)
		{
			if (!rb.collider.enabled)
				continue;

			var rbColPos = new Vector().copy_from(rb.collider.shape.position);
			rb.collider.shape.position.add(rb.transform.world.pos); // shape to world

			for (c in colliders)
			{
				if (!c.enabled)
					continue;
				if (rb.collider == c)
					continue;

				var colPos = new Vector().copy_from(c.shape.position);
				if (c.entity != null)
					c.shape.position.add(c.transform.world.pos); // shape to world

				doCollision(rb, c);

				c.shape.position.copy_from(colPos); // shape to local
			}

			rb.collider.shape.position.copy_from(rbColPos); // shape to local
		}
	}

	public function doCollision(rb:Rigidbody, c:Collider):Void
	{
		var col:ShapeCollision = Collision.shapeWithShape(rb.collider.shape, c.shape);
		if (col == null) // no col
			return;

		if (c.trigger || rb.collider.trigger)
		{
			Event.TRIGGER.fire(c.entity.events, rb.collider);
			Event.TRIGGER.fire(rb.entity.events, c);
			return;
		}

		var otherRb:Rigidbody = c.get("rigidbody");
		if (otherRb != null)
		{
			if (rb.kinematic && otherRb.kinematic)
			{
				Event.COLLIDE.fire(c.entity.events, { other: rb.collider, collision: col });
				Event.COLLIDE.fire(rb.entity.events, { other: c, collision: col });
				return;
			}
			if (rb.kinematic != otherRb.kinematic)
			{
				var nonKinematic:Rigidbody = rb.kinematic ? otherRb : rb;
				if (rb.kinematic)
					col.separation.multiplyScalar(-1);
				resolveCollision(nonKinematic, col);
				Event.COLLIDE.fire(c.entity.events, { other: rb.collider, collision: col });
				Event.COLLIDE.fire(rb.entity.events, { other: c, collision: col });
			}
			else // both non kinematic, separate with ratio
			{
				var sepX = col.separation.x;
				var sepY = col.separation.y;
				var rx:Float = 0;
				var ry:Float = 0;
				if (sepX != 0)
					rx = rb.velocity.x / (rb.velocity.x + otherRb.velocity.x);
				if (sepY != 0)
					ry = rb.velocity.y / (rb.velocity.y + otherRb.velocity.y);

				col.separation.x *= rx;
				col.separation.y *= ry;
				resolveCollision(rb, col);

				col.separation.x -= sepX;
				col.separation.y -= sepY;
				resolveCollision(rb, col);

				Event.COLLIDE.fire(c.entity.events, { other: rb.collider, collision: col });
				Event.COLLIDE.fire(rb.entity.events, { other: c, collision: col });
			}
			return;
		}

		resolveCollision(rb, col);
		Event.COLLIDE.fire(c.entity.events, { other: rb.collider, collision: col });
		Event.COLLIDE.fire(rb.entity.events, { other: c, collision: col });
	}

	public function resolveCollision(rb:Rigidbody, col:ShapeCollision):Void
	{
		// resolve to rigidbody parent, if there is
		var p = topMostRb(rb);

		// apply sep to transform
		p.transform.pos.add(col.separation);
		rb.collider.shape.position.add(col.separation);

		// zero velocity after hit and check if landed
		if(col.unitVector.x != 0) {
			p.velocity.x = rb.velocity.x = 0;
		}

		if(col.unitVector.y != 0 && Maths.sign(col.unitVector.y) != Maths.sign(rb.velocity.y)) {
			p.velocity.y = rb.velocity.y = 0;
			if(col.unitVector.y < 0) {
				p.landed = rb.landed = true;
			}
		}
	}

	private function topMostRb(rb:Rigidbody):Rigidbody
	{
		var p = rb;
		while (p.parent != null)
			p = p.parent;

		return p;
	}



	//This gets called by the engine for us to draw things if we need to,
	//It gets called every frame and is helpful for debug drawing
    override public function render()
	{
		if (!draw)
			return;

        for (c in colliders)
		{
			var colPos = new Vector().copy_from(c.shape.position);
			if (c.entity != null)
				c.shape.position.add(c.transform.world.pos); // shape to world
			drawCollider(cast c.shape);
			c.shape.position.copy_from(colPos); // shape to local
		}

    } //render

        //helper to draw colliders
    function drawCollider(shape:luxe.collision.shapes.Shape) {
		var geom:phoenix.geometry.Geometry;
		if(Std.is(shape, luxe.collision.shapes.Circle))
		{
			geom = Luxe.draw.ring({
				depth: 100,
				r: cast(shape, luxe.collision.shapes.Circle).radius,
				immediate: true
			});
		}
		else
		{
	        geom = Luxe.draw.poly({
	            solid:false,
	            close:true,
	            depth:100,
	            points:cast(shape, Polygon).vertices,
	            immediate:true
	        });
		}

        geom.transform.pos.copy_from(shape.position);
    }

}
