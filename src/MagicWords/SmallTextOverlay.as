package MagicWords
{
   import Brain.Event.EventListeners;
   import Brain.Logger.Logger;
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getQualifiedClassName;
   
   public class SmallTextOverlay extends Sprite
   {
      
      public static const DEFAULT_MIN_PX:Number = 9;
      
      private static const LAYER:Number = 1003;
      
      private static const OUTLINE_COLOR:uint = 16719904;
      
      private static const REDRAW_EVERY_FRAMES:int = 5;
      
      private var mDBFacade:DBFacade;
      
      private var mMinPx:Number;
      
      private var mUseLowercase:Boolean;
      
      private var mLabels:Vector.<TextField> = new Vector.<TextField>();
      
      private var mLabelsUsed:int;
      
      private var mFrame:int;
      
      public function SmallTextOverlay(dbFacade:DBFacade, minPx:Number, useLowercase:Boolean = false)
      {
         super();
         mDBFacade = dbFacade;
         mMinPx = minPx;
         mUseLowercase = useLowercase;
         mouseEnabled = false;
         mouseChildren = false;
         mDBFacade.addRootDisplayObject(this,1003);
         EventListeners.add(this,"enterFrame",onEnterFrame);
      }
      
      public static function logSmallText(dbFacade:DBFacade, minPx:Number, useLowercase:Boolean = false) : void
      {
         var count:int = 0;
         forEachSmallField(dbFacade,minPx,function(param1:TextField, param2:Number):void
         {
            count = count + 1;
            Logger.log(param2.toFixed(1) + "px  " + pathOf(param1) + "  \"" + param1.text.substr(0,30) + "\"");
         },useLowercase);
         Logger.log(count + " visible text field(s) under " + minPx + "px (" + (useLowercase ? "lowercase" : "uppercase") + " height)");
      }
      
      private static function forEachSmallField(dbFacade:DBFacade, minPx:Number, callback:Function, useLowercase:Boolean) : void
      {
         if(dbFacade.stageRef == null)
         {
            return;
         }
         walk(dbFacade.stageRef,dbFacade.scalingRoot,minPx,callback,useLowercase);
      }
      
      private static function walk(node:DisplayObject, scalingRoot:DisplayObjectContainer, minPx:Number, callback:Function, useLowercase:Boolean) : void
      {
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         if(node == null || !node.visible || node.alpha == 0 || node is SmallTextOverlay)
         {
            return;
         }
         var _loc7_:TextField = node as TextField;
         if(_loc7_ != null)
         {
            if(_loc7_.text == "" || node.parent == scalingRoot)
            {
               return;
            }
            _loc8_ = TextUtil.glyphHeightPx(_loc7_,useLowercase);
            if(!isNaN(_loc8_) && _loc8_ < minPx)
            {
               callback(_loc7_,_loc8_);
            }
            return;
         }
         var _loc6_:DisplayObjectContainer = node as DisplayObjectContainer;
         if(_loc6_ == null)
         {
            return;
         }
         if(_loc6_ is Loader)
         {
            return;
         }
         if(_loc6_.parent == _loc6_.stage && getQualifiedClassName(_loc6_).indexOf("com.junkbyte") == 0)
         {
            return;
         }
         _loc9_ = 0;
         while(_loc9_ < _loc6_.numChildren)
         {
            walk(_loc6_.getChildAt(_loc9_),scalingRoot,minPx,callback,useLowercase);
            _loc9_++;
         }
      }
      
      private static function pathOf(node:DisplayObject) : String
      {
         var _loc2_:String = "";
         while(node != null && node.parent != null)
         {
            _loc2_ = "/" + node.name + _loc2_;
            node = node.parent;
         }
         return _loc2_;
      }
      
      public function destroy() : void
      {
         EventListeners.remove(this,"enterFrame",onEnterFrame);
         mDBFacade.removeRootDisplayObject(this);
         mDBFacade = null;
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var overlay:SmallTextOverlay;
         var i:int;
         if(++mFrame % 5 != 0)
         {
            return;
         }
         graphics.clear();
         graphics.lineStyle(2,16719904);
         mLabelsUsed = 0;
         overlay = this;
         forEachSmallField(mDBFacade,mMinPx,function(param1:TextField, param2:Number):void
         {
            var _loc3_:Rectangle = param1.getBounds(overlay);
            overlay.graphics.drawRect(_loc3_.x,_loc3_.y,_loc3_.width,_loc3_.height);
            overlay.placeLabel(param2.toFixed(1),_loc3_.x,_loc3_.y);
         },mUseLowercase);
         i = mLabelsUsed;
         while(i < mLabels.length)
         {
            mLabels[i].visible = false;
            i = i + 1;
         }
      }
      
      private function placeLabel(text:String, x:Number, y:Number) : void
      {
         var _loc4_:TextField = null;
         if(mLabelsUsed < mLabels.length)
         {
            _loc4_ = mLabels[mLabelsUsed];
         }
         else
         {
            _loc4_ = new TextField();
            _loc4_.autoSize = "left";
            _loc4_.selectable = false;
            _loc4_.background = true;
            _loc4_.backgroundColor = 16719904;
            _loc4_.defaultTextFormat = new TextFormat("_sans",11,16777215,true);
            _loc4_.scaleX = _loc4_.scaleY = 1 / mDBFacade.viewScale;
            mLabels.push(_loc4_);
            addChild(_loc4_);
         }
         mLabelsUsed = mLabelsUsed + 1;
         _loc4_.text = text;
         _loc4_.x = x;
         _loc4_.y = y - _loc4_.height;
         _loc4_.visible = true;
      }
   }
}

