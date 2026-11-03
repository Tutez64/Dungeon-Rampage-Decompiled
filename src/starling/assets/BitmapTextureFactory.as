package starling.assets
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.IOErrorEvent;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import starling.textures.Texture;
   import starling.textures.TextureOptions;
   import starling.utils.ByteArrayUtil;
   import starling.utils.execute;
   
   public class BitmapTextureFactory extends AssetFactory
   {
      
      private static const MAGIC_NUMBERS_JPG:Array = [255,216];
      
      private static const MAGIC_NUMBERS_PNG:Array = [137,80,78,71,13,10,26,10];
      
      private static const MAGIC_NUMBERS_GIF:Array = [71,73,70,56];
      
      public function BitmapTextureFactory()
      {
         super();
         addMimeTypes("image/png","image/jpg","image/jpeg","image/gif");
         addExtensions("png","jpg","jpeg","gif");
      }
      
      override public function canHandle(reference:AssetReference) : Boolean
      {
         var _loc2_:ByteArray = null;
         if(super.canHandle(reference) || reference.data is Bitmap || reference.data is BitmapData)
         {
            return true;
         }
         if(reference.data is ByteArray)
         {
            _loc2_ = reference.data as ByteArray;
            return ByteArrayUtil.startsWithBytes(_loc2_,MAGIC_NUMBERS_PNG) || ByteArrayUtil.startsWithBytes(_loc2_,MAGIC_NUMBERS_JPG) || ByteArrayUtil.startsWithBytes(_loc2_,MAGIC_NUMBERS_GIF);
         }
         return false;
      }
      
      override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:Function, onError:Function) : void
      {
         var onBitmapDataCreated:* = function(param1:BitmapData):void
         {
            helper.executeWhenContextReady(createFromBitmapData,param1);
         };
         var createFromBitmapData:* = function(param1:BitmapData):void
         {
            options.onReady = complete;
            try
            {
               texture = Texture.fromData(param1,options);
            }
            catch(e:Error)
            {
               onError(e.message);
            }
            if(texture && url)
            {
               texture.root.onRestore = restoreTexture;
            }
         };
         var complete:* = function():void
         {
            execute(onReady,texture);
            onComplete(name,texture);
         };
         var restoreTexture:* = function():void
         {
            helper.onBeginRestore();
            reload(url,function(param1:BitmapData):void
            {
               var bitmapData:BitmapData = param1;
               helper.executeWhenContextReady(function():void
               {
                  try
                  {
                     texture.root.uploadBitmapData(bitmapData);
                  }
                  catch(e:Error)
                  {
                     helper.log("Texture restoration failed: " + e.message);
                  }
                  helper.onEndRestore();
               });
            });
         };
         var reload:* = function(param1:String, param2:Function):void
         {
            var url:String = param1;
            var onComplete:Function = param2;
            helper.loadDataFromUrl(url,function(param1:ByteArray):void
            {
               createBitmapDataFromByteArray(param1,onComplete,onReloadError);
            },onReloadError);
         };
         var onReloadError:* = function(param1:String):void
         {
            helper.log("Texture restoration failed for " + url + ". " + param1);
            helper.onEndRestore();
         };
         var texture:Texture = null;
         var url:String = reference.url;
         var data:Object = reference.data;
         var name:String = reference.name;
         var options:TextureOptions = reference.textureOptions;
         var onReady:Function = reference.textureOptions.onReady as Function;
         if(data is Bitmap)
         {
            onBitmapDataCreated((data as Bitmap).bitmapData);
         }
         else if(data is BitmapData)
         {
            onBitmapDataCreated(data as BitmapData);
         }
         else if(data is ByteArray)
         {
            createBitmapDataFromByteArray(data as ByteArray,onBitmapDataCreated,onError);
         }
         reference.data = data = null;
      }
      
      protected function createBitmapDataFromByteArray(data:ByteArray, onComplete:Function, onError:Function) : void
      {
         var loaderContext:LoaderContext;
         var onIoError:* = function(param1:IOErrorEvent):void
         {
            cleanup();
            execute(onError,param1.text);
         };
         var onLoaderComplete:* = function(param1:Object):void
         {
            complete(param1.target.content.bitmapData);
         };
         var complete:* = function(param1:BitmapData):void
         {
            cleanup();
            execute(onComplete,param1);
         };
         var cleanup:* = function():void
         {
            loaderInfo.removeEventListener("ioError",onIoError);
            loaderInfo.removeEventListener("complete",onLoaderComplete);
         };
         var loader:Loader = new Loader();
         var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
         loaderInfo.addEventListener("ioError",onIoError);
         loaderInfo.addEventListener("complete",onLoaderComplete);
         loaderContext = new LoaderContext();
         loaderContext.imageDecodingPolicy = "onLoad";
         loader.loadBytes(data,loaderContext);
      }
   }
}

