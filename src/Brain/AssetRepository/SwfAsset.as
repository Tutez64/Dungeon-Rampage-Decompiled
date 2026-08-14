package Brain.AssetRepository
{
   import Brain.Logger.Logger;
   import flash.display.MovieClip;
   
   public class SwfAsset extends Asset
   {
      
      protected var mRootClip:MovieClip;
      
      private var mSwfPath:String;
      
      protected var mHdRootClip:MovieClip = null;
      
      private var mHdSwfPath:String = null;
      
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
         if(mHdRootClip != null)
         {
            mHdRootClip.loaderInfo.loader.unloadAndStop();
            mHdRootClip = null;
         }
      }
      
      public function get swfPath() : String
      {
         return mSwfPath;
      }
      
      public function setHdAsset(hdRootClip:MovieClip, hdSwfPath:String) : void
      {
         mHdRootClip = hdRootClip;
         mHdSwfPath = hdSwfPath;
      }
      
      public function get hasHdAsset() : Boolean
      {
         return mHdRootClip != null;
      }
      
      public function get hdSwfPath() : String
      {
         return mHdSwfPath;
      }
      
      public function get root() : MovieClip
      {
         return mRootClip;
      }
      
      public function getClass(className:String, suppressWarnings:Boolean = false) : Class
      {
         if(mHdRootClip != null && mHdRootClip.loaderInfo.applicationDomain.hasDefinition(className))
         {
            return mHdRootClip.loaderInfo.applicationDomain.getDefinition(className) as Class;
         }
         if(!mRootClip.loaderInfo.applicationDomain.hasDefinition(className))
         {
            if(!suppressWarnings)
            {
               Logger.warn("Could not find class name: " + className + " in SwfAsset " + mRootClip.loaderInfo.url + (mHdRootClip != null ? " or HD asset " + mHdRootClip.loaderInfo.url : ""));
            }
            return null;
         }
         return mRootClip.loaderInfo.applicationDomain.getDefinition(className) as Class;
      }
   }
}

