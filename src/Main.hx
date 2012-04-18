package ;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.Assets;
import nme.events.Event;
import nme.geom.Rectangle;
import nme.Lib;
import nme.events.MouseEvent;
import nme.Loader;
import nme.feedback.Haptic;
import nme.display.Shape;
import nme.media.Sound;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;
import nme.events.TouchEvent;
import nme.geom.Point;
import haxe.Timer;
import nme.events.KeyboardEvent;


/**
 * ...
 * @author Deepak
 */

 class Button extends Sprite
 {
	 private var value:Int;
	 public var image:Bitmap;
	 private var image_dest:String;
	 public function new(param:Int)
	 {
		 super();
		 this.value = param;
		 construct();
	 }
	 private function construct():Void {
		 image = new Bitmap(Assets.getBitmapData("assets/button" + value + ".png"));
		 image.cacheAsBitmap = true;
		 image.y = 48 * (value%5);
		 addChild(image);
	 }
 }
 
 class Button_panel extends Sprite
 {
	 static var tick:Sound;
	 public function new (param:Int,func)   // func will be called when a button will be pressed 
	 {
		 super();
		 for (i in (param*5)...((param+1)*5))
		 {
			 var temp:Button = new Button(i);
			 tick = Assets.getSound("assets/music/tock.wav");
			 temp.addEventListener(TouchEvent.TOUCH_BEGIN, function(event:TouchEvent):Void { 
				 Haptic.vibrate(0, 70);
				 tick.play();
				 func(event.target.value);
				 } );
			 addChild(temp);
		 }
	 }
 }

 class Command_centre extends Sprite
{
	var command_centre:TextField;
	public var command_centre_value:Int;	
	var text_format:TextFormat;
	public function new()
	{
		super();
		command_centre_value = 0;
		command_centre = new TextField();
		text_format = new TextFormat('Arial', 30, 0xFFFFFF, true);
		text_format.align = TextFormatAlign.CENTER;
		command_centre.width = 50;
		command_centre.height = 40;
		command_centre.selectable = false;
		command_centre.defaultTextFormat = text_format;
		var temp:Int = 0;
		command_centre_text();
		command_centre.textColor = 0x33333;
		command_centre.border = true;
		command_centre.addEventListener(TouchEvent.TOUCH_BEGIN, function(event:MouseEvent)
		{
			 Haptic.vibrate(0, 70);
			 //command_centre_value = 0;   Doing this in main function so that correct value of command_centre is bubbled
			 //command_centre_text();
		});
		addChild(command_centre);
	}
	public function update_command_centre(param:Int):Void
	{
		if (command_centre_value >= 10) // User can't change its value 
		{
			return;
		}
		else {   // change value
			command_centre_value= command_centre_value*10 + param ;
			command_centre_text();
		}
	}
	public function command_centre_text():Void
	{
		if (command_centre_value < 10)
		{
			 command_centre.text = "0" + command_centre_value;
		}
		else
			 command_centre.text = "" + command_centre_value;
	}
}

// class Igloo
class Igloo extends Sprite
{
	var rect:Shape;
	public var strength:Int;
	public function new ():Void
	{
		super();
		rect = new Shape();
		rect.graphics.beginFill(0xFFFFFF);
		rect.graphics.drawRect(0, 0, 64, 64);
		addChild(rect);
		strength = 4;
	}
}

class Comet extends Sprite
{
	public var answer:Int;
	public var target_igloo: Int;
	public var active:Bool;
	var text:TextField;
	public function new()
	{
		super();
		var rect:Shape = new Shape();
		rect.graphics.beginFill(0xFFF000, 0.6);
		rect.graphics.drawCircle(20, 20, 20);
		addChild(rect);	
		text = new TextField();
		var text_format = new TextFormat('Arial', 20, 0xFFFFFF, true);
		text_format.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = text_format;
		text.selectable = false;
		addChild(rect);
		addChild(text);
		active = false;
	}
	public function start(targ_ingloo:Int, ans:Int, _text: String)
	{
		target_igloo = targ_ingloo;
		answer = ans;
		text.text = _text;
		active = true;
	}
	public function destroy()
	{
		active = false;
	}
}

