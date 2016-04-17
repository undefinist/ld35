package;

import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;
import luxe.components.sprite.SpriteAnimation;
import luxe.Vector;

class Ring extends luxe.Sprite
{

	public function new(pos:Vector, rot:Float)
	{
		super({
			geometry: Utils.drawThickLines(
				[new Vector(0, -8), new Vector(8, 0), new Vector(0, 8), new Vector(-8, 0), new Vector(0, -8)], 2),
			color: new phoenix.Color().rgb(0xb8c63b),
			centered: true,
			pos: pos.add_xyz(8, 8),
			rotation_z: rot
		});

		add(new Collider({
			name: "trigger",
			tag: "Ring",
			trigger: true,
			shape: new Circle(0, 0, 10)
		}));

		Event.TRIGGER.listen(events, onTrigger);
	}

	override public function update(dt:Float)
	{
		rotation_z += 360 * dt;
	}

	private function onTrigger(other:Collider)
	{
		if(other.tag != "Player" || color.a != 1)
			return;
		Level.ringsLeft--;

		color.set(0.5, 0.5, 0.5, 0.5);
	}

}
