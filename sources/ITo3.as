// forked from H.S's forked from: Mouse Position Gradation 
// forked from kawamura's Mouse Position Gradation 
package {
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.display.Loader;
    import flash.media.*;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    public class FlashTest extends Sprite {
        private var sprite:Sprite;
        public function FlashTest() {
            // write as3 code here..
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        private var day:SoundChannel, stDay:SoundTransform = new SoundTransform(0, 0);
        private var night:SoundChannel, stNight:SoundTransform = new SoundTransform(0, 0);
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            day = (new Sound(new URLRequest("http://freesound.org/data/previews/345/345950_191884-lq.mp3"))).play (0, int.MAX_VALUE, stDay);
            night = (new Sound(new URLRequest("http://freesound.org/data/previews/85/85139_278657-lq.mp3"))).play (0, int.MAX_VALUE, stNight);
            var loader1:Loader = new Loader();
            loader1.load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_day.png"), new LoaderContext(true));
            stage.addChildAt(loader1, 0);
            var loader2:Loader = new Loader();
            loader2.load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_night.png"), new LoaderContext(true));
            addChild(loader2);
            sprite = new Sprite();
            addChild(sprite);
            blendMode = "layer";
            sprite.blendMode = "alpha";
            var g:Graphics;
            g = sprite.graphics;
            var type:String = GradientType.LINEAR;
            var colors:Array = [0x0, 0x0];
            var alphas:Array = [1.0, 0.0];
            var ratios:Array = [0.0, 0xFF];
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(20, 100, 0.0 * Math.PI, 80, 0);
            g.beginGradientFill(type, colors, alphas, ratios,matrix);
            g.drawRect(0, 0, 100, 100);
            sprite.width = stage.stageWidth;
            sprite.height = stage.stageHeight;
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        private function enterFrameHandler(e:Event):void 
        {
            var rate:Number = stage.mouseX / stage.stageWidth;
            stDay.volume = 0.4 * (1 - rate); day.soundTransform = stDay;
            stNight.volume = rate; night.soundTransform = stNight;
            var g:Graphics;
            g = sprite.graphics;
            g.clear();
            var type:String = GradientType.LINEAR;
            var colors:Array = [0x0, 0x0];
            var alphas:Array = [1.0, 0.0];
            var ratios:Array = [0.0, 0xFF];
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(30, 100, 0.0 * Math.PI, -30 + 130*rate, 0);
            g.beginGradientFill(type, colors, alphas, ratios,matrix);
            g.drawRect(0, 0, 100, 100);
        }
    }
}