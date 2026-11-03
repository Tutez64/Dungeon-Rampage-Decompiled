package Brain.Render
{
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Starling.StarlingLayer;
   import Brain.Starling.StarlingLayerManager;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.geom.Rectangle;
   import starling.display.DisplayObject;
   
   public class StarlingRenderingBackend implements IRenderingBackend
   {
      
      protected var mFacade:Facade;
      
      protected var mStarlingLayerManager:StarlingLayerManager;
      
      public var onContextReady:Function;
      
      public var contextReady:Boolean;
      
      public function StarlingRenderingBackend(facade:Facade)
      {
         super();
         mFacade = facade;
      }
      
      public function get backendType() : String
      {
         return "starling";
      }
      
      public function get isReady() : Boolean
      {
         return mStarlingLayerManager != null && mStarlingLayerManager.isReady();
      }
      
      public function get starlingLayerManager() : StarlingLayerManager
      {
         return mStarlingLayerManager;
      }
      
      public function init(facade:Object, stage:Stage, designWidth:Number, designHeight:Number) : void
      {
         if(mStarlingLayerManager != null)
         {
            Logger.warn("StarlingRenderingBackend.init: already initialized");
            return;
         }
         mStarlingLayerManager = new StarlingLayerManager(mFacade,stage,designWidth,designHeight,onContextReady);
      }
      
      public function addChildToLayer(displayObject:Object, layerIndex:int) : void
      {
         if(!isReady)
         {
            Logger.warn("StarlingRenderingBackend.addChildToLayer: backend not ready");
            return;
         }
         if(displayObject == null)
         {
            Logger.warn("StarlingRenderingBackend.addChildToLayer: displayObject is null");
            return;
         }
         var _loc3_:DisplayObject = displayObject as DisplayObject;
         if(_loc3_ == null)
         {
            Logger.warn("StarlingRenderingBackend.addChildToLayer: displayObject is not a Starling DisplayObject");
            return;
         }
         var _loc4_:StarlingLayer = mStarlingLayerManager.getLayer(layerIndex);
         if(_loc4_ != null)
         {
            _loc4_.addChild(_loc3_);
         }
         else
         {
            Logger.error("StarlingRenderingBackend.addChildToLayer: layer " + layerIndex + " not found in starling layer map");
         }
      }
      
      public function removeChild(displayObject:Object) : void
      {
         if(displayObject == null)
         {
            return;
         }
         var _loc2_:DisplayObject = displayObject as DisplayObject;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.parent)
         {
            _loc2_.parent.removeChild(_loc2_);
         }
         else
         {
            Logger.error("StarlingRenderingBackend.removeChild: displayObject is not a child of any layer");
         }
      }
      
      public function clearLayer(layerIndex:int) : void
      {
         if(!isReady)
         {
            return;
         }
         var _loc2_:StarlingLayer = mStarlingLayerManager.getLayer(layerIndex);
         if(_loc2_ != null)
         {
            _loc2_.clean();
         }
      }
      
      public function markLayerDirty(layerIndex:int) : void
      {
         if(!isReady)
         {
            return;
         }
         mStarlingLayerManager.markLayerDirty(layerIndex);
      }
      
      public function syncWorldTransform(worldTransformNode:Sprite) : void
      {
         if(!isReady)
         {
            return;
         }
         mStarlingLayerManager.syncWorldTransform(worldTransformNode);
      }
      
      public function updateViewPort(rect:Rectangle) : void
      {
         if(mStarlingLayerManager != null)
         {
            mStarlingLayerManager.updateViewPort(rect);
         }
      }
      
      public function destroy() : void
      {
         onContextReady = null;
         if(mStarlingLayerManager != null)
         {
            mStarlingLayerManager.destroy();
            mStarlingLayerManager = null;
         }
         mFacade = null;
      }
   }
}

