package Brain.Render
{
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Collections.Map;
   
   public class RendererFactorySelector
   {
      
      protected var mFacade:Facade;
      
      protected var mFlashFactory:RendererFactory;
      
      protected var mStarlingFactory:RendererFactory;
      
      protected var mLayerToBackend:Map;
      
      public function RendererFactorySelector(facade:Facade)
      {
         super();
         mFacade = facade;
         mLayerToBackend = new Map();
      }
      
      public function get flashFactory() : RendererFactory
      {
         return mFlashFactory;
      }
      
      public function get starlingFactory() : RendererFactory
      {
         return mStarlingFactory;
      }
      
      public function registerFlashFactory(flashFactory:RendererFactory) : void
      {
         mFlashFactory = flashFactory;
      }
      
      public function registerStarlingFactory(starlingFactory:RendererFactory) : void
      {
         mStarlingFactory = starlingFactory;
      }
      
      public function setLayerBackend(layerIndex:int, backendType:String) : void
      {
         if(mLayerToBackend.hasKey(layerIndex))
         {
            mLayerToBackend.removeKey(layerIndex);
         }
         mLayerToBackend.add(layerIndex,backendType);
      }
      
      public function getLayerBackend(layerIndex:int) : String
      {
         if(!mLayerToBackend.hasKey(layerIndex))
         {
            return "flash";
         }
         return mLayerToBackend.itemFor(layerIndex) as String;
      }
      
      public function getFactoryForLayer(layerIndex:int) : RendererFactory
      {
         var _loc2_:String = getLayerBackend(layerIndex);
         if(_loc2_ == "starling" && mStarlingFactory != null)
         {
            if(mStarlingFactory.backend.isReady)
            {
               return mStarlingFactory;
            }
            Logger.warn("RendererFactorySelector: Starling requested for layer " + layerIndex + " but backend is not ready; falling back to available factory");
         }
         if(mFlashFactory != null)
         {
            return mFlashFactory;
         }
         Logger.error("RendererFactorySelector: No rendering factories registered for layer " + layerIndex);
         return null;
      }
      
      public function clearLayer(layerIndex:int) : void
      {
         var _loc2_:RendererFactory = getFactoryForLayer(layerIndex);
         if(_loc2_ == null)
         {
            Logger.warn("RendererFactorySelector: Cannot clear layer " + layerIndex + " - no factory available");
            return;
         }
         var _loc3_:String = getLayerBackend(layerIndex);
         if(_loc3_ == "starling" && mStarlingFactory != null && mStarlingFactory.backend.isReady)
         {
            if(mFacade.starlingRenderingBackend != null)
            {
               mFacade.starlingRenderingBackend.clearLayer(layerIndex);
            }
         }
         if(mFlashFactory != null && mFacade.flashRenderingBackend != null)
         {
            mFacade.flashRenderingBackend.clearLayer(layerIndex);
         }
      }
      
      public function destroy() : void
      {
         mFacade = null;
         mFlashFactory = null;
         mStarlingFactory = null;
         mLayerToBackend.clear();
         mLayerToBackend = null;
      }
   }
}

