package starling.assets
{
   import flash.utils.ByteArray;
   import starling.textures.AtfData;
   import starling.textures.Texture;
   import starling.utils.execute;
   
   public class AtfTextureFactory extends AssetFactory
   {
      
      public function AtfTextureFactory()
      {
         super();
         addExtensions("atf");
      }
      
      override public function canHandle(reference:AssetReference) : Boolean
      {
         return reference.data is ByteArray && AtfData.isAtfData(reference.data as ByteArray);
      }
      
      override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:Function, onError:Function) : void
      {
         var createTexture:* = function():void
         {
            var texture:Texture;
            var url:String;
            var onReady:Function = reference.textureOptions.onReady as Function;
            reference.textureOptions.onReady = function():void
            {
               execute(onReady,texture);
               onComplete(reference.name,texture);
            };
            texture = null;
            url = reference.url;
            try
            {
               texture = Texture.fromData(reference.data,reference.textureOptions);
            }
            catch(e:Error)
            {
               onError(e.message);
            }
            if(url && texture)
            {
               texture.root.onRestore = function():void
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
            }
            reference.data = null;
         };
         var onReloadError:* = function(param1:String):void
         {
            helper.log("Texture restoration failed for " + reference.url + ". " + param1);
            helper.onEndRestore();
         };
         helper.executeWhenContextReady(createTexture);
      }
   }
}

