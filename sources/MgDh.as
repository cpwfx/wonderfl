// forked from makc3d's ff[10]: Mouse Position Gradation 
// forked from H.S's ff[9]: Mouse Position Gradation 
// forked from makc3d's ff[8]: Mouse Position Gradation 
// forked from H.S's ff[7]: Mouse Position Gradation 
// forked from makc3d's ff[6]: Mouse Position Gradation 
// forked from H.S's ff[5]: Mouse Position Gradation 
// forked from makc3d's ff[4]: Mouse Position Gradation 
// forked from H.S's forked from: ff[2]: Mouse Position Gradation 
// forked from makc3d's ff[2]: Mouse Position Gradation 
// forked from H.S's forked from: Mouse Position Gradation 
// forked from kawamura's Mouse Position Gradation 
package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.media.*;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.*;
    public class FlashTest extends Sprite {
        private var kiki:Shape = new Shape(), kikiLoader:Loader, kikiData:BitmapData, matrix:Matrix = new Matrix;
        private var kikiLifePoint:Number = 100;
        private var hitFlag:Boolean;
        private var explosionData:BitmapData;
        private var explosionShape:Shape = new Shape();
        private var mousePoint:Point = new Point( -465, -465);
        private function kikiLoads(event:Event):void {
            kikiData = Bitmap(LoaderInfo(event.target).content).bitmapData; kikiLoader = null;
        }
        public function FlashTest() {
            // write as3 code here..
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            // original lineage remnants: day background, sky mask, and Kiki
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bkgLoads);
            loader.load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_day_2.png"), new LoaderContext(true));
            stage.addChild(loader);
            var explosionLoader:Loader = new Loader();
            explosionLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, explosionLoads);
            explosionLoader.load(new URLRequest("http://chococornet.sakura.ne.jp/img/explosion.png"), new LoaderContext(true));

            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        private function enterFrameHandler(e:Event):void 
        {
            var t:int = getTimer ();
            var g:Graphics = kiki.graphics;
            var kikiCenter:Point = new Point();
            var hitTestRadius:Number;
            g.clear(); g.beginFill(0,0.004); g.drawRect(0,0,465,465);
            if (kikiData && kikiLifePoint > 0) {
                var frame:int = (t / 100) % 6;
                var right:Boolean = int (t / 3000) % 2 > 0;
                var scale:Number = right ? -0.4 : 0.6;
                matrix.identity(); matrix.a = scale; matrix.d = Math.abs (scale);
                var kikix:Number, kikiy:Number, kikit:int = t % 3000;
                if (right) {
                    kikix = 0.2 * kikit * matrix.d;
                    kikiy = 120;
                } else {
                    kikix = 0.2 * (3000 - kikit) * matrix.d - 100;
                    kikiy = 75;
                }
                matrix.tx = kikix - 90 * frame * matrix.d;
                matrix.ty = kikiy;
                g.beginBitmapFill (kikiData, matrix, true, true);
                g.drawRect(kikix, kikiy, 90 * matrix.d, 65 * matrix.d);
                
                kikiCenter.x = (right)?  kikix + 35 * matrix.d : kikix + 55 * matrix.d;
                kikiCenter.y = kikiy + 65 * matrix.d / 2;
                hitTestRadius = 65 * matrix.d;
                var barColor:uint = 0x00E000;
                if (kikiLifePoint / 100 <= 0.2) barColor = 0xF5201A;
                else if (kikiLifePoint / 100 <= 0.6) barColor = 0xF5E800;
                g.beginFill(0x000000);
                g.drawRect(kikiCenter.x - 19, kikiy - 11, 38, 6);
                g.beginFill(0x606060);
                g.drawRect(kikiCenter.x - 18, kikiy - 10, 36, 4);
                g.beginFill(0xFFFFFF);
                g.drawRect(kikiCenter.x - 18, kikiy - 10, 36 * kikiLifePoint / 100, 1);
                g.beginFill(barColor);
                g.drawRect(kikiCenter.x - 18, kikiy - 9, 36 * kikiLifePoint / 100, 3);
            }
            
            var delay:int = 5;
            if (explosionData && rpgFrame >= delay && int(rpgFrame) <= 11 + delay) {
                explosionShape.graphics.clear();
                var col:int = (rpgFrame - delay) % 4;
                var row:int = Math.floor((rpgFrame - delay) / 4);
                var mX:int = mousePoint.x;
                var mY:int = mousePoint.y;
                var mA:Number = ((maskBD.getPixel32(mX, mY) >> 24) & 255) / 255.0;
                var es:Number = 0.3 + mA * Math.max(0, Math.max(mY / 200 - 1, 0.8 * Math.abs(mX / 150 - 1)));
                matrix.identity();
                matrix.translate(mousePoint.x / es - 245 - 490 * col, mousePoint.y / es - 245 - 490 * row);
                matrix.scale(es, es);
                if (mA > 0.3) {
                    g = explosionShape.graphics;
                } else {
                    // TODO here we can do kiki hit test...
                    if (int(rpgFrame) - delay <= 3 && Point.distance(kikiCenter, mousePoint) <= hitTestRadius && !hitFlag) {
                        kikiLifePoint -= 20;
                        setTimeout(damageVoice.play, 200);
                        hitFlag = true;
                    }
                }
                g.beginBitmapFill(explosionData, matrix);
                g.drawRect(mousePoint.x - 245 * es, mousePoint.y - 245 * es, 490 * es, 490 * es);
            }

            if (rpg) {
                matrix.identity();
                matrix.translate(-288 -80, -216 +30 -432 * int(rpgFrame));
                matrix.rotate(0.18); matrix.translate(288, 216);
                rpg.transform.matrix = matrix;

                if (rpgFrame > 0) {
                    rpgFrame += 0.33;
                    if (rpgFrame > 22.4) {
                        rpgFrame = 0;
                    }
                }

                matrix.identity();
                matrix.translate(-270, -180);
                matrix.scale(1.01, 1.01);
                matrix.translate(270, 180);
                var bd2:BitmapData = smokeBD;
                bd2.fillRect(smokeRect, 0);
                bd2.draw(smoke.bitmapData, matrix, smokeCT, null, null, true);
                smokeBD = smoke.bitmapData; smoke.bitmapData = bd2;
            }
        }

        private function bkgLoads(event:Event):void {
            var spriteSky:Sprite = new Sprite();
            spriteSky.scrollRect = new Rectangle (0, 0, 465, 465);
            stage.addChild(spriteSky);

            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, maskLoads);
            loader.load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_mask.png"), new LoaderContext(true));

            spriteSky.addChild(kiki = new Shape);
            spriteSky.addChild(loader);
            spriteSky.blendMode = "layer";
            loader.blendMode = "erase";
            explosionShape.scrollRect = new Rectangle(0, 58, 465, 349);
            explosionShape.y = 58;
            stage.addChild(explosionShape);
        }
        
        private function explosionLoads(event:Event):void {
            explosionData = Bitmap(LoaderInfo(event.target).content).bitmapData;
        }

        private var maskBD:BitmapData=new BitmapData(1, 1), smoke:Bitmap, smokeBD:BitmapData, smokeRect:Rectangle, circle:Shape, smokeCT:ColorTransform;
        private function maskLoads(event:Event):void {
            maskBD = Bitmap(LoaderInfo(event.target).content).bitmapData;

            kikiLoader = new Loader();
            kikiLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, kikiLoads);
            kikiLoader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/3/39/391d/391d6edbb3af07bacf345c1da6142af6d76e013b"), new LoaderContext(true));

            smoke = new Bitmap(new BitmapData (465, 349, true, 0));
            smoke.y = 58; smokeRect = smoke.bitmapData.rect;
            stage.addChild(smoke);

            smokeBD = smoke.bitmapData.clone ();

            circle = new Shape;
            matrix.createGradientBox(200, 200, 0, -100, -100);
            circle.graphics.beginGradientFill("radial",[0xffffff,0xffffff],[0.4,0],[100,255],matrix);
            circle.graphics.drawCircle(0, 0, 100);

            smokeCT = new ColorTransform();
            smokeCT.alphaOffset = -1;

            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, rpgLoads);
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/e/e3/e386/e3863b34fdf56ee36c0b34563061cf7d2e7766ca"), new LoaderContext(true));
            loader.scrollRect = new Rectangle (0, 59, 465, 349);
            loader.y = 58;
            loader.addEventListener(MouseEvent.CLICK, rpgFires);
            stage.addChild(loader);
        }

        private var rpg:Bitmap, rpgFrame:Number = 8;
        private function rpgLoads(event:Event):void {
            rpg = Bitmap(LoaderInfo(event.target).content); rpg.smoothing = true;
        }

        private var rpgShot:Sound = new Sound(new URLRequest("http://freesound.org/data/previews/33/33276_286533-lq.mp3"));
        private var rpgBoom:Sound = new Sound(new URLRequest("http://freesound.org/data/previews/264/264031_3797507-lq.mp3"));
        private var damageVoice:Sound = new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/voice_damage.mp3"));
        private function rpgFires(event:MouseEvent):void {
            if (rpg && (rpgFrame == 0)) {
                rpgFrame = 1;

                for (var i:int = 0; i < 7; i++) {
                    matrix.identity();
                    matrix.translate(
                        270 + 180 * (Math.random() - Math.random()),
                        180 + 130 * (Math.random() - Math.random())
                    );
                    smoke.bitmapData.draw (circle, matrix);
                }

                rpgShot.play();
                setTimeout(rpgBoom.play, 500);

                mousePoint.setTo(mouseX, mouseY);
                // limit the area we can hit to upper left
                mousePoint.normalize(Math.min(mousePoint.length, 290));
                hitFlag = false;
            }
        }
    }
}