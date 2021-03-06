//TextFieldを元に、シェルみたいなものを作りたい
//Enterキーが押されたときの処理がうまく動かず、
//プロンプトが出る時と出ない時がある、スクロールされないなどの場合がある
package {
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            // write as3 code here..
            var field:ShellField = new ShellField(">");
            field.text = "aaaaaaaaaaaaaaaa";
            addChild(field);
        }
    }
}

import flash.text.TextField;
import flash.text.TextFieldType;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import flash.events.KeyboardEvent;
class ShellField extends TextField {
	private var prompt:String;
	public function ShellField(prompt:String = "") {
		this.type = TextFieldType.INPUT;
		this.prompt = prompt;
		addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
	}
	public override function appendText(str:String):void {
		//一番下までスクロールされていたら、
		//追加する文字列に含まれる改行の数だけ下にスクロール
		var lastLine:Boolean = false;
		if (scrollV == maxScrollV) {
			lastLine = true;
		}
		super.appendText(str);
		if (lastLine) {
			scrollV + text.match(/\n/).length;
		}
	}
	private function keyDown(e:KeyboardEvent):void {
		//Enterキーが押された時は、
		//改行してからイベントを発生された後、プロンプトを表示
		//ここの動作が怪しい
		if (e.keyCode == Keyboard.ENTER) {
			appendText("\n");
			dispatchEvent(new ShellEvent(ShellEvent.ENTER_DOWN, "hoge"));
			appendText(prompt);
		}
	}
}

class ShellEvent extends Event {
	public static const ENTER_DOWN:String = "EnterDown";
	public var str:String; //入力された文字列
	public function ShellEvent(type:String, str:String) {
		super(type);
		this.str = str;
	}
	public override function clone():Event {
		return new ShellEvent(type, str);
	}
	public override function toString():String {
		return formatToString("ShellEvent", "type", "bubbles", "cancelable", "eventPhase", "str");
	}
}