package Brain.AssetRepository
{
   public class JsonAsset extends Asset
   {
      
      protected var mJson:Object;
      
      public function JsonAsset(loadedObject:Object)
      {
         super();
         mJson = JSON.parse(loadedObject.toString());
      }
      
      public function get json() : Object
      {
         return mJson;
      }
      
      override public function destroy() : void
      {
         mJson = null;
         super.destroy();
      }
   }
}

