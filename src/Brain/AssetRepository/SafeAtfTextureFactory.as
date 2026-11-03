package Brain.AssetRepository
{
   import flash.display3D.textures.TextureBase;
   import flash.events.ErrorEvent;
   import flash.utils.ByteArray;
   import starling.assets.AssetFactoryHelper;
   import starling.assets.AssetReference;
   import starling.assets.AtfTextureFactory;
   import starling.textures.Texture;
   import starling.utils.execute;
   
   public class SafeAtfTextureFactory extends AtfTextureFactory
   {
      
      public static const PRIORITY:int = 1;
      
      public function SafeAtfTextureFactory()
      {
         super();
      }
      
      override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:Function, onError:Function) : void
      {
         var createTexture:* = function():void
         {
            var settle:* = function():Boolean
            {
               if(settled)
               {
                  return false;
               }
               settled = true;
               return true;
            };
            var onUploadReady:* = function():void
            {
               base.removeEventListener("error",onUploadError);
               if(settle())
               {
                  execute(onReady,texture);
                  onComplete(reference.name,texture);
               }
               else
               {
                  texture.dispose();
               }
            };
            var onUploadError:* = function(param1:ErrorEvent):void
            {
               base.removeEventListener("error",onUploadError);
               texture.dispose();
               if(settle())
               {
                  onError("Error #" + param1.errorID + ": " + param1.text);
               }
            };
            var restoreTexture:* = function():void
            {
               helper.onBeginRestore();
               helper.loadDataFromUrl(url,function(param1:ByteArray):void
               {
                  var data:ByteArray = param1;
                  helper.executeWhenContextReady(function():void
                  {
                     try
                     {
                        texture.root.uploadAtfData(data);
                     }
                     catch(e:Error)
                     {
                        helper.log("Texture restoration failed: " + e.message);
                     }
                     helper.onEndRestore();
                  });
               },onReloadError);
            };
            var onReloadError:* = function(param1:String):void
            {
               helper.log("Texture restoration failed for " + url + ". " + param1);
               helper.onEndRestore();
            };
            var onReady:Function = reference.textureOptions.onReady as Function;
            var texture:Texture = null;
            var base:TextureBase = null;
            var settled:Boolean = false;
            var url:String = reference.url;
            reference.textureOptions.onReady = onUploadReady;
            try
            {
               texture = Texture.fromData(reference.data,reference.textureOptions);
            }
            catch(e:Error)
            {
               onError(e.message);
            }
            if(texture)
            {
               base = texture.root.base;
               base.addEventListener("error",onUploadError);
               if(url)
               {
                  texture.root.onRestore = restoreTexture;
               }
            }
            reference.data = null;
         };
         helper.executeWhenContextReady(createTexture);
      }
   }
}

