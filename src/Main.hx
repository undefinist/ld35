
import luxe.Input;

class Main extends luxe.Game
{

    var world:World;
    var level:Level;
    var playerDead:Bool = false;

    override function config(config:luxe.AppConfig)
    {
        config.preload.textures.push({ id: "assets/ring.png" } );
        config.preload.textures.push({ id: "assets/tileset.png" } );
        config.preload.texts.push({ id: "assets/maps/test.tmx" } );

        return config;

    } //config

    override function ready()
    {
        //Luxe.update_rate = 1 / 60;

        Luxe.input.bind_key("left", Key.left);
        Luxe.input.bind_key("left", Key.key_a);
        Luxe.input.bind_key("right", Key.right);
        Luxe.input.bind_key("right", Key.key_d);

        Luxe.renderer.clear_color = new luxe.Color().rgb(0x5E1C2B);

        Luxe.camera.zoom = 3;

        // trace(Luxe.camera.rotation.toeuler());
        // Luxe.camera.rotation.setFromRotationMatrix(phoenix.Matrix.MatrixTransform)

        Event.PLAYER_END.listen(Luxe.events, onPlayerEnd);

        world = Luxe.physics.add_engine(World);
        world.paused = false;

        level = new Level("test");
    }

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

        if(e.keycode == Key.key_0) {
            world.draw = !world.draw;
        }

    } //onkeyup

    override function update(dt:Float)
    {
        if(Luxe.camera.shaking)
        {
        }
        else if(world.paused)
        {
            playerDead = true;
        }

        if(!world.paused)
        {
            Luxe.camera.pos.copy_from(level.player.pos).subtract(new phoenix.Vector(480, 320));
        }
        if(playerDead)
        {
            restartLevel();
            playerDead = false;
        }
    } //update

    private function restartLevel()
    {
        world.paused = false;
        level.destroy();
        level = new Level(level.name);
    }

    private function onPlayerEnd(win:Bool)
    {
        if(win)
        {
            trace("WIN");
        }
        else
        {
            world.paused = true;
            Luxe.camera.shake(16);
        }
    }


} //Main