class Main extends Sprite  
{
	static var circle: Shape;
	var index:Float;
	var button_panel_left:Button_panel;
	var button_panel_right:Button_panel;
	var command_centre:Command_centre;
	var comets:Array<Comet>;
	var igloos:Array<Igloo>;
	var start_time:Float;
	var command_centre_laser:Sound;
	var command_centre_error:Sound;
	var playing:Bool;
	public function new() 
	{
		super();
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		var underlay_active:Bool = false;
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, function(event:KeyboardEvent)  // back button handler
		{
			if (event.keyCode == 27 && underlay_active == false)// In order to avoid mutiple overlay 
			{
				event.stopImmediatePropagation ();
				//Lib.exit ();
				playing = false;
				underlay_active = true;
				var exit_sprite:Sprite = new Sprite();   // Main sprite for exit and continue menu.
				var underlay:Shape = new Shape();
				underlay.graphics.beginFill(0x000000,0.85);
				underlay.graphics.drawRect(0, 0, 480, 320);
				exit_sprite.addChild(underlay);
				
				var exit:Bitmap = new Bitmap(Assets.getBitmapData("assets/exit.png"));
				var right:Bitmap = new Bitmap(Assets.getBitmapData("assets/continue.png"));
				right.scaleX = 1 / 2;
				right.scaleY = 1 / 2;
				var exit_button_sprite: Sprite = new Sprite();
				exit_button_sprite.addChild(exit);
				exit_button_sprite.x = 50;
				exit_button_sprite.y = 100;
				exit_button_sprite.addEventListener(TouchEvent.TOUCH_BEGIN, function(event) {
					Lib.exit();
				});
				
				
				var right_button_sprite: Sprite = new Sprite();
				right_button_sprite.addChild(right);
				right_button_sprite.x = 250;
				right_button_sprite.y = 100;
				right_button_sprite.addEventListener(TouchEvent.TOUCH_BEGIN, function(event) {
					removeChild(exit_sprite);
					playing = true;
					underlay_active = false;
				});
				
				exit_sprite.addChild(exit_button_sprite);
				exit_sprite.addChild(right_button_sprite);
				addChild(exit_sprite);
			}		
		});
		playing = true;
		construct();
	}
	public function construct()
	{
		
		var back:Bitmap = new Bitmap(Assets.getBitmapData("assets/back.png"));
		addChild(back);
		command_centre = new Command_centre();
		command_centre.x = 215;
		command_centre.y = 278;
		command_centre.addEventListener(TouchEvent.TOUCH_BEGIN, function(event:TouchEvent)
		{
			attack_comet(command_centre.command_centre_value);
			command_centre.command_centre_value = 0;
			command_centre.command_centre_text();
		});
		addChild(command_centre);
		
		button_panel_left = new Button_panel(0,command_centre.update_command_centre);
		button_panel_left.alpha = 0.7;
		addChild(button_panel_left);
		
		button_panel_right= new Button_panel(1,command_centre.update_command_centre);
		button_panel_right.alpha = 0.7;
		button_panel_right.x = 448;
		button_panel_right.y = 0;
		addChild(button_panel_right);
		
		igloos = new Array<Igloo>();	
		var igloo1 = new Igloo();
		igloo1.x = 15;
		igloo1.y = 256;
		addChild(igloo1);
		igloos.push(igloo1);
		
		var igloo2 = new Igloo();
		igloo2.x = 100;
		igloo2.y = 256;
		addChild(igloo2);
		igloos.push(igloo2);
		
		var igloo3 = new Igloo();
		igloo3.x = 316;
		igloo3.y = 256;
		addChild(igloo3);
		igloos.push(igloo3);
		
		var igloo4:Igloo = new Igloo();
		igloo4.x = 400;
		igloo4.y = 256;
		addChild(igloo4);
		igloos.push(igloo4);
		
		//Adding comets
		
		comets = new Array<Comet>();
		for (i in 0...6)
		{
			var temp:Comet = new Comet();
			comets.push(temp);
			temp.visible = false;
			addChildAt(temp,1);
		}
		
		command_centre_laser = Assets.getSound("assets/music/laser.wav");
		command_centre_error = Assets.getSound("assets/music/command_centre_error.wav");
		start_game();
	}
	public function start_game():Void
	{
		start_time = Lib.getTimer();
		addEventListener(Event.ENTER_FRAME, animate);
	}
	
	public function show_laser(x:Float,y:Float)
	{
		var line:Shape = new Shape();
		line.graphics.lineStyle(4, 0xFF0000);
		line.graphics.moveTo(command_centre.x + command_centre.width / 2, command_centre.y);
		line.graphics.lineTo(x, y);
		addChildAt(line,1);
		Timer.delay(function() { removeChild(line); }, 50);
	}
	public function attack_comet(val:Int)
	{
		var destroyed_comets:Int = 0;
		for ( com in comets)
		{
			if (com.active == true)
			{
				if (com.answer==val)
				{
					command_centre_laser.play();
					show_laser(com.x,com.y);
					com.visible = false;
					com.destroy();
					destroyed_comets++;
				}
			}
		}
		if (destroyed_comets == 0)
		{
			command_centre_error.play();
			show_laser(240, 0);
		}
		
	}
	
	public function generate_comet():Void
	{
		for (com in comets)
		{
			if (com.active == true)
			continue;                         // If a comet is active then continue
			var rand_target:Int = Math.floor(Math.random() * 20) % 4;  // Index starts from zero
			var num1 = Math.floor(Math.random() * 10);
			var num2 = Math.floor(Math.random() * 10);
			com.start(rand_target,num1+num2, "" + num1 + "+" + num2 + "=?");
			com.y = 0;            // return to starting point( At the top)
			com.visible = true;
			switch(rand_target)
			{
				case 0: com.x = 15; break;
				case 1: com.x = 100; break;
				case 2: com.x = 316; break;
				case 3: com.x = 400; break;
			}
			break;    // We have to add only one comet 
		}
	}
	public function animate(event:Event):Void
	{
		var current_time = Lib.getTimer();
		var diff = current_time-start_time;
		if (playing == true)	
		{
			if (diff > 3800)
			{
				start_time += diff;
				generate_comet();
			}
			for ( com in comets)
			{
				if (com.active == true)
				{
					com.y += 0.4;
					if (igloos[com.target_igloo].y < (com.y+com.height/2))
					{
						if (igloos[com.target_igloo].strength > 0)
						{
							igloos[com.target_igloo].strength--;
							igloos[com.target_igloo].y = igloos[com.target_igloo].y + igloos[com.target_igloo].height / 4;
						}
						com.visible = false;
						com.destroy();
					}
				}
			}
		}
	}
	
	public static function main()
	{
		var main_sprite:Main = new Main();
		Lib.current.addChild(main_sprite);
	}	
}