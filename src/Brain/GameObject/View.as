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
      
      protected var mFacade:Facade;
      
      protected var mRoot:Sprite;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mMovieClipRenderer:MovieClipRenderController;
      
      private var mWorkComponent:LogicalWorkComponent;
      
      private var mFadeResetTask:Task;
      
      private var mFading:Boolean;
      
      public function View(facade:Facade)
      {
         super();
         mFacade = facade;
         var _loc2_:String = "View";
         mSceneGraphComponent = new SceneGraphComponent(mFacade,_loc2_);
         mWorkComponent = new LogicalWorkComponent(mFacade,_loc2_);
         mRoot = new Sprite();
         mFading = false;
         MemoryTracker.track(this,_loc2_ + " - created in View()","brain");
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
         return new Vector3D(mRoot.x,mRoot.y);
      }
      
      public function set position(pos:Vector3D) : void
      {
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
      
      public function destroy() : void
      {
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

