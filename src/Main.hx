package;

import phoenix.Vector;
import luxe.Input;

class Main extends luxe.Game
{

    var world:World;
    var level:Level;
    var playerDead:Bool = false;
    var playerAngle:Float;
    var cameraRot:Float;
    var transitionTime:Float = 0;
    var transitionText:phoenix.geometry.TextGeometry;

    override function config(config:luxe.AppConfig)
    {
        for(i in 0...11)
            config.preload.texts.push({ id: 'assets/maps/$i.tmx' } );

        return config;

    } //config

    override function ready()
    {
        //Luxe.update_rate = 1 / 60;
        //
        //


        Luxe.input.bind_key("left", Key.left);
        Luxe.input.bind_key("left", Key.key_a);
        Luxe.input.bind_key("right", Key.right);
        Luxe.input.bind_key("right", Key.key_d);

        Luxe.renderer.clear_color = new luxe.Color().rgb(0x5E1C2B);

        Luxe.camera.zoom = 4;

        // trace(Luxe.camera.rotation.toeuler());
        // Luxe.camera.rotation.setFromRotationMatrix(phoenix.Matrix.MatrixTransform)

        Event.PLAYER_END.listen(Luxe.events, onPlayerEnd);

        world = Luxe.physics.add_engine(World);
        world.paused = false;

        level = new Level("0");
        cameraRot = 0;
        playerAngle = level.player.controller.angle;
        var rad = playerAngle * Math.PI / 180;
        var forward = new Vector(Math.cos(rad), Math.sin(rad)).multiplyScalar(32);
        var screen = Luxe.screen.size.clone().multiplyScalar(0.5);
        Luxe.camera.pos.copy_from(level.player.pos).subtract(screen).add(forward);
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
        if(transitionTime > 0)
        {
            transitionTime -= dt;
            if(transitionTime < 0)
                restartLevel();
            return;
        }

        if(Luxe.camera.shaking)
        {
        }
        else if(world.paused)
        {
            playerDead = true;
        }

        if(!world.paused)
        {
    		var input = 0;
    		if(Luxe.input.inputdown("left"))
    			input--;
    		if(Luxe.input.inputdown("right"))
    			input++;

            var rot = input * Math.PI * 0.1;
            cameraRot = luxe.utils.Maths.weighted_avg(cameraRot, rot, 30);
            Luxe.camera.rotation.setFromEuler(new Vector(0, 0, cameraRot));

            if(input != 0)
                playerAngle = level.player.controller.angle;
    		var rad = playerAngle * Math.PI / 180;
    		var forward = new Vector(Math.cos(rad), Math.sin(rad)).multiplyScalar(32);
            var screen = Luxe.screen.size.clone().multiplyScalar(0.5);
            var pos = level.player.pos.clone().subtract(screen).add(forward);
            Luxe.camera.pos.weighted_average_xy(pos.x, pos.y, 10);
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
        if(level.player != null)
            level.destroy();
        level = new Level(level.name);

        cameraRot = 0;
        Luxe.camera.rotation.setFromEuler(new Vector(0, 0, cameraRot));
        playerAngle = level.player.controller.angle;
        var rad = playerAngle * Math.PI / 180;
        var forward = new Vector(Math.cos(rad), Math.sin(rad)).multiplyScalar(32);
        var screen = Luxe.screen.size.clone().multiplyScalar(0.5);
        Luxe.camera.pos.copy_from(level.player.pos).subtract(screen).add(forward);
    }

    private function onPlayerEnd(win:Bool)
    {
        if(win)
        {
            level.name = Std.string(Std.parseInt(level.name) + 1);
            level.destroy();
            Luxe.camera.rotation.setFromEuler(new Vector(0, 0, 0));
            if(transitionText == null)
                transitionText = Luxe.draw.text( {
                    text: "OUROBOROS",
                    point_size: 32,
                    bounds: Luxe.screen.bounds.clone(),
                    align: 2,
                    align_vertical: 2,
                    color: new luxe.Color().rgb(0x541111)
                });
            transitionText.visible = true;
            transitionTime = 0.5;
            Luxe.camera.pos.set_xy(0, 0);

            if(level.name == "11")
            {
                transitionTime = 99999;
                transitionText.text = "end :(";
                transitionText.point_size = 16;
            }
        }
        else
        {
            world.paused = true;
            Luxe.camera.shake(12);
        }
    }


} //Main
