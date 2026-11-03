package Brain.Render
{
   import Brain.Facade.Facade;
   import Brain.Starling.StarlingSourceCache;
   
   public class StarlingRendererFactory extends RendererFactory
   {
      
      private static const DEFAULT_FRAME_RATE:Number = 24;
      
      protected var mSourceCache:StarlingSourceCache;
      
      public function StarlingRendererFactory(facade:Facade, backend:IRenderingBackend)
      {
         super(facade,backend);
      }
      
      public function set sourceCache(value:StarlingSourceCache) : void
      {
         mSourceCache = value;
      }
      
      public function get sourceCache() : StarlingSourceCache
      {
         if(mSourceCache != null)
         {
            return mSourceCache;
         }
         if(mFacade.starlingLayerManager != null)
         {
            mSourceCache = mFacade.starlingLayerManager.sourceCache;
         }
         return mSourceCache;
      }
   }
}

