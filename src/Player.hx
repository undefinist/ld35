package;

import luxe.collision.shapes.Ray;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;
import luxe.utils.Maths;
import phoenix.geometry.Vertex;
import phoenix.Color;
import phoenix.geometry.Geometry;
import luxe.Vector;

class Player extends luxe.Visual
{

	private static inline var BODY_RADIUS = 1;

	private static var COLOR_A = new Color().rgb(0x47962d);
	private static var COLOR_B = new Color().rgb(0x1e6d5d);

	private var points:Array<Vector>;
	private var body:PlayerBody;

	private var controller:PlayerController;

	private var currentColor:Color = COLOR_A;
	private var lerpColor:Color;
	private var colorLerp:Float = 0;

	public function new(pos:Vector, rot:Float)
	{
		super( {
			name: "player",
			geometry: Luxe.draw.circle( {x: 0, y: 0, r: BODY_RADIUS }),
			pos: pos,
			color: currentColor
		} );

		points = [ pos.clone() ];

		add(new Collider( {
			name: "collider",
			shape: new Circle(0, 0, BODY_RADIUS),
			trigger: true,
			tag: "Player"
		}));
		add(controller = new PlayerController(rot));

		Event.TRIGGER.listen(events, onCollide);
		Luxe.physics.on(ph_fixed_update_post, postfixedupdate);
	}

	override public function ondestroy()
	{
		body.destroy();

		points = null;
		body = null;
		currentColor = null;
		lerpColor = null;
		controller = null;

		Luxe.physics.off(ph_fixed_update_post, postfixedupdate);

		super.ondestroy();
	}

	override public function update(dt:Float)
	{
	}

	private function postfixedupdate(dt:Float)
	{
		if(points.length == 10)
		{
			body.add(new Collider({
				shape: new Circle(points[0].x, points[0].y, 4),
				trigger: true,
				tag: "Tail"
			}));
		}
		var move = pos.clone().subtract(points[points.length - 1]);
		var ray:Polygon = new Polygon(0, 0, [new Vector(), move]);
		controller.collider.shape = ray;

		points.push(pos.clone());

		var normVel = controller.velocity.normalized;
		var bodyLeft = new Vector(pos.x + normVel.y * BODY_RADIUS, pos.y - normVel.x * BODY_RADIUS);
		var bodyRight = new Vector(pos.x - normVel.y * BODY_RADIUS, pos.y + normVel.x * BODY_RADIUS);

		currentColor = controller.colorState ? COLOR_A : COLOR_B;
		colorLerp += (controller.colorState ? -dt : dt) * 4;
		colorLerp = Maths.clamp(colorLerp, 0, 1);
		var color = new Color();
		color.r = Maths.lerp(COLOR_A.r, COLOR_B.r, colorLerp);
		color.g = Maths.lerp(COLOR_A.g, COLOR_B.g, colorLerp);
		color.b = Maths.lerp(COLOR_A.b, COLOR_B.b, colorLerp);

		if(body == null)
			body = new PlayerBody(points[0], bodyLeft, bodyRight, color);
		else
			body.extend(bodyLeft, bodyRight, color, points.length > 4);
	}



	private function onCollide(collided:Collider)
	{
		if(collided.tag == "Map" || collided.tag == "Body")
			Event.PLAYER_END.fire(Luxe.events, false);
		if(collided.tag == "Tail")
		{
			trace("hi");
			Event.PLAYER_END.fire(Luxe.events, Level.ringsLeft == 0);
		}
	}

}

@:access(Player)
class PlayerBody extends luxe.Visual
{

	private var lastPos:Vector;

	public function new(startPoint:Vector, bodyLeft:Vector, bodyRight:Vector, bodyColor:Color)
	{
		super({
			name: "playerbody",
			geometry: Luxe.draw.poly( {
				points: [ startPoint, bodyLeft, bodyRight ],
				primitive_type: phoenix.Batcher.PrimitiveType.triangle_strip,
			 	color: bodyColor} ),
			color: bodyColor
		});

		lastPos = startPoint;
	}

	public function extend(bodyLeft:Vector, bodyRight:Vector, color:Color, collide:Bool)
	{
		var i = geometry.vertices.length >> 1;
		geometry.vertices.push(new Vertex(bodyLeft, color));
		geometry.vertices.push(new Vertex(bodyRight, color));
		var newPos = new Vector().copy_from(bodyLeft).add(bodyRight).multiplyScalar(0.5);

		if(!collide)
		{
			lastPos = newPos;
			return;
		}

		add(new Collider({
			shape: new Polygon(0, 0, [lastPos, newPos]),
			trigger: true,
			tag: "Body"
		}));

		lastPos = newPos;
	}
}
