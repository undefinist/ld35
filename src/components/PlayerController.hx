package;

import phoenix.Vector;
import luxe.utils.Maths;

class PlayerController extends Rigidbody
{

	private static inline var SPEED = 128;
	private static inline var ANGULAR_ACCELERATION = 360;
	private static inline var ANGULAR_VELOCITY_START = 180;
	private static inline var ANGULAR_VELOCITY_MAX = 480;
	private static inline var WIGGLE_DELAY = 0.5;

	public var angle(default, null):Float = 0;
	private var angularVelocity:Float = 0;
	private var wiggleTime:Float = -WIGGLE_DELAY;
	private var tail:Vector;
	private var time:Float = 0;
	public var colorState:Bool = true;

	public function new(angle:Float)
	{
		super( { kinematic: true, affectedByGravity: false } );

		this.angle = angle;
	}

	override public function init()
	{
		tail = pos.clone();
	}

	override public function update(dt:Float)
	{
		var input = 0;
		if(Luxe.input.inputdown("left"))
			input--;
		if(Luxe.input.inputdown("right"))
			input++;

		if(input < 0)
		{
			colorState = false;
			wiggleTime = -WIGGLE_DELAY;
			if(angularVelocity >= 0)
				angularVelocity = -ANGULAR_VELOCITY_START;
			else
				angularVelocity -= dt * ANGULAR_ACCELERATION;
		}
		else if(input > 0)
		{
			colorState = true;
			wiggleTime = -WIGGLE_DELAY;
			if(angularVelocity <= 0)
				angularVelocity = ANGULAR_VELOCITY_START;
			else
				angularVelocity += dt * ANGULAR_ACCELERATION;
		}
		else
		{
			angularVelocity = 0;
			wiggleTime += dt;
		}
		angularVelocity = Maths.clamp(angularVelocity, -ANGULAR_VELOCITY_MAX, ANGULAR_VELOCITY_MAX);
		var wiggle = wiggleTime < 0 ? 0 : Math.cos(wiggleTime * Math.PI * 4) * 90;

		angle += (angularVelocity + wiggle) * dt;
		angle = Maths.wrap_angle(angle, 0, 360);

		time += dt;
		if(time > 1 && Level.ringsLeft == 0)
		{
			var tailDir = tail.clone().subtract(pos);
			if(tailDir.lengthsq < 32 * 32)
			{
				var angleToTail = Maths.wrap_angle(Maths.degrees(tailDir.angle2D), 0, 360);
				var diff = angleToTail - angle;
				if(diff < -180) diff += 360;
				if(diff > 180) diff -= 360;
				angle += diff * dt * 8;
			}
		}

		angle = Maths.wrap_angle(angle, 0, 360);
		var rad = Maths.radians(angle);
		velocity.set_xy(Math.cos(rad), Math.sin(rad)).multiplyScalar(SPEED);

	}

}
