package Brain.AssetRepository
{
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.core.SetIterator;
   
   public class ActiveLoadBase
   {
      
      public var mPendingSuccessCallback:Set;
      
      public var mPendingErrorCallbacks:Set;
      
      public var mInfo:AssetLoaderInfo;
      
      public var mAssetRepository:AssetRepository;
      
      public function ActiveLoadBase(assetRepository:AssetRepository, info:AssetLoaderInfo)
      {
         super();
         mPendingErrorCallbacks = new Set();
         mPendingSuccessCallback = new Set();
         mInfo = info;
         mAssetRepository = assetRepository;
      }
      
      public function AddCallback(success:Function, failure:Function) : void
      {
         if(success != null)
         {
            mPendingSuccessCallback.add(success);
         }
         if(failure != null)
         {
            mPendingErrorCallbacks.add(failure);
         }
      }
      
      public function removeCallback(success:Function, failure:Function) : Boolean
      {
         var _loc3_:Boolean = false;
         if(success != null)
         {
            _loc3_ = mPendingSuccessCallback.remove(success);
         }
         if(failure != null)
         {
            _loc3_ ||= mPendingErrorCallbacks.remove(failure);
         }
         return _loc3_;
      }
      
      public function hasNoCallbacks() : Boolean
      {
         return mPendingSuccessCallback.size != 0 || mPendingErrorCallbacks.size != 0;
      }
      
      public function executeErrorCallbacks(assetLoaderInfo:AssetLoaderInfo) : void
      {
         var _loc3_:Function = null;
         var _loc2_:SetIterator = mPendingErrorCallbacks.iterator() as SetIterator;
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next();
            if(_loc3_ != null)
            {
               _loc3_();
            }
         }
         mPendingErrorCallbacks.clear();
      }
      
      public function executeSucessCallbacks(assetLoaderInfo:AssetLoaderInfo, asset:Asset) : void
      {
         var _loc4_:Function = null;
         var _loc3_:SetIterator = mPendingSuccessCallback.iterator() as SetIterator;
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            if(_loc4_ != null)
            {
               _loc4_(asset);
            }
         }
         mPendingSuccessCallback.clear();
      }
      
      public function destroy() : void
      {
         mPendingSuccessCallback.clear();
         mPendingErrorCallbacks.clear();
         mAssetRepository = null;
         mInfo = null;
      }
   }
}

