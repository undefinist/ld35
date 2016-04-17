package;

import luxe.importers.tiled.TiledMap;
import luxe.importers.tiled.TiledObjectGroup;
import luxe.tilemaps.Tilemap;
import luxe.Color;
import luxe.components.sprite.SpriteAnimation;
import luxe.Vector;
import luxe.Sprite;
import luxe.Entity;
import luxe.collision.shapes.Polygon;
import phoenix.Texture;

/**
 * ...
 * @author Malody Hoe / undefinist
 */
class Level
{

	public static inline var TILE_SIZE:Int = 16;



	public static var ringsLeft:Int;
	public var name:String;
	public var map:TiledMap;
	public var player:Player;
	var objects:Array<Entity>;

	public function new(name:String)
	{
		this.name = name;

		var mapData = Luxe.resources.text("assets/maps/" + name + ".tmx").asset.text;
		map = new TiledMap( { format: "tmx", tiled_file_data: mapData, asset_path: "assets/" } );

		objects = [];

		ringsLeft = 0;
		for(group in map.tiledmap_data.object_groups)
		{
			for(o in group.objects)
			{
				if(o.gid != 0) // somehow tile objects are offset by 16px
					o.pos.subtract_xyz(0, Level.TILE_SIZE);

				if(o.object_type == TiledObjectType.polyline)
				{
					var type:Int = 0;
					if(group.name == "a")
						type = 1;
					else if(group.name == "b")
						type = 2;
					objects.push(new Wall(o.pos, o.polyobject.points, type));
				}
				else if(o.type == "Player")
				{
					player = new Player(o.pos, o.rotation);
				}
				else if(o.type == "Ring")
				{
					objects.push(new Ring(o.pos, o.rotation));
					ringsLeft++;
				}
				else if(o.type == "Portal")
				{
					objects.push(new Portal(o.name, o.pos, o.properties.get("Link")));
				}
			}
		}
	}

	public function destroy():Void
	{
		map.destroy();
		player.destroy();
		for(o in objects)
			o.destroy();

		map = null;
		player = null;
	}
}
