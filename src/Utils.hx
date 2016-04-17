package;

import phoenix.Vector;
import phoenix.geometry.Geometry;

class Utils
{

	public static function drawThickLines(points:Array<Vector>, radius:Int):Geometry
	{
		var dirs:Array<Vector> = [];
		var last = points[0];
		for(i in 1...points.length)
		{
			var p = points[i];
			dirs.push(p.clone().subtract(last).normalize());
			last = p;
		}

		var closed = points[0].equals(last);

		var jointDirs:Array<Vector> = [];
		if(closed)
			jointDirs.push(dirs[0].clone().add(dirs[dirs.length - 1]).normalize());
		else
			jointDirs.push(dirs[0]);
		last = dirs[0];
		for(i in 1...dirs.length)
		{
			jointDirs.push(last.clone().add(dirs[i]).normalize());
			last = dirs[i];
		}
		if(closed)
			jointDirs.push(jointDirs[0]);
		else
			jointDirs.push(last);

		var i = 0;
		var drawPts:Array<Vector> = [];
		for(p in points)
		{
			var j = jointDirs[i++];
			var pLeft = new Vector(Math.fround(p.x + j.y * radius), Math.fround(p.y - j.x * radius));
			var pRight = new Vector(Math.fround(p.x - j.y * radius), Math.fround(p.y + j.x * radius));
			drawPts.push(pLeft);
			drawPts.push(pRight);

			// todo: IMPROVE
		}

		return Luxe.draw.poly( {
			points: drawPts,
			primitive_type: phoenix.Batcher.PrimitiveType.triangle_strip} );
	}

}
