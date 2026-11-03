package Doobers
{
   import Brain.Logger.Logger;
   import Brain.Starling.StarlingLayer;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import starling.display.Sprite;
   import starling.extensions.animate.Animation;
   
   public class StarlingDooberRenderer
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mContainer:Sprite;
      
      protected var mContent:Sprite;
      
      protected var mLayerIndex:int;
      
      protected var mAnimation:Animation;
      
      protected var mLabel:String;
      
      protected var mVisible:Boolean = true;
      
      public function StarlingDooberRenderer(dbFacade:DBFacade, holderName:String, layerIndex:int, animation:Animation, label:String)
      {
         super();
         mDBFacade = dbFacade;
         mLayerIndex = layerIndex;
         mAnimation = animation;
         mLabel = label;
         mAnimation.touchable = false;
         mAnimation.stop();
         mContainer = new Sprite();
         mContainer.touchable = false;
         mContainer.name = "StarlingDooberRenderer_" + holderName;
         mContent = new Sprite();
         mContent.touchable = false;
         mContainer.addChild(mContent);
         mContent.addChild(mAnimation);
         MemoryTracker.track(mContainer,"StarlingDooberRenderer - holder: " + holderName,"starling");
         setLayer(layerIndex);
      }
      
      public function play() : void
      {
         if(mAnimation == null)
         {
            return;
         }
         if(mLabel != null)
         {
            mAnimation.gotoLabel(mLabel,true);
         }
         else
         {
            mAnimation.loop = true;
            mAnimation.currentFrame = 0;
            mAnimation.play();
         }
         joinJuggler();
      }
      
      public function rewindAndStop() : void
      {
         if(mAnimation == null)
         {
            return;
         }
         leaveJuggler();
         var _loc1_:int = int(mLabel != null ? mAnimation.getFrame(mLabel) : 0);
         mAnimation.currentFrame = _loc1_ >= 0 ? _loc1_ : 0;
         mAnimation.pause();
      }
      
      public function get visible() : Boolean
      {
         return mVisible;
      }
      
      public function set visible(value:Boolean) : void
      {
         if(mVisible == value)
         {
            return;
         }
         mVisible = value;
         mContainer.visible = value;
         if(value)
         {
            joinJuggler();
         }
         else
         {
            leaveJuggler();
         }
      }
      
      public function setLayer(layerIndex:int) : void
      {
         if(mContainer == null || mDBFacade == null)
         {
            return;
         }
         if(mLayerIndex == layerIndex && (layerIndex == 0 || mContainer.parent != null))
         {
            return;
         }
         if(mContainer.parent != null)
         {
            mContainer.removeFromParent();
         }
         if(layerIndex == 0)
         {
            mLayerIndex = 0;
            return;
         }
         mLayerIndex = layerIndex;
         var _loc2_:StarlingLayer = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
         if(_loc2_ == null)
         {
            Logger.warn("StarlingDooberRenderer: no Starling layer for index " + mLayerIndex + ", falling back to SORTED");
            mLayerIndex = 20;
            _loc2_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
         }
         if(_loc2_ != null)
         {
            _loc2_.addChild(mContainer);
            mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
         }
      }
      
      public function setTransform(x:Number, y:Number, scaleX:Number, scaleY:Number, alpha:Number = 1, sortX:Number = NaN, sortY:Number = NaN) : void
      {
         if(isNaN(sortX))
         {
            sortX = x;
         }
         if(isNaN(sortY))
         {
            sortY = y;
         }
         mContainer.x = sortX;
         mContainer.y = sortY;
         mContainer.alpha = alpha;
         mContent.x = x - sortX;
         mContent.y = y - sortY;
         mContent.scaleX = scaleX;
         mContent.scaleY = scaleY;
         mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
      }
      
      public function destroy() : void
      {
         leaveJuggler();
         if(mAnimation != null)
         {
            mAnimation.stop();
            mAnimation.removeFromParent(true);
            mAnimation = null;
         }
         if(mContent != null)
         {
            mContent.removeFromParent(true);
            mContent = null;
         }
         if(mContainer != null)
         {
            mContainer.removeFromParent(true);
            mContainer = null;
         }
         mDBFacade = null;
      }
      
      private function joinJuggler() : void
      {
         if(mAnimation == null || !mVisible || !mAnimation.isPlaying)
         {
            return;
         }
         if(!mDBFacade.starlingLayerManager.juggler.contains(mAnimation))
         {
            mDBFacade.starlingLayerManager.juggler.add(mAnimation);
         }
      }
      
      private function leaveJuggler() : void
      {
         if(mAnimation == null || mDBFacade == null)
         {
            return;
         }
         mDBFacade.starlingLayerManager.juggler.remove(mAnimation);
      }
   }
}

