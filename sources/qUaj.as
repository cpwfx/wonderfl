// ENGLISH UI VERSION: http://wonderfl.net/c/57np
// mixi VERSION: http://mixi.jp/run_appli.pl?id=6930

// forked from checkmate's colin challenge for professionals
/**
 * Create a Flash app using Union Platform,
 * where you can collaborate with more than 4 people online.
 *
 * UnionRamen is an example app,
 * you can write code based on this, or build from scratch.
 *
 * UnionRamen is a multiuser bowl of ramen built on the Union Platform.
 * Press the 'n' key to add naruto to the bowl.
 * For Union Platform documentation, see www.unionplatform.com.
 * 
 * @author   Colin Moock
 * @date     July 2009
 * @location Toronto, Canada
 */

 /**
  * ■ TypeShoot ver 1.4.5.20090911.1 
  * 
  * これはタイピングゲームです。
  * ワードを打つとミサイルを発射し、敵陣営に到達すると敵のダメージとなります。
  * 一定量のダメージを与えると勝利となります。
  * 
  * 敵が発射したミサイルはワードを打って撃墜できます。
  * 自陣を守って敵陣を落としましょう！
  * 
  * 日本語ワードを入力するときは、ローマ字表現を英字で打ち込んでください。
  * かな入力は未対応です・・。
  * 
  * 攻撃ワードは、ゲーム中に現れるワードは全て受け付けますが、
  * 入力窓のすぐ上にあるワードを打つとダメージが2倍のミサイルになります。
  * また、アタックコンボボーナスの対象となります。
  * 
  * 攻撃・防御をミスタイプなしで連続して行うと、コンボ数がカウントされます。
  * 
  * 攻撃時にパーフェクト入力：攻撃コンボ数＋１
  * 攻撃時にミスしたが修正して入力：攻撃コンボ数不変
  * 攻撃時にミスしたまま確定：攻撃コンボ数リセット
  * 
  * 防御時にパーフェクト入力：防御コンボ数＋１
  * 防御時にミスタイプ：防御コンボ数リセット
  * 
  * 一定値に達すると、攻撃・防御の際にボーナス攻撃が発生します。
  * 攻撃コンボ→ダブルアタック：一定確率で2発同時に発射します。
  * 防御コンボ→オートリフレクション：撃墜したワードを一定確率でそのまま打ち返します。
  * 
  * ■　戦闘中のショートカットキー
  * F2　チャット入力
  * TAB 攻撃モード・防御モードの切り替え
  * ESC 防御入力中のワードの取り消し・防御対象の取り消し
  * ←→ 防御中の自機を左右に移動
  * ↑　攻撃モードに切り替え
  * ↓　防御モードに切り替え
  * SPACE ENTERのかわり、または攻防のモード切替（SETTINGSで設定）
  * F12 防御時に、優先防御範囲の変更
  * 
  * ■　SETTINGS画面の説明
  * YOUR NAMEの入力欄で名前を変更できます。空欄は受け付けません。
  * 
  * ATTACK LANGUAGEで攻撃ワード候補がどの言語で現れるかを選択できます。
  * 防御ワードは敵が打ったものがそのまま出てくるので、ここでは制御できません。
  * 
  * COLOR SETTINGで自機の色を変えられます。
  * ゲーム回数を重ねると選択できる色が増えます。最大20色です。
  *
  * COMレベルを上昇のみにセットすると、COM戦で
  * 敗北してもCOMレベルが下がりません。 
  *
  * チャット画面でユーザー名の横に表示されるかっこ内の数字は、
  * それぞれ攻撃時/防御時のそのプレイヤーの最大毎秒タイプ数です。
  * チームを選択する際におおまかな目安として利用してください。
  * 
  * VS COMを押すとコンピュータと対戦できます。
  * 勝敗に応じてコンピュータのレベルが変わります。
  * 
  * ■　■　■　あなたがこのゲームを楽しめますように！
  * 
  * 制作 Kenichi UENO (Keno)
  * 音素材 Yoichi KANEKO / ザ・マッチメイカァズ2nd 【フリー効果音素材】
  * テストプレイやアドバイスなど LOGOSWARE PDGの皆さん / 某黒猫の皆さん / Nyafu
  * 日本語ワード: Thierry Bézecourt
  * # JLPT vocabulary level 2, 3 and 4
  * # Copyright (C) 2001 Thierry Bézecourt (http://www.thbz.org)
  * 
  * 遊んでくれた人 YOU!
  */

