package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import com.junkbyte.console.ConsoleStyle;
   import com.junkbyte.console.core.ConsoleTextField;
   import com.junkbyte.console.text.StyleSheet;
   import flash.Boot;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class ConsolePanel extends Sprite
   {
      
      public static var DRAGGING_STARTED:String = "draggingStarted";
      
      public static var DRAGGING_ENDED:String = "draggingEnded";
      
      public static var SCALING_STARTED:String = "scalingStarted";
      
      public static var SCALING_ENDED:String = "scalingEnded";
      
      public static var VISIBLITY_CHANGED:String = "visibilityChanged";
      
      public static var TEXT_ROLL:String = "TEXT_ROLL";
      
      public var txtField:TextField;
      
      public var scaler:Sprite;
      
      public var moveable:Boolean;
      
      public var minWidth:int;
      
      public var minHeight:int;
      
      public var console:Console;
      
      public var bg:Sprite;
      
      public var _snaps:Array;
      
      public var _resizeTxt:TextField;
      
      public var _movedFrom:Point;
      
      public var _dragOffset:Point;
      
      public function ConsolePanel(m:Console = undefined)
      {
         if(!Boot.skip_constructor)
         {
            moveable = true;
            minHeight = 18;
            minWidth = 18;
            super();
            console = m;
            bg = new Sprite();
            bg.name = "background";
            addChild(bg);
         }
      }
      
      public static function onTextFieldMouseOut(e:MouseEvent) : void
      {
         TextField(e.currentTarget).dispatchEvent(new TextEvent("TEXT_ROLL"));
      }
      
      public static function onTextFieldMouseMove(e:MouseEvent) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc8_:* = null as XML;
         var _loc9_:* = null as XMLList;
         var _loc10_:* = null as XML;
         var _loc11_:* = null;
         var _loc3_:TextField = TextField(e.currentTarget);
         var _loc4_:int = 0;
         if(_loc3_.scrollH > 0)
         {
            _loc5_ = _loc3_.scrollH;
            _loc6_ = _loc3_.width;
            _loc3_.width = _loc6_ + _loc5_;
            _loc4_ = _loc3_.getCharIndexAtPoint(_loc3_.mouseX + _loc5_,_loc3_.mouseY);
            _loc3_.width = _loc6_;
            _loc3_.scrollH = _loc5_;
         }
         else
         {
            _loc4_ = _loc3_.getCharIndexAtPoint(_loc3_.mouseX,_loc3_.mouseY);
         }
         var _loc7_:String = null;
         if(_loc4_ > 0)
         {
            try
            {
               _loc8_ = new XML(_loc3_.getXMLText(_loc4_,_loc4_ + 1));
               _loc9_ = _loc8_.child("textformat");
               if(_loc9_.length() != 0)
               {
                  _loc10_ = _loc9_[0];
                  if(_loc10_ != null)
                  {
                     _loc7_ = _loc10_.attribute("url").toString();
                  }
               }
            }
            catch(_loc_e_:*)
            {
               _loc11_ = _loc_e_;
               null;
               _loc7_ = null;
            }
         }
         _loc3_.dispatchEvent(new TextEvent("TEXT_ROLL",false,false,_loc7_));
      }
      
      public function updateScaleText() : void
      {
         _resizeTxt.htmlText = "<low>" + int(get_width()) + "," + int(get_height()) + "</low>";
      }
      
      public function updateScale(e:Event = undefined) : void
      {
         var _loc2_:Point = returnSnappedFor(x + mouseX - _dragOffset.x,y + mouseY - _dragOffset.y);
         _loc2_.x -= x;
         _loc2_.y -= y;
         set_width(_loc2_.x < minWidth ? minWidth : _loc2_.x);
         set_height(_loc2_.y < minHeight ? minHeight : _loc2_.y);
         updateScaleText();
      }
      
      public function updateDragText() : void
      {
         _resizeTxt.htmlText = "<low>" + Std.string(int(Math.round(x * 10000000)) / 10000000) + "," + Std.string(int(Math.round(y * 10000000)) / 10000000) + "</low>";
      }
      
      public function stopScaling() : void
      {
         onScalerMouseUp(null);
      }
      
      public function stopDragging() : void
      {
         _snaps = null;
         if(stage != null)
         {
            stage.removeEventListener(MouseEvent.MOUSE_UP,onDraggerMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,onDraggerMouseMove);
         }
         if(_resizeTxt != null && _resizeTxt.parent != null)
         {
            _resizeTxt.parent.removeChild(_resizeTxt);
         }
         _resizeTxt = null;
         dispatchEvent(new Event("draggingEnded"));
      }
      
      public function set_width(value:Number) : Number
      {
         if(value < minWidth)
         {
            value = minWidth;
         }
         if(scaler != null)
         {
            scaler.x = value;
         }
         bg.width = value;
         return value;
      }
      
      override public function set width(value:Number) : void
      {
         set_width(value);
      }
      
      public function set_visible(value:Boolean) : Boolean
      {
         super.visible = value;
         dispatchEvent(new Event("visibilityChanged"));
         return value;
      }
      
      override public function set visible(value:Boolean) : void
      {
         set_visible(value);
      }
      
      public function set_scalable(b:Boolean) : Boolean
      {
         var _loc2_:uint = 0;
         if(b && scaler == null)
         {
            _loc2_ = 8 + get_style().controlSize * 0.5;
            scaler = new Sprite();
            scaler.name = "scaler";
            scaler.graphics.beginFill(0,0);
            scaler.graphics.drawRect(-_loc2_ * 1.5,-_loc2_ * 1.5,_loc2_ * 1.5,_loc2_ * 1.5);
            scaler.graphics.endFill();
            scaler.graphics.beginFill(get_style().controlColor,get_style().backgroundAlpha);
            scaler.graphics.moveTo(0,0);
            scaler.graphics.lineTo(-_loc2_,0);
            scaler.graphics.lineTo(0,-_loc2_);
            scaler.graphics.endFill();
            scaler.buttonMode = true;
            scaler.doubleClickEnabled = true;
            scaler.addEventListener(MouseEvent.MOUSE_DOWN,onScalerMouseDown,false,0,true);
            addChildAt(scaler,getChildIndex(bg) + 1);
         }
         else if(!b && scaler != null)
         {
            if(contains(scaler))
            {
               removeChild(scaler);
            }
            scaler = null;
         }
         return b;
      }
      
      public function set scalable(value:Boolean) : void
      {
         set_scalable(value);
      }
      
      public function set_height(value:Number) : Number
      {
         if(value < minHeight)
         {
            value = minHeight;
         }
         if(scaler != null)
         {
            scaler.y = value;
         }
         bg.height = value;
         return value;
      }
      
      override public function set height(value:Number) : void
      {
         set_height(value);
      }
      
      public function returnSnappedFor(X:Number, Y:Number) : Point
      {
         return new Point(getSnapOf(X,true),getSnapOf(Y,false));
      }
      
      public function registerTFRoller(field:TextField, overhandle:Function, linkHandler:Object = undefined) : void
      {
         field.addEventListener(MouseEvent.MOUSE_MOVE,ConsolePanel.onTextFieldMouseMove,false,0,true);
         field.addEventListener(MouseEvent.ROLL_OUT,ConsolePanel.onTextFieldMouseOut,false,0,true);
         field.addEventListener("TEXT_ROLL",overhandle,false,0,true);
         if(linkHandler != null)
         {
            field.addEventListener(TextEvent.LINK,linkHandler,false,0,true);
         }
      }
      
      public function registerSnaps(X:Array, Y:Array) : void
      {
         _snaps = [X,Y];
      }
      
      public function registerDragger(mc:DisplayObject, dereg:Boolean = false) : void
      {
         if(dereg)
         {
            mc.removeEventListener(MouseEvent.MOUSE_DOWN,onDraggerMouseDown);
         }
         else
         {
            mc.addEventListener(MouseEvent.MOUSE_DOWN,onDraggerMouseDown,false,0,true);
         }
      }
      
      public function onScalerMouseUp(e:Event) : void
      {
         scaler.stage.removeEventListener(MouseEvent.MOUSE_UP,onScalerMouseUp);
         scaler.stage.removeEventListener(MouseEvent.MOUSE_MOVE,updateScale);
         updateScale();
         _snaps = null;
         if(_resizeTxt != null && _resizeTxt.parent != null)
         {
            _resizeTxt.parent.removeChild(_resizeTxt);
         }
         _resizeTxt = null;
         dispatchEvent(new Event("scalingEnded"));
      }
      
      public function onScalerMouseDown(e:Event) : void
      {
         _resizeTxt = makeTF("resizingField",true);
         _resizeTxt.mouseEnabled = false;
         _resizeTxt.autoSize = TextFieldAutoSize.RIGHT;
         _resizeTxt.x = -4;
         _resizeTxt.y = -17;
         scaler.addChild(_resizeTxt);
         updateScaleText();
         _dragOffset = new Point(scaler.mouseX,scaler.mouseY);
         _snaps = [[],[]];
         scaler.stage.addEventListener(MouseEvent.MOUSE_UP,onScalerMouseUp,false,0,true);
         scaler.stage.addEventListener(MouseEvent.MOUSE_MOVE,updateScale,false,0,true);
         dispatchEvent(new Event("scalingStarted"));
      }
      
      public function onDraggerMouseUp(e:MouseEvent) : void
      {
         stopDragging();
      }
      
      public function onDraggerMouseMove(e:MouseEvent = undefined) : void
      {
         if(get_style().panelSnapping == 0)
         {
            return;
         }
         var _loc2_:Point = returnSnappedFor(parent.mouseX - _dragOffset.x,parent.mouseY - _dragOffset.y);
         x = _loc2_.x;
         y = _loc2_.y;
         updateDragText();
      }
      
      public function onDraggerMouseDown(e:MouseEvent) : void
      {
         if(stage == null || !moveable)
         {
            return;
         }
         _resizeTxt = makeTF("positioningField",true);
         _resizeTxt.mouseEnabled = false;
         _resizeTxt.autoSize = TextFieldAutoSize.LEFT;
         addChild(_resizeTxt);
         updateDragText();
         _movedFrom = new Point(x,y);
         _dragOffset = new Point(mouseX,mouseY);
         _snaps = [[],[]];
         dispatchEvent(new Event("draggingStarted"));
         stage.addEventListener(MouseEvent.MOUSE_UP,onDraggerMouseUp,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,onDraggerMouseMove,false,0,true);
      }
      
      public function moveBackSafePosition() : void
      {
         if(_movedFrom != null)
         {
            if(x + get_width() < 10 || stage != null && stage.stageWidth < x + 10 || y + get_height() < 10 || stage != null && stage.stageHeight < y + 20)
            {
               x = _movedFrom.x;
               y = _movedFrom.y;
            }
            _movedFrom = null;
         }
      }
      
      public function makeTF(n:String, back:Boolean = false) : TextField
      {
         var _loc3_:ConsoleTextField = new ConsoleTextField();
         _loc3_.name = n;
         _loc3_.styleSheet = get_style().get_styleSheet();
         if(back)
         {
            _loc3_.background = true;
            _loc3_.backgroundColor = get_style().backgroundColor;
         }
         return _loc3_;
      }
      
      public function init(w:Number, h:Number, resizable:Boolean = false, col:int = -1, a:Number = -1, rounding:int = -1) : void
      {
         bg.graphics.clear();
         bg.graphics.beginFill(col >= 0 ? uint(col) : get_style().backgroundColor,a >= 0 ? a : get_style().backgroundAlpha);
         if(rounding < 0)
         {
            rounding = get_style().roundBorder;
         }
         if(rounding <= 0)
         {
            bg.graphics.drawRect(0,0,100,100);
         }
         else
         {
            bg.graphics.drawRoundRect(0,0,rounding + 10,rounding + 10,rounding,rounding);
            bg.scale9Grid = new Rectangle(rounding * 0.5,rounding * 0.5,10,10);
         }
         set_scalable(resizable);
         set_width(w);
         set_height(h);
      }
      
      public function get_width() : Number
      {
         return bg.width;
      }
      
      override public function get width() : Number
      {
         return get_width();
      }
      
      public function get_style() : ConsoleStyle
      {
         return console.get_config().get_style();
      }
      
      public function get_scalable() : Boolean
      {
         if(scaler != null)
         {
            return true;
         }
         return false;
      }
      
      public function get scalable() : Boolean
      {
         return get_scalable();
      }
      
      public function get_height() : Number
      {
         return bg.height;
      }
      
      override public function get height() : Number
      {
         return get_height();
      }
      
      public function get_config() : ConsoleConfig
      {
         return console.get_config();
      }
      
      public function getSnapOf(v:Number, isX:Boolean) : Number
      {
         var _loc7_:Number = NaN;
         var _loc3_:Number = v + get_width();
         var _loc4_:Array = _snaps[isX ? 0 : 1];
         var _loc5_:int = get_style().panelSnapping;
         var _loc6_:int = 0;
         while(_loc6_ < int(_loc4_.length))
         {
            _loc7_ = Number(_loc4_[_loc6_]);
            _loc6_++;
            if(Math.abs(_loc7_ - v) < _loc5_)
            {
               return _loc7_;
            }
            if(Math.abs(_loc7_ - _loc3_) < _loc5_)
            {
               return _loc7_ - get_width();
            }
         }
         return v;
      }
      
      public function close() : void
      {
         stopDragging();
         console.get_panels().tooltip();
         if(parent != null)
         {
            parent.removeChild(this);
         }
         dispatchEvent(new Event(Event.CLOSE));
      }
   }
}

