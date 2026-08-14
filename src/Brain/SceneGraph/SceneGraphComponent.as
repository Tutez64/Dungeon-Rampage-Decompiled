package Brain.SceneGraph
{
   import Brain.Component.Component;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.ISetIterator;
   
   public class SceneGraphComponent extends Component
   {
      
      private static var mFadeSprite:Sprite;
      
      private static var mFadeTween:TweenMax;
      
      protected var mDisplayObjects:Set;
      
      private var mCurtainActive:Boolean = false;
      
      public function SceneGraphComponent(facade:Facade, ownerName:String = null)
      {
         super(facade);
         mDisplayObjects = new Set();
         MemoryTracker.track(this,"SceneGraphComponent - " + (ownerName || "unknown"),"brain");
      }
      
      public static function bringToFront(child:DisplayObject) : void
      {
         if(child.parent)
         {
            child.parent.addChildAt(child,child.parent.numChildren);
         }
      }
      
      public static function sendToBack(child:DisplayObject) : void
      {
         if(child.parent)
         {
            child.parent.addChildAt(child,0);
         }
      }
      
      public static function buildFadeSprite(facade:Facade) : void
      {
         mFadeSprite = new Sprite();
         mFadeSprite.graphics.beginFill(0,1);
         mFadeSprite.graphics.drawRect(0,0,facade.viewWidth,facade.viewHeight);
         mFadeSprite.graphics.endFill();
         mFadeSprite.mouseEnabled = true;
         mFadeSprite.mouseChildren = false;
      }
      
      public function addChild(child:DisplayObject, layerIndex:uint) : DisplayObject
      {
         if(!mDisplayObjects.has(child))
         {
            mDisplayObjects.add(child);
         }
         return mFacade.sceneGraphManager.addChild(child,layerIndex);
      }
      
      public function addChildAt(child:DisplayObject, layerIndex:uint, childIndex:uint) : DisplayObject
      {
         if(!mDisplayObjects.has(child))
         {
            mDisplayObjects.add(child);
         }
         return mFacade.sceneGraphManager.addChildAt(child,layerIndex,childIndex);
      }
      
      public function showPopupCurtain() : void
      {
         if(!mCurtainActive)
         {
            mFacade.sceneGraphManager.showPopupCurtain();
            mCurtainActive = true;
         }
      }
      
      public function removePopupCurtain() : void
      {
         if(mCurtainActive)
         {
            mFacade.sceneGraphManager.removePopupCurtain();
            mCurtainActive = false;
         }
      }
      
      public function removeChild(child:DisplayObject) : DisplayObject
      {
         if(child == null)
         {
            Logger.warn("SceneGraphComponent:removeChild child is null");
            return null;
         }
         mDisplayObjects.remove(child);
         return mFacade.sceneGraphManager.removeChild(child);
      }
      
      public function contains(child:DisplayObject, layerIndex:uint) : Boolean
      {
         return mDisplayObjects.has(child);
      }
      
      private function killFadeTween() : void
      {
         if(mFadeTween != null)
         {
            mFadeTween.kill();
            mFadeTween = null;
         }
      }
      
      public function fadeIn(fadeLength:Number) : void
      {
         if(mFadeSprite == null)
         {
            buildFadeSprite(mFacade);
         }
         killFadeTween();
         if(fadeLength == 0)
         {
            this.removeChild(mFadeSprite);
            return;
         }
         this.addChild(mFadeSprite,100);
         mFadeTween = TweenMax.to(mFadeSprite,fadeLength,{
            "alpha":0,
            "onComplete":finishFadeIn
         });
      }
      
      private function finishFadeIn() : void
      {
         this.removeChild(mFadeSprite);
      }
      
      private function finishFadeOut() : void
      {
      }
      
      public function fadeOut(fadeLength:Number, alphaValue:Number = 1) : void
      {
         if(mFadeSprite == null)
         {
            buildFadeSprite(mFacade);
         }
         killFadeTween();
         this.addChild(mFadeSprite,100);
         if(fadeLength == 0)
         {
            mFadeSprite.alpha = 1;
            return;
         }
         mFadeTween = TweenMax.to(mFadeSprite,fadeLength,{
            "alpha":alphaValue,
            "onComplete":finishFadeOut
         });
      }
      
      public function saturateLayers(value:Number, listOfLayersToBeAvoided:Array) : void
      {
         mFacade.sceneGraphManager.saturateLayers(value,listOfLayersToBeAvoided);
      }
      
      public function cleanBackgroundLayer() : void
      {
         mFacade.sceneGraphManager.cleanBackgroundLayer();
      }
      
      override public function destroy() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:ISetIterator = mDisplayObjects.iterator() as ISetIterator;
         while(_loc2_.hasNext())
         {
            _loc1_ = _loc2_.next() as DisplayObject;
            if(_loc1_.parent)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
         }
         mDisplayObjects.clear();
         mDisplayObjects = null;
         removePopupCurtain();
         super.destroy();
      }
   }
}

