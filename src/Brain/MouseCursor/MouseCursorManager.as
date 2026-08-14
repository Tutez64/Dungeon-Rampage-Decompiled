package Brain.MouseCursor
{
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   import org.as3commons.collections.Map;
   
   public class MouseCursorManager
   {
      
      private var mCursorTypes:Map;
      
      private var mCurrentCursor:String;
      
      private var mIsTransient:Boolean;
      
      private var mCursorClip:MovieClip;
      
      private var mCursorStack:Array;
      
      private var mFacade:Facade;
      
      private var mNextKey:uint;
      
      private var mDisabled:Boolean;
      
      public function MouseCursorManager(facade:Facade)
      {
         super();
         mFacade = facade;
         mCursorTypes = new Map();
         mNextKey = 1;
         mIsTransient = false;
         mDisabled = false;
         mCursorStack = [];
         registerBuiltInTypes();
         setMouseCursor("auto");
      }
      
      public function set disable(disabled:Boolean) : void
      {
         mDisabled = disabled;
         if(mDisabled)
         {
            if(mCursorClip)
            {
               mFacade.stageRef.removeEventListener("mouseOver",onMouseOver);
               mFacade.stageRef.removeEventListener("mouseMove",onMouseMove);
               mFacade.stageRef.removeEventListener("mouseOut",onMouseOut);
               mFacade.sceneGraphManager.removeChild(mCursorClip);
            }
            setBuiltInCursor("auto");
         }
      }
      
      private function registerBuiltInTypes() : void
      {
         var _loc1_:CursorType = new CursorType(null,true);
         mCursorTypes.add("arrow",_loc1_);
         mCursorTypes.add("auto",_loc1_);
         mCursorTypes.add("button",_loc1_);
         mCursorTypes.add("hand",_loc1_);
         mCursorTypes.add("ibeam",_loc1_);
      }
      
      public function registerMouseCursor(root:MovieClip, name:String, override:Boolean = false) : void
      {
         var _loc4_:CursorType = null;
         if(!root)
         {
            Logger.error("Trying to register a mouse cursor with a null MovieClip.");
            return;
         }
         root.mouseChildren = false;
         root.mouseEnabled = false;
         if(mCursorTypes.hasKey(name))
         {
            if(!override)
            {
               return;
            }
            _loc4_ = mCursorTypes.itemFor(name);
            _loc4_.isBuiltIn = false;
            _loc4_.root = root;
            if(name == mCurrentCursor)
            {
               setMouseCursor(name);
            }
         }
         else
         {
            _loc4_ = new CursorType(root,false);
            mCursorTypes.add(name,_loc4_);
         }
      }
      
      private function onMouseMove(event:MouseEvent) : void
      {
         mCursorClip.x = event.stageX;
         mCursorClip.y = event.stageY;
         event.updateAfterEvent();
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         if(mCursorClip)
         {
            mCursorClip.visible = true;
            mFacade.stageRef.removeEventListener("mouseOver",onMouseOver);
         }
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
         if(mCursorClip && mCursorClip.visible)
         {
            mCursorClip.visible = false;
            mFacade.stageRef.addEventListener("mouseOver",onMouseOver);
            mFacade.stageRef.removeEventListener("mouseOut",onMouseOut);
         }
      }
      
      private function setBuiltInCursor(name:String) : void
      {
         Mouse.show();
         Mouse.cursor = name;
         mCursorClip = null;
      }
      
      private function setCustomCursor(type:CursorType) : void
      {
         Mouse.hide();
         mCursorClip = type.root;
         mCursorClip.visible = true;
         mCursorClip.mouseChildren = false;
         mCursorClip.mouseEnabled = false;
         mFacade.sceneGraphManager.addChild(mCursorClip,200);
         type.root.x = type.root.stage.mouseX;
         type.root.y = type.root.stage.mouseY;
         mFacade.stageRef.addEventListener("mouseMove",onMouseMove);
         mFacade.stageRef.addEventListener("mouseOut",onMouseOut);
      }
      
      public function pushMouseCursor(name:String, transient:Boolean = false) : uint
      {
         return 0;
      }
      
      public function popMouseCursor(key:uint = 0) : void
      {
      }
      
      public function setMouseCursor(name:String) : void
      {
         var _loc2_:* = null;
      }
   }
}

import flash.display.MovieClip;

class CursorType
{
   
   public var isBuiltIn:Boolean;
   
   public var root:MovieClip;
   
   public function CursorType(clip:MovieClip, builtIn:Boolean)
   {
      super();
      root = clip;
      isBuiltIn = builtIn;
   }
}
