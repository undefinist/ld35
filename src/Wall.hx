package;

import luxe.Vector;
import luxe.Visual;
import luxe.collision.shapes.Polygon;

class Wall extends Visual
{

	private static inline var DRAW_RADIUS = 1;

	private var wallColor:luxe.Color = new luxe.Color().rgb(0x541111);

	public function new(pos:Vector, points:Array<Vector>, type:Int)
	{
		for(p in points)
		{
			p.add(pos);
		}
		points = Utils.smoothPath(points, 4, 4);

		var tag = "Wall";
		if(type != 0)
		{
			tag += type == 1 ? "A" : "B";
			wallColor = type == 1 ? Player.COLOR_A : Player.COLOR_B;
		}

		super({
			name: "wall",
			name_unique: true,
			geometry: Utils.drawThickLines(points, DRAW_RADIUS),
			color: wallColor
		});

		var last = points[0];
		for(i in 1...points.length)
		{
			var p = points[i];
			var poly:Polygon = new Polygon(0, 0, [last, p]);
			add(new Collider({
				tag: tag,
				trigger: true,
				shape: poly
			}));
			last = p;
		}
	}

}
