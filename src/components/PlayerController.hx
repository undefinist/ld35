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
		if(Luxe.input.inputdown("left"))
		{
			colorState = false;
			wiggleTime = -WIGGLE_DELAY;
			if(angularVelocity >= 0)
				angularVelocity = -ANGULAR_VELOCITY_START;
			else
				angularVelocity -= dt * ANGULAR_ACCELERATION;
		}
		else if(Luxe.input.inputdown("right"))
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
		if(time > 1)
		{
			var tailDir = tail.clone().subtract(pos);
			if(tailDir.lengthsq < 16 * 16)
			{
				var angleToTail = Maths.wrap_angle(Maths.degrees(tailDir.angle2D), 0, 360);
				var diff = angleToTail - angle;
				if(diff < -180) diff += 360;
				if(diff > 180) diff -= 360;
				angle += diff * dt * 4;
			}
		}

		angle = Maths.wrap_angle(angle, 0, 360);
		var rad = Maths.radians(angle);
		velocity.set_xy(Math.cos(rad), Math.sin(rad)).multiplyScalar(SPEED);

	}

}
