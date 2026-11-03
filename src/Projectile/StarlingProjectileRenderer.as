package Projectile
{
   import Brain.Logger.Logger;
   import Brain.Starling.StarlingLayer;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import starling.display.Sprite;
   import starling.extensions.animate.Animation;
   import starling.filters.GlowFilter;
   
   public class StarlingProjectileRenderer
   {
      
      private var mDBFacade:DBFacade;
      
      private var mContainer:Sprite;
      
      private var mLayerIndex:int;
      
      private var mBodyAnimation:Animation;
      
      private var mEffectAnimation:Animation;
      
      private var mBodyLabel:String;
      
      private var mEffectLabel:String;
      
      private var mVisible:Boolean = true;
      
      private var mBodyColorMatrix:Vector.<Number>;
      
      private var mBodyGlowFilter:GlowFilter;
      
      private var mEffectColorMatrix:Vector.<Number>;
      
      private var mEffectGlowFilter:GlowFilter;
      
      public function StarlingProjectileRenderer(dbFacade:DBFacade, holderName:String, layerIndex:int, bodyAnimation:Animation, bodyLabel:String, effectAnimation:Animation = null, effectLabel:String = null)
      {
         super();
         mDBFacade = dbFacade;
         mLayerIndex = layerIndex;
         mBodyAnimation = bodyAnimation;
         mBodyLabel = bodyLabel;
         mEffectAnimation = effectAnimation;
         mEffectLabel = effectLabel;
         mContainer = new Sprite();
         mContainer.touchable = false;
         mContainer.name = "StarlingProjectileRenderer_" + holderName;
         if(mEffectAnimation != null)
         {
            mEffectAnimation.touchable = false;
            mEffectAnimation.stop();
            mContainer.addChild(mEffectAnimation);
         }
         if(mBodyAnimation != null)
         {
            mBodyAnimation.touchable = false;
            mBodyAnimation.stop();
            mContainer.addChild(mBodyAnimation);
         }
         MemoryTracker.track(mContainer,"StarlingProjectileRenderer - holder: " + holderName,"starling");
         setLayer(layerIndex);
      }
      
      public function attachEffect(effectAnimation:Animation, effectLabel:String) : Boolean
      {
         if(mContainer == null || mEffectAnimation != null)
         {
            return false;
         }
         mEffectAnimation = effectAnimation;
         mEffectLabel = effectLabel;
         mEffectAnimation.touchable = false;
         mEffectAnimation.stop();
         mEffectAnimation.setColorMatrix(mEffectColorMatrix);
         mContainer.addChildAt(mEffectAnimation,0);
         return true;
      }
      
      public function play() : void
      {
         playAnimation(mBodyAnimation,mBodyLabel);
         if(mEffectAnimation != null && mEffectAnimation.visible)
         {
            playAnimation(mEffectAnimation,mEffectLabel);
         }
         joinJuggler();
      }
      
      public function stop() : void
      {
         stopAnimation(mBodyAnimation);
         stopAnimation(mEffectAnimation);
         leaveJuggler();
      }
      
      public function setBodyVisible(visible:Boolean) : void
      {
         if(mBodyAnimation != null)
         {
            mBodyAnimation.visible = visible;
         }
      }
      
      public function setEffectVisible(visible:Boolean) : void
      {
         if(mEffectAnimation != null)
         {
            mEffectAnimation.visible = visible;
         }
         if(visible)
         {
            playAnimation(mEffectAnimation,mEffectLabel);
            joinJuggler();
         }
      }
      
      public function playEffect() : void
      {
         playAnimation(mEffectAnimation,mEffectLabel);
         joinJuggler();
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
            Logger.warn("StarlingProjectileRenderer: no Starling layer for index " + mLayerIndex + ", falling back to SORTED");
            mLayerIndex = 20;
            _loc2_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
         }
         if(_loc2_ != null)
         {
            _loc2_.addChild(mContainer);
            mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
         }
      }
      
      public function setTransform(x:Number, y:Number, scaleX:Number, scaleY:Number, alpha:Number = 1) : void
      {
         mContainer.x = x;
         mContainer.y = y;
         mContainer.alpha = alpha;
         if(mBodyAnimation != null)
         {
            mBodyAnimation.scaleX = scaleX;
            mBodyAnimation.scaleY = scaleY;
         }
         mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
      }
      
      public function setBodyRotation(rotationDegrees:Number) : void
      {
         if(mBodyAnimation != null)
         {
            mBodyAnimation.rotation = rotationDegrees * 3.141592653589793 / 180;
            mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
         }
      }
      
      public function setEffectRotation(rotationDegrees:Number) : void
      {
         if(mEffectAnimation != null)
         {
            mEffectAnimation.rotation = rotationDegrees * 3.141592653589793 / 180;
            mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
         }
      }
      
      public function setBodyColorFilter(matrix:Array) : void
      {
         mBodyColorMatrix = toColorMatrix(matrix);
         if(mBodyAnimation != null)
         {
            mBodyAnimation.setColorMatrix(mBodyColorMatrix);
         }
      }
      
      public function clearBodyColorFilter() : void
      {
         mBodyColorMatrix = null;
         if(mBodyAnimation != null)
         {
            mBodyAnimation.setColorMatrix(null);
         }
      }
      
      public function setBodyGlowFilter(color:uint, alpha:Number, blur:Number, quality:Number = 1) : void
      {
         if(mBodyAnimation == null)
         {
            return;
         }
         if(mBodyGlowFilter == null)
         {
            mBodyGlowFilter = new GlowFilter(color,alpha,blur,quality);
         }
         else
         {
            mBodyGlowFilter.color = color;
            mBodyGlowFilter.alpha = alpha;
            mBodyGlowFilter.blur = blur;
            mBodyGlowFilter.quality = quality;
         }
         updateBodyFilters();
      }
      
      public function clearBodyGlowFilter() : void
      {
         var _loc1_:GlowFilter = null;
         if(mBodyGlowFilter != null)
         {
            _loc1_ = mBodyGlowFilter;
            mBodyGlowFilter = null;
            updateBodyFilters();
            _loc1_.dispose();
         }
      }
      
      public function setEffectColorFilter(matrix:Array) : void
      {
         mEffectColorMatrix = toColorMatrix(matrix);
         if(mEffectAnimation != null)
         {
            mEffectAnimation.setColorMatrix(mEffectColorMatrix);
         }
      }
      
      public function clearEffectColorFilter() : void
      {
         mEffectColorMatrix = null;
         if(mEffectAnimation != null)
         {
            mEffectAnimation.setColorMatrix(null);
         }
      }
      
      public function setEffectGlowFilter(color:uint, alpha:Number, blur:Number, quality:Number = 1) : void
      {
         if(mEffectAnimation == null)
         {
            return;
         }
         if(mEffectGlowFilter == null)
         {
            mEffectGlowFilter = new GlowFilter(color,alpha,blur,quality);
         }
         else
         {
            mEffectGlowFilter.color = color;
            mEffectGlowFilter.alpha = alpha;
            mEffectGlowFilter.blur = blur;
            mEffectGlowFilter.quality = quality;
         }
         updateEffectFilters();
      }
      
      public function clearEffectGlowFilter() : void
      {
         var _loc1_:GlowFilter = null;
         if(mEffectGlowFilter != null)
         {
            _loc1_ = mEffectGlowFilter;
            mEffectGlowFilter = null;
            updateEffectFilters();
            _loc1_.dispose();
         }
      }
      
      public function destroy() : void
      {
         leaveJuggler();
         if(mBodyAnimation != null)
         {
            mBodyAnimation.stop();
            mBodyAnimation.filter = null;
            mBodyAnimation.removeFromParent(true);
            mBodyAnimation = null;
         }
         if(mEffectAnimation != null)
         {
            mEffectAnimation.stop();
            mEffectAnimation.filter = null;
            mEffectAnimation.removeFromParent(true);
            mEffectAnimation = null;
         }
         mBodyColorMatrix = null;
         mEffectColorMatrix = null;
         if(mBodyGlowFilter != null)
         {
            mBodyGlowFilter.dispose();
            mBodyGlowFilter = null;
         }
         if(mEffectGlowFilter != null)
         {
            mEffectGlowFilter.dispose();
            mEffectGlowFilter = null;
         }
         if(mContainer != null)
         {
            mContainer.removeFromParent(true);
            mContainer = null;
         }
         mDBFacade = null;
      }
      
      private function playAnimation(animation:Animation, label:String) : void
      {
         if(animation == null)
         {
            return;
         }
         if(label != null && animation.getFrame(label) >= 0)
         {
            animation.gotoLabel(label,true);
         }
         else
         {
            animation.loop = true;
            animation.currentFrame = 0;
            animation.play();
         }
      }
      
      private function stopAnimation(animation:Animation) : void
      {
         if(animation == null)
         {
            return;
         }
         animation.stop();
      }
      
      private function joinJuggler() : void
      {
         if(mContainer == null || !mVisible || mDBFacade == null)
         {
            return;
         }
         if(mBodyAnimation != null && mBodyAnimation.isPlaying && !mDBFacade.starlingLayerManager.juggler.contains(mBodyAnimation))
         {
            mDBFacade.starlingLayerManager.juggler.add(mBodyAnimation);
         }
         if(mEffectAnimation != null && mEffectAnimation.isPlaying && !mDBFacade.starlingLayerManager.juggler.contains(mEffectAnimation))
         {
            mDBFacade.starlingLayerManager.juggler.add(mEffectAnimation);
         }
      }
      
      private function leaveJuggler() : void
      {
         if(mDBFacade == null)
         {
            return;
         }
         if(mBodyAnimation != null)
         {
            mDBFacade.starlingLayerManager.juggler.remove(mBodyAnimation);
         }
         if(mEffectAnimation != null)
         {
            mDBFacade.starlingLayerManager.juggler.remove(mEffectAnimation);
         }
      }
      
      private function toColorMatrix(matrix:Array) : Vector.<Number>
      {
         var _loc2_:int = 0;
         if(matrix == null || matrix.length != 20)
         {
            return null;
         }
         var _loc3_:Vector.<Number> = new Vector.<Number>(20,true);
         _loc2_ = 0;
         while(_loc2_ < 20)
         {
            _loc3_[_loc2_] = Number(matrix[_loc2_]);
            _loc2_++;
         }
         return _loc3_;
      }
      
      private function updateBodyFilters() : void
      {
         if(mBodyAnimation != null)
         {
            mBodyAnimation.filter = mBodyGlowFilter;
         }
      }
      
      private function updateEffectFilters() : void
      {
         if(mEffectAnimation != null)
         {
            mEffectAnimation.filter = mEffectGlowFilter;
         }
      }
   }
}

