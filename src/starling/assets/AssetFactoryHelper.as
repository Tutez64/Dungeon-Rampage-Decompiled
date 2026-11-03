package starling.assets
{
   import starling.utils.SystemUtil;
   
   public class AssetFactoryHelper
   {
      
      private var _dataLoader:DataLoader;
      
      private var _getNameFromUrlFunc:Function;
      
      private var _getExtensionFromUrlFunc:Function;
      
      private var _addPostProcessorFunc:Function;
      
      private var _addAssetFunc:Function;
      
      private var _onRestoreFunc:Function;
      
      private var _logFunc:Function;
      
      public function AssetFactoryHelper()
      {
         super();
      }
      
      public function getNameFromUrl(url:String) : String
      {
         if(_getNameFromUrlFunc != null)
         {
            return _getNameFromUrlFunc(url);
         }
         return "";
      }
      
      public function getExtensionFromUrl(url:String) : String
      {
         if(_getExtensionFromUrlFunc != null)
         {
            return _getExtensionFromUrlFunc(url);
         }
         return "";
      }
      
      public function loadDataFromUrl(url:String, onComplete:Function, onError:Function) : void
      {
         if(_dataLoader)
         {
            _dataLoader.load(url,onComplete,onError);
         }
      }
      
      public function addPostProcessor(processor:Function, priority:int = 0) : void
      {
         if(_addPostProcessorFunc != null)
         {
            _addPostProcessorFunc(processor,priority);
         }
      }
      
      public function onBeginRestore() : void
      {
         if(_onRestoreFunc != null)
         {
            _onRestoreFunc(false);
         }
      }
      
      public function onEndRestore() : void
      {
         if(_onRestoreFunc != null)
         {
            _onRestoreFunc(true);
         }
      }
      
      public function log(message:String) : void
      {
         if(_logFunc != null)
         {
            _logFunc(message);
         }
      }
      
      public function addComplementaryAsset(name:String, asset:Object, type:String = null) : void
      {
         if(_addAssetFunc != null)
         {
            _addAssetFunc(name,asset,type);
         }
      }
      
      public function executeWhenContextReady(call:Function, ... rest) : void
      {
         if(SystemUtil.isDesktop)
         {
            call.apply(this,rest);
         }
         else
         {
            rest.unshift(call);
            SystemUtil.executeWhenApplicationIsActive.apply(this,rest);
         }
      }
      
      internal function set getNameFromUrlFunc(value:Function) : void
      {
         _getNameFromUrlFunc = value;
      }
      
      internal function set getExtensionFromUrlFunc(value:Function) : void
      {
         _getExtensionFromUrlFunc = value;
      }
      
      internal function set dataLoader(value:DataLoader) : void
      {
         _dataLoader = value;
      }
      
      internal function set logFunc(value:Function) : void
      {
         _logFunc = value;
      }
      
      internal function set addAssetFunc(value:Function) : void
      {
         _addAssetFunc = value;
      }
      
      internal function set onRestoreFunc(value:Function) : void
      {
         _onRestoreFunc = value;
      }
      
      internal function set addPostProcessorFunc(value:Function) : void
      {
         _addPostProcessorFunc = value;
      }
   }
}

