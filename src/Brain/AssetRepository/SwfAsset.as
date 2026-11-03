package Brain.AssetRepository
{
   import Brain.Logger.Logger;
   import flash.display.MovieClip;
   
   public class SwfAsset extends Asset
   {
      
      protected var mRootClip:MovieClip;
      
      private var mSwfPath:String;
      
      public function SwfAsset(rootClip:MovieClip, swfPath:String)
      {
         mRootClip = rootClip;
         mSwfPath = swfPath;
         super();
      }
      
      override public function destroy() : void
      {
         mRootClip.loaderInfo.loader.unloadAndStop();
         mRootClip = null;
      }
      
      public function get swfPath() : String
      {
         return mSwfPath;
      }
      
      public function get root() : MovieClip
      {
         return mRootClip;
      }
      
      public function getClass(className:String, suppressWarnings:Boolean = false) : Class
      {
         if(!mRootClip.loaderInfo.applicationDomain.hasDefinition(className))
         {
            if(!suppressWarnings)
            {
               Logger.warn("Could not find class name: \'" + className + "\' in SwfAsset " + mRootClip.loaderInfo.url);
            }
            return null;
         }
         return mRootClip.loaderInfo.applicationDomain.getDefinition(className) as Class;
      }
   }
}

