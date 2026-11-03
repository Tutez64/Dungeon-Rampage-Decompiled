package Brain.Render
{
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import flash.display.DisplayObject;
   
   public class FlashRenderingBackend implements IRenderingBackend
   {
      
      protected var mFacade:Facade;
      
      public function FlashRenderingBackend(facade:Facade)
      {
         super();
         mFacade = facade;
      }
      
      public function get backendType() : String
      {
         return "flash";
      }
      
      public function get isReady() : Boolean
      {
         return true;
      }
      
      public function addChildToLayer(displayObject:Object, layerIndex:int) : void
      {
         if(displayObject == null)
         {
            Logger.warn("FlashRenderingBackend.addChildToLayer: displayObject is null");
            return;
         }
         mFacade.sceneGraphManager.addChild(displayObject as DisplayObject,layerIndex);
      }
      
      public function removeChild(displayObject:Object) : void
      {
         if(displayObject == null)
         {
            return;
         }
         mFacade.sceneGraphManager.removeChild(displayObject as DisplayObject);
      }
      
      public function clearLayer(layerIndex:int) : void
      {
         var _loc2_:Layer = mFacade.sceneGraphManager.getLayer(layerIndex);
         if(_loc2_ == null)
         {
            Logger.warn("FlashRenderingBackend.clearLayer: unknown layer index " + layerIndex);
            return;
         }
         while(_loc2_.numChildren > 0)
         {
            _loc2_.removeChildAt(0);
         }
      }
      
      public function destroy() : void
      {
         mFacade = null;
      }
   }
}

