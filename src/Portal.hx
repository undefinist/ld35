package;

import phoenix.Vector;

class Portal extends luxe.Sprite
{

	private var link:String;

	public function new(name:String, pos:Vector, ?link:String)
	{
		super({
			name: name,
			geometry: Luxe.draw.box({x:-8, y:-8, w:16, h:16}),
			color: new phoenix.Color(0,0,0,1),
			centered: true,
			pos: pos.add_xyz(8, 8)
		});

		add(new Collider({
			name: "trigger",
			tag: "Portal",
			trigger: true,
			shape: new luxe.collision.shapes.Circle(0, 0, 10)
		}));

		Event.TRIGGER.listen(events, onTrigger);

		this.link = link == null ? "" : link;
	}

	override public function update(dt:Float)
	{
		rotation_z -= 360 * dt;
	}

	private function onTrigger(other:Collider)
	{
		if(other.tag != "Player" || color.a != 1)
			return;

		var player:Player = cast other.entity;

		if(link == "")
			return;
		var link:luxe.Sprite = Luxe.scene.get(link);
		player.splitBody(link.pos);
	}

}
