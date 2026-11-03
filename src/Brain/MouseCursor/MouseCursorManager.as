package Brain.MouseCursor
{
   import Brain.Event.EventListeners;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.ui.Mouse;
   import flash.ui.MouseCursorData;
   import flash.utils.Dictionary;
   
   public class MouseCursorManager
   {
      
      public static const MAX_CURSOR_SIZE:int = 32;
      
      private static const NATIVE_NAME_PREFIX:String = "custom_";
      
      private static const BUILT_IN_CURSORS:Array = ["arrow","auto","button","hand","ibeam"];
      
      private var mFacade:Facade;
      
      private var mCursors:Dictionary;
      
      private var mStack:Vector.<CursorEntry>;
      
      private var mDefaultCursor:String;
      
      private var mNextKey:uint;
      
      private var mHoveredTextInput:TextField;
      
      private var mTextInputCursorKey:uint;
      
      private var mCursorHidden:Boolean;
      
      public function MouseCursorManager(facade:Facade)
      {
         super();
         mFacade = facade;
         mCursors = new Dictionary();
         for each(var _loc2_:String in BUILT_IN_CURSORS)
         {
            mCursors[_loc2_] = _loc2_;
         }
         mStack = new Vector.<CursorEntry>();
         mDefaultCursor = "auto";
         mNextKey = 1;
         EventListeners.add(mFacade.stageRef,"mouseOver",onStageMouseOver,true);
         EventListeners.add(mFacade.stageRef,"mouseMove",onMouseKeyboardInput,true);
         EventListeners.add(mFacade.stageRef,"mouseDown",onMouseKeyboardInput,true);
         EventListeners.add(mFacade.stageRef,"mouseWheel",onMouseKeyboardInput,true);
         EventListeners.add(mFacade.stageRef,"keyDown",onMouseKeyboardInput,true);
         refresh();
      }
      
      private static function rasterize(art:DisplayObject) : MouseCursorData
      {
         var _loc4_:Rectangle = art.getBounds(art);
         var _loc5_:Number = Math.min(1,32 / Math.max(_loc4_.width,_loc4_.height));
         var _loc3_:BitmapData = new BitmapData(32,32,true,0);
         var _loc6_:Matrix = new Matrix(_loc5_,0,0,_loc5_,-_loc4_.x * _loc5_,-_loc4_.y * _loc5_);
         _loc3_.drawWithQuality(art,_loc6_,null,null,null,true,"best");
         var _loc2_:MouseCursorData = new MouseCursorData();
         _loc2_.data = Vector.<BitmapData>([_loc3_]);
         _loc2_.hotSpot = new Point(clampToCursor(-_loc4_.x * _loc5_),clampToCursor(-_loc4_.y * _loc5_));
         return _loc2_;
      }
      
      private static function clampToCursor(value:Number) : int
      {
         return Math.max(0,Math.min(32 - 1,Math.round(value)));
      }
      
      public function hideMouseCursor() : void
      {
         if(mCursorHidden)
         {
            return;
         }
         mCursorHidden = true;
         Mouse.hide();
         mFacade.stageRef.mouseChildren = false;
      }
      
      private function onMouseKeyboardInput(event:Event) : void
      {
         if(!mCursorHidden)
         {
            return;
         }
         mCursorHidden = false;
         mFacade.stageRef.mouseChildren = true;
         Mouse.show();
         refresh();
      }
      
      public function registerMouseCursor(name:String, art:DisplayObject) : void
      {
         if(!art)
         {
            Logger.error("Trying to register mouse cursor " + name + " without art.");
            return;
         }
         if(BUILT_IN_CURSORS.indexOf(name) != -1)
         {
            Logger.error("Trying to replace built-in mouse cursor " + name + ".");
            return;
         }
         if(!Mouse.supportsNativeCursor)
         {
            Logger.warn("Native mouse cursors are not supported, " + name + " will show the system cursor.");
            return;
         }
         var _loc3_:String = "custom_" + name;
         Mouse.registerCursor(_loc3_,rasterize(art));
         mCursors[name] = _loc3_;
         refresh();
      }
      
      public function set defaultMouseCursor(name:String) : void
      {
         mDefaultCursor = name;
         refresh();
      }
      
      public function pushMouseCursor(name:String, transient:Boolean = false) : uint
      {
         if(mStack.length > 0 && mStack[mStack.length - 1].transient)
         {
            mStack.pop();
         }
         var _loc3_:uint = mNextKey++;
         mStack.push(new CursorEntry(_loc3_,name,transient));
         refresh();
         return _loc3_;
      }
      
      public function popMouseCursor(key:uint) : void
      {
         var _loc2_:int = 0;
         _loc2_ = mStack.length - 1;
         while(_loc2_ >= 0)
         {
            if(mStack[_loc2_].key == key)
            {
               mStack.splice(_loc2_,1);
               refresh();
               return;
            }
            _loc2_--;
         }
      }
      
      private function refresh() : void
      {
         var _loc2_:String = mStack.length > 0 ? mStack[mStack.length - 1].name : mDefaultCursor;
         var _loc1_:String = mCursors[_loc2_];
         Mouse.cursor = _loc1_ ? _loc1_ : "auto";
      }
      
      private function onStageMouseOver(event:MouseEvent) : void
      {
         var _loc2_:TextField = event.target as TextField;
         if(_loc2_ == mHoveredTextInput)
         {
            return;
         }
         releaseTextInputCursor();
         if(_loc2_ && _loc2_.type == "input")
         {
            mHoveredTextInput = _loc2_;
            EventListeners.add(mHoveredTextInput,"mouseOut",onTextInputLeft);
            EventListeners.add(mHoveredTextInput,"removedFromStage",onTextInputLeft);
            mTextInputCursorKey = pushMouseCursor("ibeam");
         }
      }
      
      private function onTextInputLeft(event:Event) : void
      {
         releaseTextInputCursor();
      }
      
      private function releaseTextInputCursor() : void
      {
         if(!mHoveredTextInput)
         {
            return;
         }
         EventListeners.remove(mHoveredTextInput,"mouseOut",onTextInputLeft);
         EventListeners.remove(mHoveredTextInput,"removedFromStage",onTextInputLeft);
         mHoveredTextInput = null;
         popMouseCursor(mTextInputCursorKey);
         mTextInputCursorKey = 0;
      }
   }
}

class CursorEntry
{
   
   public var key:uint;
   
   public var name:String;
   
   public var transient:Boolean;
   
   public function CursorEntry(key:uint, name:String, transient:Boolean)
   {
      super();
      this.key = key;
      this.name = name;
      this.transient = transient;
   }
}