package  
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import net.user1.logger.Logger;
	import net.user1.reactor.Reactor;
	import net.user1.reactor.ReactorEvent;
	import net.user1.reactor.Room;
	import net.user1.reactor.XMLSocketConnection;
	import net.user1.utils.LocalData;
	
        [SWF(width = "465", height = "465", backgroundColor = "0", fps = "60")]
		public class TypeShootWonderfl extends Sprite
	{
		protected var reactor:Reactor = new Reactor();
		protected var gameController:GameController;
		
//		protected var enterUI:EnterUI = new EnterUI();
		protected var infoUI:InfoUI;// = new InfoUI();
		protected var gameStage:GameStage;// = new GameStage();
		
		protected var nowProgress:Number = 0;
		
		public function TypeShootWonderfl() 
		{
			Security.loadPolicyFile("http://www.nyafuri.com/crossdomain.xml");
			SoundManager.initChecker.addEventListener(ProgressEvent.PROGRESS, onProgress);
			SoundManager.init();
			ImageManager.initChecker.addEventListener(ProgressEvent.PROGRESS, onProgress);
			ImageManager.init();
			Score.initScore();
			Score.lastLevel = Score.getLevel();
			infoUI = new InfoUI();
			gameStage = new GameStage();
			Roma.init();
			this.graphics.lineStyle(2, 0x00FF00);
			this.graphics.moveTo(0, 230);
			this.addEventListener(Event.ENTER_FRAME, onProgress);
			connect();
		}
		
		// サウンドのロードエフェクト + ついでにunion接続
		private function onProgress(e:Event):void {
			nowProgress = nowProgress + 0.25 * (((ImageManager.count + SoundManager.count + (reactor.isReady()?1:0)) / (ImageManager.countMax + SoundManager.countMax+1)) - nowProgress);
			this.graphics.lineTo(Constants.STAGE_WIDTH * nowProgress, 230);
			if ( nowProgress >= 0.99 ) {
				this.alpha *= 0.75;
				if ( this.alpha < 0.05 ) {
					this.removeEventListener(Event.ENTER_FRAME, onProgress);
					this.graphics.clear();
					this.alpha = 1.0;
//					start();
					gameStart();
				}
			}
		}
/*
		// 入室画面表示
		private function start():void{
			this.addChild( enterUI ); // 名前いれないほうが入りやすいかなあ
			enterUI.x = 0.5 * (Constants.STAGE_WIDTH - enterUI.width);
			enterUI.y = 0.5 * (Constants.STAGE_HEIGHT - enterUI.height);
			enterUI.addEventListener("enter", onEnter);
		}
		protected function onEnter(e:Event):void {
			enterUI.removeEventListener("enter", onEnter);
			gameStart();
		}
*/
		protected function connect():void{
			reactor.addEventListener(ReactorEvent.READY, onProgress);
			reactor.addEventListener(ReactorEvent.CLOSE, onClose);
			
			reactor.getConnectionManager().addConnection(new XMLSocketConnection("tryunion.com", 80));
			reactor.getConnectionManager().connect();
//			reactor.connect("tryunion.com", 9100);
		}
		protected function onClose(e:ReactorEvent):void {
			if ( gameController ) gameController.noticeClosed();
//			else trace( e );
		}
		protected function gameStart():void {
			reactor.addEventListener(ReactorEvent.READY, onReconnect);
			reactor.removeEventListener(ReactorEvent.READY, onProgress);
			reactor.getConnectionMonitor().setAutoReconnectFrequency(2000);
			reactor.getConnectionMonitor().setConnectionTimeout(7000);
			reactor.getConnectionMonitor().setHeartbeatFrequency(3000);
			Security.allowDomain("*");

			try {
				ExternalInterface.addCallback('logout', onLogOutJS);
			} catch(e:*) {}
			reactor.getLog().setLevel(Logger.FATAL);
//			reactor.getLog().setLevel(Logger.DEBUG);
			ServerClockUtil.init( reactor.getServer() );
//			this.removeChild( enterUI );
			this.addChild( gameStage );
			this.addChild( infoUI );
			infoUI.visible = false;
			gameController = new GameController(reactor, infoUI, gameStage); // 選択画面とゲーム画面をコントロール
			
			gameController.startInfo();
		}
		protected function onReconnect(e:ReactorEvent):void {
			removeChild( infoUI );
			removeChild( gameStage );
			gameStage = new GameStage();
			infoUI = new InfoUI();
			this.addChild( gameStage );
			this.addChild( infoUI );
			
			gameController = new GameController(reactor, infoUI, gameStage);
			gameController.startInfo(true);
		}
		protected function onLogOutJS():void {
			reactor.disconnect();
		}
	}
}
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.system.IME;
	import flash.system.IMEConversionMode;
	import flash.system.Capabilities;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.text.engine.FontDescription;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.escapeMultiByte;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import net.user1.reactor.AttributeEvent;
	import net.user1.reactor.Client;
	import net.user1.reactor.ClientManager;
	import net.user1.reactor.CustomClient;
	import net.user1.reactor.filters.AttributeComparison;
	import net.user1.reactor.filters.AttributeFilter;
	import net.user1.reactor.filters.CompareType;
	import net.user1.reactor.filters.Filter;
	import net.user1.reactor.filters.IFilter;
	import net.user1.reactor.IClient;
	import net.user1.reactor.MessageListener;
	import net.user1.reactor.RoomEvent;
	import net.user1.reactor.Server;
	import net.user1.reactor.ServerEvent;
	import net.user1.reactor.UserAccount;
	import net.user1.utils.LocalData;
	import net.user1.reactor.Room;
	import net.user1.reactor.Reactor;
	import net.user1.utils.UDictionary;
	
	// 背景エフェクト
	class BackGround extends Bitmap {
		protected var bd:BitmapData = new BitmapData(Constants.STAGE_WIDTH, Constants.DISTANCE, true, 0x0);
		protected var p:Point = new Point();
		protected var filter:BitmapFilter = new BlurFilter();
		public var sprite:Sprite;
		public function BackGround(sprite:Sprite) {
			this.sprite = sprite;
			this.bitmapData = bd;
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		protected function onEnterFrame(e:Event):void {
			bd.applyFilter(bd, bd.rect, p, filter);
			bd.draw(sprite);
		}
		public function setFilter(type:int):void {
			switch(type) {
				case 0:
					filter = new ColorMatrixFilter([0.98, 0, 0, 0, 0, 0, 0.98, 0, 0, 0, 0, 0, 0.9, 0, 0, 0, 0, 0, 0.98, 0]);
					break;
				case 1:
					filter = new BlurFilter(4, 4, 2);
					break;
			}
		}
	}
	
	
	class EffectSprite extends Sprite {
		public function EffectSprite() {
			this.mouseEnabled = this.mouseChildren = false;
			this.blendMode = BlendMode.MULTIPLY;
		}
		private var particleList:Array = [];
		public function hitMotion(y:Number, x:Number):void {
			var hit:HitMotion = new HitMotion();
			this.addChild( hit );
			hit.y = y;
			
			for ( var i:int = 0; i < 20; i++ ){
				var particle:Particle = new Particle();
				this.addChild( particle );
				particleList.push(particle);
				particle.x = x + Math.random() * 20 - 10;
				particle.y = y;
				particle.init();
				particle.life = Math.random() * 7;
				particle.vx = Math.random() * 72 - 36;
				if( y == 0 ){
					particle.vy = Math.random() * 24;
				} else {
					particle.vy = - Math.random() * 24;
				}
			}
			this.addEventListener( Event.ENTER_FRAME, onEnterFrame);
		}
		public function missileDestroy(p:Point):void {
			var am:AttackMotion = new AttackMotion();
			
			this.addChild( am );
			am.x = p.x;
			am.y = p.y;
			for ( var i:int = 0; i < 10; i++ ){
				var yakochu:Yakochu = new Yakochu();
				this.addChild( yakochu );
				particleList.push(yakochu);
				yakochu.x = p.x;
				yakochu.y = p.y;
			}
			this.addEventListener( Event.ENTER_FRAME, onEnterFrame);
		}
		private function onEnterFrame(e:Event):void {
			update();
			if ( particleList.length == 0 ) {
				this.removeEventListener( Event.ENTER_FRAME, onEnterFrame);
			}
		}
		public function update():void {
			var count:int = particleList.length;
			for ( var i:int = 0; i < count; i++ ) {
				if ( !particleList[i].update() ) {
					this.removeChild( particleList[i] );
					particleList.splice(i--, 1); // ループ続行
					count--;
				}
			}
		}
	}
	
	class Yakochu extends Sprite {
		private var vx:Number = Math.random() * 2.0 - 1;
		private var vy:Number = Math.random() * 2.0 - 1;
		private var ax:Number = Math.random() * 0.5 - 0.25;
		private var ay:Number = Math.random() * 0.5 - 0.25;
		public function Yakochu(baseColor:int = 0xAAAAAA):void {
			graphics.beginFill(Math.random() * 0xFFFFFF | baseColor, 1);
			graphics.drawCircle(0, 0, Math.random() * 3);
			this.alpha = 6 * Math.random();
//			blendMode = BlendMode.ADD;
		}
		public function update():Boolean {
			vx += ax; vy += ay;
			this.x += vx;
			this.y += vy;
			this.alpha *= 0.9;
			if ( this.alpha < 0.1 ) {
				return false;
			}
			return true;
		}
	}
	
	// based on cellfusion's Particle class
	class Particle extends Sprite
	{
		public var vx:Number;
		public var vy:Number;
		public var life:Number;
		public var size:Number;

		private var _count:uint;
		private var _destroy:Boolean;

		public function Particle()
		{
			size = Math.random() * 25;
			
			var red:uint = Math.floor(Math.random()*100+156);
			var blue:uint = Math.floor(Math.random()*100+100);
			var green:uint = Math.floor(Math.random()*156);
			var color:Number = (red << 16) | (green << 8) | (blue);
			
			var fillType:String = GradientType.RADIAL;
			var colors:Array = [color ,color];
			var alphas:Array = [100, 0];
			var ratios:Array = [0x00, 0xFF];
			var mat:Matrix = new Matrix();
			mat.createGradientBox(size * 2, size * 2, 0, -size, -size);
			var spreadMethod:String = SpreadMethod.PAD;

			graphics.clear();
			graphics.beginGradientFill(fillType, colors, alphas, ratios, mat, spreadMethod);
			graphics.drawCircle(0, 0, size);
			graphics.endFill();
			
			blendMode = "add";

			_destroy = true;
		}
		
		public function get count():uint {
			return _count;
		}
		
		public function init():void
		{
			_count = 0;
			_destroy = false;
		}

		
		public function update():Boolean
		{
			x += vx * this.alpha;
			y += vy * this.alpha;
			this.alpha = _count / life;

			_count++;
			
			// 死亡フラグ
			if (life < _count) {
				_destroy = true;
//				parent.removeChild(this);
			}
			return !_destroy;
		}

		public function get destroy():Boolean
		{
			return _destroy;
		}
	}
	
	// 顔表示
	class FaceManager extends Sprite {
		private var face_A:Bitmap = new Bitmap(new BitmapData(80, 80));
		private var face_B:Bitmap = new Bitmap(new BitmapData(80, 80));
		private var faceLayer:Sprite = new Sprite();
//		private var faceMask:Sprite = new Sprite();
		public function FaceManager() {
			this.addChild( faceLayer );
			faceLayer.addChild( face_A );
			faceLayer.addChild( face_B );
//			faceLayer.mask = faceMask;
			faceLayer.scaleY = 0;
//			faceLayer.addChild( faceMask );
//			faceMask.graphics.beginFill(0);
//			faceMask.graphics.drawRect(0, 0, 80, 80);
		}
		public function show():void {
			this.addEventListener(Event.ENTER_FRAME, onShowEnterFrame);
		}
		private function onShowEnterFrame(e:Event):void {
			faceLayer.scaleY += ( 1 - faceLayer.scaleY) * 0.25;
			if ( faceLayer.scaleY > 0.98 ) {
				stopTimerFlg = false;
				setTimer();
				faceLayer.scaleY = 1;
				this.removeEventListener(Event.ENTER_FRAME, onShowEnterFrame);
			}
			faceLayer.y = 40 * (1 - faceLayer.scaleY);
		}
		public function stopSpeaking():void {
			stopTimerFlg = true;
		}
		public function hide():void {
			stopTimerFlg = true;
			this.addEventListener(Event.ENTER_FRAME, onHideEnterFrame);
		}
		private function onHideEnterFrame(e:Event):void {
			faceLayer.scaleY += ( 0 - faceLayer.scaleY) * 0.4;
			if ( faceLayer.scaleY < 0.02 ) {
				faceLayer.scaleY = 0;
				this.removeEventListener(Event.ENTER_FRAME, onHideEnterFrame);
				dispatchEvent(new Event(Event.COMPLETE));
			}
			faceLayer.y = 40 * (1 - faceLayer.scaleY);
		}
		public function setFace(faceA:DisplayObject, faceB:DisplayObject):void {
			face_A.bitmapData.draw(faceA);
			face_B.bitmapData.draw(faceB);
		}
        private function changeStatus():void{
            face_B.visible = !face_B.visible;
        }
		private var stopTimerFlg:Boolean = false;
        private function setTimer():void{
            var timer:Timer = new Timer(100, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE,
                function():void{
                    changeStatus();
                    setTimer();
                }
            );
            if( face_B.visible ){ // 50-100msで口を閉じる
                timer.delay -= 50 * Math.random();
            } else { // 100-400msでまた口をあける
                timer.delay += 250 * Math.random();
            }
			if( !stopTimerFlg || face_B.visible )	timer.start();
        }
	}
	
	// 情報表示
	class InfoWindow extends Sprite {
		private var tf:TextField = new TextField();
		private var messageCue:Array = [];
		private var isShowing:Boolean = false;
		private var hideX:Number = -210;
		private var showX:Number = -5; // 
		private var isLeft:Boolean = true;
		private var face:FaceManager = new FaceManager();
		public function InfoWindow() {
			this.mouseEnabled = this.mouseChildren = false;
			TextFieldUtil.setupBorder(tf);
			tf.selectable = false;
			tf.width = 100;
			tf.height = 40;
			tf.y = 5;
			tf.x = 95;
			tf.wordWrap = true;
			this.addChild( tf );
			this.addChild( face );
			setParts();
			this.x = -210;
			
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		protected function onTimer(e:TimerEvent):void {
			if ( (e.target as Timer).currentCount == 2 ) face.stopSpeaking();
		}
		protected function setParts():void {
			if ( isLeft ) {
				this.graphics.clear();
				this.graphics.lineStyle(2, 0x88FF88, 0.8);
				this.graphics.beginFill(0, 0.5);
				this.graphics.lineTo(200, 0);
				this.graphics.lineTo(200, 50);
				this.graphics.lineTo(95, 50);
				this.graphics.lineTo(95, 90);
				this.graphics.lineTo(0, 90);
				this.graphics.endFill();
				tf.x = 95;
				tf.y = 5;
				face.x = 10;
				face.y = 5;
				face.scaleX = 1;
//				showX = -93; // 顔非表示
				showX = -5;
				hideX = -210;
			} else {
				this.graphics.clear();
				this.graphics.lineStyle(2, 0x88FF88, 0.8);
				this.graphics.beginFill(0, 0.5);
				this.graphics.lineTo(0, 90);
				this.graphics.lineTo(-95, 90);
				this.graphics.lineTo(-95, 50);
				this.graphics.lineTo(-200, 50);
				this.graphics.lineTo(-200, 0);
				this.graphics.endFill();
				tf.x = -195;
				tf.y = 5;
				face.x = -10;
				face.y = 5;
				face.scaleX = -1;
//				showX = Constants.STAGE_WIDTH + 93; // 顔非表示
				showX = Constants.STAGE_WIDTH + 5;
				hideX = Constants.STAGE_WIDTH + 210;
			}
		}
		public function setFace(faceA:DisplayObject, faceB:DisplayObject):void {
			face.setFace(faceA, faceB);
		}
		public function setSide(isLeft:Boolean):void {
			if ( this.isLeft != isLeft ) {
				this.x = Constants.STAGE_WIDTH - this.x;
			}
			this.isLeft = isLeft;
			setParts();
		}
		public function setMessage(msg:String, isEmergency:Boolean = false):void {
			if ( !isShowing ) show();
			if ( isEmergency ) {
				messageCue = [msg];
				messageShow();
			}
			else messageCue.push( msg );
		}
		private function show():void {
			this.removeEventListener( Event.ENTER_FRAME, onHideEnterFrame );
			isShowing = true;
			this.addEventListener( Event.ENTER_FRAME, onShowEnterFrame);
		}
		private function onShowEnterFrame(e:Event):void {
			this.x += ( showX - this.x ) * 0.15;
			if ( Math.abs(this.x - showX) < 1 ) {
				this.removeEventListener(Event.ENTER_FRAME, onShowEnterFrame);
				this.x = showX;
				messageShow();
				face.show();
			}
		}
		private var timer:Timer = new Timer(1000, 3);
		private function messageShow():void {
			tf.text = messageCue[0];
			messageCue.shift();
			timer.reset();
			timer.start();
			face.show();
		}
		private function onTimerComplete(e:TimerEvent):void {
			if ( messageCue.length == 0 ) {
				tf.text = "";
				face.addEventListener(Event.COMPLETE, onFaceHideComplete);
				face.hide();
//				hide();
			} else {
				messageShow();
			}
		}
		private function onFaceHideComplete(e:Event):void {
			hide();
		}
		private function hide():void {
			isShowing = false;
			this.addEventListener( Event.ENTER_FRAME, onHideEnterFrame) ;
		}
		private function onHideEnterFrame(e:Event):void {
			this.x += ( hideX - this.x) * 0.15;
			if ( Math.abs(this.x - hideX) < 1 ) {
				this.removeEventListener( Event.ENTER_FRAME, onHideEnterFrame  );
				this.x = hideX;
			}
		}
	}
	
	// 攻撃用ワード表示
	class AttackQuestion extends Sprite {
		protected var tf:TextField = new TextField();
		protected var word:String = "";
		protected var jWord:Array;
		public var isJapanese:Boolean;
		protected var missile:Sprite = new Sprite();
		protected var angle:Number = 0;
		public function AttackQuestion() {
			missile.graphics.lineStyle(0, 0x00FF00);
			missile.graphics.moveTo(15, 0);
			missile.graphics.lineTo(0, 5);
			missile.graphics.lineTo(0, -5);
			missile.graphics.lineTo(15, 0);
			tf.defaultTextFormat = new TextFormat(TextFieldUtil.getFont(), 14, 0xFFFFFF);
			tf.autoSize = "left";
			this.addChild( missile );
			this.addChild( tf );
			tf.x = 17;
			tf.y = -11;
			do {
				isJapanese = Score.isJapanese();
				if ( isJapanese ) {
					jWord = Words.getJRandom();
					//word = jWord[0]; // 漢字
					word = jWord[1]; // ひらがな
					//word = Roma.getRomaToType(jWord[1]).toLowerCase(); // ローマ字
				} else {
					word = Words.getRandom();
				}
				tf.text = HandicapUtil.getHandicapWord(word);
			} while( tf.text.length > 26 ) // 最大26文字
			this.mouseChildren = false;
		}
		// 現在有効なワードを明るくする
		public function setBright():void {
			missile.graphics.beginFill(0x88FF88);
			missile.graphics.moveTo(15, 0);
			missile.graphics.lineTo(0, 5);
			missile.graphics.lineTo(0, -5);
			missile.graphics.lineTo(15, 0);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}
		protected function onEnterFrame(e:Event):void {
			angle+=8.5;
			missile.rotationX = angle;
		}
		// このワードのストリング値を返す
		public function getText():String {
			return word;
		}
	}
	
	// 攻撃用ユーザーインターフェース
	class AttackUI extends Sprite {
		protected var input:TextField = new TextField();
		protected var questionNum:int = 3;
		protected var questionList:Array = [];
		public function AttackUI() {
			TextFieldUtil.setupBorder(input);
			input.scaleY = 1.25;
			input.scaleX = 1.25;
			input.width = 180 / 1.25;
			input.height = 18;
			input.type = "input";
			
			input.restrict = "a-z,.'\\-"; // スペースは見えなくする
			input.y = 40;
			this.addChild( input );
			
			input.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			input.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
		}
		protected var addToType:int = 0;
		public function setup():void {
			for ( var i:int = 0; i < questionNum; i++ ) {
				questionList.push(new AttackQuestion());
			}
			for ( i = 0; i < questionNum; i++ ) {
				addChild( questionList[i] );
			}
			for ( i = 1; i < questionNum; i++ ) {
				questionList[i].y = questionList[i-1].y -13;
			}
			
			questionList[0].setBright();
			setFocus();
			this.addEventListener( Event.ENTER_FRAME, onEnterFrame);
		}
		public function reset():void {
			this.removeEventListener( Event.ENTER_FRAME, onEnterFrame);
			while ( questionList.length ) {
				removeChild(questionList[questionList.length-1]);
				questionList.pop();
			}
			input.text = "";
			addToType = 0;
		}
		// 入力部分にフォーカスをあてる
		public function setFocus():void {
			if ( this.stage != null ) {
				stage.focus = input;
				input.setSelection(input.text.length, input.text.length);
				if ( Capabilities.hasIME ) {
					try {
						IME.enabled = false;
					} catch(e:*){}
				}
			}
		}
		// 
		protected function onEnterFrame(e: Event):void {
			if ( questionList[0].y < 28 ) {
				for ( var i:int = 0; i < questionNum; i++ )
					questionList[i].y ++;
			}
		}
		protected var beforeIMEText:String = "";
		protected function onKeyUp(e:KeyboardEvent):void {
			if ( beforeIMEText != "" ) input.text = beforeIMEText;
			if ( textClear ) {
				input.text = "";
				textClear = false;
			}
		}
		protected var textClear:Boolean = false;
		protected function onKeyDown(e:KeyboardEvent):void {
			if ( e.keyCode == 229 ) {
				if ( Capabilities.hasIME ) {
					try {
						IME.enabled = false;
					} catch(e:*){}
				}
				beforeIMEText = input.text;
				return;
			} else {
				beforeIMEText = "";
			}
			if ( e.keyCode == Constants.CHAT_KEY || e.keyCode == Score.SWITCH_MODE_KEY || e.keyCode == Constants.DEFENCE_MODE_CHANGE_KEY ) return;
			if ( e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.UP ) return;
			if ( e.keyCode == Keyboard.ENTER || e.keyCode == Score.ALTER_ENTER ) {
				var word:String = HandicapUtil.getUnHandicapWord(input.text);
				var power:Number = 0;
				
				if ( input.text.length <= addToType ) {
					// 選択状態のお方でいらっしゃいますか
					if ( questionList[0].isJapanese ) {
						var jword:String = Roma.getHiragana(word); // ひらがなモード用
						if ( questionList[0].getText() == jword ) word = jword;
					}
					if ( questionList[0].getText() == word ) { // 選択ワードと一致しました
						power = 1;
						removeChild( questionList[0] );
						questionList.shift();
						questionList[0].setBright();
						var aq:AttackQuestion = new AttackQuestion();
						aq.y = questionList[questionNum-2].y - 13;
						questionList.push( aq );
						addChild(aq);
						if ( input.text.length == addToType ) {
							Score.attackCombo++;
							if ( Score.attackCombo == Constants.ATTACK_COMBO_START ) {
								dispatchEvent(new GameEvent(GameEvent.ATTACK_COMBO_START, true));
								SoundManager.ComboSound.play();
							}
						}
					} else {
						if ( Words.isExist( word ) ) {
							power = 0.5;
						} else if ( Words.isJExist( word ) ) {
							word = Roma.getHiragana( word );
							power = 0.5;
						}
					}
					if ( power == 0 ) { // 間違い確定しなければコンボ継続
//					if ( (power == 0) || (input.text.length != addToType) ) {
						if ( Score.attackCombo >= Constants.ATTACK_COMBO_START ) {
							dispatchEvent(new GameEvent(GameEvent.ATTACK_COMBO_END, true));
						}
						Score.attackCombo = 0;
					}
					if ( power > 0 ) {
						Score.correct += input.text.length;
						Score.type += addToType;
						addToType = 0;
						dispatchEvent(new GameEvent(GameEvent.ATTACK, true, false, word + "-" + power + "-" + input.text.length));
						var bonusCount:int = int(Score.getAttackBonusRate() * 0.01);
						for ( var i:int = 0; i < bonusCount; i++ )
							dispatchEvent(new GameEvent(GameEvent.ATTACK_DOUBLE, true, false, word + "-" + power + "-" + input.text.length));
						if ( (	Score.getAttackBonusRate() % 100) > (Math.random() * 100) ) 
							dispatchEvent(new GameEvent(GameEvent.ATTACK_DOUBLE, true, false, word + "-" + power + "-" + input.text.length));
					}
				}
//				input.text = "";
				textClear = true;
			} else {
				if ( e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT ) {
					e.stopPropagation();
				}
				addToType++;
			}
			
		}
	}
	class HandicapUtil {
		public static function getUnHandicapWord(text:String):String {
			return text;
/*			var temp:Array = text.split(" ");
			var flg:Boolean = true;
			for ( var i:int = 1; i < temp.length; i++ ) {
				flg = flg && (temp[0] == temp[i]);
			}
			if ( flg && (Score.handicap == temp.length) ) {
				return temp[0];
			} else {
				return "";
			}
*/
		}
		public static function getHandicapWord(text:String):String {
			return text;
/*
			var ret:String = text;
			for ( var i:int = 1; i < Score.handicap; i++ ) {
				ret += " " + text;
			}
			return ret;
*/
		}

	}
	
	class DefenceUI extends Sprite {
		protected var words1:TextField = new TextField();
		protected var focusWord:TextField = new TextField();
		public function DefenceUI() {
			this.addChild( words1 );
			this.addChild( focusWord );
			TextFieldUtil.setupBorder(focusWord);
			TextFieldUtil.setupBorder(words1);
			focusWord.selectable = words1.selectable = false;
			words1.border = false;
			words1.y = 30;
			words1.width = 180;
			words1.height = 40;
			words1.wordWrap = true;
//			words1.visible = false;
			focusWord.autoSize = "left";
			focusWord.visible = false;
		}
		public function reset():void {
			//
		}
		public function set1stText(str:String):void {
			words1.htmlText = str;
		}
		public function setTargets(array:Array):void {
			
		}
		public function setFocus(text:String):void {
			if ( text == null || text == "" ) {
				focusWord.visible = false;
				return;
			} else {
				focusWord.visible = true;
			}
			focusWord.htmlText = text;
			focusWord.x = 0.5 * (180 - focusWord.width);
		}
		public function set enable(value:Boolean):void {
			if( value ){
				this.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			}else {
				if( this.stage != null )
					this.stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			}
		}
		protected function onKeyDown(e:KeyboardEvent):void {
			dispatchEvent(new GameEvent(GameEvent.DEFENCE_TYPE, true, false, String(e.charCode)));
		}
	}
	
	class ScoreUI extends Sprite {
		protected var baseTF:TextField = new TextField();
		protected var scoreTF:TextField = new TextField();
		public function ScoreUI() {
			baseTF.defaultTextFormat = new TextFormat(TextFieldUtil.getFont(), null, 0xFFFFFF, false, null, null, null, null, null, null, null, null, 2);
			scoreTF.autoSize = "right";
			scoreTF.defaultTextFormat = new TextFormat(TextFieldUtil.getFont(), null, 0xFFFFFF, false, null, null, null, null, "right", null, null, null, 2);
			baseTF.autoSize = "left";
			
			var timer:Timer = new Timer( 1000 );
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			updateScore();
			
			baseTF.text = "タイプ数:\n攻撃コンボ:\n防御コンボ:\nスコア:\n支援:";
			this.addChild( baseTF );
			this.addChild( scoreTF );
		}
		protected function onTimer(e:TimerEvent):void {
			updateScore();
		}
		protected function updateScore():void{
			var typeStr:String = String(Score.type);
			if ( Score.type > 0 ) typeStr += ( "(" + int(100*Score.correct / Score.type) + "%)");
			scoreTF.text = typeStr + "\n" + int(Score.attackCombo) + "\n" + int(Score.defenceCombo) + "\n" + int(Score.score) + "\n";
			var attackBonusRate:Number = Score.getAttackBonusRate();
			var defenceBonusRate:Number = Score.getDefenceBonusRate();
			if ( attackBonusRate == 0 && defenceBonusRate == 0 ) {
				scoreTF.appendText( "なし" );
			} else {
				if ( attackBonusRate > 0 ) {
					scoreTF.appendText( "[DA"+ Score.getAttackBonusRate() +"%]" );
				}
				if ( defenceBonusRate > 0 ) {
					scoreTF.appendText( "[AR"+ Score.getDefenceBonusRate() +"%]" );
				}
				if ( Score.handicap > 1 ) {
					scoreTF.appendText( "(+" + int((Score.handicap-1)*100) + "%)" );
				}
			}
			scoreTF.x = 160 - scoreTF.width;
		}
		
	}
	
	class OperationUI extends Sprite {
		protected var attackerBtn:Button = new Button(90, 25, "攻撃モード");
		protected var defenderBtn:Button = new Button(90, 25, "防御モード");
		
		protected var attackUI:AttackUI = new AttackUI();
		protected var defenceUI:DefenceUI = new DefenceUI();
		protected var scoreUI:ScoreUI = new ScoreUI();
		
		protected var dammyTF:TextField;
		
		protected var playMode:String;
		public function OperationUI(dammyTF:TextField) {
			this.dammyTF = dammyTF;
			this.addChild( attackerBtn );
			this.addChild( defenderBtn );
			this.addChild( attackUI );
			this.addChild( defenceUI );
			this.addChild( scoreUI );
			
			attackUI.visible = defenceUI.visible = defenceUI.enable = false;
			attackerBtn.x = 10;
			attackerBtn.y = 15;
			defenderBtn.x = 10;
			defenderBtn.y = 50;
			attackUI.x = 110;
			attackUI.y = 15;
			defenceUI.x = 110;
			defenceUI.y = 10;
			scoreUI.x = 300;
			scoreUI.y = 10;
			attackerBtn.addEventListener(MouseEvent.CLICK, onAttackerClick);
			defenderBtn.addEventListener(MouseEvent.CLICK, onDefenderClick);
		}
		public function setDefenceFocus(text:String):void {
			defenceUI.setFocus(text);
		}
		public function setDefenceText(texts:Array):void {
			defenceUI.set1stText(texts.join("\n"));
		}
		public function getPlayMode():String {
			return playMode;
		}
		public function setup():void {
			attackUI.setup();
		}
		public function reset():void {
			attackUI.reset();
			defenceUI.reset();
		}
		protected function tempDisabled():void {
			this.mouseChildren = false;
		}
		public function switchMode():void {
			if ( playMode == Constants.PLAY_MODE_ATTACKER ) {
				SoundManager.ClickSound.play();
				dispatchEvent( new GameEvent(GameEvent.MODE_DEFENCE, true) );
			} else if ( playMode == Constants.PLAY_MODE_DEFENDER ) {
				SoundManager.ClickSound.play();
				dispatchEvent( new GameEvent(GameEvent.MODE_ATTACK, true) );
			}
		}
		// 基本的にmessage経由で呼び出す
		public function setMode(playMode:String):void {
			this.playMode = playMode;
			if ( playMode == Constants.PLAY_MODE_ATTACKER ) {
				attackerBtn.selected = true;
				defenderBtn.selected = false;
				attackUI.visible = true;
				defenceUI.visible = false;
				defenceUI.enable = false;
				setFocus();
			} else if ( playMode == Constants.PLAY_MODE_DEFENDER ) {
				attackerBtn.selected = false;
				defenderBtn.selected = true;
				attackUI.visible = false;
				defenceUI.visible = true;
				defenceUI.enable = true;
			} else if ( playMode == "" ) {
				attackerBtn.selected = false;
				defenderBtn.selected = false;
				attackUI.visible = false;
				defenceUI.visible = false;
				defenceUI.enable = false;
			}
		}
		public function setFocus():void {
			if ( this.stage != null ) {
				stage.focus = dammyTF;
			}
			switch( playMode ) {
				case Constants.PLAY_MODE_ATTACKER:
					attackUI.setFocus();
					break;
				case Constants.PLAY_MODE_DEFENDER:
					break;
			}
		}
		protected function onAttackerClick(e:MouseEvent):void {
			if( !attackerBtn.selected ){
				attackerBtn.selected = defenderBtn.selected = false;
				dispatchEvent( new GameEvent(GameEvent.MODE_ATTACK, true) );
			}
		}
		protected function onDefenderClick(e:MouseEvent):void {
			if( !defenderBtn.selected ){
				attackerBtn.selected = defenderBtn.selected = false;
				dispatchEvent( new GameEvent(GameEvent.MODE_DEFENCE, true) );
			}
		}
	}
	
	class Battery extends Sprite {
		protected var base:Sprite = new Sprite();
		protected var cannonBarrel:Sprite = new Sprite();
		protected var attackBase:Sprite = new Sprite();
		protected var tf:TextField = new TextField();
		protected var color:int;
		protected var baseColor:int;
		protected var attackComboEffect:Sprite = new Sprite();
		protected var defenceComboEffect:Sprite = new Sprite();
		public var focusList:Array = [];
		public function Battery(isMySide:Boolean, baseLevel:int, color:int, baseColor:int) {
			draw(baseLevel, color, baseColor);
			this.addChild( attackBase );
			this.addChild( base );
			base.addChild( cannonBarrel );
			this.addChild( tf );
			tf.autoSize = "left";
			tf.defaultTextFormat = new TextFormat(TextFieldUtil.getFont(), null, 0xFFFFFF);
			setSide(isMySide);
			attackComboEffect.graphics.lineStyle(0, 0xFF0000);
			attackComboEffect.graphics.beginFill(0xFF8888, 0.5);
			attackComboEffect.graphics.drawCircle(0, 0, 50);
			attackComboEffect.alpha = 1.0;  attackComboEffect.scaleX = attackComboEffect.scaleY = 0;
			defenceComboEffect.graphics.lineStyle(0, 0x0000FF);
			defenceComboEffect.graphics.beginFill(0x8888FF, 0.5);
			defenceComboEffect.graphics.drawEllipse(-70, -10, 140, 20);
			defenceComboEffect.alpha = 1.0;  defenceComboEffect.scaleX = defenceComboEffect.scaleY = 0;
			defenceComboEffect.y = -20;
			base.addChild( defenceComboEffect );
			attackBase.addChild( attackComboEffect );
			attackComboEffect.visible = defenceComboEffect.visible = false;
			this.mouseEnabled = this.mouseChildren = false;
		}
		public function setSide(isMySide:Boolean):void {
			if( isMySide ){
				tf.y = 13;
				base.rotation = attackBase.rotation = 0;
				defenceComboEffect.rotation = 0;
				base.y = 0;
				attackBase.y = 0;
			} else {
				tf.y = -Constants.BATTERY_DEFAULT_Y;
				base.rotation = attackBase.rotation = 180;
				defenceComboEffect.rotation = 180;
				base.y = tf.y + 16 + Constants.BATTERY_DEFAULT_Y;
				attackBase.y = tf.y + 16 + Constants.BATTERY_DEFAULT_Y;
			}
		}
		protected function onEnterFrame(e:Event):void {
			if ( attackComboEffect.visible ) {
				attackComboEffect.alpha *= 0.88;
				attackComboEffect.scaleX += (1 - attackComboEffect.scaleX) * 0.05;
				attackComboEffect.scaleY += (1 - attackComboEffect.scaleY) * 0.05;
				if ( attackComboEffect.alpha <= 0.1 ) {
					attackComboEffect.alpha = 2.0;  attackComboEffect.scaleX = attackComboEffect.scaleY = 0;
				}
			}
			if ( defenceComboEffect.visible ) {
				defenceComboEffect.alpha *= 0.88;
				defenceComboEffect.scaleX += (1 - defenceComboEffect.scaleX) * 0.05;
				defenceComboEffect.scaleY += (1 - defenceComboEffect.scaleY) * 0.05;
				if ( defenceComboEffect.alpha <= 0.1 ) {
					defenceComboEffect.alpha = 2.0;  defenceComboEffect.scaleX = defenceComboEffect.scaleY = 0;
				}
			}
		}
		public function updateCombo(name:String, isStart:Boolean):void {
			switch ( name ) {
				case "attackCombo":
					attackComboEffect.visible = isStart;
					break;
				case "defenceCombo":
					defenceComboEffect.visible = isStart;
					break;
			}
			if ( isStart ) {
				this.addEventListener( Event.ENTER_FRAME, onEnterFrame, false, 0, true );
			}
		}
		public function setAngle(angle:Number):void {
			cannonBarrel.rotation = angle;
		}
		public function setMode(playMode:String):void {
			if ( playMode == Constants.PLAY_MODE_ATTACKER ) {
				base.visible = false;
				attackBase.visible = true;
			} else {
				attackBase.visible = false;
				base.visible = true;
			}
		}
		public function setName(name:String):void {
			tf.text = name;
			tf.x = -0.5 * tf.width;
		}
		public function draw(baseLevel:int = 0, color:int = 0x999999, baseColor:int = 0x999999):void {
			attackBase.graphics.clear();
			base.graphics.clear();
			cannonBarrel.graphics.clear();
//			switch( baseLevel ) {
//				case Constants.BASE_LEVEL_0:
//				default:
					attackBase.graphics.lineStyle(0, 0xFFFFFF, 0.5);
					attackBase.graphics.beginFill(color);
					attackBase.graphics.moveTo(0, -8);
					attackBase.graphics.lineTo(10, 10);
					attackBase.graphics.lineTo( -10, 10);
					attackBase.graphics.endFill();
					attackBase.graphics.beginFill(baseColor);
					attackBase.graphics.moveTo(0, -4);
					attackBase.graphics.lineTo(7, 8);
					attackBase.graphics.lineTo( -7, 8);
					attackBase.graphics.endFill();
					
					base.graphics.lineStyle(1, 0xFFFFFF, 0.5);
					base.graphics.beginFill(color);
					base.graphics.drawCircle(0, 0, 10);
					base.graphics.beginFill(baseColor);
					base.graphics.drawCircle(0, 0, 7);
					cannonBarrel.graphics.lineStyle(1, 0xFFFFFF, 0.5);
					cannonBarrel.graphics.beginFill(baseColor);
					cannonBarrel.graphics.drawRect( -2, -15, 4, 16 );
					cannonBarrel.graphics.beginFill(color);
					cannonBarrel.graphics.drawRect( -3, 0, 6, 3);
//					break;
//			}
		}
		public function attackMotion():void {
			attackBase.addChild( new AttackMotion() );
		}
		public function reflectMotion():void {
			base.addChild( new ReflectMotion() );
		}
	}
	
	class AttackMotion extends Sprite {
		public function AttackMotion() {
			this.mouseChildren = this.mouseEnabled = false;
			this.graphics.lineStyle(0, 0xFFFF00);
			this.graphics.drawCircle(0, 0, 10);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		protected function onEnterFrame(e:Event):void {
			this.scaleX *= 1.1;
			this.scaleY *= 1.1;
			this.alpha *= 0.9;
			if ( this.alpha < 0.1 ) {
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				if ( this.parent != null ) this.parent.removeChild( this );
			}
		}
	}
	class ReflectMotion extends Sprite {
		public function ReflectMotion() {
			this.mouseChildren = this.mouseEnabled = false;
			this.graphics.lineStyle(0, 0x00FF00);
			this.graphics.beginFill(0, 0x88FF88);
			this.graphics.drawEllipse(-8, 0, 16, 3);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.y = -20;
		}
		protected function onEnterFrame(e:Event):void {
			this.scaleX *= 1.1;
			this.alpha *= 0.92;
			if ( this.alpha < 0.1 ) {
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				if ( this.parent != null ) this.parent.removeChild( this );
			}
		}
	}
	
	class DamageMotion extends Sprite {
		public function DamageMotion(vx:Number, vy:Number) {
			this.mouseChildren = this.mouseEnabled = false;
			this.graphics.beginFill(0x00FF00 | (int(Math.random()*80)<<24) | (int(Math.random()*80)));
			this.graphics.drawCircle( -60*vx + -3 + Math.random() * 6, -60*vy + -3 + Math.random() * 6, 0.8);
			this.graphics.drawCircle( -60*vx + -3 + Math.random() * 6, -60*vy + -3 + Math.random() * 6, 0.8);
			this.graphics.drawCircle( -60*vx + -3 + Math.random() * 6, -60*vy + -3 + Math.random() * 6, 0.8);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		protected function onEnterFrame(e:Event):void {
			this.scaleX *= 1.1;
			this.scaleY *= 1.1;
			this.alpha *= 0.9;
			if ( this.alpha < 0.1 ) {
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				if ( this.parent != null ) this.parent.removeChild( this );
			}
		}
	}
	
	// 本拠地のダメージモーション
	class HitMotion extends Sprite {
		public function HitMotion() {
			this.mouseChildren = this.mouseEnabled = false;
			this.graphics.beginFill(0xFF0000);
			this.graphics.drawRect(0, -1, Constants.STAGE_WIDTH, 2);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		protected function onEnterFrame(e:Event):void {
			this.scaleY = this.scaleY + 0.3;
			this.alpha *= 0.9;
			if ( this.alpha < 0.1 ) {
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				if ( this.parent != null ) this.parent.removeChild( this );
			}
		}
	}
	
	// CPUクライアント
	class CPUClient extends Sprite implements IClient {
		public var self:IClient;
		private var attr:Object = { };
		public var missiles:Array = [];
		private var _word:String;
		public var attackid:int;
		public var focus:Missile;
		public function CPUClient() {
			
		}
		public function start():void {
			enable();
		}
		protected var timer:Timer;
		public function enable():void {
			attackid = 0;
			typedLength = 0;
			defenceLength = 0;
			_word = Words.getJRandom()[1];
			timer = new Timer(1000 / Math.max(0.5, Score.cpuLV));
			missiles = [];
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		public function disable():void {
			timer.stop();
		}
		protected var typedLength:int = 0;
		protected var defenceLength:int = 0;
		protected function onTimer(e:TimerEvent):void {
			for ( var i:int = 0; i < missiles.length; i++ ) {
				if ( missiles[i].y > (0.5*Constants.DISTANCE) && missiles[i].isMySide && (missiles[i].wordLength > 0)) {
					if ( focus == null ) focus = missiles[i];
					else if ( focus.y < missiles[i].y ) focus = missiles[i];
				}
			}
			if ( focus != null ) {
				focus.wordLength--;
				if ( focus.wordLength > 0 ) {
					dispatchEvent(new GameEvent(GameEvent.SHOOT, false, false, "0"));
				} else {
					dispatchEvent(new GameEvent(GameEvent.SHOOT, false, false, "1"));
					focus = null;
				}
			} else {
				
				typedLength++;
				if ( Roma.getRomaToType(_word).length == typedLength ) {
					dispatchEvent(new GameEvent(GameEvent.ATTACK, false, false, _word));
					_word = Words.getJRandom()[1];
					attackid++;
					typedLength = 0;
				}
			}
		}
                public function ban(duration:int, reason:String = null):void{}
                public function isAdmin():Boolean{return false;}
                public function logoff(password:String = null):void{}
                public function getUserID():String{return null}
                public function getPassword():String{return null}
                public function getReactor():Reactor{return null}
                public function login(userID:String, password:String):void {}
                public function changePassword(newPassword:String, oldPassword:String = null):void{}
                public function getConnectTime () : Number {return 0;}
		public function getConnectionState () : int { return 0; }
		public function IClient ():void{}
		public function isSelf () : Boolean { return false; }
		public function getAttribute (attrName:String, attrScope:String = null ) : String{return attr[attrName]}
		public function getRoomIDs () : Array { return []; }
		public function getPing () : int { return 0; }
		public function isInRoom (roomID:String) : Boolean { return false; }
		public function setClientClass (scope:String, clientClass:Class, ...rest) : void{}
		public function getAttributes () : Object{ return {}}
		public function deleteAttribute (attrName:String, attrScope:String = null) : void{}
		public function getConnection () : Reactor { return null; }
		public function getClientID () : String{ return "0"}
		public function getIP () : String{ return ""}
		public function sendMessage (messageName:String, ...rest) : void { }
		public function getClientManager () : ClientManager {return null;}
		public function getTimeOnline () : Number { return 0; }
		public function getOccupiedRoomIDs () : Array { return []; }
		public function getObservedRoomIDs () : Array { return [];}
		public function getAttributesByScope (scope:String = null) : Object {return null;}
		public function isObservingRoom (roomID:String) : Boolean {return false;}
		public function kick () : void {return;}
		public function getAccount () : UserAccount { return null;}
//		public function setAttribute (attrName:String, attrValue:String, attrScope:String = null, isShared:Boolean = true, isUnique:Boolean = false, evaluate:Boolean = false) : void { attr[attrName] = attrValue; ;}
		public function setAttribute (attrName:String, attrValue:String, attrScope:String = null, isShared:Boolean = true, evaluate:Boolean = false) : void { attr[attrName] = attrValue; ;}
		public function stopObserving () : void {return;}
		public function observe () : void {return;}
	}
	
	// ゲーム全体・メッセージ制御
	class GameController extends EventDispatcher {
		protected var gameRoom:Room;
		protected var lobbyRoom:Room;
		protected var reactor:Reactor;
		
		protected var _lobbyUserNum:int;
		
		protected var infoUI:InfoUI;
		protected var gameStage:GameStage;
		protected var missileID:int = 0;
		
		protected var blueNum:int;
		protected var redNum:int;
		
		protected var cpu:CPUClient = new CPUClient();

		
		protected function clientStatusInit( selfClient:IClient ):void {
			LocalData.remove(Constants.LD_FIELD, Constants.USER_BATTERY_BASE_LEVEL);
			if ( LocalData.read(Constants.LD_FIELD, Constants.USER_NAME) == null ) {
				LocalData.write(Constants.LD_FIELD, Constants.USER_NAME, "Guest" + selfClient.getClientID());
			}
			
			var userName:String = String(LocalData.read(Constants.LD_FIELD, Constants.USER_NAME));
			if( userName != null ) selfClient.setAttribute(Constants.USER_NAME, userName);
			selfClient.setAttribute("status", Constants.STATUS_CHATING);
			selfClient.setAttribute(Constants.HANDICAP, String(Score.handicap));
			cpu.self = selfClient;
			
			// 砲台の形とか色とか
			var baseLevel:String = (LocalData.read(Constants.LD_FIELD, Constants.USER_BATTERY_BASE_LEVEL))?
				String(LocalData.read(Constants.LD_FIELD, Constants.USER_BATTERY_BASE_LEVEL)):
				String(Constants.DEFAULT_USER_BATTERY_BASE_LEVEL);
			selfClient.setAttribute(Constants.USER_BATTERY_BASE_LEVEL, baseLevel);
			var color:String = (LocalData.read(Constants.LD_FIELD, Constants.USER_BATTERY_COLOR))?
				String(LocalData.read(Constants.LD_FIELD, Constants.USER_BATTERY_COLOR)):
				String(Constants.DEFAULT_USER_BATTERY_COLOR);
			selfClient.setAttribute(Constants.USER_BATTERY_COLOR, color);
			var baseColor:String = (LocalData.read(Constants.LD_FIELD, Constants.USER_BATTERY_BASE_COLOR))?
				String(LocalData.read(Constants.LD_FIELD, Constants.USER_BATTERY_BASE_COLOR)):
				String(Constants.DEFAULT_USER_BATTERY_BASE_COLOR);
			selfClient.setAttribute(Constants.USER_BATTERY_BASE_COLOR, baseColor);
			
		}
		// コンストラクタ
		public function GameController(reactor:Reactor, infoUI:InfoUI, gameStage:GameStage) {
			this.reactor = reactor;
			this.infoUI = infoUI;
			this.gameStage = gameStage;
			
			clientStatusInit( reactor.self() );
			
			
			
			reactor.getMessageManager().addMessageListener(Constants.ATTACK_LOG, attackLogAction);
			
			// ゲームのメッセージ類
//			gameRoom = reactor.getRoomManager().createRoom(Score.myGameRoom);
//			setupGameRoom();

			lobbyRoom = reactor.getRoomManager().createRoom(Constants.LOBBY_ROOM);
			lobbyRoom.addEventListener(AttributeEvent.UPDATE, onLobbyUpdateRoomAttribute);
			lobbyRoom.addEventListener(RoomEvent.UPDATE_CLIENT_ATTRIBUTE, onLobbyUpdateClientAttribute);
			lobbyRoom.addEventListener(RoomEvent.OCCUPANT_COUNT, onLobbyClientCount);
			
			// 情報画面からのイベントを受け取る
			infoUI.addEventListener(GameEvent.JOIN_BLUE, onJoinBlue);
			infoUI.addEventListener(GameEvent.JOIN_RED, onJoinRed);
			infoUI.addEventListener(GameEvent.JOIN_SOLO, onJoinSolo );
			infoUI.addEventListener(GameEvent.OBSERVE_BLUE, onObserveBlue );
			infoUI.addEventListener(GameEvent.OBSERVE_RED, onObserveRed );
			infoUI.addEventListener(GameEvent.COLOR_SELECT, onColorSelect);
			infoUI.addEventListener(GameEvent.HANDICAP_SELECT, onHandicapSelect); // ハンデかわりました
			infoUI.addEventListener(GameEvent.NAME_CHANGE, onNameChange); // 名前かわりました
			
			// ゲーム画面からのイベントを受け取る
			gameStage.addEventListener(GameEvent.MOVE_BATTERY, onMoveBattery);
			gameStage.addEventListener(GameEvent.MODE_ATTACK, onModeAttack);
			gameStage.addEventListener(GameEvent.MODE_DEFENCE, onModeDefence);
			gameStage.addEventListener(GameEvent.ATTACK, onAttack); //　通常攻撃
			gameStage.addEventListener(GameEvent.ATTACK_DOUBLE, onAttackDouble); // ダブルアタック！
			gameStage.addEventListener(GameEvent.ATTACK_REFLECT, onAttackReflect); // オートリフレクション！
			gameStage.addEventListener(GameEvent.HIT, onHit); // 敵陣到達！
			
			gameStage.addEventListener(GameEvent.ATTACK_COMBO_START, onAttackComboStart);
			gameStage.addEventListener(GameEvent.ATTACK_COMBO_END, onAttackComboEnd);
			gameStage.addEventListener(GameEvent.DEFENCE_COMBO_START, onDefefnceComboStart);
			gameStage.addEventListener(GameEvent.DEFENCE_COMBO_END, onDeffenceComboEnd);
			
			gameStage.addEventListener(GameEvent.SHOOT, onShoot); // 撃ってます
			gameStage.addEventListener(GameEvent.MISSILE_DESTROY, onMissileDestroy); // ミサイルいっこ壊した
			gameStage.addEventListener(GameEvent.CHAT, onChat); // チームチャット
			gameStage.addEventListener(GameEvent.END_GAME, endGame); // エンディング描画完了
			
			
		}
		protected function onAttackComboStart(e:GameEvent):void {
			gameStage.setInfoMsg("攻撃支援開始！\n自動的にミサイルを追加します。");
			reactor.self().setAttribute("attackCombo", "true", Score.myGameRoom);
		}
		protected function onAttackComboEnd(e:GameEvent):void {
			gameStage.setInfoMsg("攻撃支援を終了します。");
			reactor.self().setAttribute("attackCombo", "false", Score.myGameRoom);
		}
		protected function onDefefnceComboStart(e:GameEvent):void {
			gameStage.setInfoMsg("防御支援開始！\n自動反撃します。");
			reactor.self().setAttribute("defenceCombo", "true", Score.myGameRoom);
		}
		protected function onDeffenceComboEnd(e:GameEvent):void {
			gameStage.setInfoMsg("防御支援を終了します。");
			reactor.self().setAttribute("defenceCombo", "false", Score.myGameRoom);
		}
		protected function onNameChange(e:GameEvent):void {
			if( e.data != null ) reactor.self().setAttribute(Constants.USER_NAME, e.data);
		}
		protected function onHandicapSelect(e:GameEvent):void {
			Score.handicap = Number(e.data);
			reactor.self().setAttribute(Constants.HANDICAP, e.data);
			infoUI.updateHandicap();
		}
		protected function onColorSelect(e:GameEvent):void {
			var temp:Array = e.data.split("-");
			var colorType:String = temp[0];
			var color:String = temp[2];
			if ( colorType == Constants.USER_BATTERY_BASE_COLOR || colorType == Constants.USER_BATTERY_COLOR ) {
				reactor.self().setAttribute(colorType, color);
			}
		}
		protected function setupGameRoom(startTime:String = "0"):void {
//			trace(" Score.isobserve", Score.isObserve );
			addListeners();
			if ( Score.isObserve ) {
				gameStage.enable = true;
				reactor.self().setAttribute("status", Constants.STATUS_OBSERVING);
				return;
			}
			changeHandicap();
			
			var nowTime:Number = ServerClockUtil.getTime();
			var waitTime:Number = Number(startTime) - nowTime;
			if ( waitTime > 0 ) {
				var timer:Timer = new Timer(waitTime, 1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onStart);
				gameStage.setTimer(Number(startTime));
				timer.start();
			} else {
				reactor.self().setAttribute("status", Constants.STATUS_PLAYING);
				gameStage.enable = true;
			}
		}
		protected function onStart(e:TimerEvent):void {
			e.target.removeEventListener(TimerEvent.TIMER_COMPLETE, onStart);
			gameRoom.setAttribute("status", Constants.STATUS_PLAYING); // 複数人でセットしてしまっている
			reactor.self().setAttribute("status", Constants.STATUS_PLAYING);
			if (Score.isSolo) gameStage.cpu = cpu;
			else gameStage.cpu = null;
			
			gameStage.enable = true;
		}
		protected function addListeners():void{
//			trace( "add!!!", gameRoom.getRoomID());
			gameRoom.addMessageListener(Constants.ATTACK, attackAction);
			gameRoom.addMessageListener(Constants.ATTACK_REFLECT, attackReflectAction);
			gameRoom.addMessageListener(Constants.HIT, hitAction);
			gameRoom.addMessageListener(Constants.SEND_ME_LOG, onAddClient);
			
			gameRoom.addEventListener(AttributeEvent.UPDATE, onGameUpdateRoomAttribute);
			gameRoom.addEventListener(RoomEvent.UPDATE_CLIENT_ATTRIBUTE, onGameUpdateClientAttribute);
			
			gameRoom.addEventListener(RoomEvent.REMOVE_OCCUPANT, onLeaveClient);
			
			gameRoom.addMessageListener(Constants.SHOOT, shootAction);
			gameRoom.addMessageListener(Constants.DESTROY, destroyAction);
			gameRoom.addMessageListener(Constants.GAME_CHAT, gameChatAction);
		}
		protected function removeListeners():void {
//			trace( "remove!!!", gameRoom.getRoomID());
			gameRoom.removeMessageListener(Constants.ATTACK, attackAction);
			gameRoom.removeMessageListener(Constants.ATTACK_REFLECT, attackReflectAction);
			gameRoom.removeMessageListener(Constants.HIT, hitAction);
			gameRoom.removeMessageListener(Constants.SEND_ME_LOG, onAddClient);
			
			gameRoom.removeEventListener(AttributeEvent.UPDATE, onGameUpdateRoomAttribute);
			gameRoom.removeEventListener(RoomEvent.UPDATE_CLIENT_ATTRIBUTE, onGameUpdateClientAttribute);
			
			gameRoom.removeEventListener(RoomEvent.REMOVE_OCCUPANT, onLeaveClient);
			
			gameRoom.removeMessageListener(Constants.SHOOT, shootAction);
			gameRoom.removeMessageListener(Constants.DESTROY, destroyAction);
			gameRoom.removeMessageListener(Constants.GAME_CHAT, gameChatAction);
		}
		protected function gameChatAction(fromClient:IClient, msg:String):void {
			gameStage.putChatMessage(ClientUtil.getUserName(fromClient) + "> " + String(decodeURI(msg)));
		}
		protected function onChat(e:GameEvent):void {
			var filter:AttributeFilter = new AttributeFilter();
			var myTeam:String = ClientUtil.getTeam(reactor.self());
			filter.addComparison( new AttributeComparison("team", myTeam, CompareType.EQUAL) );
			gameRoom.sendMessage(Constants.GAME_CHAT, true, filter, String(encodeURI(e.data)));
		}
		protected function endGame(e:GameEvent):void { // ゲーム終了。部屋から出る。
//			trace("endGame");
			startInfo();
			
			var self:IClient = reactor.self();
			Score.playMode = ClientUtil.getPlayMode(self);
			
			if ( Score.isObserve ) {
				if( gameRoom.clientIsObservingRoom() ){
					gameRoom.stopObserving();
					removeListeners();
				}
				gameStage.clearAll();
			} else {
				gameRoom.leave();
				gameStage.clearAll();
				gameStage.removeMissilesOf(reactor.self());
			}
			reactor.self().setAttribute("status", Constants.STATUS_CHATING);
			reactor.self().setAttribute("team", Constants.TEAM_NONE);
			reactor.self().setAttribute("isSolo", "");
			reactor.self().setAttribute(Constants.BATTERY_X, "-1", Score.myGameRoom);
		}
		protected function shootAction(fromClient:IClient, clientId:int, missileId:int, shootTime:Number, bulletSpeed:Number, isDestroy:String):void {
			gameStage.addBullet(fromClient, reactor.getClientManager().getClient(String(clientId)), missileId, shootTime, bulletSpeed, isMySide(fromClient), (isDestroy == "true"));
		}
		protected function destroyAction(fromClient:IClient, clientId:String, missileId:int):void {
			if ( fromClient.isSelf() ) {
				Score.defence++;
			}
			gameStage.destroy(fromClient, clientId, missileId);
		}
		protected function onShoot(e:GameEvent):void {
			var sch:SoundChannel = SoundManager.TypeSound.play();
			if( sch != null ) sch.soundTransform = new SoundTransform(0.5);
			var arr:Array = e.data.split("-");
			var clientId:int = arr[0];
			var missileId:int = arr[1];
			var isDestroy:Boolean = arr[2] == "1";
			gameRoom.sendMessage(Constants.SHOOT, true, null, clientId, missileId, ServerClockUtil.getTime(), Constants.BULLET_SPEED, isDestroy);
			LogAnalyzer.addDefenceLog(1);
		}
		protected function onMissileDestroy(e:GameEvent):void {
			var arr:Array = e.data.split("-");
			var clientId:int = arr[0];
			var missileId:int = arr[1];
			gameRoom.sendMessage(Constants.DESTROY, true, null, clientId, missileId);
		}
		protected function attackLogAction(fromClient:IClient, text:String, id:int, power:Number, attackTime:Number, arriveTime:Number, xpos:Number):void {
			gameStage.addAttackLog(fromClient, text, isMySide(fromClient), id, power, attackTime, arriveTime, xpos);
		}
		protected function onAddClient(fromClient:IClient):void {
			gameStage.sendLogTo(fromClient);
			changeHandicap();
		}
		protected function onLeaveClient(e:RoomEvent):void {
			gameStage.removeMissilesOf(e.getClient());
			changeHandicap();
		}
		protected function hitAction(fromClient:IClient, x:String, damage:String):void {
			if ( gameStage.cpu != null && damage == "cpu" ) {
				fromClient = gameStage.cpu;
				damage = "1";
			}
			SoundManager.HitSound.play();
			var score:Number = 100;
			var attName:String = "";
			if ( ClientUtil.isTeamBlue(fromClient) ) {
				score *= redNum;
				attName = "bluePoint";
			} else if ( ClientUtil.isTeamRed(fromClient) ) {
				score *= blueNum;
				attName = "redPoint";
			}
			if ( isMySide( fromClient ) ) {
				gameStage.hitMotion(true, x);
				Score.score += score;
			} else {
				gameStage.hitMotion(false, x);
				Score.score -= score;
			}
			if ( fromClient.isSelf() ) {
				Score.hit++;
				gameRoom.setAttribute(attName, "%v+" + Number(damage), true, false, true);
			} else if ( ClientUtil.isCPU( fromClient ) ) {
				gameRoom.setAttribute(attName, "%v+" + Number(damage), true, false, true);
			}
			setDamage();
		}
		protected function setDamage():void {
			var bluePoint:int = int(gameRoom.getAttribute("bluePoint"));
			var redPoint:int = int(gameRoom.getAttribute("redPoint"));
			if ( Score.myGameTeam == Constants.TEAM_BLUE ) {
				gameStage.setDamage( redPoint, bluePoint );
			} else {
				gameStage.setDamage( bluePoint, redPoint );
			}
		}
		protected function onHit(e:GameEvent):void {
			var temp:Array = e.data.split("-");
			var missileX:String = temp[0];
			var damage:String = temp[1];
			gameRoom.sendMessage(Constants.HIT, true, null, temp[0], temp[1]);
		}
		protected function attackAction(fromClient:IClient, msg:String, xpos:Number, arriveTime:Number, id:int, power:Number):void {
			SoundManager.AttackSound.play();
			gameStage.addAttack(fromClient, msg, isMySide(fromClient), id, power, ServerClockUtil.getTime()+arriveTime, xpos);
		}
		protected function attackReflectAction(fromClient:IClient, msg:String, xpos:Number, arriveTime:Number, id:int, power:Number):void {
			SoundManager.ReflectSound.play();
			gameStage.addAttack(fromClient, msg, isMySide(fromClient), id, power, ServerClockUtil.getTime()+arriveTime, xpos, true);
		}
		protected function onAttack(e:GameEvent):void {
//			trace( "attack!" );
			if ( !gameStage.enable ) return;
			attackHandler(e, true);
		}
		protected function onAttackDouble(e:GameEvent):void {
			attackHandler(e, false);
		}
		protected function attackHandler(e:GameEvent, logTrack:Boolean):void {
//			trace( gameRoom.getRoomID() );
			var temp:Array = e.data.split("-");
			var missileMsg:String = temp[0];
			var missilePower:String = temp[1];
			var wordlength:String = temp[2];
			Score.attack++;
			var attackLoc:Number = Constants.STAGE_WIDTH - 40 -ClientUtil.getBatteryX(reactor.self()) - 50 + Math.random() * 100;
			if ( attackLoc < 0 ) attackLoc = 50 + Math.random() * 50;
			if ( attackLoc > (Constants.STAGE_WIDTH - 80) ) attackLoc = (Constants.STAGE_WIDTH - 180) + Math.random() * 50;
			gameRoom.sendMessage(Constants.ATTACK, true, null, missileMsg, attackLoc, Constants.MISSILE_ARRIVE_TIME, missileID++, Number(missilePower));
			if( logTrack && (missilePower == "1"))LogAnalyzer.addAttackLog(int(wordlength));
		}
		protected function onAttackReflect(e:GameEvent):void {
			var temp:Array = e.data.split("-");
			var missileMsg:String = temp[0];
			var missilePower:String = temp[1];
			Score.attack++;
			var attackLoc:Number = Constants.STAGE_WIDTH - 40-ClientUtil.getBatteryX(reactor.self()) - 20 + Math.random() * 40;
			if ( attackLoc < 0 ) attackLoc = 20 + Math.random() * 20;
			if ( attackLoc > (Constants.STAGE_WIDTH - 80) ) attackLoc = (Constants.STAGE_WIDTH - 120) + Math.random() * 20;
			gameRoom.sendMessage(Constants.ATTACK_REFLECT, true, null, missileMsg, attackLoc, Constants.MISSILE_ARRIVE_TIME, missileID++, Number(missilePower));
		}
		protected function onModeAttack(e:GameEvent):void {
			reactor.self().setAttribute(Constants.PLAY_MODE, Constants.PLAY_MODE_ATTACKER, Score.myGameRoom);
		}
		protected function onModeDefence(e:GameEvent):void {
			reactor.self().setAttribute(Constants.PLAY_MODE, Constants.PLAY_MODE_DEFENDER, Score.myGameRoom);
		}
		protected function isMySide(client:IClient):Boolean {
//			return ( ClientUtil.getTeam(reactor.self()) == ClientUtil.getTeam(client) );
			return ( Score.myGameTeam == ClientUtil.getTeam(client) );
		}
		protected function onMoveBattery(e:GameEvent):void {
			reactor.self().setAttribute(Constants.BATTERY_X, String(gameStage.myBatteryMoveTo), Score.myGameRoom);
		}
		protected function onJoin(e:RoomEvent = null):void {
			SoundManager.playGameBgm();
			infoUI.fadeOut();
			onSynchronize();
		}
		protected function onObserve(e:RoomEvent = null):void {
			SoundManager.playGameBgm();
			infoUI.fadeOut();
			onSynchronize();
		}
		protected function onSynchronize(e:RoomEvent = null):void {
			gameRoom.removeEventListener(RoomEvent.JOIN, onJoin);
//			gameRoom.removeEventListener(RoomEvent.SYNCHRONIZE, onSynchronize);
			ServerClockUtil.init( reactor.getServer() );
			Score.resetCombo();
			gameRoom.sendMessage(Constants.SEND_ME_LOG);
			var self:IClient = reactor.self();
			
			// 既存のゲーム内情報を追加
			var users:Array = gameRoom.getOccupants();
			
			var teamNum:int = 1;
			for ( var i:int = 0; i < users.length; i++ ) {
				if ( !users[i].isSelf() ) {
					if ( isMySide(users[i]) ) teamNum++;
					var batteryX:Number = ClientUtil.getBatteryX(users[i]);
					if ( batteryX >= 0 ) gameStage.setBattery(users[i], Number(batteryX), isMySide(users[i]));
					var playMode:String = ClientUtil.getPlayMode(users[i]);
					if ( playMode != null ) gameStage.setPlayMode(users[i], playMode);
				}
			}
			var loc:Number = 22;
			var tempLoc:Number = 0.5 *( Constants.STAGE_WIDTH - 44 );
			while ( teamNum > 0 ) {
				loc += tempLoc * (teamNum & 1);
				tempLoc *= 0.5;
				teamNum >>= 1;
			}
			self.setAttribute(Constants.BATTERY_X, String(loc), Score.myGameRoom);
			self.setAttribute("status", Constants.STATUS_WAITING);
			gameStage.setBattery(self, loc, true);
			gameStage.setPlayMode(self, Score.playMode);
			
			if ( Score.isSolo ) {
				cpu.setAttribute(Constants.USER_NAME, "COM Lv " + Score.cpuLV );
				cpu.setAttribute(Constants.BATTERY_X, String(Constants.STAGE_WIDTH*0.5));
				cpu.setAttribute(Constants.PLAY_MODE, Constants.PLAY_MODE_ATTACKER);
				cpu.setAttribute("team", Constants.TEAM_RED);
				gameStage.setBattery(cpu, ClientUtil.getBatteryX(cpu), false);
				gameStage.setPlayMode(cpu, Constants.PLAY_MODE_ATTACKER);
			} else {
				self.setAttribute("isSolo", "false");
			}
			
			var str:String = gameRoom.getAttribute("status");
			if ( str == null ) {
				setupGameRoom(String(ServerClockUtil.getTime() + (Score.isSolo?Constants.CPU_START_WAITTIME:Constants.GAME_START_WAITTIME)));
				gameRoom.setAttribute("status", Constants.STATUS_WAITING);
				gameRoom.setAttribute("startTime", String(ServerClockUtil.getTime() + (Score.isSolo?Constants.CPU_START_WAITTIME:Constants.GAME_START_WAITTIME)));
				if( !Score.isSolo ){
					lobbyRoom.setAttribute("gameRoomStartTime", String(ServerClockUtil.getTime() + (Score.isSolo?Constants.CPU_START_WAITTIME:Constants.GAME_START_WAITTIME)), true );
				}
			} else {
				if ( str == Constants.STATUS_PLAYING ) {
					setupGameRoom();
					reactor.self().setAttribute("status", Constants.STATUS_PLAYING);
				} else if ( str == Constants.STATUS_WAITING ) {
					setupGameRoom(gameRoom.getAttribute("startTime"));
					reactor.self().setAttribute("status", Constants.STATUS_WAITING);
				}
			}
			
			setDamage();
			LogAnalyzer.reset();
		}
		protected function onObserveSynchronize(e:RoomEvent = null):void {
			gameRoom.removeEventListener(RoomEvent.OBSERVE, onObserve);
//			gameRoom.removeEventListener(RoomEvent.SYNCHRONIZE, onObserveSynchronize);
			ServerClockUtil.init( reactor.getServer() );
			gameRoom.sendMessage(Constants.SEND_ME_LOG);
			var self:IClient = reactor.self();
			
			// 既存のゲーム内情報を追加
			var users:Array = gameRoom.getOccupants();
			
			var teamNum:int = 1;
			for ( var i:int = 0; i < users.length; i++ ) {
				if ( !users[i].isSelf() ) {
					if ( isMySide(users[i]) ) teamNum++;
					var batteryX:Number = ClientUtil.getBatteryX(users[i]);
					if ( batteryX >= 0 ) gameStage.setBattery(users[i], Number(batteryX), isMySide(users[i]));
					var playMode:String = ClientUtil.getPlayMode(users[i]);
					if ( playMode != null ) gameStage.setPlayMode(users[i], playMode);
				}
			}
			
			setupGameRoom();
			setDamage();
		}
		protected function onObserveBlue(e:GameEvent):void {
			gameStage.cpu = null;
			Score.myGameTeam = Constants.TEAM_BLUE;
			Score.isObserve = true;
			Score.isSolo = false;
//			trace("observe", Score.isObserve);
			gameStage.setup(Constants.TEAM_BLUE);
			Score.myGameRoom = Constants.GAME_ROOM;
				
//			trace("observe", Score.isObserve);
			observe();
//			trace("observe", Score.isObserve);
		}
		protected function onObserveRed(e:GameEvent):void {
			gameStage.cpu = null;
			Score.myGameTeam = Constants.TEAM_RED;
			Score.isObserve = true;
			Score.isSolo = false;
//			trace("observe", Score.isObserve);
			gameStage.setup(Constants.TEAM_RED);
			Score.myGameRoom = Constants.GAME_ROOM;
				
//			trace("observe", Score.isObserve);
			observe();
//			trace("observe", Score.isObserve);
		}
		protected function onJoinBlue(e:GameEvent):void {
			gameStage.setFace(ImageManager.MikiA, ImageManager.MikiB);
			Score.isSolo = false;
			Score.isObserve = false;
			gameStage.cpu = null;
			Score.myGameTeam = Constants.TEAM_BLUE;
			reactor.self().setAttribute("team", Constants.TEAM_BLUE);
			gameStage.setup(Constants.TEAM_BLUE);
			
			Score.myGameRoom = Constants.GAME_ROOM;
			if ( Score.playMode != Constants.PLAY_MODE_ATTACKER &&  Score.playMode != Constants.PLAY_MODE_DEFENDER )
				Score.playMode = Constants.PLAY_MODE_DEFENDER;
				
			if ( !Score.isWaitingAtLobby )
			joinTeam();
		}
		protected function onJoinRed(e:GameEvent):void {
			gameStage.setFace(ImageManager.SasakoA, ImageManager.SasakoB);
			Score.isSolo = false;
			Score.isObserve = false;
			gameStage.cpu = null;
			Score.myGameTeam = Constants.TEAM_RED;
			reactor.self().setAttribute("team", Constants.TEAM_RED);
			gameStage.setup(Constants.TEAM_RED);
			
			Score.myGameRoom = Constants.GAME_ROOM;
			if ( Score.playMode != Constants.PLAY_MODE_ATTACKER &&  Score.playMode != Constants.PLAY_MODE_DEFENDER )
				Score.playMode = Constants.PLAY_MODE_ATTACKER;
			
			if ( !Score.isWaitingAtLobby )
			joinTeam();
		}
		protected function joinTeam():void {
			gameStage.startNavigation(Score.myGameTeam);
			gameRoom = reactor.getRoomManager().createRoom(Score.myGameRoom);
			gameRoom.addEventListener(RoomEvent.JOIN, onJoin);
//			gameRoom.addEventListener(RoomEvent.SYNCHRONIZE, onSynchronize);
			reactor.self().setAttribute(Constants.PLAY_MODE, Score.playMode, Score.myGameRoom);

			if ( gameRoom.clientIsInRoom() ) {
				onJoin();
				onSynchronize();
			} else {
				gameRoom.join();
			}
		}
		protected function observe():void {
			gameRoom = reactor.getRoomManager().createRoom(Score.myGameRoom);
			gameRoom.addEventListener(RoomEvent.OBSERVE, onObserve);
//			gameRoom.addEventListener(RoomEvent.SYNCHRONIZE, onObserveSynchronize);
//			reactor.self().setAttribute(Constants.PLAY_MODE, Score.playMode, Score.myGameRoom);

			gameRoom.observe();
		}
		protected function onJoinSolo(e:GameEvent):void {
			gameStage.setFace(ImageManager.MikiA, ImageManager.MikiB);
			reactor.self().setAttribute("isSolo", "true");
			reactor.self().setAttribute("team", Constants.TEAM_BLUE);
			gameStage.setup(Constants.TEAM_BLUE);
			
			Score.isSolo = true;
			Score.isObserve = false;
			Score.myGameTeam = Constants.TEAM_BLUE;
			Score.myGameRoom = Constants.CPU_ROOM_DEFAULT + "_" + reactor.self().getClientID();
			if ( Score.playMode != Constants.PLAY_MODE_ATTACKER &&  Score.playMode != Constants.PLAY_MODE_DEFENDER )
				Score.playMode = Constants.PLAY_MODE_ATTACKER;
				
			joinTeam();
		}
		public function noticeClosed():void {
			infoUI.noticeClosed();
		}
		// 情報ウィンドウ表示。ロビー入室
		public function startInfo(isReconnect:Boolean = false ):void {
//			trace("startInfo");
			var self:IClient = reactor.self();
			var typeNums:Array = LogAnalyzer.analyze();
			self.setAttribute(Constants.ATTACK_POWER, String(Score.attackPower));
			self.setAttribute(Constants.DEFENCE_POWER, String(Score.defencePower));
			if( Score.myGameRoom ){
				self.setAttribute("attackCombo", "false", Score.myGameRoom);
				self.setAttribute("defenceCombo", "false", Score.myGameRoom);
			}
			SoundManager.stopGameBgm();
			if ( !lobbyRoom.clientIsInRoom() ) {
				lobbyRoom.join();
				infoUI.setChatRoom(lobbyRoom, isReconnect);
			}
			if ( typeNums[0] != -1 ) {
				infoUI.setInfoMessage("打鍵数: " + typeNums[0] + "(正確性 "+ int(typeNums[1]/typeNums[0]*10000)/100 +"%)");
			}
			infoUI.display();
			infoUI.updateSoloInfo("COMレベル: " + Score.cpuLV);
			infoUI.setBatteryColors(ClientUtil.getBaseLevel(self), ClientUtil.getColor(self), ClientUtil.getBaseColor(self));
		}
		
		// ゲームルームの属性変更
		protected function onGameUpdateRoomAttribute(e:AttributeEvent):void {
			switch( e.getChangedAttr().name ) {
				case "startTime": // スタート時間変化
					setupGameRoom( e.getChangedAttr().value );
//					lobbyRoom.setAttribute("gameRoomStartTime", e.getChangedAttr().value);
					break;
				case "redPoint": // RED 勝利
					if ( int(e.getChangedAttr().value) >= (0.8 * Constants.VICTORY_POINT) ) {
//						if ( e.getClient().isSelf() )gameRoom.setAttribute("status", Constants.STATUS_FINISHING);
					}
					if ( int(e.getChangedAttr().value) >= Constants.VICTORY_POINT ) {
						if ( Score.isObserve ) {
							infoUI.setInfoMessage("赤チームが勝利しました。");
							gameStage.end(true);
							removeListeners();
							return;
						}
						if ( ClientUtil.isTeamRed(reactor.self()) ) {
							infoUI.setInfoMessage("おめでとう！あなたの勝利です！");
							Score.win++;
							gameStage.end(true);
						} else {
							if (gameStage.cpu != null ) {
								gameStage.cpu.disable();
								infoUI.setInfoMessage("あなたは敗北しました。");
								if( !Score.comLock ) Score.cpuLV-= 0.5;
								if ( Score.cpuLV < 0.5 ) Score.cpuLV = 0.5;
							} else {
								infoUI.setInfoMessage("あなたのチームは敗北しました。");
							}
							SoundManager.DangerSound.play();
							Score.lose++;
							gameStage.end(false);
						}
						removeListeners();
						if ( e.getChangedAttr().byClient.isSelf() ) {
							gameRoom.setAttribute("bluePoint", "0", true, false, true);
							gameRoom.setAttribute("redPoint", "0", true, false, true);
						}
						gameRoom.setAttribute("status", Constants.STATUS_WAITING);
						gameRoom.setAttribute("startTime", String(ServerClockUtil.getTime() + Constants.GAME_END_NEXT_WAITTIME));
						Score.save();
					}
					break;
				case "bluePoint": // BLUE 勝利
					if ( int(e.getChangedAttr().value) >= (0.8 * Constants.VICTORY_POINT) ) {
//						if ( e.getClient().isSelf() )gameRoom.setAttribute("status", Constants.STATUS_FINISHING);
					}
					if ( int(e.getChangedAttr().value) >= Constants.VICTORY_POINT ) {
						if ( Score.isObserve ) {
							infoUI.setInfoMessage("青チームが勝利しました。");
							gameStage.end(true);
							removeListeners();
							return;
						}
						if ( ClientUtil.isTeamBlue(reactor.self()) ) {
							if (gameStage.cpu != null ) {
								gameStage.cpu.disable();
								infoUI.setInfoMessage("おめでとう！あなたの勝利です！");
								Score.cpuLV += 1;
							} else {
								infoUI.setInfoMessage("おめでとう！あなたの勝利です！");
							}
							Score.win++;
							gameStage.end(true);
						} else {
							infoUI.setInfoMessage("あなたのチームは敗北しました。");
							SoundManager.DangerSound.play();
							Score.lose++;
							gameStage.end(false);
						}
						removeListeners();
						if ( e.getChangedAttr().byClient.isSelf() ) {
							gameRoom.setAttribute("bluePoint", "0", true, false, true);
							gameRoom.setAttribute("redPoint", "0", true, false, true);
						}
						gameRoom.setAttribute("status", Constants.STATUS_WAITING);
						gameRoom.setAttribute("startTime", String(ServerClockUtil.getTime() + 20000));
						Score.save();
					}
					break;
			}
		}
		protected function onLobbyUpdateRoomAttribute(e:AttributeEvent):void {
			switch ( e.getChangedAttr().name ) {
				case "gameRoomStartTime": // ゲームルームの状態
						if ( Number(e.getChangedAttr().value) < ServerClockUtil.getTime() ) {
							if ( redNum == 0 && blueNum == 0 ) {
								infoUI.updateNormalRoomStatus("参加できます");
								infoUI.setGameRoomStatus(Constants.STATUS_CHATING);
							} else {
//								trace("対戦中1");
								infoUI.updateNormalRoomStatus("対戦中です");
								infoUI.setGameRoomStatus(Constants.STATUS_PLAYING);
							}
						} else if ( Number(e.getChangedAttr().value) >= ServerClockUtil.getTime() ) {
							infoUI.addEventListener( Event.ENTER_FRAME, onGameRoomCountDown );
						}
					break;
			}
		}
		
		protected function onGameRoomCountDown(e:Event):void {
			if ( blueNum == 0 && redNum == 0 ) {
				infoUI.removeEventListener( Event.ENTER_FRAME, onGameRoomCountDown );
				infoUI.updateNormalRoomStatus("参加できます");
				infoUI.setGameRoomStatus(Constants.STATUS_CHATING);
				return;
			}
			var time:Number = Number(lobbyRoom.getAttribute("gameRoomStartTime")) - ServerClockUtil.getTime();
			if( time > 0 ) {
				infoUI.updateNormalRoomStatus("開始まで " + Math.ceil(time / 1000) + "秒");
				infoUI.setGameRoomStatus(Constants.STATUS_WAITING);
			} else {
				infoUI.removeEventListener(Event.ENTER_FRAME, onGameRoomCountDown);
//				trace("対戦中2");
				infoUI.updateNormalRoomStatus("対戦中です");
				infoUI.setGameRoomStatus(Constants.STATUS_PLAYING);
			}
			
		}
		
		// ゲームルーム中のクライアントの属性変更
		protected function onGameUpdateClientAttribute(e:RoomEvent):void {
//			if ( ClientUtil.getStatus(e.getClient()) != Constants.STATUS_PLAYING ) return;
			switch( e.getChangedAttr().name ) {
				case Constants.BATTERY_X: // 位置の移動
					gameStage.setBattery(e.getClient(), Number(e.getChangedAttr().value), isMySide(e.getClient()) );
					break;
				case Constants.PLAY_MODE: // プレイモード変更
					gameStage.setPlayMode(e.getClient(), e.getChangedAttr().value);
					break;
				case Constants.ANGLE: // 砲台の角度
					gameStage.setBatteryAngle(e.getClient(), Number(e.getChangedAttr().value));
					break;
				case "attackCombo":
				case "defenceCombo":
					gameStage.updateComboStatus(e.getClient(), e.getChangedAttr().name, (e.getChangedAttr().value == "true"));
					break;
				case "status": // 当然STATUS_PLAYING
					gameStage.setBattery(e.getClient(), ClientUtil.getBatteryX(e.getClient()), isMySide(e.getClient()) );
					gameStage.setPlayMode(e.getClient(), ClientUtil.getPlayMode(e.getClient()));
					break;
				case "team":
					gameStage.setBattery(e.getClient(), ClientUtil.getBatteryX(e.getClient()), isMySide(e.getClient()) );
					break;
			}
		}
		// ロビー中のクライアントの属性変更
		protected function onLobbyUpdateClientAttribute(e:RoomEvent):void {
			switch( e.getChangedAttr().name ) {
				case "team":
				case "isSolo":
				case Constants.USER_NAME:
				case "status":
				case Constants.ATTACK_POWER:
				case Constants.DEFENCE_POWER:
//					trace( e.getChangedAttr().name, e.getChangedAttr().value );
					updateTeamUsersNum();
					break;
			}
			if( e.getClient().isSelf() ){
				switch( e.getChangedAttr().name ) {
					case Constants.USER_BATTERY_BASE_COLOR:
					case Constants.USER_BATTERY_COLOR:
					case Constants.USER_BATTERY_BASE_LEVEL:
						var client:IClient = e.getClient();
						infoUI.setBatteryColors(ClientUtil.getBaseLevel(client), ClientUtil.getColor(client), ClientUtil.getBaseColor(client));
						break;
				}
			}
		}
		
		protected function onLobbyClientCount(e:RoomEvent):void {
			lobbyUserNum = e.getNumClients();
			updateTeamUsersNum();
		}
		protected var oldBlueHandicap:Number = 1;
		protected var oldRedHandicap:Number = 1;
		protected function changeHandicap():void {
			if ( Score.isObserve ) return;
			var clients:Array = lobbyRoom.getOccupants();
			var bluePower:Number = 0;
			var redPower:Number = 0;
			for ( var i:int = 0; i < clients.length; i++ ) {
				var teamAtt:String = ClientUtil.getTeam( clients[i] );
				var isSolo:Boolean = ClientUtil.isSolo( clients[i] );
				var attackPower:Number = ClientUtil.getAttackPower(clients[i]);
				var defencePower:Number = ClientUtil.getDefencePower(clients[i]);
				
				if ( !isSolo ) {
					if ( teamAtt == Constants.TEAM_BLUE ) {
						if ( (!(attackPower > 0)) && (!(defencePower > 0)) ) bluePower += 2500;
						else bluePower += Math.max( attackPower, defencePower );
					}
					if ( teamAtt == Constants.TEAM_RED ) {
						if ( (!(attackPower > 0)) && (!(defencePower > 0)) ) redPower += 2500;
						else redPower += Math.max( attackPower, defencePower );
					}
				}
			}
			if ( bluePower == 0 ) bluePower = redPower;
			if ( redPower == 0 ) redPower = bluePower;
			
			var handicap:Number = 1.0;
			if ( !Score.isSolo ) {
				var blueHandicap:Number = redPower / bluePower;
				var redHandicap:Number = bluePower / redPower;
				if ( blueHandicap < 1 ) blueHandicap = 1;
				if ( redHandicap < 1 ) redHandicap = 1;
				
				if ( blueHandicap > 6 ) blueHandicap = 6;
				if ( redHandicap > 6 ) redHandicap = 6;
				
				if ( blueHandicap != oldBlueHandicap || redHandicap != oldRedHandicap ) {
					if ( blueHandicap == redHandicap ) {
						gameStage.setInfoMsg( "ハンデ解消です。" );
					} else {
						gameStage.setInfoMsg( "ハンデ変更です。\n" + (blueHandicap > 1?"青チーム":"赤チーム") + "に＋" + int((Math.max(redHandicap, blueHandicap) - 1) * 100) + "%のボーナス補正。" );
					}
				}
				
				oldBlueHandicap = blueHandicap;
				oldRedHandicap = redHandicap;
				
				if ( Score.myGameTeam == Constants.TEAM_BLUE ) {
					Score.handicap = blueHandicap;
				} else {
					Score.handicap = redHandicap;
				}
			} else {
				Score.handicap = 1.0;
			}
		}
		protected function updateTeamUsersNum():void {
			var clients:Array = lobbyRoom.getOccupants();
			var blueNum:int = 0;
			var redNum:int = 0;
			var blueAttack:Number = 0;
			var blueDefence:Number = 0;
			var redAttack:Number = 0;
			var redDefence:Number = 0;
			var isPlaying:Boolean = false;
			for ( var i:int = 0; i < clients.length; i++ ) {
				var teamAtt:String = ClientUtil.getTeam( clients[i] );
				var isSolo:Boolean = ClientUtil.isSolo( clients[i] );
				var attackPower:Number = ClientUtil.getAttackPower(clients[i]);
				var defencePower:Number = ClientUtil.getDefencePower(clients[i]);
				
				if( !isSolo ){
					if ( teamAtt == Constants.TEAM_BLUE ) {
						blueNum++;
						blueAttack += attackPower;
						blueDefence += defencePower;
					}
					if ( teamAtt == Constants.TEAM_RED ) {
						redNum++;
						redAttack += attackPower;
						redDefence += defencePower;
					}
					if( ClientUtil.getStatus(clients[i]) == Constants.STATUS_PLAYING ) isPlaying = true;
				}
			}
			this.blueNum = blueNum;
			this.redNum = redNum;
			
			if ( blueNum && redNum && Score.isWaitingAtLobby ) {
				Score.isWaitingAtLobby = false;
				joinTeam();
			}

			if ( blueNum == 0 || redNum == 0 || !isPlaying ) {
				infoUI.updateNormalRoomStatus("参加できます");
				infoUI.setGameRoomStatus(Constants.STATUS_CHATING);
			} else {
//				trace("対戦中3", Number(lobbyRoom.getAttribute("gameRoomStartTime")));
				infoUI.updateNormalRoomStatus("対戦中です");
				infoUI.setGameRoomStatus(Constants.STATUS_PLAYING);
			}

			infoUI.setBlueTeamInfo( blueNum, blueAttack, blueDefence );
			infoUI.setRedTeamInfo( redNum, redAttack, redDefence );
		}
		public function get lobbyUserNum():int { return _lobbyUserNum; }
		
		public function set lobbyUserNum(value:int):void 
		{
			_lobbyUserNum = value;
			infoUI.setLobbyUserNum( value );
		}
	}
	
	// 測定くん
	class LogAnalyzer {
		protected static var attackLog:Array = [];
		protected static var defenceLog:Array = [];
		protected static var old_type:Number = -1;
		protected static var old_correct:Number = -1;
		
		public static function reset():void {
			attackLog = [];
			defenceLog = [];
			old_type = Score.type;
			old_correct = Score.correct;
		}
		
		public static function addAttackLog(wordLength:int):void {
			attackLog.push([wordLength, getTimer()]);
		}
		public static function addDefenceLog(wordLength:int):void {
			defenceLog.push([wordLength, getTimer()]);
		}
		protected static function analyzeArray(log:Array):Number {
			var power:Number = 0;
			var count:int = log.length;
			var lastEnd:int = 0;
			var limitTime:Number;
			var strNum:Number;
			if ( count < 2 ) return 0;
			for ( var i:int = 0; i < count; i++ ) {
				limitTime = log[i][1] + 10000;
				for ( var j:int = lastEnd; j < count; j++ ) {
					if ( log[j][1] > limitTime ) {
						break;
					}
				}
				lastEnd = j;
				strNum = 0;
				for ( j = i+1; j < lastEnd; j++ ) {
					strNum += log[j][0];
				}
				if ( i == lastEnd ) continue;
				var temp:Number = (log[lastEnd - 1][1] - log[i][1]);
				if ( temp < 3000 ) continue; // 最低3秒間持続
				temp = 1000000 * strNum / temp;
				if ( temp > power ) power = temp;
				if ( lastEnd == count ) break;
			}
			return power;
		}
		public static function analyze():Array {
			var attackPower:Number = analyzeArray(attackLog);
			var defencePower:Number = analyzeArray(defenceLog);
			if( attackPower > 0 ){
				if ( Score.attackPower < attackPower ) {
					Score.attackPower = (attackPower + Score.attackPower/4)/1.25;
				} else {
					Score.attackPower = (attackPower/16 + Score.attackPower)/1.0625;
				}
			}
			if( defencePower > 0 ){
				if ( Score.defencePower < defencePower ) {
					Score.defencePower = (defencePower + Score.defencePower/4)/1.25;
				} else {
					Score.defencePower = (defencePower/16 + Score.defencePower)/1.0625;
				}
			}
			Score.save();
			if ( old_type == -1 ) {
				return [-1, -1];
			} else {
				return [Score.type - old_type, Score.correct - old_correct];
			}
		}
	}
	
	// 弾の軌道制御とか
	class Bullet extends Sprite {
		
		protected var startX:Number;
		protected var startY:Number;
		protected var vx:Number;
		protected var vy:Number;
		protected var startTime:Number;
		protected var hitTime:Number;
		protected var target:Missile;
		protected var isDestroy:Boolean;
		public function Bullet(targetMissile:Missile, bulletSpeed:Number, startX:Number, startY:Number, startTime:Number, isDestroy:Boolean) {
			
			this.graphics.beginFill(0xFFFFFF - int(Math.random() * 0x40));
			this.graphics.drawRect(0, 0, 2, 2);
			this.mouseEnabled = this.mouseChildren = false;
			this.startX = startX;
			this.startY = startY;
			this.startTime = startTime;
			this.target = targetMissile;
			this.isDestroy = isDestroy;
			var x:Number = (Constants.STAGE_WIDTH - 80 - targetMissile.x) - startX;
			var yd:Number = Constants.DISTANCE - targetMissile.y - startY + 5;
			var missileSpeed:Number = targetMissile.durationT;
			var vd:Number = missileSpeed * missileSpeed;
			var md:Number = bulletSpeed * bulletSpeed;
			var meetTime:Number = (yd * missileSpeed - Math.sqrt( yd * yd * vd - (x * x + yd * yd) * (vd - md) ) ) / (vd - md);
			vx = x / meetTime;
			vy = Math.sqrt(md - vx * vx);
			hitTime = startTime + meetTime;
		}
		public function getAngle():String {
			return String( 180 * Math.atan2(-vx, vy) / Math.PI );
		}
		// 弾が進む。ヒットしたか画面外にいったらtrueを返してremoveChildしてもらう。 効果音つき
		public function update(time:Number):Boolean {
			var ellapse:Number = time - startTime;
			this.x = ellapse * vx + startX;
			this.y = ellapse * vy + startY;
			if ( target.parent != null && time > hitTime ) {
//				dispatchEvent(new GameEvent(GameEvent.MISSILE_DAMAGE, true));
				target.damage(vx, vy, isDestroy);
				var sch:SoundChannel = SoundManager.ShootSound.play();
				if( sch != null ) sch.soundTransform = new SoundTransform(0.5);
				return true;
			}
			if ( this.x > (200+Constants.STAGE_WIDTH) || this.x < -200 || this.y > Constants.STAGE_HEIGHT || this.y < -200 ) {
				return true;
			}
			return false;
		}
	}

	// ミサイルの軌道制御とか
	class Missile extends Sprite {
		public var arriveTime:Number;
		public var attackTime:Number;
		public var durationT:Number;
		public var id:int;
		public var client:IClient;
		public var isSelf:Boolean;
		public var text:String = "";
		public var word:String = "";
		public var wordLength:int = 0;
		public var isMySide:Boolean;
		public var power:Number;
		protected var circle:Sprite = new Sprite();
		protected var body:Sprite = new Sprite();
		protected var inputIndex:int = 0;
		protected var tf:TextField = new TextField();
		protected var tfCover:Sprite = new Sprite();
		protected var index:int = 0;
		public var isJapaneseWord:Boolean = false;
		protected var focusCount:Number = 0;
		public function get isTypable():Boolean {
			return tf.visible;
		}
		
		public function Missile(client:IClient, attackTime:Number, arriveTime:Number, id:int, power:Number, isSelf:Boolean) {
			this.mouseChildren = false;
			this.mouseEnabled = false;
			this.client = client;
			this.attackTime = attackTime;
			this.arriveTime = arriveTime;
			this.power = power;
			durationT = Constants.DISTANCE / (arriveTime - attackTime);
			this.id = id;
			this.isSelf = isSelf;
			if ( ClientUtil.isTeamBlue(client) ) {
				body.graphics.lineStyle(0, 0x3366FF);
				body.graphics.beginFill(0x3399FF);
			} else if ( ClientUtil.isTeamRed(client) ) {
				body.graphics.lineStyle(0, 0xFF3333);
				body.graphics.beginFill(0xFF8888);
			}
			body.graphics.lineTo(power * 4, power * -16)
			body.graphics.lineTo(power * -4, power * -16);
			body.graphics.lineTo(0, 0);
			addChild( body );
			body.y = power * 8;
			tf.defaultTextFormat = new TextFormat(TextFieldUtil.getFont(), 14, 0xFFFFFF);
			tf.autoSize = "left";
			tf.border = true;
			tf.background = true;
			tf.backgroundColor = 0x0;
			tf.borderColor = 0xFFFFFF;
			tf.visible = false;
		}
		public function damage(vx:Number, vy:Number, isDestroy:Boolean):void {
			var damageMotion:DamageMotion = new DamageMotion(vx, vy);
			if ( this.parent != null ) {
				this.parent.addChild( damageMotion );
				damageMotion.x = this.x;
				damageMotion.y = this.y;
			}
			if ( isDestroy && (client.isSelf() || ClientUtil.isCPU(client) ) ) { // 自分のミサイルだったら破壊判定
				dispatchEvent(new GameEvent(GameEvent.MISSILE_DESTROY, true, false, client.getClientID() + "-" + id));
			}
		}
		// ミサイル破壊モーション　効果音つき
		public function destroiedMotion():void {
			SoundManager.DamageSound.play();
			tf.visible = false;
			
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xFFFF00, 0.5);
			this.graphics.drawCircle(0, 0, 5);
			body.visible = false;
			this.addEventListener(Event.ENTER_FRAME, onDestroyEnterFrame);
		}
		protected function onDestroyEnterFrame(e:Event):void {
			this.scaleX *= 1.2;
			this.scaleY *= 1.2;
			this.alpha *= 0.85;
			if ( this.alpha < 0.1 ) {
				this.removeEventListener(Event.ENTER_FRAME, onDestroyEnterFrame);
				this.parent.removeChild(this);
			}
		}
		public function update(time:Number):void {
			this.y = (time-attackTime) * durationT;
			body.rotationY += power * 8;
//			if ( focusCircle != null ) {
//				focusCircle.setParams( 1 - y / Constants.DISTANCE, this.power, 0.5, 0 );
//			}
		}
		public function setText(text:String, isMySide:Boolean):void {
			isJapaneseWord = Roma.isJapaneseWord(text);
			this.word = text;
			this.toType = isJapaneseWord?Roma.getRomaToType(word):word;
			this.wordLength = toType.length;
			this.text = HandicapUtil.getHandicapWord(text);
			this.isMySide = isMySide;
			if( !isMySide ){
				this.addChild( circle );
				this.addChild( tf );
				tf.visible = true;	
				this.addChild( tfCover );
				isJapaneseWord?setJIndex(Roma.getRomaToType(word)):setIndex(0);
			}
		}
		public function tryType(char:String):int {
			if ( isJapaneseWord ) {
				char = char.toUpperCase();
				var str:String = Roma.getRomaToType(text, typed + char );
				if ( str ) {
					typed += char;
					var toType:String = str.substr(typed.length);
//					setJIndex(toType);
					this.toType = str.substr(typed.length);
					setJIndex("<font color='#888888'>" + typed + "</font><font color='#FFFFFF'>" + toType + "</font>");
				} else {
					return Constants.RESULT_FAULT;
				}
				if ( toType.length ) {
					return Constants.RESULT_SUCCESS;
				} else {
					tf.visible = false;
//					focusCircle.removeThis();
					return Constants.RESULT_DESTROY;
				}
			} else {
				if ( text.substr(index, 1) == char ) {
					setIndex(++index);
				} else {
					return Constants.RESULT_FAULT;
				}
				if ( text.length == index ) {
					tf.visible = false;
//					focusCircle.removeThis();
					return Constants.RESULT_DESTROY;
				} else {
					return Constants.RESULT_SUCCESS;
				}
			}
		}
		protected var typed:String = "";
		public function tryStart(char:String):Boolean {
			if ( isMySide || (typed != "") || !tf.visible ) return false;
			
			if ( isJapaneseWord ) {
				char = char.toUpperCase();
				var str:String = Roma.getRomaToType(text, char);
				if ( str ) {
					typed = char;
					this.toType = str.substr(typed.length);
					setJIndex("<font color='#888888'>" + typed + "</font><font color='#FFFFFF'>" + str.substr(typed.length) + "</font>");
					setFocus();
					return true;
				}
				return false;
			} else {
				if ( text.charAt(0) == char ) {
					setIndex(1);
					setFocus();
					return true;
				}
				return false;
			}
		}
		public function get center():Number {
			return this.x +  this.width * 0.5;
		}
		public var focused:Boolean = false;
//		protected var focusCircle:FocusCircle;
		public function setFocus():void {
//			focusCircle = new FocusCircle(20, 2);
//			circle.addChild( focusCircle );
			focused = true;
			tf.borderColor = 0xFFFF00;
		}
		public function setCircle(level:int):void {
			circle.graphics.clear();
			switch ( level ) {
				case 2:
					circle.graphics.lineStyle(0, 0xFFFF00, 0.3);
					circle.graphics.drawCircle(0, 0, 30);
					break;
				case 1:
					circle.graphics.lineStyle(1, 0xFFFF00, 0.4);
					circle.graphics.drawCircle(0, 0, 35);
					break;
				case 0:
					circle.graphics.lineStyle(2, 0xFFFF00, 0.5);
					circle.graphics.drawCircle(0, 0, 40);
					break;
				default:
					break;
			}
		}
		public function darken():void {
			if ( !focused ) tf.borderColor = 0x333333;
		}
		
		public function undarken():void {
			if ( !focused ) tf.borderColor = 0xFFFFFF;
		}
		public function reset():void {
//			if ( circle.contains( focusCircle ) ) removeChild( focusCircle );
			focused = false;
			typed = "";
			this.toType = isJapaneseWord?Roma.getRomaToType(word):word;

			tf.borderColor = 0xFFFFFF;
			isJapaneseWord?setJIndex(Roma.getRomaToType(word)):setIndex(0);
		}
		protected function setJIndex(toType:String):void {
			typeDisplayString = "  " + text + "  " + "\n" + "  " + toType + "  ";
			tf.htmlText = "  " + text + "  " + "\n" + "  " + toType + "  ";
			tf.x = -0.5 * tf.width;
		}
		protected function setIndex(num:int):void {
			toType = text.substr(num);
			typeDisplayString = "  " + text.substr(num) + "  ";
			index = num;
			tf.htmlText = "  " + text.substr(num) + "  ";
			tf.x = -0.5 * tf.width;
		}
		protected var toType:String = "";
		public function getToType():String {
			return toType;
		}
		public var typeDisplayString:String;
	}
	
	// チームチャット
	class ChatItem extends Sprite {
		protected var tf:TextField = new TextField();
		public function ChatItem(msg:String) {
			tf.autoSize = "left";
			tf.defaultTextFormat = new TextFormat(null, null, 0xFFFFFF);
			tf.text = msg;
			this.addChild(tf);
			this.mouseChildren = this.mouseEnabled = false;
			var timer:Timer = new Timer(Constants.TEAM_CHAT_DURATION, 1);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
		}
		protected function onTimer(e:TimerEvent):void {
			e.target.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		protected function onEnterFrame(e:Event):void {
			this.alpha *= 0.9;
			if ( this.alpha < 0.1 ) {
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				if( this.parent != null ){
					this.parent.removeChild(this);
				}
			}
		}
	}
	
	// ディフェンスUI
	class DefenceTargets extends Sprite {
		public var missileList:Array;
		public var firstClaster:Array = [];
		public var secondClaster:Array = [];
		public var thirdClaster:Array = [];
		public var topTargets:Array = [];
		protected var maxWidth:Number = 180;
		protected var speed:Number = Constants.DISTANCE / Constants.MISSILE_ARRIVE_TIME;
		public function DefenceTargets() {
			setMode(Boolean(Score.defenceMode & 1));
			drawXbasis();
			this.visible = false;
		}
		private function drawXbasis():void {
			this.graphics.clear();
			this.graphics.lineStyle(2, 0x00FF00, 0.5);
			this.graphics.moveTo( -0.5 * maxWidth, 0);
			this.graphics.lineTo( -0.5 * maxWidth, Constants.DISTANCE);
			this.graphics.moveTo( 0.5 * maxWidth, 0);
			this.graphics.lineTo( 0.5 * maxWidth, Constants.DISTANCE);
			this.graphics.lineStyle(0, 0x00FF00, 1);
			this.graphics.moveTo( -0.5 * maxWidth, 0);
			this.graphics.lineTo( -0.5 * maxWidth, Constants.DISTANCE);
			this.graphics.moveTo( 0.5 * maxWidth, 0);
			this.graphics.lineTo( 0.5 * maxWidth, Constants.DISTANCE);
//			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		public function changeMaxWidth():void {
			Score.defenceMode ^= 1;
			setMode(Boolean(Score.defenceMode & 1));
			drawXbasis();
		}
		public function setMode(defenceMode:Boolean):void {
			if ( defenceMode ) maxWidth = 2 * Constants.STAGE_WIDTH;
			else maxWidth = 180;
		}
		public function updateTopFocus():void {
			missileList = missileList.sort( sortFunc );
			firstClaster = [];
			secondClaster = [];
			thirdClaster = [];
			var maxX:Number = this.x + 0.5 * maxWidth;
			var minX:Number = this.x - 0.5 * maxWidth;
			var count:int = missileList.length;
			for ( var i:int = 0; i < count; i++ ) {
				var missile:Missile = missileList[i];
//				if ( !missile.isMySide && missile.word.length ) {
				if ( missile.isTypable ) {
//					missile.setCircle(4);
					if ( missile.center > minX && missile.center < maxX ) {
						firstClaster.push( missileList[i] );
						missile.undarken();
					} else {
						secondClaster.push( missile );
						missile.darken();
					}
				}
			}
			firstClaster = firstClaster.sort( sortFunc );
			secondClaster = secondClaster.sort( sortFunc );
/*
			if ( topTargets.length < 5 ) {
				i = 0;
				for ( i = 0; i < firstClaster.length; i++ ) {
					topTargets
					firstClaster[i].setCircle(i);
				}
			}
*/
		}
		public function resetTopTargets():void {
			topTargets = [];
			updateTopFocus();
		}
		public function getDefenceText():Array {
			var ret:Array = [];
			var time:Number = ServerClockUtil.getTime();
			var power:Number = Score.attackPower;
			for each( var missile:Missile in firstClaster ) {
//				if( !missile.focused )
				if ( ret.length > 3 ) break;
				
				ret.push(
				 (missile.isJapaneseWord?" [" +missile.word + "]":"")
				 + setTextColor(missile.getToType(), missile.arriveTime - time, power)
				); 
			}
			for each( missile in secondClaster ) {
//				if( !missile.focused )
				if ( ret.length > 3 ) break;
				ret.push(
				 (missile.isJapaneseWord?" [" +missile.word + "]":"")
				 + setTextColor(missile.getToType(), missile.arriveTime - time, power)
				); 
			}
			return ret;
		}
		protected function setTextColor( text:String, time:Number, power:Number ):String {
			var canTypeCount:Number = time * power * 0.000001;
			if ( power == 0 ) return text;
			if ( text.length * 1.5 > canTypeCount ) {
				return "<font color='#FF0000'>" + text + "</font>";
			} else if ( text.length * 3.0 > canTypeCount) {
				return "<font color='#FFFF00'>" + text + "</font>";
			} else {
				return text;
			}
		}
		protected function sortFunc(value1:Missile, value2:Missile):int {
			if ( value1.y < value2.y ) {
				return 1;
			} else if ( value1.y > value2.y ) {
				return -1;
			} else {
				return 0;
			}
		}
	}
	
	// ゲーム画面管理
	class GameStage extends Sprite {
		protected var dammyTF:TextField = new TextField();
		protected var bgGrid:Sprite = new Sprite();
		protected var myMissiles:Sprite = new Sprite();
		protected var enemyMissiles:Sprite = new Sprite();
		protected var operationBG:Sprite = new Sprite();
		protected var operationUI:OperationUI = new OperationUI(dammyTF);
		protected var moveUI:MoveBatteryUI = new MoveBatteryUI();
		protected var enemyBG:Sprite = new Sprite();
		protected var batteryList:UDictionary = new UDictionary(false);
		protected var bulletList:Array = [];
		protected var _missileList:Array = [];
		protected var chatInputBar:TextField = new TextField();
		protected var effectSp:EffectSprite = new EffectSprite();
		protected var bg:BackGround = new BackGround(effectSp);
		protected var defenceTargets:DefenceTargets = new DefenceTargets();
		protected var observeTF:TextField = new TextField();
		
		protected var infoWindow:InfoWindow = new InfoWindow();
		
		protected var _myBatteryMoveTo:Number;
		protected var chatUI:Sprite = new Sprite(); // インプットバーとログの表示
		public var cpu:CPUClient;
		
		public function setPlayMode(client:IClient, playMode:String):void {
			if ( client.isSelf() ) {
				operationUI.setMode(playMode);
				moveUI.setMode(playMode);
				// 防御UI表示/非表示
				if ( playMode == Constants.PLAY_MODE_DEFENDER) {
					defenceTargets.visible = true;
				} else {
					defenceTargets.visible = false;
				}
			}
			if ( batteryList[client.getClientID()] != undefined ) {
				Battery(batteryList[client.getClientID()]).setMode(playMode);
			}
		}
		
		public function GameStage() {
			this.addChild( dammyTF );
			dammyTF.visible = true;
			dammyTF.type = "input";
			dammyTF.y = 0;
			dammyTF.defaultTextFormat = new TextFormat(null, 1, 0);
			
			observeTF.visible = false;
			TextFieldUtil.setupNoBorder(observeTF, false);
			observeTF.defaultTextFormat.size = 20;
			observeTF.defaultTextFormat.color = 0xFFFF00;
			observeTF.text = "観戦中";
			
			drawBG();
			this.addChild( bgGrid );
			bgGrid.addChild( bg );
			bg.y = 40;
			effectSp.y = 40;
			
			bgGrid.addChild( myMissiles );
			myMissiles.rotation = 180;
			bgGrid.addChild( enemyMissiles );
			enemyMissiles.x = 40;
			myMissiles.x = Constants.STAGE_WIDTH - 40;
			myMissiles.y = Constants.DISTANCE + 40;
			enemyMissiles.y = 40;
			myMissiles.mouseEnabled = enemyMissiles.mouseEnabled = 
			myMissiles.mouseChildren = enemyMissiles.mouseChildren = false;
			this.addChild( operationBG );
			operationBG.addChild( moveUI ); // 砲台移動用
			moveUI.addEventListener(MouseEvent.CLICK, onMoveClick);
			operationBG.addChild( operationUI);
			operationUI.x = 0.5 * (Constants.STAGE_WIDTH - operationUI.width);
			operationUI.y = 40;
			defenceTargets.missileList = _missileList;
			
			operationBG.y = Constants.DISTANCE + 40;
			this.addChild( enemyBG );
			this.addChild( defenceTargets );
			defenceTargets.y = 40;
			bgGrid.mouseEnabled = bgGrid.mouseChildren = false;
			operationBG.mouseEnabled = false;
			
			operationUI.addEventListener(GameEvent.DEFENCE_TYPE, onDefenceKeyDown);

			this.addChild(chatUI);
			chatUI.x = 15;
			chatUI.y = Constants.DISTANCE + 15;
			this.addChild(chatInputBar);
			chatInputBar.border = true;
			chatInputBar.type = "input";
			chatInputBar.borderColor = 0xFFFFFF;
			chatInputBar.defaultTextFormat = new TextFormat(null, null, 0xFFFFFF);
			chatInputBar.width = 250;
			chatInputBar.height = 20;
			chatInputBar.y = Constants.DISTANCE + 15;
			chatInputBar.x = 15;
			chatInputBar.addEventListener(KeyboardEvent.KEY_UP, onChatKeyUp);
			chatInputBar.addEventListener(KeyboardEvent.KEY_DOWN, onChatKeyDown);
			chatInputBar.multiline = true;
			chatInputBar.visible = false;
			this.addChild( observeTF );
			this.addChild(infoWindow);
			
			this.addChild( _exitBtn );
			_exitBtn.visible = false;
			_exitBtn.x = (Constants.STAGE_WIDTH - _exitBtn.width) * 0.5;
			_exitBtn.y = (Constants.STAGE_HEIGHT-80-Constants.DISTANCE-_exitBtn.height) * 0.5 + 80 + Constants.DISTANCE;
			_exitBtn.addEventListener(MouseEvent.CLICK, onExit);
		}
		public function setFace(faceA:DisplayObject, faceB:DisplayObject):void {
			infoWindow.setFace(faceA, faceB);
		}
		public function setInfoMsg(str:String):void {
			infoWindow.setMessage(str);
		}
		protected var startTime:Number;
		public function setTimer(startTime:Number):void {
			bg.setFilter(0);
			this.startTime = startTime;
			this.addEventListener(Event.ENTER_FRAME, onCountDown);
		}
		protected var lastTime:Number = -1;
		protected function onCountDown(e:Event):void {
			var rest:int = ((startTime - ServerClockUtil.getTime()) / 1000);
			if ( rest <= 0 ) this.removeEventListener(Event.ENTER_FRAME, onCountDown);
			if ( lastTime == rest ) return;
			lastTime = rest;
			var temp:TextField = new TextField();
			temp.defaultTextFormat = new TextFormat("Arial", 60, 0xFFFF00, true);
			temp.text = (rest >= 0)?String(1+int(rest)):"";
			temp.autoSize = "left";
			bg.bitmapData.draw(temp, new Matrix(1,0,0,1,0.5*(Constants.STAGE_WIDTH-temp.textWidth),0.45 * Constants.DISTANCE));
		}
		public function updateComboStatus(client:IClient, attrName:String, isStart:Boolean):void {
			if( batteryList[client.getClientID()] != undefined )
				batteryList[client.getClientID()].updateCombo(attrName, isStart);
		}
		protected function clearLoserAndMissiles():void {
			for ( var i:int = 0; i < _missileList.length; i++ ) {
				if (_missileList[i].parent != null )_missileList[i].parent.removeChild(_missileList[i]);
			}
			_missileList = [];
			defenceTargets.missileList = _missileList;

			for ( i = 0; i < bulletList.length; i++ ) {
				if (bulletList[i].parent != null )bulletList[i].parent.removeChild(bulletList[i]);
			}
			bulletList = [];
			
			var clearTarget:Sprite = (mySideWon)?enemyBG:operationBG;
			for( var id:String in batteryList ) {
				if( batteryList[id].parent == clearTarget ){
					clearTarget.removeChild(batteryList[id]);
				}
			}
		}
		public function clearAll():void {
			for ( var i:int = 0; i < _missileList.length; i++ ) {
				if (_missileList[i].parent != null )_missileList[i].parent.removeChild(_missileList[i]);
			}
			_missileList = [];
			defenceTargets.missileList = _missileList;
			for ( i = 0; i < bulletList.length; i++ ) {
				if (bulletList[i].parent != null )bulletList[i].parent.removeChild(bulletList[i]);
			}
			bulletList = [];
			
			for each( var battery:Battery in batteryList ) {
				if( battery.parent != null )
					battery.parent.removeChild(battery);
			}
			batteryList = new UDictionary(false);
		}
		protected function onShortcutKeyDown(e:KeyboardEvent):void {
			if ( Score.isObserve ) {
				switch( e.keyCode ) {
					case Keyboard.F11:
							Score.missileDisplayMode = (Score.missileDisplayMode + 1 % 3);
						break;
				}
			} else {
				switch( e.keyCode ) {
					case Keyboard.TAB:
							e.stopImmediatePropagation();
							operationUI.switchMode();
	//						operationUI.setFocus();
	/*						
							switch( operationUI.getPlayMode() ) {
								case Constants.PLAY_MODE_ATTACKER:
										operationUI.setFocus();
									break;
								case Constants.PLAY_MODE_DEFENDER:
										changeFocus(e.shiftKey);
									break;
							}
	*/
						break;
					case Constants.DEFENCE_MODE_CHANGE_KEY:
							defenceTargets.changeMaxWidth();
						break;
					case Constants.CHAT_KEY:
							chatInputMode = true;
						break;
					case Keyboard.UP:
							SoundManager.ClickSound.play();
							dispatchEvent( new GameEvent(GameEvent.MODE_ATTACK, true) );
						break;
					case Keyboard.DOWN:
							SoundManager.ClickSound.play();
							dispatchEvent( new GameEvent(GameEvent.MODE_DEFENCE, true) );
						break;
					case Keyboard.RIGHT:
							myBatteryMoveTo = myBatteryMoveTo + 30;
						break;
					case Keyboard.LEFT:
							myBatteryMoveTo = myBatteryMoveTo - 30;
						break;
					case Score.SWITCH_MODE_KEY:
							e.stopImmediatePropagation();
							operationUI.switchMode();
						break;
				}
			}
		}
		protected function onShortcutKeyUp(e:KeyboardEvent):void {
			switch( e.keyCode ) {
				case Keyboard.TAB:
						operationUI.setFocus();
					break;
			}
		}
		public function hitMotion(isMySide:Boolean, missileX:String):void {
//			var hitMotion:HitMotion = new HitMotion();
			
//			this.addChild( hitMotion );
//			effectSp.addChild( hitMotion );
			var x:Number = Number(missileX);

			if ( isMySide ) {
				effectSp.hitMotion(0, Constants.STAGE_WIDTH - (x+40));
//				hitMotion.y = 40;
//				hitMotion.y = 0;
			} else {
				effectSp.hitMotion(Constants.DISTANCE, (x+40));
//				hitMotion.y = Constants.DISTANCE + 40;
//				hitMotion.y = Constants.DISTANCE;
				this.addEventListener(Event.ENTER_FRAME, onHitEnterFrame);
			}
		}
		protected function onHitEnterFrame(e:Event):void {
			if ( this.x == 0 ) {
				this.x = -5 + 10 * Math.random();
				this.y = -5 + 10 * Math.random();
			} else {
				this.x = this.y = 0;
				this.removeEventListener(Event.ENTER_FRAME, onHitEnterFrame);
			}
		}
		public function putChatMessage(msg:String):void {
			var chatItem:ChatItem = new ChatItem(msg);
			chatUI.addChild( chatItem );
			var count:int = chatUI.numChildren;
			for ( var i:int = 0; i < count; i++ ){
				chatUI.getChildAt(i).y -= chatItem.height;
			}
		}
		protected var endEffect:Sprite = new Sprite();
		protected var mySideWon:Boolean;
		public function end(isVictory:Boolean):void {
			mySideWon = isVictory;
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onShortcutKeyDown);
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, onShortcutKeyUp);
			
			this.addEventListener( Event.ENTER_FRAME, onEndEnterFrame);
			this.addChild( endEffect );
			endEffect.graphics.clear();
			endEffect.scaleX = 1.0;
			endEffect.scaleY = 1.0;
			if ( isVictory ) {
				endEffect.graphics.lineStyle(8, 0xFFFFFF);
				endEffect.x = Constants.STAGE_WIDTH * 0.5;
				endEffect.y = 20;
			} else {
				endEffect.graphics.lineStyle(8, 0xFFCCCC);
				endEffect.x = Constants.STAGE_WIDTH * 0.5;
				endEffect.y = Constants.DISTANCE + 60;
			}
			endEffect.graphics.moveTo( -600, 0);
			endEffect.graphics.lineTo( 600, 0);
			endEffect.graphics.moveTo( 0, -600);
			endEffect.graphics.lineTo( 0, 600);
			endEffect.alpha = 1.5;
			firstFlg = true;
		}
		public function endObserve():void {
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onShortcutKeyDown);
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, onShortcutKeyUp);
			firstFlg = true;
			dispatchEvent(new GameEvent(GameEvent.END_GAME, true));
		}
		protected var firstFlg:Boolean;
		protected function onEndEnterFrame(e:Event):void {
			endEffect.scaleX *= 1.1;
			endEffect.scaleY *= 1.1;
			endEffect.alpha *= 0.99;
			if ( endEffect.alpha < 1.0 && firstFlg ) {
				clearLoserAndMissiles();
				firstFlg = false;
			}
			if ( endEffect.alpha < 0.3 ) {
				this.removeChild(endEffect);
				this.removeEventListener( Event.ENTER_FRAME, onEndEnterFrame );
				onEnd();
			}
		}
		protected function onEnd():void {
//			trace( "onEnd" );
			this.removeEventListener( Event.ENTER_FRAME, onEnterFrame);
			dispatchEvent(new GameEvent(GameEvent.END_GAME, true));
		}
		public function setBatteryAngle(client:IClient, angle:Number):void {
			if ( batteryList[client.getClientID()] == undefined ) return;
			batteryList[client.getClientID()].setAngle(angle);
		}
		protected function onMissileDamage(e:GameEvent):void { // 未使用だったり
			for ( var i:int = 0; i < bulletList.length; i++ ) {
				var bullet:Bullet = bulletList[i];
				if ( e.target == bullet ) {
					bulletList.splice(i, 1);
					bullet.parent.removeChild(bullet);
					break;
				}
			}
		}
		public function destroy(destroyer:IClient, missileClientId:String, missileId:int):void {
			for ( var i:int = 0; i < _missileList.length; i++ ) {
				var missile:Missile = _missileList[i];
				if ( missile.client.getClientID() == missileClientId && missile.id == missileId ) {
					var p:Point = effectSp.globalToLocal(missile.localToGlobal(new Point(0, 0)));
					effectSp.missileDestroy(p);
					missile.destroiedMotion();
					_missileList.splice(i, 1);
					if ( focus == missile ) focus = null;
					break;
				}
			}
		}
		protected var clientsForcusList:Object = { }; // [clientID] = Misslie
		protected var _focus:Missile = null;
		public function set focus(value:Missile):void {
			_focus = value;
			if ( value != null ) {
				operationUI.setDefenceFocus( value.typeDisplayString );
			} else {
				operationUI.setDefenceFocus( null );
			}
		}
		public function get focus():Missile {
			return _focus;
		}
		public function addBullet(shooter:IClient, target:IClient, missileId:int, shootTime:Number, bulletSpeed:Number, isMySide:Boolean, isDestroy:Boolean):void {
			
			var count:int = _missileList.length;
			for ( var i:int = 0; i < count; i++ ) {
				var missile:Missile = _missileList[i];
				if ( missile.client == target && missile.id == missileId ) {
					if ( isMySide ) {
						if( !isDestroy ){
							clientsForcusList[shooter.getClientID()] = missile;
						} else {
							clientsForcusList[shooter.getClientID()] = null;
						}
					}
					var bullet:Bullet = new Bullet(missile, bulletSpeed, Constants.STAGE_WIDTH - 40 - ClientUtil.getBatteryX(shooter), -Constants.BATTERY_DEFAULT_Y, shootTime, isDestroy );
					if ( shooter.isSelf() ) { shooter.setAttribute(Constants.ANGLE, bullet.getAngle(), Score.myGameRoom) };
					if ( cpu != null && ClientUtil.isCPU(shooter) ) batteryList["0"].setAngle(bullet.getAngle());
					var bulletLayer:Sprite = (isMySide?myMissiles:enemyMissiles);
					bulletLayer.addChild( bullet );
					bulletList.push(bullet);
					break;
				}
			}
		}
		protected var focusIndex:int = -1;
		protected function changeFocus(isShiftKeyDown:Boolean):void {
			if ( focus != null ) {
				focus.reset();
				focus = null;
			}
			var count:int = _missileList.length;
			if ( count == 0 ) return;
			for ( var i:int = 0; i < count; i++ ) {
				if ( !Missile(_missileList[i]).isMySide ) break;
			}
			if ( i == count ) return;
			do {
//				focusIndex = ( (focusIndex + (isShiftKeyDown)? -1:1) + count) % count;
				focusIndex += (isShiftKeyDown)? -1:1;
				focusIndex = (focusIndex + count) % count;
			} while ( Missile(_missileList[focusIndex]).isMySide )
			focus = _missileList[focusIndex];
			focus.setFocus();
			var focusParent:DisplayObjectContainer = focus.parent;
			if ( focusParent != null ) {
				focusParent.addChild( focus );
			}
		}
		protected var isPerfect:Boolean = true;
		protected function onDefenceKeyDown(e:GameEvent):void {
			var keyCode:int = int(e.data);
			var char:String = String.fromCharCode(keyCode).toLowerCase();
			if ( focus != null && focus.parent == null ) {
				focus = null;
			}
			if ( focus != null ) {
				if ( focus.parent != null ) {
					if ( keyCode == Keyboard.ESCAPE ) {
						focus.reset();
						focus = null;
						return;
					}
					var result:int = focus.tryType(char);
					operationUI.setDefenceFocus( focus.typeDisplayString );
					switch( result ) {
						case Constants.RESULT_SUCCESS:
							Score.type++;
							Score.correct++;
							if ( cpu != null ) {
								LogAnalyzer.addDefenceLog(1);
								addBullet(cpu.self, cpu, focus.id, ServerClockUtil.getTime(), Constants.BULLET_SPEED, true, false);
								var sch:SoundChannel = SoundManager.TypeSound.play();
								if( sch != null ) sch.soundTransform = new SoundTransform(0.5);
							} else {
								dispatchEvent( new GameEvent(GameEvent.SHOOT, false, false, focus.client.getClientID() + "-" + focus.id + "-0") );
							}
							break;
						case Constants.RESULT_FAULT:
							Score.type++;
							if ( (Score.defenceCombo >= Constants.DEFENCE_COMBO_START) ) {
								dispatchEvent( new GameEvent(GameEvent.DEFENCE_COMBO_END) );
							}
							Score.defenceCombo = 0;
							isPerfect = false;
							break;
						case Constants.RESULT_DESTROY:
							Score.type++;
							Score.correct++;
							Score.defence++;
							if ( isPerfect ) Score.defenceCombo++;
							if ( (Score.defenceCombo == Constants.DEFENCE_COMBO_START) ) {
								dispatchEvent( new GameEvent(GameEvent.DEFENCE_COMBO_START) );
								SoundManager.ComboSound.play();
							}
							if ( cpu != null ) {
								LogAnalyzer.addDefenceLog(1);
								addBullet(cpu.self, cpu, focus.id, ServerClockUtil.getTime(), Constants.BULLET_SPEED, true, true);
								sch = SoundManager.TypeSound.play();
								if( sch != null ) sch.soundTransform = new SoundTransform(0.5);
							} else {
								dispatchEvent( new GameEvent(GameEvent.SHOOT, false, false, focus.client.getClientID() + "-" + focus.id + "-1") ); // 破壊フラグk	
							}
							var comboCount:Number = int(Score.getDefenceBonusRate() * 0.01);
							for ( i = 0; i < comboCount; i++ )
								dispatchEvent( new GameEvent(GameEvent.ATTACK_REFLECT, false, false, focus.word + "-" + focus.power) );
							if ( (Score.getDefenceBonusRate() % 100) > (Math.random()*100) )
								dispatchEvent( new GameEvent(GameEvent.ATTACK_REFLECT, false, false, focus.word + "-" + focus.power) );
							focus = null;
							break;
					}
				}
			} else {
				var count:int = defenceTargets.firstClaster.length;
				for ( var i:int = 0; i < count; i++ ) {
					if ( Missile(defenceTargets.firstClaster[i]).tryStart(char) ) {
						Score.correct++;
						focus = defenceTargets.firstClaster[i];
						var focusParent:DisplayObjectContainer = focus.parent;
						if ( focusParent != null ) {
							focusParent.addChild( focus );
						}
						if ( cpu != null ) {
							addBullet(cpu.self, cpu, focus.id, ServerClockUtil.getTime(), Constants.BULLET_SPEED, true, false);
							LogAnalyzer.addDefenceLog(1);
							sch = SoundManager.TypeSound.play();
							if( sch != null ) sch.soundTransform = new SoundTransform(0.5);
						} else {
							dispatchEvent( new GameEvent(GameEvent.SHOOT, false, false, focus.client.getClientID() + "-" + focus.id + "-0") );
						}
						break;
					}
				}
				if( i == count ){
					count = defenceTargets.secondClaster.length;
					for ( i = 0; i < count; i++ ) {
						if ( Missile(defenceTargets.secondClaster[i]).tryStart(char) ) {
							Score.correct++;
							focus = defenceTargets.secondClaster[i];
							focusParent = focus.parent;
							if ( focusParent != null ) {
								focusParent.addChild( focus );
							}
							if ( cpu != null ) {
								addBullet(cpu.self, cpu, focus.id, ServerClockUtil.getTime(), Constants.BULLET_SPEED, true, false);
								LogAnalyzer.addDefenceLog(1);
							} else {
								dispatchEvent( new GameEvent(GameEvent.SHOOT, false, false, focus.client.getClientID() + "-" + focus.id + "-0") );
							}
							break;
						}
					}
				}
				if( i == count ){
					count = defenceTargets.thirdClaster.length;
					for ( i = 0; i < count; i++ ) {
						if ( Missile(defenceTargets.thirdClaster[i]).tryStart(char) ) {
							Score.correct++;
							focus = defenceTargets.thirdClaster[i];
							focusParent = focus.parent;
							if ( focusParent != null ) {
								focusParent.addChild( focus );
							}
							if ( cpu != null ) {
								addBullet(cpu.self, cpu, focus.id, ServerClockUtil.getTime(), Constants.BULLET_SPEED, true, false);
								LogAnalyzer.addDefenceLog(1);
							} else {
								dispatchEvent( new GameEvent(GameEvent.SHOOT, false, false, focus.client.getClientID() + "-" + focus.id + "-0") );
							}
							break;
						}
					}
				}
				if ( focus != null ) {
					Score.type++;
					isPerfect = true;
				}
			}
		}
		// クライアント退室時にミサイルと砲台を除去
		public function removeMissilesOf(client:IClient):void {
//			trace("removeMissilesOf");
			var count:int = _missileList.length;
			var removeList:Array = [];
			for ( var i:int = 0; i < count; i++ ) {
				if ( Missile(_missileList[i]).client == client ) {
					removeList.unshift(i);
				}
			}
			for ( i = 0; i < removeList.length; i++ ) {
				_missileList[removeList[i]].parent.removeChild( _missileList[removeList[i]] );
				_missileList.splice(removeList[i], 1);
			}
			
			if ( batteryList[client.getClientID()] != undefined ) {
				batteryList[client.getClientID()].parent.removeChild(batteryList[client.getClientID()]);
				
				delete( batteryList[client.getClientID()] );
			}
			if ( batteryList.length == 0 && Score.isObserve ) {
				endObserve();
			}
		}
		public function sendLogTo(client:IClient):void {
			var count:int = _missileList.length;
			for ( var i:int = 0; i < count; i++ ) {
				var missile:Missile = Missile(_missileList[i]);
				if (  missile.isSelf ) {
					client.sendMessage(Constants.ATTACK_LOG, missile.text, missile.id, missile.power, missile.attackTime, missile.arriveTime, missile.x);
				}
			}
		}
		protected function onEnterFrame(e:Event):void {
			if( cpu != null ) cpu.missiles = _missileList;
			var count:int = _missileList.length;
			var removeList:Array = [];
			var nowTime:Number = ServerClockUtil.getTime();
			for ( var i:int = 0; i < count; i++ ) {
				var missile:Missile = _missileList[i];
				missile.update( nowTime );
				if ( missile.y > Constants.DISTANCE ) {
					removeList.unshift(i);
					if ( missile.isSelf ) {
						dispatchEvent(new GameEvent(GameEvent.HIT, false, false, String(missile.x)+"-"+String(missile.power)) );
					} else if ( cpu && ClientUtil.isCPU(missile.client) ) {
						dispatchEvent(new GameEvent(GameEvent.HIT, false, false, String(missile.x)+"-cpu") );
					}
					if ( focus == missile ) focus = null;
				}
			}
			for ( i = 0; i < removeList.length; i++ ) {
				_missileList[removeList[i]].parent.removeChild( _missileList[removeList[i]] );
				_missileList.splice(removeList[i], 1);
			}
			var bcount:int = bulletList.length;
//			for ( i = 0; i < bcount; i++ ) {
			for ( i = bulletList.length-1; i >= 0; i-- ) {
				if ( bulletList[i].update( nowTime ) ) {
					bulletList[i].parent.removeChild(bulletList[i]);
					bulletList.splice(i, 1);
				}
			}
			defenceTargets.updateTopFocus();
			
			operationUI.setDefenceText(defenceTargets.getDefenceText());
		}
		public function addAttack(client:IClient, text:String, isMySide:Boolean, id:int, power:Number, arriveTime:Number, xpos:Number, isReflect:Boolean = false):void {
			var missile:Missile = new Missile(client, ServerClockUtil.getTime(), arriveTime, id, power, client.isSelf());
			var target:Sprite = (isMySide?myMissiles:enemyMissiles);
			target.addChildAt( missile, 0 );
			missile.x = xpos;
			_missileList.push(missile);
			missile.setText( text, isMySide );
			
			if( batteryList[client.getClientID()] != undefined ) {
				if ( isReflect ) {
					Battery(batteryList[client.getClientID()]).reflectMotion();
				} else {
					Battery(batteryList[client.getClientID()]).attackMotion();
				}
			}
		}
		
		// addAttackと統一しても問題ないとは思う・・
		public function addAttackLog(client:IClient, text:String, isMySide:Boolean, id:int, power:Number,attackTime:Number, arriveTime:Number, xpos:Number):void {
			var missile:Missile = new Missile(client, attackTime, arriveTime, id,  power, client.isSelf());
			var target:Sprite = (isMySide?myMissiles:enemyMissiles);
			target.addChildAt( missile, 0 );
			missile.x = xpos;
			_missileList.push(missile);
			missile.setText( text, isMySide );
		}

		protected function onMoveClick(e:MouseEvent):void {
			myBatteryMoveTo = moveUI.mouseX;
		}
		
		// 砲台設置など
		public function setBattery(client:IClient, position:Number, isMySide:Boolean):void {
			if ( client.isSelf() ) {
				if ( Score.isObserve ) return;
				_myBatteryMoveTo = position;
				defenceTargets.x = position;
				if ( _myBatteryMoveTo < 0.4 * Constants.STAGE_WIDTH ) infoWindow.setSide(false);
				if ( _myBatteryMoveTo > 0.6 * Constants.STAGE_WIDTH ) infoWindow.setSide(true);
			}
			if ( batteryList[client.getClientID()] == undefined ) { // 未設置
				var battery:Battery = new Battery(isMySide, ClientUtil.getBaseLevel(client), ClientUtil.getColor(client), ClientUtil.getBaseColor(client));
				battery.updateCombo( "attackCombo", ClientUtil.getIsAttackCombo(client) );
				battery.updateCombo( "defenceCombo", ClientUtil.getIsDefenceCombo(client) );
//				battery.draw(ClientUtil.getBaseLevel(client), ClientUtil.getColor(client), ClientUtil.getBaseColor(client));
				battery.setName( ClientUtil.getUserName(client) );
				batteryList[client.getClientID()] = battery;
				(isMySide?operationBG:enemyBG).addChild( battery );
				battery.x = (isMySide?position:(Constants.STAGE_WIDTH - position));
				
				battery.y = Constants.BATTERY_DEFAULT_Y;
				battery.setMode( ClientUtil.getPlayMode(client));
			} else {
				battery = batteryList[client.getClientID()];
				(isMySide?operationBG:enemyBG).addChild( battery );
				battery.setSide(isMySide);
				battery.x = (isMySide?position:(Constants.STAGE_WIDTH - position));
			}
			// 設置完了
		}
		
		protected function drawBG():void {
                        bgGrid.graphics.beginFill(0x0);
                        bgGrid.graphics.drawRect(0,0,465,465);
                        bgGrid.graphics.endFill();
			bgGrid.graphics.lineStyle(0, 0x00FF00, 0.5);
			for ( var i:int = 0; i <= Constants.STAGE_WIDTH/30; i++ ) {
				bgGrid.graphics.moveTo( 7 + 30 * i, 0 );
				bgGrid.graphics.lineTo( 7 + 30 * i, Constants.STAGE_HEIGHT );
				bgGrid.graphics.moveTo( 0, 7 + 30 * i );
				bgGrid.graphics.lineTo( Constants.STAGE_WIDTH, 7 + 30 * i );
			}
			setup( Constants.TEAM_NONE );
		}
		protected function drawOperationBG(color:uint):void {
			operationBG.graphics.clear();
			operationBG.graphics.beginGradientFill("linear", [color, color], [1.0, 0.0], [0, 255], new Matrix(0, -0.1, 0.1, 0, 0, 50));
			operationBG.graphics.drawRect( 0, 0, Constants.STAGE_WIDTH, 125);
			operationBG.graphics.lineStyle(2, 0xFFFFFF);
			operationBG.graphics.moveTo(0, 0);
			operationBG.graphics.lineTo(Constants.STAGE_WIDTH, 0);
			operationBG.graphics.moveTo(0, 40);
			operationBG.graphics.lineTo(Constants.STAGE_WIDTH, 40);
		}
		public function setDamage(mySide:int, enemySide:int):void {
			operationBG.graphics.lineStyle(2, 0xFF0000 | (0x101 * int(255 - 255 * (mySide / Constants.VICTORY_POINT))));
			enemyBG.graphics.lineStyle(2, 0xFF0000 | (0x101 * int(255 - 255 * (enemySide / Constants.VICTORY_POINT))));
			operationBG.graphics.moveTo(0, 0);
			operationBG.graphics.lineTo(Constants.STAGE_WIDTH, 0);
			enemyBG.graphics.moveTo(0, 40);
			enemyBG.graphics.lineTo(Constants.STAGE_WIDTH, 40);
		}
		protected function drawEnemyBG(color:uint):void {
			enemyBG.graphics.clear();
			enemyBG.graphics.beginGradientFill("linear", [color, color], [1.0, 0.0], [0, 255], new Matrix(0, 0.1, -0.1, 0, 0, -10));
			enemyBG.graphics.drawRect(0, 0, Constants.STAGE_WIDTH, 40);
			enemyBG.graphics.lineStyle(2, 0xFFFFFF);
			enemyBG.graphics.moveTo(0, 40);
			enemyBG.graphics.lineTo(Constants.STAGE_WIDTH, 40);
		}
		
		protected var _chatInputMode:Boolean = false;
		protected function onChatKeyUp(e:KeyboardEvent):void {
			if ( e.keyCode == Keyboard.ENTER ) {
				var arr:Array = chatInputBar.text.split("\r");
				if ( arr.length >= 2 ) {
/*					
					if ( chatInputBar.text == "\r" ) {
						chatInputMode = false;
						operationUI.setFocus();
						return;
					}
*/
					chatInputMode = false;
					operationUI.setFocus();
					dispatchEvent(new GameEvent(GameEvent.CHAT, false, false, arr.join("")));
					chatInputBar.text = "";
				}
			}
		}
		protected function onChatKeyDown(e:KeyboardEvent):void {
			if ( e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT ) {
				e.stopPropagation();
			}
		}
		public function startNavigation(team:String):void {
			if ( team == Constants.TEAM_BLUE ) {
				if ( !Score.isObserve ) infoWindow.setMessage("青チームで作戦を開始します。");
			} else {
				if ( !Score.isObserve ) infoWindow.setMessage("赤チームで作戦を開始します。");
			}
		}
		// チームに入ってゲーム開始
		public function setup(team:String):void {
			var operationBGColor:uint;
			var enemyBGColor:uint;
			operationUI.reset();
				
			if ( team == Constants.TEAM_BLUE ) {
				operationUI.setup();
				operationBGColor = 0x0000AA;
				enemyBGColor = 0x990000;
//				operationUI.setMode(Constants.PLAY_MODE_DEFENDER); // デフォルトで防御モード
				this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onShortcutKeyDown);
				this.stage.addEventListener(KeyboardEvent.KEY_UP, onShortcutKeyUp);
				this.addEventListener( Event.ENTER_FRAME, onEnterFrame );
			} else if ( team == Constants.TEAM_RED ) {
				operationUI.setup();
				operationBGColor = 0x990000;
				enemyBGColor = 0x0000AA;
//				operationUI.setMode(Constants.PLAY_MODE_ATTACKER); // デフォルトで攻撃モード
				this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onShortcutKeyDown);
				this.stage.addEventListener(KeyboardEvent.KEY_UP, onShortcutKeyUp);
				this.addEventListener( Event.ENTER_FRAME, onEnterFrame );
			} else if ( team == Constants.TEAM_NONE ) {
				operationBGColor = 0x666666;
				enemyBGColor = 0x666666;
				operationUI.setMode("");
				if ( this.stage != null ) {
					this.stage.removeEventListener( KeyboardEvent.KEY_DOWN, onShortcutKeyDown );
					this.stage.removeEventListener( KeyboardEvent.KEY_UP, onShortcutKeyUp );
				}
			}
			drawOperationBG(operationBGColor);
			drawEnemyBG(enemyBGColor);
			enable = false;
		}
		protected var _enable:Boolean = false;
		protected var _exitBtn:Button = new Button(80, 40, "ロビーに戻る");
		public function get enable():Boolean { return _enable; }
		public function set enable(value:Boolean ):void {
//			trace(" gameStage.enable", value );
			observeTF.visible = Score.isObserve && value;
			_exitBtn.visible = Score.isObserve && value;
			if ( !_enable && value ) {
				bg.setFilter(1);
				var temp:TextField = new TextField();
				temp.defaultTextFormat = new TextFormat("Arial", 60, 0xFFFF00, true);
				temp.text = "START";
				temp.autoSize = "left";
				if ( !Score.isObserve ) {
					bg.bitmapData.draw(temp, new Matrix(1, 0, 0, 1, 0.5 * (Constants.STAGE_WIDTH - temp.textWidth), 130));
					moveUI.mouseEnabled = true;
				} else {
					moveUI.mouseEnabled = false;
				}
				if( cpu != null ){
					cpu.start();
					cpu.addEventListener(GameEvent.ATTACK, onCPUAttack);
					cpu.addEventListener(GameEvent.SHOOT, onCPUShoot);
				}
				operationUI.setFocus();
			} else if ( _enable && !value ) {
				if( cpu != null ){
					cpu.disable();
					cpu.removeEventListener(GameEvent.ATTACK, onCPUAttack);
					cpu.removeEventListener(GameEvent.SHOOT, onCPUShoot);
				}
			}
			_enable = value;
			this.mouseChildren = value;
			this.operationUI.visible = value && !Score.isObserve;
			if( value ){
				this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onShortcutKeyDown);
				this.stage.addEventListener(KeyboardEvent.KEY_UP, onShortcutKeyUp);
				this.addEventListener( GameEvent.MISSILE_DAMAGE, onMissileDamage );
			} else {
				this.removeEventListener( GameEvent.MISSILE_DAMAGE, onMissileDamage );
			}
		}
		protected function onExit(e:MouseEvent):void {
			endObserve();
		}
		// 一人用
		
		protected function onCPUAttack(e:GameEvent):void {
			SoundManager.AttackSound.play();
			batteryList["0"].setMode(Constants.PLAY_MODE_ATTACKER);
			
			addAttack(cpu, e.data, false, cpu.attackid, 1, ServerClockUtil.getTime()+Constants.MISSILE_ARRIVE_TIME, -80+80*Math.random()+ClientUtil.getBatteryX(cpu));
		}
		protected function onCPUShoot(e:GameEvent):void {
			batteryList["0"].setMode(Constants.PLAY_MODE_DEFENDER);
			addBullet(cpu, cpu.self, cpu.focus.id, ServerClockUtil.getTime(), Constants.BULLET_SPEED, false, (e.data=="1"));
		}
		
		public function get myBatteryMoveTo():Number { return _myBatteryMoveTo; }
		
		public function set myBatteryMoveTo(value:Number):void 
		{
			if ( value < 22 ) value = 22;
			if ( value > (Constants.STAGE_WIDTH-22) ) value = (Constants.STAGE_WIDTH-22);
			_myBatteryMoveTo = value;
			dispatchEvent( new GameEvent(GameEvent.MOVE_BATTERY) );
		}
		public function get chatInputMode():Boolean { return _chatInputMode; }
		
		public function set chatInputMode(value:Boolean):void 
		{
			if ( _chatInputMode == false && value == true ) {
				chatInputBar.visible = true;
			} else if( !value ) {
				chatInputBar.visible = false;
			}
			if ( value ) {
				stage.focus = chatInputBar;
				if ( Capabilities.hasIME ) {
					try {
						IME.enabled = true;
					} catch(e:*){}
				}
			}

			_chatInputMode = value;
		}
	}
	class ColorSettingPanel extends Sprite {
		protected var colorTable:Array = [
			0x888888, 0xAA8888, 0x88AA88, 0x8888AA, 0x88AAAA, 0xAA88AA, 0xAAAA88, 0x666666, 0xAA6666, 0x66AA66,
			0x6666AA, 0x226666, 0x662266, 0x666622, 0xCC2222, 0x22CC22, 0x2222CC, 0x22CCCC, 0xCC22CC, 0xCCCC22
		];
		protected var bg:Sprite = new Sprite;
		protected var colors:Sprite = new Sprite;
		public function ColorSettingPanel() {
			bg.mouseEnabled = false;
			this.addChild( colors );
			this.addChild( bg );
			colors.addEventListener(MouseEvent.CLICK, onClick);
			colors.buttonMode = true;
		}
		public function setLevel(level:int):void {
			if ( level > colorTable.length ) level = colorTable.length;
			bg.graphics.clear();
			colors.graphics.clear();
			for ( var i:int = 0; i <level; i++ ) {
				bg.graphics.lineStyle( 0, 0xFFFFFF );
				bg.graphics.drawRect( 27 * (i % 10), 28 * int(i / 10), 16, 16);
				colors.graphics.beginFill( colorTable[i] );
				colors.graphics.drawRect( 27 * (i % 10), 28 * int(i / 10), 16, 16);
			}
			for ( ; i < 20; i++ ) { // 20: max level
				bg.graphics.lineStyle(0, 0xFFFFFF, 0.25);
				bg.graphics.drawRect( 27 * (i % 10), 28 * int(i / 10), 16, 16);
			}
		}
		protected function onClick(e:MouseEvent):void {
			var index:int = 10 * int(e.localY / 28) + int(e.localX / 27);
			dispatchEvent(new GameEvent("color", false, false, index + "-" + colorTable[index]) );
		}
	}
	
	// 設定ウィンドウ
	class OptionWindow extends Sprite {
		protected var attackTF:TextField = new TextField();
		protected var defenceTF:TextField = new TextField();
		protected var titleTF:TextField = new TextField();
		protected var baseColorTF:TextField = new TextField();
		protected var colorTF:TextField = new TextField();
		protected var handicapTitleTF:TextField = new TextField();
		protected var handicapTF:TextField = new TextField();
		protected var nameTF:TextField = new TextField();
		protected var nameChangeTF:TextField = new TextField();
		protected var languageTF:TextField = new TextField();
		protected var comLockTF:TextField = new TextField();
		protected var attackBattery:Battery = new Battery( true, 0, 0, 0);
		protected var defenceBattery:Battery = new Battery( true, 0, 0, 0);
		protected var baseColorPanel:ColorSettingPanel = new ColorSettingPanel();
		protected var colorPanel:ColorSettingPanel = new ColorSettingPanel();
		protected var keyconfigTF:TextField = new TextField();
		protected var alterEnterBtn:Button = new Button(100, 20, "ワード確定", true, true, 0x0);
		protected var switchToggleBtn:Button = new Button(100, 20, "モード切替", true, false, 0x0);
		protected var comLockBtn:Button = new Button(100, 20, "LV上昇のみ", true, false, 0x0);
		protected var closeBtn:Button = new Button(100, 20, "閉じる", true, false, 0x888888);
		protected var normalBtn:Button = new Button(100, 20, "NO HANDICAP", true, true, 0x0);
		protected var hardBtn:Button = new Button(100, 20, "DOUBLE WORD", true, false, 0x0);
		protected var veryHardBtn:Button = new Button(100, 20, "TRIPLE WORD", true, false, 0x0);
		protected var EngBtn:Button = new Button(90, 20, "英語のみ", true, false, 0x0);
		protected var BothBtn:Button = new Button(80, 20, "日英両方", true, false, 0x0);
		protected var JpnBtn:Button = new Button(80, 20, "日本語のみ", true, false, 0x0);
		
		public function OptionWindow() {
			this.graphics.beginFill(0x888888, 0.90);
			this.graphics.lineStyle(2, 0xFFFFFF);
			this.graphics.drawRoundRect(0, 0, Constants.OPTION_WINDOW_WIDTH, Constants.OPTION_WINDOW_HEIGHT, 10);
			this.graphics.lineStyle(1, 0xFFFFFF);
			this.graphics.beginFill(0x0);
			this.graphics.drawRoundRect(15, 80, 275, 33, 10);
			this.graphics.drawRoundRect(15, 140, 275, 58, 10);
			this.graphics.drawRoundRect(15, 225, 275, 58, 10);
//			this.graphics.drawRoundRect(310, 170, 100, 113, 10);
			this.graphics.moveTo(300, 10);
			this.graphics.lineTo(300, 50);
			this.graphics.moveTo(15, 55);
			this.graphics.lineTo(410, 55);
			this.graphics.moveTo(300, 60);
			this.graphics.lineTo(300, 283);
			this.graphics.moveTo(305, 135);
			this.graphics.lineTo(410, 135);
			
			baseColorPanel.x = 22;
			baseColorPanel.y = 147;
			colorPanel.x = 22;
			colorPanel.y = 232;
			
			TextFieldUtil.setupNoBorder(attackTF, false);
			TextFieldUtil.setupNoBorder(defenceTF, false);
			TextFieldUtil.setupNoBorder(titleTF, false);
			TextFieldUtil.setupNoBorder(baseColorTF, false);
			TextFieldUtil.setupNoBorder(colorTF, false);
			TextFieldUtil.setupNoBorder(handicapTitleTF, false);
			TextFieldUtil.setupNoBorder(keyconfigTF, false);
			TextFieldUtil.setupNoBorder(handicapTF, false);
			TextFieldUtil.setupNoBorder(nameTF, false);
			TextFieldUtil.setupNoBorder(languageTF, false);
			TextFieldUtil.setupNoBorder(comLockTF, false);
			TextFieldUtil.setupBorder(nameChangeTF);
			
			attackTF.text = "攻撃モード";
			defenceTF.text = "防御モード";
			titleTF.text = "砲台カラー設定";
			baseColorTF.text = "カラー設定１";
			colorTF.text = "カラー設定２";
			handicapTitleTF.text = "HANDICAP SETTING";
			keyconfigTF.text = "SPACEキー設定";
			comLockTF.text = "COM設定";
			nameTF.text = "あなたの名前";
			languageTF.text = "攻撃用言語設定";
			nameChangeTF.type = "input";
			
			this.addChild(titleTF);
			this.addChild(baseColorTF);
			this.addChild(colorTF);
			
			this.addChild(nameTF);
			this.addChild(nameChangeTF);
			
			this.addChild(languageTF);
			this.addChild(EngBtn);
			this.addChild(BothBtn);
			this.addChild(JpnBtn);
			
			this.addChild(comLockTF);
			
//			this.addChild(handicapTF);
//			this.addChild(handicapTitleTF);
			this.addChild(keyconfigTF);

			this.addChild(attackTF);
			this.addChild(defenceTF);
			this.addChild(attackBattery);
			this.addChild(defenceBattery);
			this.addChild(closeBtn);
//			this.addChild(normalBtn);
			this.addChild(alterEnterBtn);
//			this.addChild(hardBtn);
			this.addChild(switchToggleBtn);
//			this.addChild(veryHardBtn);
			this.addChild(comLockBtn);
			
			nameTF.x = 310;
			nameTF.y = 7;
			nameChangeTF.x = 310;
			nameChangeTF.y = 27;
			nameChangeTF.width = 100;
			nameChangeTF.height = 20;
			
			languageTF.x = 15;
			languageTF.y = 7;
			EngBtn.x = 15;
			BothBtn.x = 115;
			JpnBtn.x =  205;
			EngBtn.y = BothBtn.y = JpnBtn.y = 27;
			
//			handicapTitleTF.x = 310;
//			handicapTitleTF.y = 60;
			keyconfigTF.x = 310;
			keyconfigTF.y = 60;
//			handicapTF.x = 315;
//			handicapTF.y = 175;
//			handicapTF.width = 90;
//			handicapTF.wordWrap = true;
//			normalBtn.x = 310;
//			normalBtn.y = 80;
			alterEnterBtn.x = 310;
			alterEnterBtn.y = 80;
//			hardBtn.x = 310;
			switchToggleBtn.x = 310;
			switchToggleBtn.y = 110;
//			hardBtn.y = 110;
//			veryHardBtn.x = 310;
//			veryHardBtn.y = 140;
			comLockTF.x = 310;
			comLockTF.y = 140;
			comLockBtn.x = 310;
			comLockBtn.y = 160;
			titleTF.x = 15;
			titleTF.y = 60;
			baseColorTF.x = 15;
			baseColorTF.y = 120;
			colorTF.x = 15;
			colorTF.y = 205;
			attackTF.x = 20;
			attackTF.y = 90;
			defenceTF.x = 175;
			defenceTF.y = 90;
			attackBattery.x = 110;
			attackBattery.y = 95;
			defenceBattery.x = 265;
			defenceBattery.y = 98;
			closeBtn.x = 170;
			closeBtn.y = 300;
			this.addChild( baseColorPanel );
			this.addChild( colorPanel );
			
			attackBattery.setMode(Constants.PLAY_MODE_ATTACKER);
			defenceBattery.setMode(Constants.PLAY_MODE_DEFENDER);
			closeBtn.addEventListener(MouseEvent.CLICK, onClick);
			
			EngBtn.addEventListener(MouseEvent.CLICK, onEngClick);
			BothBtn.addEventListener(MouseEvent.CLICK, onBothClick);
			JpnBtn.addEventListener(MouseEvent.CLICK, onJpnClick);
			
			comLockBtn.addEventListener(MouseEvent.CLICK, onComLockClick);
			
//			normalBtn.addEventListener(MouseEvent.CLICK, onNormalClick);
			alterEnterBtn.addEventListener(MouseEvent.CLICK, onAlterEnterClick);
//			hardBtn.addEventListener(MouseEvent.CLICK, onHardClick);
			switchToggleBtn.addEventListener(MouseEvent.CLICK, onSwitchToggleClick);
//			veryHardBtn.addEventListener(MouseEvent.CLICK, onVeryHardClick);
			baseColorPanel.addEventListener("color", onBaseColor);
			colorPanel.addEventListener("color", onColor);
		}
		public function setName():void {
			nameChangeTF.text = String(LocalData.read(Constants.LD_FIELD, Constants.USER_NAME));
		}
		protected function onComLockClick(e:MouseEvent):void {
			comLockBtn.selected = !comLockBtn.selected;
			Score.comLock = comLockBtn.selected;
			setCom();
		}
		protected function onAlterEnterClick(e:MouseEvent):void {
			Score.ALTER_ENTER = Keyboard.SPACE;
			Score.SWITCH_MODE_KEY = 999;
			setSpaceKey();
		}
		protected function onSwitchToggleClick(e:MouseEvent):void {
			Score.ALTER_ENTER = 999;
			Score.SWITCH_MODE_KEY = Keyboard.SPACE;
			setSpaceKey();
		}
		protected function onEngClick(e:MouseEvent):void {
			Score.japaneseRate = 0;
			setLanguage();
		}
		protected function onBothClick(e:MouseEvent):void {
			Score.japaneseRate = 0.5;
			setLanguage();
		}
		protected function onJpnClick(e:MouseEvent):void {
			Score.japaneseRate = 1.0;
			setLanguage();
		}
		protected function onNormalClick(e:MouseEvent):void {
			dispatchEvent( new GameEvent(GameEvent.HANDICAP_SELECT, true, false, "1") );
		}
		protected function onHardClick(e:MouseEvent):void {
			dispatchEvent( new GameEvent(GameEvent.HANDICAP_SELECT, true, false, "2") );
		}
		protected function onVeryHardClick(e:MouseEvent):void {
			dispatchEvent( new GameEvent(GameEvent.HANDICAP_SELECT, true, false, "3") );
		}
		protected function onBaseColor(e:GameEvent):void {
			dispatchEvent( new GameEvent(GameEvent.COLOR_SELECT, true, false, Constants.USER_BATTERY_BASE_COLOR + "-" + e.data) );
		}
		public function setCom():void {
			comLockBtn.selected = Score.comLock;
		}
		public function setLanguage():void {
			EngBtn.selected = BothBtn.selected = JpnBtn.selected = false;
			switch( Score.japaneseRate ) {
				case 0:
					EngBtn.selected = true;
					break;
				case 1:
					JpnBtn.selected = true;
					break;
				default:
					BothBtn.selected = true;
					break;
			}
		}
		
		public function setSpaceKey():void {
			alterEnterBtn.selected = switchToggleBtn.selected = false;
			if ( Score.ALTER_ENTER == Keyboard.SPACE ) {
				alterEnterBtn.selected = true;
			} else {
				switchToggleBtn.selected = true;
			}
		}
		
		public function setHandicap():void {
			normalBtn.selected = hardBtn.selected = veryHardBtn.selected = false;
			var str:String = "";
			switch( Score.handicap ) {
				case 1:
					normalBtn.selected = true;
					str= "NO HANDICAP.\n";
					break;
				case 2:
					hardBtn.selected = true;
					str = "YOU HAVE TO TYPE WORDS TWICE TO ATTACK OR DEFENCE.\n";
					break;
				case 3:
					veryHardBtn.selected = true;
					str= "YOU HAVE TO TYPE WORDS THREE TIMES TO ATTACK OR DEFENCE.\n";
					break;
			}
			
			str +="\nATK:" +int(Score.attackPower / 1000) + "->" +int(Score.attackPower / 1000 / Score.handicap);
			str += "\nDEF:" +int(Score.defencePower / 1000) + "->" +int(Score.defencePower / 1000 / Score.handicap);
			
			handicapTF.text = str;
		}
		public function setLevel():void {
			baseColorPanel.setLevel(Score.getLevel());
			colorPanel.setLevel(Score.getLevel());
		}
		protected function onColor(e:GameEvent):void {
			dispatchEvent( new GameEvent(GameEvent.COLOR_SELECT, true, false, Constants.USER_BATTERY_COLOR + "-" + e.data) );
		}
		
		// 砲台の色設定
		public function setColors(baseLevel:int, color:int, baseColor:int):void {
			attackBattery.draw(baseLevel, color, baseColor);
			defenceBattery.draw(baseLevel, color, baseColor);
		}
		protected function onClick(e:MouseEvent):void {
			var oldName:String = String(LocalData.read(Constants.LD_FIELD, Constants.USER_NAME));
			if ( nameChangeTF.text != oldName && nameChangeTF.text != "" ) {
				dispatchEvent(new GameEvent(GameEvent.NAME_CHANGE, true, false, nameChangeTF.text));
				LocalData.write(Constants.LD_FIELD, Constants.USER_NAME, nameChangeTF.text);
			}
			Score.save();
			dispatchEvent(new Event("close"));
		}
	}
	
	// 情報ウィンドウ
	class InfoUI extends Sprite {
		protected var lobbyUserNumText:TextField = new TextField();
		protected var blueTeamNumText:TextField = new TextField();
		protected var redTeamNumText:TextField = new TextField();
		protected var defaultTextFormat:TextFormat = new TextFormat(TextFieldUtil.getFont(), null, 0xFFFFFF, true);
		
		protected var blueBtn:Button = new Button(60, 18, "ブルー", true, false, 0x0000FF);
		protected var redBtn:Button = new Button(60, 18, "レッド", true, false, 0xFF0000);
		protected var autoJoinBtn:Button = new Button(100, 40, "", true, false, 0x999999);
		protected var optionBtn:Button = new Button(80, 20, "設定", true, false, 0x333333);
		protected var tweetBtn:Button = new Button(60, 20, "TWEET", true, false, 0x333333);
		protected var gameRoomTF:TextField = new TextField();
		protected var gameRoomStatusTF:TextField = new TextField();
		protected var normalRoomPanel:Sprite = new Sprite();
		
		protected var optionWindow:OptionWindow = new OptionWindow();
		protected var chatWindow:ChatWindow;
		
		
		protected var soloRoomPanel:Sprite = new Sprite();
		protected var soloBtn:Button = new Button(100, 20, "COM対戦", true, false, 0x999999);
		protected var soloTitle:TextField = new TextField();
		protected var soloInfo:TextField = new TextField();
		
		protected var blueNum:int;
		protected var redNum:int;
		
		protected var coverSp:Sprite = new Sprite();
		
		public function InfoUI() {
			this.x = 0.5 * (Constants.STAGE_WIDTH - 405);
			this.y = 0.5 * (Constants.STAGE_HEIGHT - 415);
			this.graphics.beginFill(0x0, 0.5);
			this.graphics.drawRect( -this.x, -this.y, Constants.STAGE_WIDTH, Constants.STAGE_HEIGHT);
			this.graphics.endFill();
			this.graphics.beginFill(0x888888, 0.75);
			this.graphics.lineStyle(2, 0xFFFFFF);
			this.graphics.drawRoundRect(0, 0, 405, 415, 10);
			lobbyUserNumText.defaultTextFormat = blueTeamNumText.defaultTextFormat = redTeamNumText.defaultTextFormat = defaultTextFormat;
			lobbyUserNumText.autoSize = blueTeamNumText.autoSize = redTeamNumText.autoSize = "left";
			this.addChild( lobbyUserNumText );
			
			normalRoomPanel.addChild( blueTeamNumText );
			normalRoomPanel.addChild( redTeamNumText );
			normalRoomPanel.addChild( autoJoinBtn );
			normalRoomPanel.addChild( blueBtn );
			normalRoomPanel.addChild( redBtn );
			normalRoomPanel.addChild( gameRoomTF );
			normalRoomPanel.addChild( gameRoomStatusTF );
			this.addChild( normalRoomPanel );
			
			soloRoomPanel.addChild( soloTitle );
			soloRoomPanel.addChild( soloBtn );
			soloRoomPanel.addChild( soloInfo );
			
			this.addChild( soloRoomPanel );
			this.addChild( optionBtn );
			this.addChild( tweetBtn );
			blueBtn.addEventListener(MouseEvent.CLICK, onBlueClick);
			redBtn.addEventListener(MouseEvent.CLICK, onRedClick);
			autoJoinBtn.addEventListener(MouseEvent.CLICK, autoJoinFunc);
			optionBtn.addEventListener(MouseEvent.CLICK, onOptionClick);
			tweetBtn.addEventListener(MouseEvent.CLICK, onTweet);
			soloBtn.addEventListener(MouseEvent.CLICK, onSolo);
			
			TextFieldUtil.setupNoBorder( gameRoomTF, false );
			TextFieldUtil.setupNoBorder( gameRoomStatusTF, false );
			TextFieldUtil.setupNoBorder( soloTitle, false );
			TextFieldUtil.setupNoBorder( soloInfo, false );
			
			gameRoomTF.text = "通常ルーム";
			gameRoomTF.x = 6;  gameRoomTF.y = 2;
			gameRoomStatusTF.y = 20;
			gameRoomStatusTF.defaultTextFormat.bold = true;
			normalRoomPanel.graphics.beginFill(0xCCCCCC);
			normalRoomPanel.graphics.drawRect( 0, 0, 5, 18 );
			normalRoomPanel.graphics.lineStyle(0, 0xFFFFFF);
			normalRoomPanel.graphics.moveTo( 0, 18 );
			normalRoomPanel.graphics.lineTo( 120, 18 );
			lobbyUserNumText.x = 10; lobbyUserNumText.y = 10;
			tweetBtn.x = 245;
			tweetBtn.y = 10;
			optionBtn.x = 315;
			optionBtn.y = 10;
			optionWindow.x = -10;
			optionWindow.y = 10;
			normalRoomPanel.x = 10;
			normalRoomPanel.y = 335;
			
			soloRoomPanel.x = 10; soloRoomPanel.y = 387;
			soloRoomPanel.graphics.beginFill(0xCCCCCC);
			soloRoomPanel.graphics.drawRect( 0, 0, 5, 18 );
			soloRoomPanel.graphics.lineStyle(0, 0xFFFFFF);
			soloRoomPanel.graphics.moveTo( 0, 18 );
			soloRoomPanel.graphics.lineTo( 120, 18 );
			soloTitle.text = "COM対戦ルーム";
			soloInfo.autoSize = "left";
			soloTitle.x = 6;  soloTitle.y = 2;
			soloBtn.x = 120; soloBtn.y = 0;
			soloInfo.x = 225; soloInfo.y = 2;
			
			redTeamNumText.x = 290; redTeamNumText.y = 23;
			blueTeamNumText.x = 290; blueTeamNumText.y = 1;
			autoJoinBtn.x = 120; autoJoinBtn.y = 0;
			blueBtn.x = 225; blueBtn.y = 0;
			redBtn.x = 225; redBtn.y = 22;
			
			optionWindow.addEventListener("close", onClose);
			
			coverSp.graphics.beginFill(0x0, 0.5);
			coverSp.graphics.drawRect( 0, 0, Constants.STAGE_WIDTH, Constants.STAGE_HEIGHT);
			coverSp.graphics.endFill();
			
//			setGameRoomStatus(
		}
		protected var isObserve:Boolean = false;
		public function setGameRoomStatus(status:String):void {
//			trace( status );
			switch( status ) {
				case Constants.STATUS_CHATING:
						isObserve = false;
						autoJoinBtn.setText( Score.isWaitingAtLobby?"参加待機中":"ゲーム参加" );
						autoJoinBtn.setBorderColor( 0xFFFFFF, -1 );
					break;
				case Constants.STATUS_PLAYING:
						isObserve = true;
						autoJoinBtn.setText( "観戦する" );
//						autoJoinBtn.setText( "ゲーム参加" );
						autoJoinBtn.setBorderColor( 0xFFFFFF, -1 );
					break;
				case Constants.STATUS_WAITING:
						isObserve = false;
						autoJoinBtn.setText( Score.isWaitingAtLobby?"参加待機中":"ゲーム参加" );
						autoJoinBtn.setBorderColor( ((getTimer() / 1000) & 1)?0xFFFFFF:0xFFFF00, ((getTimer() / 1000) & 1)?-1:0xFFFF00 );
					break;
			}
		}
		public function updateSoloInfo(msg:String):void {
			soloInfo.text = msg;
		}
		public function updateNormalRoomStatus(msg:String):void {
			gameRoomStatusTF.text = msg;
		}
		public function onTweet(e:MouseEvent):void {
//			ExternalInterface.call("mixi.util.requestExternalNavigateTo",
//				"http://twitter.com/home/?status=" 
//				+ escapeMultiByte("Join me and play TypeShoot! http://wonderfl.net/c/qUaj")
//			);
			navigateToURL(new URLRequest("http://twitter.com/home/?status=" 
				+ escapeMultiByte("Join and play TypeShoot! http://wonderfl.net/c/qUaj"))
			);
		}
		public function updateHandicap():void {
			optionWindow.setHandicap();
		}
		protected function onClose(e:Event):void {
			this.removeChild(optionWindow);
			this.removeChild(coverSp);
		}
		
		protected function onOptionClick(e:MouseEvent):void {
			optionWindow.setLevel();
//			optionWindow.setHandicap();
			optionWindow.setSpaceKey();
			optionWindow.setLanguage();
			optionWindow.setCom();
			optionWindow.setName();
			this.addChild(coverSp);
			coverSp.x = -this.x;
			coverSp.y = -this.y;
			this.addChild(optionWindow);
		}
		
		public function fadeOut():void {
			this.mouseEnabled = false;
			this.mouseChildren = false;
			this.addEventListener(Event.ENTER_FRAME, onFadeOutEnterFrame);
		}
		protected function onFadeOutEnterFrame(e:Event):void {
			this.alpha *= 0.9;
			if ( this.alpha < 0.1 ) {
				this.removeEventListener(Event.ENTER_FRAME, onFadeOutEnterFrame);
				this.alpha = 0;
				this.visible = false;
			}
		}
		public function setInfoMessage(msg:String):void {
			chatWindow.setInfoMessage(msg);
		}
		public function setChatRoom(lobby:Room, isReconnect:Boolean):void {
			chatWindow = new ChatWindow(lobby, isReconnect);
			this.addChild( chatWindow );
			chatWindow.y = 40;
			chatWindow.x = 10;
		}
		public function noticeClosed():void {
			chatWindow.setInfoMessage("切断されました。");
		}
		public function display():void {
			this.mouseEnabled = true;
			this.mouseChildren = true;
			this.alpha = 1.0;
			this.visible = true;
			if ( this.stage != null ) {
				chatWindow.setFocus(this.stage);
			}
			if ( Score.lastLevel < Score.getLevel() ) {
				chatWindow.setInfoMessage("LV UP! 機体色が増えました！");
			}
			Score.lastLevel = Score.getLevel();
		}
		public function setBatteryColors(baseLevel:int, color:int, baseColor:int):void {
			LocalData.write(Constants.LD_FIELD, Constants.USER_BATTERY_COLOR, String(color));
			LocalData.write(Constants.LD_FIELD, Constants.USER_BATTERY_BASE_COLOR, String(baseColor));
			optionWindow.setColors(baseLevel, color, baseColor );
		}
		public function autoJoinFunc(e:MouseEvent):void {
			this.mouseChildren = false;
			if ( isObserve ) {
				if ( Math.random() < 0.5 ) {
					dispatchEvent(new GameEvent(GameEvent.OBSERVE_BLUE));
				} else {
					dispatchEvent(new GameEvent(GameEvent.OBSERVE_RED));
				}
				return;
			}
			if ( blueNum < redNum ) {
				if ( redNum == 0 ) {
					Score.isWaitingAtLobby = true;
				}
				dispatchEvent(new GameEvent(GameEvent.JOIN_BLUE));
			} else if ( blueNum > redNum ) {
				if ( blueNum == 0 ) {
					Score.isWaitingAtLobby = true;
				}
				dispatchEvent(new GameEvent(GameEvent.JOIN_RED));
			} else {
				if ( Math.random() < 0.5 ) {
					if ( redNum == 0 ) {
						Score.isWaitingAtLobby = true;
					}
					dispatchEvent(new GameEvent(GameEvent.JOIN_BLUE));
				} else {
					if ( blueNum == 0 ) {
						Score.isWaitingAtLobby = true;
					}
					dispatchEvent(new GameEvent(GameEvent.JOIN_RED));
				}
			}
			if ( Score.isWaitingAtLobby ) {
				this.mouseChildren = true;
				autoJoinBtn.setText( "参加待機中" );
			}
		}
		public function onSolo(e:MouseEvent):void {
			this.mouseChildren = false;
			dispatchEvent(new GameEvent(GameEvent.JOIN_SOLO));
		}
		public function onBlueClick(e:MouseEvent):void {
//			blueBtn.selected = true;
			this.mouseChildren = false;
			if ( isObserve ) {
				dispatchEvent(new GameEvent(GameEvent.OBSERVE_BLUE));
			} else {
				if ( redNum == 0 ) {
					Score.isWaitingAtLobby = true;
				}
				dispatchEvent(new GameEvent(GameEvent.JOIN_BLUE));
			}
			if ( Score.isWaitingAtLobby ) {
				this.mouseChildren = true;
				autoJoinBtn.setText( "参加待機中" );
			}
		}
		public function onRedClick(e:MouseEvent):void {
//			redBtn.selected = true;
			this.mouseChildren = false;
			if ( isObserve ) {
				dispatchEvent(new GameEvent(GameEvent.OBSERVE_RED));
			} else {
				if ( blueNum == 0 ) {
					Score.isWaitingAtLobby = true;
				}
				dispatchEvent(new GameEvent(GameEvent.JOIN_RED));
			}
			if ( Score.isWaitingAtLobby ) {
				this.mouseChildren = true;
				autoJoinBtn.setText( "参加待機中" );
			}
		}
		public function setLobbyUserNum(num:int ):void {
			lobbyUserNumText.text = "" + num + " ユーザーが接続中です！";
		}
		public function setBlueTeamInfo(num:int, attack:Number, defence:Number):void {
			blueNum = num;
			blueTeamNumText.text = num + "名" + " ("+int(attack/1000)+"/"+int(defence/1000)+")";
		}
		public function setRedTeamInfo(num:int, attack:Number, defence:Number):void {
			redNum = num;
			redTeamNumText.text = num + "名" + " ("+int(attack/1000)+"/"+int(defence/1000)+")";
		}
	}
	
	// チャットウィンドウ
	class ChatWindow extends Sprite {
		protected var input:TextField = new TextField();
		protected var coming:TextField = new TextField();
		protected var users:TextField = new TextField();
		protected var lobby:Room;
		
		public function ChatWindow(lobby:Room, isReconnect:Boolean = false) {
			
			this.lobby = lobby;
			users.border = input.border = coming.border = true;
			users.background = input.background = coming.background = true;
			users.borderColor = input.borderColor = coming.borderColor = 0xFFFFFF;
			users.backgroundColor = input.backgroundColor = coming.backgroundColor = 0x0;
			TextFieldUtil.setupNoBorder(users);
			TextFieldUtil.setupNoBorder(input);
			TextFieldUtil.setupNoBorder(coming);
//			users.defaultTextFormat = input.defaultTextFormat = coming.defaultTextFormat = new TextFormat(null, null, 0xFFFFFF);
			coming.width = 280;
			coming.height = 260;
			coming.wordWrap = true;
			coming.textColor = 0xFFFFFF;
			input.type = "input";
			input.width = 385;
			input.height = 20;
			input.y = 265;
			users.width = 100;
			users.height = 260;
			users.x = 285;
			
			this.addChild( coming );
			this.addChild( input );
			this.addChild( users );
			
			var defaultText:String = "";
			if ( isReconnect ) {
				defaultText += getNowTimeFormat() + " *** 再接続しました\n";
			} else {
				defaultText += getNowTimeFormat() + " *** TypeShoot へようこそ！ ***\n";
				defaultText += getNowTimeFormat() + " * ver 1.4.5\n";
				defaultText += getNowTimeFormat() + " * これはタイピングゲームです。\n";
				defaultText += getNowTimeFormat() + " * 青と赤のチームにわかれ、敵側に\n";
				defaultText += getNowTimeFormat() + " * ミサイルを撃ち込みます。先に\n";
				defaultText += getNowTimeFormat() + " * 敵のライフを0にすると勝利です。\n";
				defaultText += getNowTimeFormat() + " * \n";
				defaultText += getNowTimeFormat() + " * 攻撃モードを選択し、ワードを\n";
				defaultText += getNowTimeFormat() + " * 打ちこむと攻撃できます。選択中の\n";
				defaultText += getNowTimeFormat() + " * ワード入力にはボーナスがつきます。\n";
				defaultText += getNowTimeFormat() + " * 防御するには防御モードを選択し、\n";
				defaultText += getNowTimeFormat() + " * 敵ミサイルのワードを撃ちます。\n";
				defaultText += getNowTimeFormat() + " * \n";
				defaultText += getNowTimeFormat() + " * ショートカットキー操作の一覧を\n";
				defaultText += getNowTimeFormat() + " * 見るには、/hと入力してください。\n";
				defaultText += getNowTimeFormat() + " * \n";
				defaultText += getNowTimeFormat() + " * それでは、お楽しみください！\n";
			}
			coming.text = defaultText;
			
			input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			lobby.addEventListener(RoomEvent.OCCUPANT_COUNT, onClientCount);
			lobby.addEventListener(RoomEvent.ADD_OCCUPANT, onJoin);
			lobby.addEventListener(RoomEvent.REMOVE_OCCUPANT, onLeave);
			lobby.addEventListener(RoomEvent.UPDATE_CLIENT_ATTRIBUTE, onUpdateClientAttribute);
			lobby.addMessageListener("CHAT_MESSAGE", chatMessageAction);
		}
		public function setFocus(stage:Stage):void {
			stage.focus = input;
		}
		protected function onJoin(e:RoomEvent):void {
			setInfoMessage(ClientUtil.getUserName(e.getClient()) + " joined");
		}
		protected function onLeave(e:RoomEvent):void {
			setInfoMessage(ClientUtil.getUserName(e.getClient()) + " left");
		}
		protected function onUpdateClientAttribute(e:RoomEvent):void {
			switch( e.getChangedAttr().name ) {
				case "team":
				case "isSolo":
						updateUserList();
						break;
				case Constants.USER_NAME:
						if( e.getChangedAttr().oldValue != null ) setInfoMessage(e.getChangedAttr().oldValue + " is now " + e.getChangedAttr().value );
						updateUserList();
						break;
				case Constants.ATTACK_POWER:
						if ( e.getClient().isSelf() ) {
							setInfoMessage("Your attack power: " + int(Number(e.getChangedAttr().oldValue)/100)/10 + " -> " + int(Number(e.getChangedAttr().value)/100)/10);
						}
						updateUserList();
						break;
				case Constants.DEFENCE_POWER:
						if ( e.getClient().isSelf() ) {
							setInfoMessage("Your defence power: " + int(Number(e.getChangedAttr().oldValue)/100)/10 + " -> " + int(Number(e.getChangedAttr().value)/100)/10);
						}
						updateUserList();
						break;
				case Constants.HANDICAP:
						updateUserList();
						break;
					break;
			}
		}
		protected function onClientCount(e:RoomEvent):void {
			
			updateUserList();
		}
		protected function updateUserList():void {
			var list:Array = lobby.getOccupants();
			var listStr:String = "";
			for ( var i:int = 0; i < list.length; i++ ) {
				var userStr:String = ClientUtil.getUserName(list[i]);
				var attackPower:Number = ClientUtil.getAttackPower(list[i]);
				var defencePower:Number = ClientUtil.getDefencePower(list[i]);
				var handicap:Number = ClientUtil.getHandicap(list[i]);
				var colorStr:String = "#FFFFFF";
				var powerColor:String = "#FFFFFF";
				if ( ClientUtil.isSolo( list[i] ) ) {
					colorStr = "#666666";
				} else {
					if ( ClientUtil.isTeamBlue( list[i] ) ) colorStr = "#6666FF";
					if ( ClientUtil.isTeamRed( list[i] ) ) colorStr = "#FF6666";
				}
				if ( (list[i] as IClient).isSelf() ) colorStr = "#66FF66";
				if ( handicap == 2 ) powerColor = "#FFFF66";
				if ( handicap == 3 ) powerColor = "#FF6666";
				listStr += "<font color='" + colorStr +"'>" + userStr + "</font>" +
				"(<font color='"+powerColor+"'>"+int(int(attackPower)/1000/handicap)+"</font>/<font color='"+powerColor+"'>"+int(int(defencePower)/1000/handicap)+"</font>)\n";
			}
			users.htmlText = "<font color='#FFFFFF' face='_等幅'>" + listStr +"</font>";
		}
		protected function getNowTimeFormat():String {
			var date:Date = new Date();
			var timeStr:String = 
				String("00" + date.getHours()).substr( -2, 2) + ":" + 
				String("00" + date.getMinutes()).substr( -2, 2) + ":" +
				String("00" + date.getSeconds()).substr( -2, 2);
			return timeStr;
		}
		protected function chatMessageAction(from:IClient, msg:String):void {
			if( from.isSelf() )
				coming.appendText( getNowTimeFormat() + " )" + ClientUtil.getUserName(from) + "( " + String(decodeURI(msg)) + "\n" );
			else
				coming.appendText( getNowTimeFormat() + " (" + ClientUtil.getUserName(from) + ") " + String(decodeURI(msg)) + "\n" );
			coming.scrollV = coming.maxScrollV;
		}
		public function setInfoMessage(msg:String):void {
			coming.appendText( getNowTimeFormat() + " *** " + msg + "\n" );
			coming.scrollV = coming.maxScrollV;
		}
		protected function onKeyDown(e:KeyboardEvent):void {
			if ( (e.keyCode == Keyboard.ENTER) && ( input.text != "" ) ) {
				switch( input.text ) {
					case "/version":
					case "/v":
						setInfoMessage(Constants.VERSION);
						break;
					case "/help":
					case "/h":
						setInfoMessage("【チャット画面】");
						setInfoMessage("/hと入力: 操作一覧");
						setInfoMessage("/vと入力: バージョン表示");
						setInfoMessage("【ゲーム画面】");
						setInfoMessage("F2: チームチャット");
						setInfoMessage("Tab: 攻撃/防御モード切替");
						if( Score.ALTER_ENTER == Keyboard.SPACE ) {
							setInfoMessage("Space: ワード確定");
						} else {
							setInfoMessage("Space: 攻撃/防御モード切替");
						}
						setInfoMessage("【ゲーム画面 防御モード】");
						setInfoMessage("F12: 防御範囲変更");
						setInfoMessage("ESC: 入力リセット");
						break;
					default:
						lobby.sendMessage("CHAT_MESSAGE", true, null, String(encodeURI(input.text)));
						break;
				}
				input.text = "";
			}
		}
	}
	
	class ClientUtil {
		public static function isCPU(client:IClient):Boolean {
			return ( client.getClientID() == "0" ) 
		}
		public static function getIsAttackCombo(client:IClient):Boolean {
			return ( String(client.getAttribute("attackCombo")) == "true" ) 
		}
		public static function getIsDefenceCombo(client:IClient):Boolean {
			return ( String(client.getAttribute("defenceCombo")) == "true" ) 
		}
		public static function getTeam(client:IClient):String {
			return ( String(client.getAttribute("team")) );
		}
		public static function getPlayMode(client:IClient):String {
			return ( String(client.getAttribute(Constants.PLAY_MODE, Score.myGameRoom)) );
		}
		public static function getBatteryX(client:IClient):Number {
			return ( Number(client.getAttribute(Constants.BATTERY_X, Score.myGameRoom)) );
		}
		public static function getBatteryScreenPosition(client:IClient):Point {
			return new Point();
		}
		public static function isSolo(client:IClient):Boolean {
			return ( client.getAttribute("isSolo") == "true" );
		}
		public static function isTeamBlue(client:IClient):Boolean {
			return ( client.getAttribute("team") == Constants.TEAM_BLUE );
		}
		public static function isTeamRed(client:IClient):Boolean {
			return ( client.getAttribute("team") == Constants.TEAM_RED );
		}
		public static function getUserName(client:IClient):String {
			return decodeURIComponent(String(client.getAttribute(Constants.USER_NAME)));
		}
		public static function getHandicap(client:IClient):Number {
			return Number(client.getAttribute(Constants.HANDICAP));
		}
		public static function getAttackPower(client:IClient):Number {
			return Number(client.getAttribute(Constants.ATTACK_POWER));
		}
		public static function getDefencePower(client:IClient):Number {
			return Number(client.getAttribute(Constants.DEFENCE_POWER));
		}
		public static function getBaseLevel(client:IClient):int {
			return int(client.getAttribute(Constants.USER_BATTERY_BASE_LEVEL));
		}
		public static function getColor(client:IClient):int {
			return int(client.getAttribute(Constants.USER_BATTERY_COLOR));
		}
		public static function getBaseColor(client:IClient):int {
			return int(client.getAttribute(Constants.USER_BATTERY_BASE_COLOR));
		}
		public static function setColor(client:IClient, color:int):void {
			client.setAttribute(Constants.USER_BATTERY_COLOR, String(color));
		}
		public static function setBaseColor(client:IClient, baseColor:int):void {
			client.setAttribute(Constants.USER_BATTERY_BASE_COLOR, String(baseColor));
		}
		public static function getStatus(client:IClient):String {
			return String(client.getAttribute("status") );
		}
	}
	
	// 
	class GameEvent extends Event {
//		public static const INFO_START:String = "infoStart";
//		public static const GAME_START:String = "gameStart";
//		public static const LOBBY_USER_NUM_UPDATE:String = "lobbyUserNumUpdate";
//		public static const GAME_USER_NUM_UPDATE:String = "gameUserNumUpdate";
		public static const JOIN_BLUE:String = "joinBlue";
		public static const JOIN_RED:String = "joinRed";
		public static const JOIN_SOLO:String = "joinSolo";
		public static const AUTO_JOIN:String = "autoJoin";
		public static const MOVE_BATTERY:String = "moveBattery";
		public static const MODE_ATTACK:String = "modeAttack";
		public static const MODE_DEFENCE:String = "modeDefender";
		public static const HIT:String = "hit";
		public static const ATTACK:String = "attack";
		public static const DEFENCE_TYPE:String = "defenceType";
		public static const DESTROY:String = "destroy";
		public static const SHOOT:String = "shoot";
		public static const MISSILE_DESTROY:String = "missileDestroy";
		public static const MISSILE_DAMAGE:String = "missileDamage";
		public static const CHAT:String = "chat";
		public static const END_GAME:String = "endGame";
		public static const COLOR_SELECT:String = "colorSelect";
		public static const HANDICAP_SELECT:String = "handicapSelect";
		public static const ATTACK_REFLECT:String = "attackReflect";
		public static const ATTACK_DOUBLE:String = "attackDouble";
		public static const NAME_CHANGE:String = "nameChange";
		public static const ATTACK_COMBO_END:String = "attackComboEnd";
		public static const ATTACK_COMBO_START:String = "attackComboStart";
		public static const DEFENCE_COMBO_END:String = "defenceComboEnd";
		public static const DEFENCE_COMBO_START:String = "defenceComboStart";
		public static const OBSERVE_BLUE:String = "observeBlue";
		public static const OBSERVE_RED:String = "observeRed";
		
		public var data:String;
		
		public function GameEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, data:String=null) {
			super(type, bubbles, cancelable);
			this.data = data;
		}
		override public function clone():Event 
		{
			return new GameEvent(type, bubbles, cancelable, data);
		}
	}
	
	// 入室時のインターフェース
	class EnterUI extends Sprite {
		protected var tf:TextField = new TextField();
		protected var btn:Button = new Button(100, 20, "ENTER", false);
		public function EnterUI () {
			draw();
		}
		protected function draw():void {
			tf.width = 100;
			tf.height = 18;
			TextFieldUtil.setupBorder(tf);
			tf.type = "input";
			btn.y = 30;
			var userNameObj:Object = LocalData.read(Constants.LD_FIELD, Constants.USER_NAME);
			if ( userNameObj == null ) {
				tf.text = "Input your name";
				tf.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			} else {
				tf.text = String(userNameObj);
				enterEnable();
			}
			tf.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			this.addChild( tf );
			this.addChild( btn );
			btn.addEventListener(MouseEvent.CLICK, onClick);
		}
		protected function onClick(e:MouseEvent = null):void {
			LocalData.write(Constants.LD_FIELD, Constants.USER_NAME, tf.text);
			LocalData.flush(Constants.LD_FIELD);
			btn.selected = true;
			this.dispatchEvent(new Event("enter"))
		}
		protected function onMouseDown(e:MouseEvent):void {
			tf.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			tf.text = "";
		}
		protected function onKeyUp(e:KeyboardEvent):void {
			if ( tf.text.length > 0 ) {
				enterEnable();
				if ( e.keyCode == Keyboard.ENTER ) {
					onClick(); // ENTER押したのと同じにする
				}
			} else {
				enterDisable();
			}
		}
		protected function enterEnable():void {
			btn.enable = true;
		}
		protected function enterDisable():void {
			btn.enable = false;
		}
	}
	
	// テキストとグラフィックで作るボタン
	class Button extends Sprite {
		protected var bgBlack:Sprite = new Sprite();
		protected var bgGray:Sprite = new Sprite();
		protected var highlight:Sprite = new Sprite();
		protected var tf:TextField = new TextField();
		protected var w:int;
		protected var h:int;
		protected var bgColor:int;
		public function Button(width:int, height:int, text:String, isEnabled:Boolean = true, isSelected:Boolean = false, bgColor:int = 0x0) {
			this.bgColor = bgColor;
			w = width;
			h = height;
			setBorderColor(0xFFFFFF, bgColor);
			bgGray.graphics.beginFill(0xFFFFFF, 0.5);
			bgGray.graphics.drawRoundRect(0, 0, width, height, 5);
			highlight.graphics.beginFill(0x88FF88, 0.5);
			highlight.graphics.drawRoundRect(0, 0, width, height, 5);
			this.addChild( bgBlack );
			this.addChild( bgGray );
			this.addChild( highlight );
			highlight.mouseEnabled = highlight.mouseChildren = false;
			this.selected = isSelected;
			this.addEventListener(MouseEvent.ROLL_OVER, function():void { bgGray.alpha = 1.0 } );
			this.addEventListener(MouseEvent.ROLL_OUT, function():void { bgGray.alpha = 0 } );
			bgGray.alpha = 0;
			tf.autoSize = "left";
			TextFieldUtil.setupNoBorder(tf);
			setText(text);
			this.addChild( tf );
			this.mouseChildren = false;
			this.enable = isEnabled;
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		public function setText(text:String):void {
			tf.text = text;
			tf.x = 0.5 * (w - tf.width);
			tf.y = 0.5 * (h - tf.height);
		}
		public function setBorderColor(color:int, bgColor:int):void {
			if ( bgColor == -1 ) bgColor = this.bgColor;
			bgBlack.graphics.clear();
			bgBlack.graphics.lineStyle(0, color);
			bgBlack.graphics.beginFill(bgColor, 0.75);
			bgBlack.graphics.drawRoundRect(0, 0, w, h, 5);
		}
		protected function onClick(e:MouseEvent):void {
			SoundManager.ClickSound.play();
		}
		public function get selected():Boolean {
			return highlight.visible;
		}
		public function set selected(value:Boolean):void {
			highlight.visible = value;
		}
		public function set enable(value:Boolean):void {
			this.mouseEnabled = value;
//			this.buttonMode = value;
			this.alpha = (value?1.0:0.5);
		}
	}
	
	// 砲台移動用ユーザーインターフェース
	class MoveBatteryUI extends Sprite {
		private var batteryShadow:Battery = new Battery(true, 0,0,0);
		public function MoveBatteryUI() {
			batteryShadow.filters =[ new ColorMatrixFilter([0, 0, 0, 0.4, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 1.0, 0])];
			this.addChild( batteryShadow );
			batteryShadow.y = Constants.BATTERY_DEFAULT_Y;
			batteryShadow.visible = false;
			this.graphics.beginFill(0x0, 0);
			this.graphics.drawRect(0, 0, 480, 40);
			
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		protected function onRollOver(e:MouseEvent):void {
			batteryShadow.visible = true;
		}
		protected function onRollOut(e:MouseEvent):void {
			batteryShadow.visible = false;
		}
		protected function onMouseMove(e:MouseEvent):void {
			batteryShadow.x = this.mouseX;
		}
		// 砲台シャドウの形態変更
		public function setMode(playMode:String):void {
			batteryShadow.setMode(playMode);
		}
	}
	
	class FocusCircle extends Sprite
	{
		public var timeQA:QuarterArc = new QuarterArc();
		public var damageQA:QuarterArc = new QuarterArc();
		public var sameTargetQA:QuarterArc = new QuarterArc();
		public var typedQA:QuarterArc = new QuarterArc();
		private var r:Number;
		private var w:Number;
		public function FocusCircle(r:Number, w:Number) {
			this.r = r;
			this.w = w;
			this.graphics.lineStyle(0, 0xFFFF00);
			this.graphics.drawCircle(0, 0, r);
			this.graphics.drawCircle(0, 0, r + w);
			this.graphics.moveTo(r, 0);
			this.graphics.lineTo(r+w, 0);
			this.graphics.moveTo(-r, 0);
			this.graphics.lineTo(-r-w, 0);
			this.graphics.moveTo(0, r);
			this.graphics.lineTo(0, r+w);
			this.graphics.moveTo(0, -r);
			this.graphics.lineTo(0, -r-w);
			this.addChild( timeQA );
			this.addChild( damageQA );
			this.addChild( sameTargetQA );
			this.addChild( typedQA );
			damageQA.scaleX = -1;
			sameTargetQA.scaleY = -1;
			typedQA.rotation = 180;
			this.alpha = 0;
			this.scaleX = 2;
			this.scaleY = 2;
			this.rotation = 100;
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		private function onEnterFrame(e:Event):void {
			this.alpha += ( 1 - this.alpha ) * 0.25;
			this.scaleX += ( 1 - this.scaleX ) * 0.25;
			this.scaleY += ( 1 - this.scaleY ) * 0.25;
			this.rotation += ( - this.rotation ) * 0.25;
			if ( this.alpha == 0.98 ) {
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				this.alpha = 1;
				this.scaleX = this.scaleY = 1;
				this.rotation = 1;
			}
		}
		public function removeThis():void {
			this.addEventListener(Event.ENTER_FRAME, onRemoveEnterFrame);
		}
		private function onRemoveEnterFrame(e:Event):void {
			this.alpha += ( 0 - this.alpha ) * 0.25;
			this.scaleX += ( 1.5 - this.scaleX ) * 0.25;
			this.scaleY += ( 1.5 - this.scaleY ) * 0.25;
			this.rotation += ( -50 - this.rotation ) * 0.25;
			if ( this.alpha < 0.5 ) {
				this.removeEventListener(Event.ENTER_FRAME, onRemoveEnterFrame);
				if ( this.parent != null ) {
					this.parent.removeChild( this );
				}
			}
		}
		public function setParams(timeRate:Number, damageRate:Number, typedRate:Number, sameTargetRate:Number):void {
			timeQA.setParams(r, w, timeRate, getColor(timeRate));
			damageQA.setParams(r, w, damageRate, getColor(damageRate));
			typedQA.setParams(r, w, typedRate, 0x00FF00);
			sameTargetQA.setParams(r, w, 1.0, getColor(sameTargetRate));
		}
		private function getColor(rate:Number):int{
			var ret:int = 0;
			var temp:Number;
			if( rate < 0.5 ){
				temp = rate / 0.5;
				ret = 0xFF0000;
				ret |= int( temp * 255 ) << 8;
			} else {
				temp = (1 - rate) / 0.5;
				ret = 0x00FF00;
				ret |= int( temp * 255) << 16;
			}
			return ret;
		}
	}
	
	/**
	 * 1/4の円弧を描く
	 * @author Kenichi UENO
	 */
	class QuarterArc extends Sprite
	{
		private var maskSp:Sprite = new Sprite();
		public function QuarterArc()
		{
			this.mask = maskSp;
			this.addChild( maskSp );
		}
		public function setParams(radius:Number, width:Number, rate:Number, color:int):void {
			var radian:Number = rate < 0.5?Math.PI * 0.5 * rate:Math.PI * 0.5 * (rate-0.5);
			var maskG:Graphics = maskSp.graphics;
			var outsideR:Number = radius + width;
			graphics.clear();
			maskG.clear();
			graphics.beginFill(color);
			graphics.drawCircle(0, 0, outsideR);
			graphics.drawCircle(0, 0, radius);
			maskG.beginFill(0xFF);
			maskG.lineTo(outsideR, 0);
			if( rate < 0.5 ){
				maskG.lineTo(outsideR, -outsideR * Math.tan( radian ));
			} else {
				maskG.lineTo(outsideR, -outsideR);
				maskG.lineTo(outsideR * ( 1 - Math.tan( radian )), -outsideR);
			}
			maskG.lineTo(0, 0);
			maskG.endFill();
		}
		
	}
	
	// ゲーム設定値とか定数とかとにかく放り込んだ
	class Constants {
		public static const VERSION:String = "version 1.4.5.20090911.1";
		public static const STAGE_WIDTH:Number = 465;
		public static const STAGE_HEIGHT:Number = 465;
		public static const DISTANCE:Number = 300; // 敵味方までのpixel
		public static const OPTION_WINDOW_WIDTH:Number = 425;
		public static const OPTION_WINDOW_HEIGHT:Number = 330;
		public static const CPU_START_WAITTIME:Number = 3000;
		public static const GAME_START_WAITTIME:Number = 10000;
		public static const GAME_END_NEXT_WAITTIME:Number = 20000;
		public static const ANGLE:String = "angle";
		public static const LD_FIELD:String = "wonderflGame1";
		public static const USER_NAME:String = "userName";
		public static const STATUS_CHATING:String = "statusChating"; // lobby
		public static const STATUS_WAITING:String = "statusWaiting"; // 入室まち
		public static const STATUS_PLAYING:String = "statusPlaying"; // プレイ中
		public static const STATUS_OBSERVING:String = "statusObserving"; // 観戦中
		public static const STATUS_FINISHING:String = "statusFinishing"; // 未使用
		public static const CPU_ROOM_DEFAULT:String = "wonderfl.keno.missileGame.game.cpu";
		public static const GAME_ROOM:String = "wonderfl.keno.missileGame.game.room2";
		public static const LOBBY_ROOM:String = "wonderfl.keno.missileGame.lobby2";
		public static const TEAM_NONE:String = "teamNone";
		public static const TEAM_BLUE:String = "teamBlue";
		public static const TEAM_RED:String = "teamRed";
		public static const BATTERY_DEFAULT_Y:Number = 12;
		public static const BATTERY_X:String = "batteryX";
		public static const PLAY_MODE:String = "playMode";
		public static const PLAY_MODE_ATTACKER:String = "playModeAttacker";
		public static const PLAY_MODE_DEFENDER:String = "playModeDefender";
		public static const USER_BATTERY_BASE_LEVEL:String = "userBatteryBaseLevel";
		public static const USER_BATTERY_COLOR:String = "UserBatteryColor";
		public static const USER_BATTERY_BASE_COLOR:String = "UserBatteryBaseColor";
		public static const USER_BATTERY_EFFECT_LEVEL:String = "UserBatteryEffectLevel";
		public static const DEFAULT_USER_BATTERY_BASE_LEVEL:int = 0;
		public static const DEFAULT_USER_BATTERY_COLOR:int = 0x888888
		public static const DEFAULT_USER_BATTERY_BASE_COLOR:int = 0x888888;
		public static const ATTACK:String = "attack";
		public static const ATTACK_LOG:String = "attackLog";
		public static const ATTACK_REFLECT:String = "attackReflect";
		public static const REMOVE_MISSILE:String = "attackLog";
		public static const RESULT_SUCCESS:int = 1;
		public static const NO_VALUE:int = -1;
		public static const RESULT_FAULT:int = 0;
		public static const RESULT_DESTROY:int = 3;
		public static const SEND_ME_LOG:String = "sendMeLog";
		public static const SHOOT:String = "shoot";
		public static const DESTROY:String = "destroy";
		public static const HIT:String = "hit";
		public static const TEAM_CHAT_DURATION:Number = 5000; // 5000 msec
		public static const GAME_CHAT:String = "gameChat";
		public static const VICTORY_POINT:Number = 10;
		public static var MISSILE_ARRIVE_TIME:Number = 27 * DISTANCE; // 8000 msec
		public static const BULLET_SPEED:Number = 170 / 1000; // 170pixel per 1000msec
		public static const BASE_LEVEL_0:int = 0; // 円
		public static const BASE_LEVEL_1:int = 1; // 三角
		public static const BASE_LEVEL_2:int = 2; // A字
		public static const BASE_LEVEL_3:int = 3; // スター
		public static const CHAT_KEY:uint = Keyboard.F2;
		public static const DEFENCE_MODE_CHANGE_KEY:uint = Keyboard.F12;
		public static const ATTACK_POWER:String = "attackPower";
		public static const DEFENCE_POWER:String = "defencePower";
		public static const HANDICAP:String = "handicap";
		public static const ATTACK_COMBO_START:int = 15;
		public static const DEFENCE_COMBO_START:int = 15;
		public static const DEFENCE_MODE_Y_AXIS:int = 0;
		public static const DEFENCE_MODE_X_AXIS:int = 1;
		public static const DEFENCE_MODE_PLAYER:int = 2;
	}
	
	// テキストフィールドでよく使う設定
	class TextFieldUtil {
		public static function getFont():String {
//			return "_sans";
			return "_等幅";
//			return "ＭＳ ゴシック";
		}
		public static function setupBorder(tf:TextField):void {
			tf.defaultTextFormat = new TextFormat(getFont(), null, 0xFFFFFF);
			tf.border = true;
			tf.borderColor = 0xFFFFFF;
			tf.background = true;
			tf.backgroundColor = 0x0;
		}
		public static function setupNoBorder(tf:TextField, selectable:Boolean = true):void {
			tf.defaultTextFormat = new TextFormat(getFont(), null, 0xFFFFFF);
			tf.selectable = selectable;
		}
	}
	
	// 自分用データ（共有しない）
	class Score {
		public static var type:Number = 0; // SO保存
		public static var correct:Number = 0; // SO保存
		public static var attack:Number = 0; // SO保存
		public static var defence:Number = 0; // SO保存
		public static var hit:Number = 0; // SO保存
		public static var damage:Number = 0; // SO保存
		public static var win:Number = 0; // SO保存
		public static var lose:Number = 0; // SO保存
		public static var score:Number = 0;
		public static var defencePower:Number = 0; // SO保存
		public static var attackPower:Number = 0; // SO保存
		public static var handicap:Number = 1;
		public static var attackCombo:Number = 0;
		public static var defenceCombo:Number = 0;
		public static var japaneseRate:Number = 1; // SO保存
		public static var lastLevel:int = 0;
		public static var playMode:String = null;
		public static var myGameRoom:String = null;
		public static var isSolo:Boolean = false;
		public static var isObserve:Boolean = false;
		public static var cpuLV:Number = 3; // SO保存
		public static var ALTER_ENTER:uint = Keyboard.SPACE; // SO保存
		public static var SWITCH_MODE_KEY:uint = 999;
		public static var defenceMode:int = 0; // SO保存
		public static var myGameTeam:String;
		public static var comLock:Boolean = false; // SO保存
		public static var missileDisplayMode:int = 0;
		public static var isWaitingAtLobby:Boolean = false;
		protected static var expTable:Array = [0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 12000, 14000, 16000, 18000, 20000, 25000, 30000, 35000, 40000, 45000];
		public static function initScore():void {
			type = Number(LocalData.read(Constants.LD_FIELD, "totalType"));
			correct = Number(LocalData.read(Constants.LD_FIELD, "totalCorrect"));
			attack = Number(LocalData.read(Constants.LD_FIELD, "attack"));
			defence = Number(LocalData.read(Constants.LD_FIELD, "defence"));
			hit = Number(LocalData.read(Constants.LD_FIELD, "hit"));
			damage = Number(LocalData.read(Constants.LD_FIELD, "damage"));
			win = Number(LocalData.read(Constants.LD_FIELD, "win"));
			lose = Number(LocalData.read(Constants.LD_FIELD, "lose"));
			attackPower = Number(LocalData.read(Constants.LD_FIELD, "attackPower"));
			defencePower = Number(LocalData.read(Constants.LD_FIELD, "defencePower"));
//			handicap = Number(LocalData.read(Constants.LD_FIELD, "handicap"));
//			if ( handicap == 0 ) handicap = 1;

			tempObj = LocalData.read(Constants.LD_FIELD, "japaneseRate");
			if ( tempObj != null ) japaneseRate = Number( tempObj );
			
			cpuLV = Number(LocalData.read(Constants.LD_FIELD, "cpuLV"));
			if ( cpuLV == 0 ) cpuLV = Math.max( int(attackPower / 1000), int(defencePower / 1000), 0.5 );
			
			ALTER_ENTER = uint(LocalData.read(Constants.LD_FIELD, "alterEnter"));
			if ( ALTER_ENTER == 0 || ALTER_ENTER == Keyboard.SPACE ) {
				ALTER_ENTER = Keyboard.SPACE;
				SWITCH_MODE_KEY = 999;
			} else {
				ALTER_ENTER = 999;
				SWITCH_MODE_KEY = Keyboard.SPACE;
			}
			
			defenceMode = int(LocalData.read(Constants.LD_FIELD, "defenceMode"));
			var tempObj:Object = LocalData.read(Constants.LD_FIELD, "comLock");
			if ( tempObj != null ) {
				comLock = Boolean(tempObj);
			}
		}
		public static function save():void {
			LocalData.write(Constants.LD_FIELD, "totalType", type);
			LocalData.write(Constants.LD_FIELD, "totalCorrect", correct);
			LocalData.write(Constants.LD_FIELD, "attack", attack);
			LocalData.write(Constants.LD_FIELD, "defence", defence);
			LocalData.write(Constants.LD_FIELD, "hit", hit);
			LocalData.write(Constants.LD_FIELD, "damage", damage);
			LocalData.write(Constants.LD_FIELD, "win", win);
			LocalData.write(Constants.LD_FIELD, "lose", lose);
			LocalData.write(Constants.LD_FIELD, "defencePower", defencePower);
			LocalData.write(Constants.LD_FIELD, "attackPower", attackPower);
//			LocalData.write(Constants.LD_FIELD, "handicap", handicap);
			LocalData.write(Constants.LD_FIELD, "japaneseRate", japaneseRate);
			LocalData.write(Constants.LD_FIELD, "cpuLV", cpuLV);
			LocalData.write(Constants.LD_FIELD, "alterEnter", ALTER_ENTER);
			LocalData.write(Constants.LD_FIELD, "defenceMode", defenceMode);
			LocalData.write(Constants.LD_FIELD, "comLock", comLock);
		}
		public static function resetCombo():void {
			attackCombo = defenceCombo = 0;
		}
		public static function getLevel():int {
			var exp:Number = win * 500 + lose * 100 + correct * 5 + hit * 100;
			for ( var i:int = 0; i < 20; i++ ) {
				if ( exp < expTable[i] ) {
					break;
				}
			}
			return i;
		}
		public static function getAttackBonusRate():int {
			var rate:int = (attackCombo - Constants.ATTACK_COMBO_START) * 0.5 * handicap;
			if ( rate > (80*handicap) ) rate = (80*handicap);
			if ( rate < 0 ) rate = 0;
			return rate + int(100 * (handicap-1));
		}
		public static function getDefenceBonusRate():int {
			var rate:int = (defenceCombo - Constants.DEFENCE_COMBO_START) * 0.5 * handicap;
			if ( rate > (80*handicap) ) rate = (80*handicap);
			if ( rate < 0 ) rate = 0;
			return rate + int(100 * (handicap-1));
		}
		public static function isJapanese():Boolean {
			return ( japaneseRate > Math.random() );
		}
	}
	
	// 時間の同期クラス
	class ServerClockUtil {
		public static var timeDiff:Number = 0;
		public static function init(server:Server):void {
			server.addEventListener(ServerEvent.TIME_SYNC, function():void {
				timeDiff = server.getServerTime() - Number(getTimer());
			});
			server.syncTime();
//			timeDiff = serverTime - Number(getTimer());
		}
		public static function getTime():Number {
			return Number(getTimer()) + timeDiff;
		}
	}
	
	// ローマ字変換クラス てきとうですが
	class Roma {
		public static function isJapaneseWord(word:String):Boolean {
			return ( word.charCodeAt(0) > 127 );
		}
		public static function getHiragana(roma:String):String {
			roma = roma.toUpperCase();
			var index:int = 0;
			var ret:String = "";
			while ( index < roma.length ) {
				var char:String = roma.charAt(index);
				if ( roma.length > (index + 1) ) {
					if ( (char != "A") && (char != "I") && (char != "U") && (char != "E") && (char != "O") &&
					(char != "N") && (char != "-") && (char == roma.charAt(index + 1)) ) {
						ret += "っ";
						index++;
						continue;
					}
				}
				for ( var i:int = 3; i > 0; i-- ) {
					var test:String = roma.substr(index, i);
					var kana:String = hiraganaTable[test];
					if ( kana ) {
						ret += kana;
						index += test.length;
						break;
					}
				}
				if ( i == 0 ) {
					ret += roma.substr(index);
					break;
				}
			}
			return ret;
		}
		public static function init():void {
			hiraganaTable = makeReverseTable( romaTable );
		}
		
		protected static var hiraganaTable:Object;
		
		protected static function makeReverseTable(table:Object):Object {
			var ret:Object = { };
			for ( var str:String in table ) {
				if ( table[str] is Array ) {
					for each( var roma:String in table[str] ) {
						ret[roma] = str;
					}
				} else {
					var temp:Object = makeReverseTable( table[str] );
					for ( var str2:String in temp ) {
						ret[str2] = str + temp[str2];
					}
				}
			}
			return ret;
		}
		public static function getRomaToType(hiragana:String, typed:String = ""):String {
			var default_ltu_alone:Boolean = false;
			var index:int = 0;
			var ret:String = "";
			var char:String = "";
			var addChar:String = "";
			var nextChar:String = "";
			var nn:Boolean = false;
			var hatsuon:Boolean = false;
			
			var typedIndex:int = 0;
			var typedLength:int = typed.length;
			var targetChar:String;
			var wordLength:int;
			var isOk:Boolean;
			var i:int;
			var j:int;
			var test:String = "";
			
			var oldTypedIndex:int = 0;
			
			var targetArray:Array;
			var nextTargetArray:Array;
			var addIndex:int = 1;
			
			while ( index < hiragana.length) {
				char = hiragana.charAt(index);
				if ( char == "ん" && (index + 1 < hiragana.length ) ) {
					nn = true;
					index++;
					continue;
				}
				if ( char == "っ" ) {
					//
					if ( (typedIndex < typedLength) && 
					( typed.charAt(typedIndex) == "L" || typed.charAt(typedIndex) == "X" ) ) { // 単独文字として扱う
						default_ltu_alone = true; // 実装未定・・
						hatsuon = false;
					} else 
					//
					{
						hatsuon = true; // 判断先送り
						index++;
						continue;
					}
				}
				
				addIndex = 1;
				if ( (romaTable[char] is Array) ) { // 一文字決まり
					targetArray = romaTable[char];
				} else {
					if( ((index + 1) < hiragana.length) ){ // 二文字目あり
						nextChar = hiragana.charAt(index + 1);
					} else { // 二文字目なし
						nextChar = "";
					}
					if ( romaTable[char][nextChar] == null ) { // 二文字目はあるけど候補なし
						targetArray = romaTable[char][""];
					} else { // 二文字目まで候補あり
						targetArray = romaTable[char][nextChar];
						nextTargetArray = romaTable[char][""];
						addIndex = 2;
					}
				}
				//
				if ( typedIndex < typedLength ) {
					if ( nn ) {
						if ( typed.charAt(typedIndex) != "N" ) return null;
						typedIndex++;
						if ( typedIndex < typedLength ) {
							if ( typed.charAt(typedIndex) == "N" ) {
								typedIndex++;
							} else {
								switch( typed.charAt(typedIndex) ) {
									case "A":
									case "I":
									case "U":
									case "E":
									case "O":
									case "Y":
										return null;
										break;
									default:
									break;
								}
							}
						}
					}
					if ( hatsuon ) {
						test = getRomaToType(hiragana.substr(index, 2), typed.substr(typedIndex, 1));
						if ( !test ) return null;
						typedIndex++;
						if ( (typedIndex < typedLength) && (typed.charAt(typedIndex) != test.charAt(0)) ) return null;
					}
					for ( i = 0; i < targetArray.length; i++ ) {
						targetChar = targetArray[i];
						wordLength = targetChar.length;
						isOk = true;
						for ( j = typedIndex; j < typedIndex + wordLength; j++ ) {
							if ( j == typedLength ) break;
							if ( typed.charAt(j) != targetChar.charAt(j - typedIndex) ) {
								isOk = false;
								break;
							}
						}
						if ( isOk ) break;
					}
					if ( !isOk && (addIndex == 2) ) { // 二文字あるけど一文字ずつ区切って打とうとしている場合
						addIndex = 1;
						targetArray = nextTargetArray;
						for ( i = 0; i < targetArray.length; i++ ) {
							targetChar = targetArray[i];
							wordLength = targetChar.length;
							isOk = true;
							for ( j = typedIndex; j < typedIndex + wordLength; j++ ) {
								if ( j == typedLength ) break;
								if ( typed.charAt(j) != targetChar.charAt(j - typedIndex) ) {
									isOk = false;
									break;
								}
							}
							if ( isOk ) break;
						}
					}
					if ( !isOk ) return null;
					typedIndex += j - typedIndex;
					if( i > 0 ){
						targetArray.splice(i, 1);
						targetArray.unshift(targetChar);
					}
				}
				//
				addChar = targetArray[0];
				index += addIndex;
					
				if ( hatsuon ) {
					ret += addChar.substr(0, 1);
					hatsuon = false;
				}
				if ( nn ) {
					switch( addChar.substr(0, 1) ) {
						case "A":
						case "I":
						case "U":
						case "E":
						case "O":
						case "N":
						case "Y":
							ret += "NN";
							break;
						default:
							ret += "N";
							break;
					}
					nn = false;
				}
				ret += addChar;
				addChar = "";
			}
			if ( nn ) {
				ret += "NN";
			}
			return ret;
		}
		protected static const romaTable:Object = {
			"あ": ["A"],
			"い": {
				"ぇ": ["YE"],
				"": ["I", "YI"]
			},
			"う": {
				"ぃ": ["WI"],
				"ぇ": ["WE"],
				"": ["U", "WU"]
			},
			"え": ["E"],
			"お": ["O"],
			"か": ["KA", "CA"],
			"き": {
				"ゃ": ["KYA"],
				"ぃ": ["KYI"],
				"ゅ": ["KYU"],
				"ぇ": ["KYE"],
				"ょ": ["KYO"],
				"": ["KI"]
			},
			"く": {
				"ぁ": ["KWA"],
				"": ["KU", "CU"]
			},
			"け": ["KE"],
			"こ": ["KO", "CO"],
			"が": ["GA"],
			"ぎ": {
				"ゃ": ["GYA"],
				"ぃ": ["GYI"],
				"ゅ": ["GYU"],
				"ぇ": ["GYE"],
				"ょ": ["GYO"],
				"": ["GI"]
			},
			"ぐ": {
				"ぁ": ["GWA"],
				"": ["GU"]
			},
			"げ": ["GE"],
			"ご": ["GO"],
			"さ": ["SA"],
			"し": {
				"ゃ": ["SYA", "SHA"],
				"ぃ": ["SYI"],
				"ゅ": ["SYU", "SHU"],
				"ぇ": ["SYE", "SHE"],
				"ょ": ["SYO", "SHO"],
				"": ["SI", "SHI", "CI"]
			},
			"す": {
				"ぁ": ["SWA"],
				"ぃ": ["SWI"],
				"ぅ": ["SWU"],
				"ぇ": ["SWE"],
				"ぉ": ["SWO"],
				"": ["SU"]
			},
			"せ": ["SE", "CE"],
			"そ": ["SO"],
			"ざ": ["ZA"],
			"じ": {
				"ゃ": ["ZYA", "JYA", "JA"],
				"ぃ": ["ZYI", "JYI"],
				"ゅ": ["ZYU", "JYU", "JU"],
				"ぇ": ["ZYE", "JYE"],
				"ょ": ["ZYO", "JYO", "JO"],
				"": ["ZI", "JI"]
			},
			"ず": ["ZU"],
			"ぜ": ["ZE"],
			"ぞ": ["ZO"],
			"た": ["TA"],
			"ち": {
				"ゃ": ["TYA","CHA", "CYA"],
				"ぃ": ["TYI","CYI"],
				"ゅ": ["TYU","CHU", "CYU"],
				"ぇ": ["TYE", "CHE", "CYE"],
				"ょ": ["TYO", "CHO", "CYO"],
				"": ["TI", "CHI"]
			},
			"つ": {
				"ぁ": ["TSA"],
				"ぃ": ["TSI"],
				"ぅ": ["TSU"],
				"ぇ": ["TSE"],
				"ぉ": ["TSO"],
				"": ["TU", "TSU"]
			},
			"て": {
				"ゃ": ["THA"],
				"ぃ": ["THI"],
				"ゅ": ["THU"],
				"ぇ": ["THE"],
				"ょ": ["THO"],
				"": ["TE"]
			},
			"と": {
				"ぁ": ["TWA"],
				"ぃ": ["TWI"],
				"ぅ": ["TWU"],
				"ぇ": ["TWE"],
				"ぉ": ["TWO"],
				"": ["TO"]
			},
			"だ": ["DA"],
			"ぢ": {
				"ゃ": ["DYA"],
				"ぃ": ["DYI"],
				"ゅ": ["DYU"],
				"ぇ": ["DYE"],
				"ょ": ["DYO"],
				"": ["DI"]
			},
			"づ": ["DU"],
			"で": {
				"ゃ": ["DHA"],
				"ぃ": ["DHI"],
				"ゅ": ["DHU"],
				"ぇ": ["DHE"],
				"ょ": ["DHO"],
				"": ["DE"]
			},
			"ど": {
				"ぁ": ["DWA"],
				"ぃ": ["DWI"],
				"ぅ": ["DWU"],
				"ぇ": ["DWE"],
				"ぉ": ["DWO"],
				"": ["DO"]
			},
			"な": ["NA"],
			"に": {
				"ゃ": ["NYA"],
				"ぃ": ["NYI"],
				"ゅ": ["NYU"],
				"ぇ": ["NYE"],
				"ょ": ["NYO"],
				"": ["NI"]
			},
			"ぬ": ["NU"],
			"ね": ["NE"],
			"の": ["NO"],
			"は": ["HA"],
			"ひ": {
				"ゃ": ["HYA"],
				"ぃ": ["HYI"],
				"ゅ": ["HYU"],
				"ぇ": ["HYE"],
				"ょ": ["HYO"],
				"": ["HI"]
			},
			"ふ": {
				"ぁ": ["FA"],
				"ぃ": ["FI"],
				"ぇ": ["FE"],
				"ぉ": ["FO"],
				"": ["FU", "HU"]
			},
			"へ": ["HE"],
			"ほ": ["HO"],
			"ば": ["BA"],
			"び": {
				"ゃ": ["BYA"],
				"ぃ": ["BYI"],
				"ゅ": ["BYU"],
				"ぇ": ["BYE"],
				"ょ": ["BYO"],
				"": ["BI"]
			},
			"ぶ": ["BU"],
			"べ": ["BE"],
			"ぼ": ["BO"],
			"ぱ": ["PA"],
			"ぴ": {
				"ゃ": ["PYA"],
				"ぃ": ["PYI"],
				"ゅ": ["PYU"],
				"ぇ": ["PYE"],
				"ょ": ["PYO"],
				"": ["PI"]
			},
			"ぷ": ["PU"],
			"ぺ": ["PE"],
			"ぽ": ["PO"],
			"ま": ["MA"],
			"み": {
				"ゃ": ["MYA"],
				"ぃ": ["MYI"],
				"ゅ": ["MYU"],
				"ぇ": ["MYE"],
				"ょ": ["MYO"],
				"": ["MI"]
			},
			"む": ["MU"],
			"め": ["ME"],
			"も": ["MO"],
			"や": ["YA"],
			"ゆ": ["YU"],
			"よ": ["YO"],
			"ら": ["RA"],
			"り": {
				"ゃ": ["RYA"],
				"ぃ": ["RYI"],
				"ゅ": ["RYU"],
				"ぇ": ["RYE"],
				"ょ": ["RYO"],
				"": ["RI"]
			},
			"る": ["RU"],
			"れ": ["RE"],
			"ろ": ["RO"],
			"わ": ["WA"],
			"を": ["WO"],
			"ゎ": ["LWA", "XWA"],
			"ぁ": ["LA", "XA"],
			"ぃ": ["LI", "XI"],
			"ぅ": ["LU", "XU"],
			"ぇ": ["LE", "XE"],
			"ぉ": ["LO", "XO"],
			"ゃ": ["LYA", "XYA"],
			"ゅ": ["LYU", "XYU"],
			"ょ": ["LYO", "XYO"],
			"っ": ["LTU", "XTU", "LTSU"],
			"ん": ["N", "NN"],
			"ー": ["-"],
			" ": [" "]
			// ん, っ については別ルール適用
		}
	}
	
	// 単語管理クラス
	class Words {
		public static const jKanjiList:Array = [
			"会う", "青い", "赤い", "明い", "秋", "開く", "開ける",
			"上げる", "朝", "朝御飯", "あさって", "足", "あした", "あそこ",
			"遊ぶ", "暖かい", "頭", "新しい", "あちら", "暑い", "熱い",
			"厚い", "後", "あなた", "兄", "姉", "あの", "アパート", "あびる",
			"危ない", "甘い", "あまり", "雨", "洗う", "ある", "歩く", "あれ",
			"いい", "よい", "いいえ", "言う", "家", "行く", "行く", "いくつ",
			"いくら", "池", "医者", "いす", "忙しい", "痛い", "一",
			"一日", "いちばん", "いつ", "五日", "一緒", "五つ", "いつも",
			"今", "意味", "妹", "嫌", "入口", "居る", "要る", "入れる",
			"色", "いろいろ", "上", "後", "薄い", "歌", "歌う", "うち",
			"生まれる", "海", "売る", "上着", "映画", "映画館", "英語",
			"ええ", "駅", "エレベーター", "鉛筆", "おいしい", "大きい",
			"大勢", "お母さん", "お菓子", "お金", "起きる", "置く", "奥さん",
			"お酒", "お皿", "伯父", "叔父", "おじいさん", "教える", "押す",
			"遅い", "お茶", "お手洗い", "お父さん", "弟", "男",
			"男の子", "おととい", "おととし", "大人", "おなか", "同じ",
			"お兄さん", "お姉さん", "伯母", "叔母", "おばあさん", "お弁当",
			"覚える", "重い", "おもしろい", "泳ぐ", "降りる", "終る",
			"音楽", "女", "女の子", "外国", "外国人", "会社",
			"階段", "買い物", "買う", "返す", "帰る", "顔", "かぎ",
			"書く", "学生", "かける", "傘", "貸す", "風", "家族",
			"片仮名", "学校", "角", "家内", "かばん", "花瓶", "かぶる",
			"紙", "カメラ", "火曜日", "辛い", "体", "借りる", "軽い",
			"カレンダー", "川", "河", "かわいい", "漢字", "黄色い", "消える",
			"聞く", "北", "ギター", "汚い", "喫茶店", "切手", "切符",
			"昨日", "九", "牛肉", "今日", "教室", "兄弟", "去年",
			"嫌い", "切る", "着る", "きれい", "キロ", "銀行", "金曜日",
			"薬", "ください", "果物", "口", "靴", "靴下", "国", "曇る",
			"暗い", "くらい", "ぐらい", "クラス", "グラム", "来る", "車",
			"黒い", "今朝", "消す", "結構", "結婚", "月曜日",
			"玄関", "元気", "五", "公園", "交番", "声", "コート",
			"ここ", "午後", "九日", "九つ", "御主人", "午前", "答える",
			"こちら", "コップ", "今年", "言葉", "子供", "この", "御飯",
			"困る", "これ", "今月", "今週", "こんな", "今晩", "さあ",
			"魚", "先", "咲く", "作文", "さす", "雑誌", "砂糖",
			"寒い", "再来年", "三", "四", "散歩", "塩", "しかし",
			"時間", "仕事", "辞書", "静か", "下", "七", "質問", "自転車",
			"自動車", "死ぬ", "字引", "自分", "閉まる", "閉める", "締める",
			"じゃあ", "写真", "シャツ", "十", "授業", "宿題", "上手",
			"丈夫", "しょうゆ", "食堂", "知る", "白い", "新聞", "水曜日",
			"吸う", "スカート", "好き", "すぐに", "少し", "涼しい", "ストーブ",
			"スプーン", "スポーツ", "ズボン", "住む", "スリッパ", "する", "座る",
			"背", "生徒", "せっけん", "セーター", "背広", "狭い", "ゼロ",
			"千", "先月", "先週", "先生", "洗濯", "全部", "掃除",
			"そうして", "そして", "そこ", "そちら", "外", "その", "そば", "空",
			"それ", "それから", "それでは", "大学", "大使館", "大丈夫",
			"大好き", "大切", "たいてい", "台所", "たいへん", "高い",
			"たくさん", "タクシー", "出す", "立つ", "建物", "楽しい", "頼む",
			"たばこ", "たぶん", "食べ物", "食べる", "卵", "だれ", "誕生日",
			"だんだん", "小さい", "近い", "違う", "近く", "地下鉄",
			"地図", "父", "茶色", "ちゃわん", "ちょうど", "ちょっと", "一日",
			"使う", "疲れる", "次", "着く", "机", "作る", "つける", "勤める",
			"つまらない", "冷たい", "強い", "手", "テープ", "テーブル", "出かける",
			"手紙", "できる", "出口", "テスト", "では", "デパート", "でも",
			"出る", "テレビ", "天気", "電気", "電車", "電話", "戸", "ドア",
			"トイレ", "どうして", "どうぞ", "動物", "どうも", "十", "遠い", "十日",
			"時々", "時計", "どこ", "所", "図書館", "どちら", "とても", "どなた",
			"隣", "どの", "飛ぶ", "止まる", "友達", "土曜日", "鳥", "鳥肉",
			"取る", "撮る", "どれ", "どんな", "ない", "ナイフ", "中", "長い",
			"鳴く", "夏", "夏休み", "七つ", "何", "七日", "名前", "習う",
			"並ぶ", "並べる", "二", "にぎやか", "肉", "西", "日曜日",
			"荷物", "ニュース", "庭", "脱ぐ", "ネクタイ", "寝る", "ノート", "登る",
			"飲み物", "飲む", "乗る", "歯", "パーティー", "はい", "灰皿",
			"入る", "葉書", "はく", "箱", "橋", "はし", "始まる", "初めに",
			"初めて", "走る", "バス", "バター", "二十歳", "働く", "八", "二十日",
			"花", "鼻", "話", "話す", "母", "早い", "速い", "春",
			"はる", "晴れる", "半", "晩", "パン", "ハンカチ", "番号",
			"晩御飯", "半分", "東", "引く", "弾く", "低い", "飛行機",
			"左", "人", "一つ", "一月", "一人", "暇", "百", "病院",
			"病気", "平仮名", "昼", "昼御飯", "広い", "フィルム", "封筒",
			"プール", "フォーク", "吹く", "服", "二つ", "豚肉", "二人", "二日",
			"太い", "冬", "降る", "古い", "ふろ", "パージ", "下手", "ベッド",
			"部屋", "辺", "ペン", "勉強", "便利", "ほう", "帽子", "ボールペン",
			"外", "ポケット", "欲しい", "細い", "ボタン", "ホテル", "本",
			"本棚", "ほんとうに", "毎朝", "毎月", "毎月", "毎週", "毎日",
			"毎年", "毎年", "毎晩", "前", "曲る", "まずい", "また", "まだ",
			"町", "待つ", "まっすぐ", "マッチ", "窓", "丸い", "円い", "万",
			"万年筆", "磨く", "右", "短い", "水", "店", "見せる", "道",
			"三日", "三つ", "皆さん", "南", "耳", "見る", "みんな", "六日",
			"向こう", "難しい", "六つ", "目", "メートル", "眼鏡", "もう",
			"木曜日", "もしもし", "もちろん", "持つ", "もっと", "物", "門",
			"問題", "八百屋", "野菜", "易しい", "安い", "休み", "休む",
			"八つ", "山", "やる", "夕方", "郵便局", "ゆうべ", "有名",
			"雪", "ゆっくり", "八日", "洋服", "よく", "横", "四日", "四つ",
			"呼ぶ", "読む", "夜", "来月", "来週", "来年", "ラジオ",
			"りっぱ", "留学生", "両親", "料理", "旅行", "零", "冷蔵庫",
			"レコード", "レストラン", "練習", "六", "ワイシャツ", "若い",
			"分る","忘れる","私","わたし","渡す","渡る","悪い"
		];
		public static const jList:Array = [
			"あう","あおい","あかい","あかるい","あき","あく","あける", // JLPT lv 4
			"あげる","あさ","あさごはん","あさって","あし","あした","あそこ",
			"あそぶ","あたたかい","あたま","あたらしい","あちら","あつい","あつい",
			"あつい","あと","あなた","あに","あね","あの","あぱーと","あびる",
			"あぶない","あまい","あまり","あめ","あらう","ある","あるく","あれ",
			"いい","よい","いいえ","いう","いえ","いく","ゆく","いくつ",
			"いくら","いけ","いしゃ","いす","いそがしい","いたい","いち",
			"いちにち","いちばん","いつ","いつか","いっしょ","いつつ","いつも",
			"いま","いみ","いもうと","いや","いりぐち","いる","いる","いれる",
			"いろ","いろいろ","うえ","うしろ","うすい","うた","うたう","うち",
			"うまれる","うみ","うる","うわぎ","えいが","えいがかん","えいご",
			"ええ","えき","えれべーたー","えんぴつ","おいしい","おおきい",
			"おおぜい","おかあさん","おかし","おかね","おきる","おく","おくさん",
			"おさけ","おさら","おじ","おじ","おじいさん","おしえる","おす",
			"おそい","おちゃ","おてあらい","おとうさん","おとうと","おとこ",
			"おとこのこ","おととい","おととし","おとな","おなか","おなじ",
			"おにいさん","おねえさん","おば","おば","おばあさん","おべんとう",
			"おぼえる","おもい","おもしろい","およぐ","おりる","おわる",
			"おんがく","おんな","おんなのこ","がいこく","がいこくじん","かいしゃ",
			"かいだん","かいもの","かう","かえす","かえる","かお","かぎ",
			"かく","がくせい","かける","かさ","かす","かぜ","かぞく",
			"かたかな","がっこう","かど","かない","かばん","かびん","かぶる",
			"かみ","かめら","かようび","からい","からだ","かりる","かるい",
			"かれんだー","かわ","かわ","かわいい","かんじ","きいろい","きえる",
			"きく","きた","ぎたー","きたない","きっさてん","きって","きっぷ",
			"きのう","きゅう","ぎゅうにく","きょう","きょうしつ","きょうだい","きょねん",
			"きらい","きる","きる","きれい","きろ","ぎんこう","きんようび",
			"くすり","ください","くだもの","くち","くつ","くつした","くに","くもる",
			"くらい","くらい","ぐらい","くらす","ぐらむ","くる","くるま",
			"くろい","けさ","けす","けっこう","けっこん","げつようび",
			"げんかん","げんき","ご","こうえん","こうばん","こえ","こーと",
			"ここ","ごご","ここのか","ここのつ","ごしゅじん","ごぜん","こたえる",
			"こちら","こっぷ","ことし","ことば","こども","この","ごはん",
			"こまる","これ","こんげつ","こんしゅう","こんな","こんばん","さあ",
			"さかな","さき","さく","さくぶん","さす","ざっし","さとう",
			"さむい","さらいねん","さん","し","さんぽ","しお","しかし",
			"じかん","しごと","じしょ","しずか","した","しち","しつもん","じてんしゃ",
			"じどうしゃ","しぬ","じびき","じぶん","しまる","しめる","しめる",
			"じゃあ","しゃしん","しゃつ","じゅう","じゅぎょう","しゅくだい","じょうず",
			"じょうぶ","しょうゆ","しょくどう","しる","しろい","しんぶん","すいようび",
			"すう","すかーと","すき","すぐに","すこし","すずしい","すとーぶ",
			"すぷーん","すぽーつ","ずぼん","すむ","すりっぱ","する","すわる",
			"せい","せいと","せっけん","せーたー","せびろ","せまい","ぜろ",
			"せん","せんげつ","せんしゅう","せんせい","せんたく","ぜんぶ","そうじ",
			"そうして","そして","そこ","そちら","そと","その","そば","そら",
			"それ","それから","それでは","だいがく","たいしかん","だいじょうぶ",
			"だいすき","たいせつ","たいてい","だいどころ","たいへん","たかい",
			"たくさん","たくしー","だす","たつ","たてもの","たのしい","たのむ",
			"たばこ","たぶん","たべもの","たべる","たまご","だれ","たんじょうび",
			"だんだん","ちいさい","ちかい","ちがう","ちかく","ちかてつ",
			"ちず","ちち","ちゃいろ","ちゃわん","ちょうど","ちょっと","ついたち",
			"つかう","つかれる","つぎ","つく","つくえ","つくる","つける","つとめる",
			"つまらない","つめたい","つよい","て","てーぷ","てーぶる","でかける",
			"てがみ","できる","でぐち","てすと","では","でぱーと","でも",
			"でる","てれび","てんき","でんき","でんしゃ","でんわ","と","どあ",
			"といれ","どうして","どうぞ","どうぶつ","どうも","とお","とおい","とおか",
			"ときどき","とけい","どこ","ところ","としょかん","どちら","とても","どなた",
			"となり","どの","とぶ","とまる","ともだち","どようび","とり","とりにく",
			"とる","とる","どれ","どんな","ない","ないふ","なか","ながい",
			"なく","なつ","なつやすみ","ななつ","なに","なのか","なまえ","ならう",
			"ならぶ","ならべる","に","にぎやか","にく","にし","にちようび",
			"にもつ","にゅーす","にわ","ぬぐ","ねくたい","ねる","のーと","のぼる",
			"のみもの","のむ","のる","は","ぱーてぃー","はい","はいざら",
			"はいる","はがき","はく","はこ","はし","はし","はじまる","はじめに",
			"はじめて","はしる","ばす","ばたー","はたち","はたらく","はち","はつか",
			"はな","はな","はなし","はなす","はは","はやい","はやい","はる",
			"はる","はれる","はん","ばん","ぱん","はんかち","ばんごう",
			"ばんごはん","はんぶん","ひがし","ひく","ひく","ひくい","ひこうき",
			"ひだり","ひと","ひとつ","ひとつき","ひとり","ひま","ひゃく","びょういん",
			"びょうき","ひらがな","ひる","ひるごはん","ひろい","ふぃるむ","ふうとう",
			"ぷーる","ふぉーく","ふく","ふく","ふたつ","ぶたにく","ふたり","ふつか",
			"ふとい","ふゆ","ふる","ふるい","ふろ","ぱーじ","へた","べっど",
			"へや","へん","ぺん","べんきょう","べんり","ほう","ぼうし","ぼーるぺん",
			"ほか","ぽけっと","ほしい","ほそい","ぼたん","ほてる","ほん",
			"ほんだな","ほんとうに","まいあさ","まいげつ","まいつき","まいしゅう","まいにち",
			"まいねん","まいとし","まいばん","まえ","まがる","まずい","また","まだ",
			"まち","まつ","まっすぐ","まっち","まど","まるい","まるい","まん",
			"まんねんひつ","みがく","みぎ","みじかい","みず","みせ","みせる","みち",
			"みっか","みっつ","みなさん","みなみ","みみ","みる","みんな","むいか",
			"むこう","むずかしい","むっつ","め","めーとる","めがね","もう",
			"もくようび","もしもし","もちろん","もつ","もっと","もの","もん",
			"もんだい","やおや","やさい","やさしい","やすい","やすみ","やすむ",
			"やっつ","やま","やる","ゆうがた","ゆうびんきょく","ゆうべ","ゆうめい",
			"ゆき","ゆっくり","ようか","ようふく","よく","よこ","よっか","よっつ",
			"よぶ","よむ","よる","らいげつ","らいしゅう","らいねん","らじお",
			"りっぱ","りゅうがくせい","りょうしん","りょうり","りょこう","れい","れいぞうこ",
			"れこーど","れすとらん","れんしゅう","ろく","わいしゃつ","わかい",
			"わかる","わすれる","わたくし","わたし","わたす","わたる","わるい",
			"ああ","あいさつ","あいだ","あう","あかちゃん","あがる","あかんぼう","あく","あくせさりー","あげる","あさい","あじ","あじあ","あす","あそび", // JLPT lv 3
			"あつまる","あつめる","あなうんさー","あふりか","あめりか","あやまる","あるこーる","あるばいと","あんしん","あんぜん","あんな","あんない",
			"いか","いがい","いがく","いきる","いけん","いし","いじめる","いじょう","いそぐ","いたす","いただく","いちど","いっしょうけんめい","いっぱい",
			"いと","いない","いなか","いのる","いらっしゃる","うえる","うかがう","うかがう","うけつけ","うける","うごく","うそ","うち","うつ","うつくしい",
			"うつす","うつる","うで","うまい","うら","うりば","うれしい","うん","うんてんしゅ","うんてん","うんどう","えすかれーたー","えだ","えらぶ","えんりょ",
			"おいでになる","おいわい","おーとばい","おーばー","おかげ","おかしい","おく","おくじょう","おくりもの","おくる","おくれる","おこさん","おこす",
			"おこなう","おこる","おしいれ","おじょうさん","おたく","おちる","おっしゃる","おっと","おつり","おと","おとす","おどり","おどる","おどろく",
			"おまつり","おみまい","おみやげ","おもいだす","おもう","おもちゃ","おもて","おや","おりる","おる","おる","おれい","おれる","おわり","かーてん",
			"かいがん","かいぎ","かいぎしつ","かいじょう","かいわ","かえり","かえる","かがく","かがみ","かける","かける","かける","かざる","かじ","がす",
			"がそりん","がそりんすたんど","かた","かたい","かたち","かたづける","かちょう","かつ","かっこう","かない","かなしい","かならず","かねもち",
			"おかねもち","かのじょ","かべ","かまう","かみ","かむ","かよう","がらす","かれ","かれら","かわく","かわり","かわる","かんがえる","かんけい",
			"かんごふ","かんたん","がんばる","き","きかい","きけん","きこえる","きしゃ","ぎじゅつ","きせつ","きそく","きっと","きぬ","きびしい","きぶん",
			"きまる","きみ","きめる","きもち","きもの","きゃく","きゅう","きゅうこう","きょういく","きょうかい","きょうそう","きょうみ","きんじょ","ぐあい",
			"くうき","くうこう","くさ","くださる","くび","くも","くらべる","くれる","くれる","け","け","けいかく","けいけん","けいざい","けいさつ","けが",
			"けーき","けしき","けしごむ","げしゅく","けっして","けれど","けれども","げんいん","けんか","げんかん","けんきゅう","けんきゅうしつ","けんぶつ",
			"こ","こう","こうがい","こうぎ","こうぎょう","こうこう","こうとうがっこう","こうこうせい","こうじょう","こうちょう","こうつう","こうどう",
			"こうむいん","こくさい","こころ","ごしゅじん","こしょう","ごぞんじ","こたえ","ごちそう","こっち","こと","ことり","このあいだ","このごろ",
			"こまかい","ごみ","こむ","こめ","ごらんになる","これから","こわい","こわす","こわれる","こんさーと","こんど","こんや","さいきん","さいご",
			"さいしょ","さか","さがす","さがる","さかん","さげる","さしあげる","さっき","さびしい","さらいげつ","さらいしゅう","さらだ","さわぐ","さわる",
			"さんぎょう","さんだる","さんどいっち","ざんねん","し","じ","しあい","しかた","しかる","しけん","じこ","じしん","じだい","したぎ","したくする",
			"しっかり","しっぱい","しつれい","じてん","しなもの","しばらく","しま","しみん","じむしょ","しゃかい","しゃちょう","じゃま","じゃむ","じゆう",
			"しゅうかん","じゅうしょ","じゅうどう","じゅうぶん","しゅっせきする","しゅっぱつする","しゅみ","じゅんびする","しょうかい","しょうがつ",
			"しょうがっこう","しょうせつ","しょうたいする","しょうちする","しょうらい","しょくじする","しょくしゅ","しょくりょうひん","じょせい","しらせる",
			"しらべる","じんこう","じんじゃ","しんせつ","しんぱいする","しんぶんしゃ","すいえい","すいどう","ずいぶん","すうがく","すーつ","すーつけーす",
			"すーぱー","すぎる","すく","すく","すくりーん","すごい","すすむ","すっかり","ずっと","すてーき","すてれお","すてる","すな","すばらしい",
			"すべる","すみ","すむ","すり","すると","せいかつする","せいさんする","せいじ","せいよう","せかい","せき","せつめい","せなか","ぜひ","せわする",
			"せん","ぜんぜん","せんそう","せんぱい","せんもん","そう","そうだんする","そだてる","そつぎょう","そふ","そふと","そぼ","それで","それに",
			"それほど","そろそろ","そんな","そんなに","たいいんする","だいがくせい","だいじ","だいたい","たいてい","たいぷ","だいぶ","たいふう",
			"たおれる","だから","たしか","たす","たずねる","たずねる","ただしい","たたみ","たてる","たてる","たとえば","たな","たのしむ","たのしみ",
			"たまに","ため","だめ","たりる","だんせい","だんぼう","ち","ちぇっく","ちから","ちっとも","ちゅうい","ちゅうがっこう","ちゅうしゃ",
			"ちゅうしゃじょう","ちり","つかまえる","つき","つく","つける","つける","つごう","つたえる","つづく","つづける","つつむ","つま","つもり",
			"つる","つれる","ていねい","てきすと","てきとう","できる","できるだけ","てつだう","てにす","てぶくろ","てら","てん","てんいん",
			"てんきよほう","でんとう","でんぽう","てんらんかい","と","どうぐ","とうとう","どうぶつえん","とおく","とおり","とおる","とくに","とくべつ",
			"とこや","とちゅう","とっきゅう","とどける","とまる","とめる","とりかえる","どろぼう","どんどん","なおす","なおる","なおる","なかなか",
			"なく","なくなる","なくなる","なげる","なさる","なる","なるべく","なるほど","なれる","におい","にがい","にげる","にっき","にゅういん",
			"にゅうがく","にる","にんぎょう","ぬすむ","ぬる","ぬれる","ねだん","ねつ","ねっしん","ねぼう","ねむい","ねむる","のこる","のど","のりかえる",
			"のりもの","は","ばあい","ぱーと","ばい","はいけん","はいしゃ","はこぶ","はじめる","ばしょ","はず","はずかしい","ぱそこん","はつおん",
			"はっきり","はなみ","ぱぱ","はやし","はらう","ばんぐみ","はんたい","はんばーぐ","ひ","ぴあの","ひえる","ひかる","ひかり","ひきだし","ひげ",
			"ひこうじょう","ひさしぶり","びじゅつかん","ひじょうに","びっくりする","ひっこす","ひつよう","ひどい","ひらく","びる","ひるま","ひるやすみ",
			"ひろう","ふぁっくす","ふえる","ふかい","ふくざつ","ふくしゅう","ぶちょう","ふつう","ぶどう","ふとる","ふとん","ふね","ふべん","ふむ",
			"ぷれぜんと","ぶんか","ぶんがく","ぶんぽう","べつ","べる","へん","へんじ","ぼうえき","ほうそう","ほうりつ","ぼく","ほし","ほど","ほとんど",
			"ほめる","ほんやく","まいる","まける","まじめ","まず","または","まちがえる","まにあう","まわり","まわる","まんが","まんなか","みえる",
			"みずうみ","みそ","みつかる","みつける","みな","みなと","むかえる","むかう","むかし","むし","むすこ","むすめ","むり","めしあがる","めずらしい",
			"もうしあげる","もうす","もうすぐ","もし","もちろん","もっとも","もどる","もめん","もらう","もり","やく","やくにたつ","やくそく","やける",
			"やさしい","やせる","やっと","やはり","やっぱり","やむ","やめる","やる","やわらかい","ゆ","ゆうはん","ゆしゅつ","ゆにゅう","ゆび","ゆびわ",
			"ゆめ","ゆれる","よう","よう","ようい","ようじ","よごれる","よしゅう","よてい","よやく","よる","よろこぶ","よろしい","りゆう","りよう",
			"りょうほう", "りょかん", "るす", "れいぼう", "れきし", "れじ", "れぽーと", "れんらく", "わーぷろ", "わかす", "わかれる", "わく", "わけ", "わすれもの", "わらう", "わりあい", "われる"/*,
			"おかえりなさいませ","ごしゅじんさま","おみまい","もうしあげます","しょちゅうみまい","ごめんください","ありがとうございます",
			"ごくろうさまです","おひさしぶりです","さんたくろーす","でもんすとれーしょん","てぃっしゅぺーぱー","といれっとぺーぱー","でこれーしょん",
			"どらいくりーにんぐ","さるもきからおちる","えんのしたのちからもち","おんをあだでかえす","きじょうのくうろん","あんずるよりうむがやすし",
			"あきのひはつるべおとし","いりでっぽうにでおんな","いぬもあるけばぼうにあたる","いしゃのふようじょう","おんなごころとあきのそら",
			"えびでたいをつる","おしてもだめならひいてみな","かいいぬにてをかまれる","かぜがふけばおけやがもうかる","かねもちけんかせず",
			"かっぱのかわながれ","げいがみをたすける","たなからぼたもち","ないそではふれぬ","ねこもしゃくしも","のうあるたかはつめをかくす",
			"びんぼうひまなし","ひやめしをくわせる","ふうぜんのともしび","ふくすいぼんにかえらず","へそでちゃをわかす","まかぬたねははえぬ",
			"みいらとりがみいらになる","いしのうえにもさんねん","めいきょうしすい","ももくりさんねんかきはちねん","やけいしにみず",
			"やけぼっくりにひがつく","ゆいがどくそん","よこやりをいれる","るいはともをよぶ","わざわいてんじてふくとなす","わらうかどにはふくきたる",
			"たいぜんじじゃく","えいこせいすい","ぎおんしょうじゃ","あびきょうかん","いちれんたくしょう","いしんでんしん","いっきとうせん",
			"いっちょういっせき","いふうどうどう","ういてんぺん","うよきょくせつ","おんこうとくじつ","がでんいんすい","がりょうてんせい",
			"ぎしんあんき","きんかぎょくじょう","こうとうむけい","じゅうおうむじん","じゅんぷうまんぱん","しんらばんしょう","せいれんけっぱく",
			"たいきばんせい","ちょうさんぼし","ないゆうがいかん","にりつはいはん","ふんこつさいしん","ぼうじゃくぶじん","ゆうゆうじてき",
			"わようせっちゅう","いちじゅういっさい","いちじつせんしゅう","いちぞくろうとう","あんちゅうもさく","いきしょうちん","うみせんやません",
			"おかめはちもく","かいとうらんま","ないじゅうがいごう","がしんしょうたん","かちょうふうげつ","かんわきゅうだい","かんぜんむけつ",
			"かんぜんちょうあく","きそうてんがい","きしょうてんけつ","きょうみしんしん","ぎょくせきこんこう","きようびんぼう","けいせいさいみん",
			"けんけんごうごう","けんにんふばつ","ごうがけんらん","こうげんれいしょく","こうめいせいだい","ごえつどうしゅう","ここんとうざい",
			"さいしょくけんび","さんかんしおん","じきゅうじそく","じきそうしょう","しちてんばっとう","しつじつごうけん","しんらばんしょう","はらんばんじょう"*/
		];
		public static const list:Array = [
			"able","about","account","acid","across","act","addition","adjustment","advertisement","after","again","against","agreement","air","all","almost","among","amount","amusement","and","angle","angry","animal","answer","ant","any","apparatus","apple","approval","arch","argument","arm","army","art","as","at","attack","attempt","attention","attraction","authority","automatic","awake",
			"baby","back","bad","bag","balance","ball","band","base","basin","basket","bath","be","beautiful","because","bed","bee","before","behaviour","belief","bell","bent","berry","between","bird","birth","bit","bite","bitter","black","blade","blood","blow","blue","board","boat","body","boiling","bone","book","boot","bottle","box","boy","brain","brake","branch","brass","bread","breath","brick","bridge","bright","broken","brother","brown","brush","bucket","building","bulb","burn","burst","business","but","butter","button","by",
			"cake","camera","canvas","card","care","carriage","cart","cat","cause","certain","chain","chalk","chance","change","cheap","cheese","chemical","chest","chief","chin","church","circle","clean","clear","clock","cloth","cloud","coal","coat","cold","collar","colour","comb","come","comfort","committee","common","company","comparison","competition","complete","complex","condition","connection","conscious","control","cook","copper","copy","cord","cork","cotton","cough","country","cover","cow","crack","credit","crime","cruel","crush","cry","cup","cup","current","curtain","curve","cushion",
			"damage","danger","dark","daughter","day","dead","dear","death","debt","decision","deep","degree","delicate","dependent","design","desire","destruction","detail","development","different","digestion","direction","dirty","discovery","discussion","disease","disgust","distance","distribution","division","do","dog","door","doubt","down","drain","drawer","dress","drink","driving","drop","dry","dust",
			"ear","early","earth","east","edge","education","effect","egg","elastic","electric","end","engine","enough","equal","error","even","event","ever","every","example","exchange","existence","expansion","experience","expert","eye",
			"face","fact","fall","false","family","far","farm","fat","father","fear","feather","feeble","feeling","female","fertile","fiction","field","fight","finger","fire","first","fish","fixed","flag","flame","flat","flight","floor","flower","fly","fold","food","foolish","foot","for","force","fork","form","forward","fowl","frame","free","frequent","friend","from","front","fruit","full","future",
			"garden","general","get","girl","give","glass","glove","go","goat","gold","good","government","grain","grass","great","green","grey","grip","group","growth","guide","gun",
			"hair","hammer","hand","hanging","happy","harbour","hard","harmony","hat","hate","have","he","head","healthy","hear","hearing","heart","heat","help","high","history","hole","hollow","hook","hope","horn","horse","hospital","hour","house","how","humour",
			"ice","idea","if","ill","important","impulse","in","increase","industry","ink","insect","instrument","insurance","interest","invention","iron","island",
			"jelly","jewel","join","journey","judge","jump",
			"keep","kettle","key","kick","kind","kiss","knee","knife","knot","knowledge",
			"land","language","last","late","laugh","law","lead","leaf","learning","leather","left","leg","let","letter","level","library","lift","light","like","limit","line","linen","lip","liquid","list","little","living","lock","long","look","loose","loss","loud","love","low",
			"machine","make","male","man","manager","map","mark","market","married","mass","match","material","may","meal","measure","meat","medical","meeting","memory","metal","middle","military","milk","mind","mine","minute","mist","mixed","money","monkey","month","moon","morning","mother","motion","mountain","mouth","move","much","muscle","music",
			"nail","name","narrow","nation","natural","near","necessary","neck","need","needle","nerve","net","new","news","night","no","noise","normal","north","nose","not","note","now","number","nut",
			"observation","of","off","offer","office","oil","old","on","only","open","operation","opinion","opposite","or","orange","order","organization","ornament","other","out","oven","over","owner",
			"page","pain","paint","paper","parallel","parcel","part","past","paste","payment","peace","pen","pencil","person","physical","picture","pig","pin","pipe","place","plane","plant","plate","play","please","pleasure","plough","pocket","point","poison","polish","political","poor","porter","position","possible","pot","potato","powder","power","present","price","print","prison","private","probable","process","produce","profit","property","prose","protest","public","pull","pump","punishment","purpose","push","put",
			"quality","question","quick","quiet","quite",
			"rail","rain","range","rat","rate","ray","reaction","reading","ready","reason","receipt","record","red","regret","regular","relation","religion","representative","request","respect","responsible","rest","reward","rhythm","rice","right","ring","river","road","rod","roll","roof","room","root","rough","round","rub","rule","run",
			"sad","safe","sail","salt","same","sand","say","scale","school","science","scissors","screw","sea","seat","second","secret","secretary","see","seed","seem","selection","self","send","sense","separate","serious","servant","sex","shade","shake","shame","sharp","sheep","shelf","ship","shirt","shock","shoe","short","shut","side","sign","silk","silver","simple","sister","size","skin","skirt","sky","sleep","slip","slope","slow","small","smash","smell","smile","smoke","smooth","snake","sneeze","snow","so","soap","society","sock","soft","solid","some","son","song","sort","sound","soup","south","space","spade","special","sponge","spoon","spring","square","stage","stamp","star","start","statement","station","steam","steel","stem","step","stick","sticky","stiff","still","stitch","stocking","stomach","stone","stop","store","story","straight","strange","street","stretch","strong","structure","substance","such","sudden","sugar","suggestion","summer","sun","support","surprise","sweet","swim","system",
			"table","tail","take","talk","tall","taste","tax","teaching","tendency","test","than","that","the","then","theory","there","thick","thin","thing","this","thought","thread","throat","through","through","thumb","thunder","ticket","tight","till","time","tin","tired","to","toe","together","tomorrow","tongue","tooth","top","touch","town","trade","train","transport","tray","tree","trick","trouble","trousers","true","turn","twist",
			"umbrella","under","unit","up","use",
			"value","verse","very","vessel","view","violent","voice",
			"waiting","walk","wall","war","warm","wash","waste","watch","water","wave","wax","way","weather","week","weight","well","west","wet","wheel","when","where","while","whip","whistle","white","who","why","wide","will","wind","window","wine","wing","winter","wire","wise","with","woman","wood","wool","word","work","worm","wound","writing","wrong",
			"year", "yellow", "yes", "yesterday", "you", "young"
		];
		public static function getRandom():String {
			return list[ int(Math.random() * list.length) ];
		}
		public static function getJRandom():Array {
			var index:int = int(Math.random() * jList.length);
			//return [jKanjiList[index], jList[index]];
			return ["", jList[index]];
		}
		public static function isExist(word:String):Boolean {
			return( (list.indexOf(word) >= 0) );
		}
		public static function isJExist(word:String):Boolean {
			if ( word.charCodeAt(0) < 128 ) {
				word = Roma.getHiragana(word);
			}
			return( (jList.indexOf(word) >= 0 ) );
		}
	}
	
	// グラフィック管理クラス
	class ImageManager {
		public static var SasakoA:Loader = new Loader();
		public static var SasakoB:Loader = new Loader();
		public static var MikiA:Loader = new Loader();
		public static var MikiB:Loader = new Loader();
		public static var count:Number = 0;
		public static const countMax:Number = 4;
		public static var initChecker:EventDispatcher = new EventDispatcher();
		public static function init():void {
			SasakoA.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			SasakoA.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			SasakoA.load(new URLRequest("http://www.nyafuri.com/TypeShoot/sasako_1.png"));
			SasakoB.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			SasakoB.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			SasakoB.load(new URLRequest("http://www.nyafuri.com/TypeShoot/sasako_2.png"));
			MikiA.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			MikiA.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			MikiA.load(new URLRequest("http://www.nyafuri.com/TypeShoot/miki_1.png"));
			MikiB.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			MikiB.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			MikiB.load(new URLRequest("http://www.nyafuri.com/TypeShoot/miki_2.png"));
		}
		protected static function onIoError(e:IOErrorEvent):void {
//			trace( e );
		}
		private static function onComplete(e:Event):void {
			count++;
			e.target.removeEventListener(Event.COMPLETE, onComplete);
			initChecker.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, count, countMax));
		}
	}
	
	// 音管理クラス
	class SoundManager {
		public static var ClickSound:Sound = new Sound();
		public static var ComboSound:Sound = new Sound();
		public static var ShootSound:Sound = new Sound();
		public static var AttackSound:Sound = new Sound();
		public static var HitSound:Sound = new Sound();
		public static var DamageSound:Sound = new Sound();
		public static var DangerSound:Sound = new Sound();
		public static var TypeSound:Sound = new Sound();
		public static var GameBGM:Sound = new Sound();
		public static var ReflectSound:Sound = new Sound();
		public static var count:Number = 0;
		public static const countMax:Number = 10;
		public static var initChecker:EventDispatcher = new EventDispatcher();
		public static function init():void {
			ClickSound.addEventListener(Event.COMPLETE, onComplete);
			ClickSound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			ClickSound.load(new URLRequest("http://www.nyafuri.com/TypeShoot/click.mp3"));
			ComboSound.addEventListener(Event.COMPLETE, onComplete);
			ComboSound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			ComboSound.load(new URLRequest("http://www.nyafuri.com/TypeShoot/combo.mp3"));
			ShootSound.addEventListener(Event.COMPLETE, onComplete);
			ShootSound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			ShootSound.load(new URLRequest("http://www.nyafuri.com/TypeShoot/shoot.mp3"));
			AttackSound.addEventListener(Event.COMPLETE, onComplete);
			AttackSound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			AttackSound.load(new URLRequest("http://www.nyafuri.com/TypeShoot/attack.mp3"));
			HitSound.addEventListener(Event.COMPLETE, onComplete);
			HitSound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			HitSound.load(new URLRequest("http://www.nyafuri.com/TypeShoot/hit.mp3"));
			DamageSound.addEventListener(Event.COMPLETE, onComplete);
			DamageSound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			DamageSound.load(new URLRequest("http://www.nyafuri.com/TypeShoot/damage.mp3"));
			DangerSound.addEventListener(Event.COMPLETE, onComplete);
			DangerSound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			DangerSound.load(new URLRequest("http://www.nyafuri.com/TypeShoot/danger.mp3"));
			TypeSound.addEventListener(Event.COMPLETE, onComplete);
			TypeSound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			TypeSound.load(new URLRequest("http://www.nyafuri.com/TypeShoot/type.mp3"));
			GameBGM.addEventListener(Event.COMPLETE, onComplete);
			GameBGM.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			GameBGM.load(new URLRequest("http://www.nyafuri.com/TypeShoot/gameBgm.mp3"));
			ReflectSound.addEventListener(Event.COMPLETE, onComplete);
			ReflectSound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			ReflectSound.load(new URLRequest("http://www.nyafuri.com/TypeShoot/reflect.mp3"));
		}
		protected static function onIoError(e:IOErrorEvent):void {
//			trace( e );
		}
		private static var gameBgmCh:SoundChannel;
		public static function playGameBgm():void {
			timer.stop();
			if( gameBgmCh == null ) gameBgmCh = GameBGM.play(0, 99999);
		}
		public static function stopGameBgm():void {
			if ( gameBgmCh != null ) {
				timer.start();
				timer.addEventListener(TimerEvent.TIMER, onTimer);
			}
		}
		private static var timer:Timer = new Timer(100, 10);
		private static var volume:Number = 1.0;
		private static function onTimer(e:TimerEvent):void {
			gameBgmCh.soundTransform = new SoundTransform(volume);
			volume-= 0.1;
			if ( volume < 0.1 ) {
				e.target.removeEventListener(TimerEvent.TIMER, onTimer);
				gameBgmCh.stop();
				gameBgmCh = null;
			}
		}
		private static function onComplete(e:Event):void {
			count++;
			e.target.removeEventListener(Event.COMPLETE, onComplete);
			initChecker.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, count, countMax));
		}
		
	}