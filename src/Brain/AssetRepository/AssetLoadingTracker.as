package Brain.AssetRepository
{
   public class AssetLoadingTracker
   {
      
      public var pendingLoadCallback:Function;
      
      public var pendingErrorCallback:Function;
      
      public var assetLoadingComponent:AssetLoadingComponent;
      
      public var assetKey:String;
      
      public function AssetLoadingTracker(assetKey:String, assetLoadingComponent:AssetLoadingComponent, pendingLoadCallback:Function, pendingErrorCallback:Function)
      {
         super();
         this.assetKey = assetKey;
         this.assetLoadingComponent = assetLoadingComponent;
         this.pendingLoadCallback = pendingLoadCallback;
         this.pendingErrorCallback = pendingErrorCallback;
         this.assetLoadingComponent.mPendingDownloads.add(this);
      }
      
      public function errorCallback() : void
      {
         if(pendingErrorCallback != null)
         {
            pendingErrorCallback();
         }
         if(assetLoadingComponent != null)
         {
            assetLoadingComponent.RemoveLoader(this);
         }
      }
      
      public function successCallback(asset:Asset) : void
      {
         if(pendingLoadCallback != null)
         {
            pendingLoadCallback(asset);
         }
         if(assetLoadingComponent != null)
         {
            assetLoadingComponent.RemoveLoader(this);
         }
      }
      
      public function destroy() : void
      {
         pendingLoadCallback = null;
         pendingErrorCallback = null;
         assetLoadingComponent = null;
         assetKey = null;
      }
   }
}

