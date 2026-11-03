package Brain.GameObject
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Render.MovieClipRenderController;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.geom.Vector3D;
   import flash.utils.getQualifiedClassName;
   
   public class View
   {
      
      private static var sAllViews:Vector.<View> = new Vector.<View>();
      
      protected var mFacade:Facade;
      
      protected var mRoot:Sprite;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mMovieClipRenderer:MovieClipRenderController;
      
      private var mWorkComponent:LogicalWorkComponent;
      
      private var mFadeResetTask:Task;
      
      private var mFading:Boolean;
      
      protected var mTickPosX:Number = NaN;
      
      protected var mTickPosY:Number = NaN;
      
      protected var mPrevPosX:Number = NaN;
      
      protected var mPrevPosY:Number = NaN;
      
      public function View(facade:Facade, category:String = "brain")
      {
         super();
         mFacade = facade;
         var _loc3_:String = "View";
         mSceneGraphComponent = new SceneGraphComponent(mFacade,_loc3_,category);
         mWorkComponent = new LogicalWorkComponent(mFacade,_loc3_,category);
         mRoot = new Sprite();
         mFading = false;
         sAllViews.push(this);
         MemoryTracker.track(this,_loc3_ + " - created in View()",category);
      }
      
      private static function recursiveFindChildrenOfClass(foundArray:Array, node:DisplayObject, classNames:Array) : void
      {
         var _loc5_:int = 0;
         var _loc6_:String = getQualifiedClassName(node);
         if(classNames.indexOf(_loc6_) != -1)
         {
            foundArray.push(node);
         }
         var _loc4_:DisplayObjectContainer = node as DisplayObjectContainer;
         if(_loc4_)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.numChildren)
            {
               recursiveFindChildrenOfClass(foundArray,_loc4_.getChildAt(_loc5_),classNames);
               _loc5_++;
            }
         }
      }
      
      public static function findChildrenOfClass(searchNode:DisplayObjectContainer, classNames:Array) : Array
      {
         var _loc3_:Array = [];
         recursiveFindChildrenOfClass(_loc3_,searchNode,classNames);
         return _loc3_;
      }
      
      public static function beginTickAll() : void
      {
         for each(var _loc1_:View in sAllViews)
         {
            _loc1_.beginTick();
         }
      }
      
      public static function renderInterpolatedAll(alpha:Number) : void
      {
         for each(var _loc2_:View in sAllViews)
         {
            _loc2_.renderInterpolated(alpha);
         }
      }
      
      public function init() : void
      {
      }
      
      public function unFade() : void
      {
         mRoot.alpha = 1;
         mFadeResetTask.destroy();
         mFadeResetTask = null;
         mFading = false;
      }
      
      public function updateFade(gameClock:GameClock) : void
      {
         var _loc2_:Number = NaN;
         if(mFading)
         {
            mRoot.alpha *= 0.85;
            if(mRoot.alpha <= 0.3)
            {
               mFading = false;
               mRoot.alpha = 0.3;
            }
         }
         else
         {
            _loc2_ = 1 - mRoot.alpha;
            mRoot.alpha = 1 - _loc2_ * _loc2_;
            if(mRoot.alpha > 0.975)
            {
               unFade();
            }
         }
      }
      
      public function doFade() : void
      {
         mFading = true;
         if(!mFadeResetTask)
         {
            mFadeResetTask = mWorkComponent.doEveryFrame(updateFade);
         }
      }
      
      public function get movieClipRenderer() : MovieClipRenderController
      {
         return mMovieClipRenderer;
      }
      
      public function get position() : Vector3D
      {
         if(isNaN(mTickPosX))
         {
            return new Vector3D(mRoot.x,mRoot.y);
         }
         return new Vector3D(mTickPosX,mTickPosY);
      }
      
      public function get positionX() : Number
      {
         return isNaN(mTickPosX) ? mRoot.x : mTickPosX;
      }
      
      public function get positionY() : Number
      {
         return isNaN(mTickPosX) ? mRoot.y : mTickPosY;
      }
      
      public function set position(pos:Vector3D) : void
      {
         if(isNaN(mPrevPosX))
         {
            mPrevPosX = pos.x;
            mPrevPosY = pos.y;
         }
         mTickPosX = pos.x;
         mTickPosY = pos.y;
         mRoot.x = pos.x;
         mRoot.y = pos.y;
      }
      
      public function snapPosition(pos:Vector3D) : void
      {
         mPrevPosX = pos.x;
         mPrevPosY = pos.y;
         mTickPosX = pos.x;
         mTickPosY = pos.y;
         mRoot.x = pos.x;
         mRoot.y = pos.y;
      }
      
      public function get rotation() : Number
      {
         return mRoot.rotation;
      }
      
      public function set rotation(rot:Number) : void
      {
         mRoot.rotation = rot;
      }
      
      public function get rotationX() : Number
      {
         return mRoot.rotationX;
      }
      
      public function set rotationX(rot:Number) : void
      {
         mRoot.rotationX = rot;
      }
      
      public function get rotationY() : Number
      {
         return mRoot.rotationY;
      }
      
      public function set rotationY(rot:Number) : void
      {
         mRoot.rotationY = rot;
      }
      
      public function get rotationZ() : Number
      {
         return mRoot.rotationZ;
      }
      
      public function set rotationZ(rot:Number) : void
      {
         mRoot.rotationZ = rot;
      }
      
      public function get root() : Sprite
      {
         return mRoot;
      }
      
      public function isViewObjectTweenDriven() : Boolean
      {
         return false;
      }
      
      public function beginTick() : void
      {
         mPrevPosX = mTickPosX;
         mPrevPosY = mTickPosY;
         if(!isNaN(mTickPosX) && (mPrevPosX != mTickPosX || mPrevPosY != mTickPosY))
         {
            mRoot.x = mTickPosX;
            mRoot.y = mTickPosY;
         }
         mPrevPosX = mTickPosX;
         mPrevPosY = mTickPosY;
      }
      
      public function renderInterpolated(alpha:Number) : void
      {
         if(isNaN(mTickPosX))
         {
            return;
         }
         if(isViewObjectTweenDriven())
         {
            return;
         }
         if(mPrevPosX == mTickPosX && mPrevPosY == mTickPosY)
         {
            mRoot.x = mTickPosX;
            mRoot.y = mTickPosY;
            return;
         }
         mRoot.x = mPrevPosX + (mTickPosX - mPrevPosX) * alpha;
         mRoot.y = mPrevPosY + (mTickPosY - mPrevPosY) * alpha;
      }
      
      public function destroy() : void
      {
         var _loc1_:int = sAllViews.indexOf(this);
         if(_loc1_ >= 0)
         {
            sAllViews.splice(_loc1_,1);
         }
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
         if(mFadeResetTask)
         {
            mFadeResetTask.destroy();
            mFadeResetTask = null;
         }
         if(mWorkComponent)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
         if(mRoot.parent)
         {
            mRoot.parent.removeChild(mRoot);
         }
         if(mMovieClipRenderer)
         {
            mMovieClipRenderer.destroy();
            mMovieClipRenderer = null;
         }
         mRoot = null;
         mFacade = null;
      }
   }
}

