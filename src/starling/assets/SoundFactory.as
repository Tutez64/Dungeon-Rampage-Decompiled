package starling.assets
{
   import flash.media.Sound;
   import flash.utils.ByteArray;
   import starling.utils.ByteArrayUtil;
   
   public class SoundFactory extends AssetFactory
   {
      
      private static const MAGIC_NUMBERS_A:Array = [255,251];
      
      private static const MAGIC_NUMBERS_B:Array = [73,68,51];
      
      public function SoundFactory()
      {
         super();
         addMimeTypes("audio/mp3","audio/mpeg3","audio/mpeg");
         addExtensions("mp3");
      }
      
      override public function canHandle(reference:AssetReference) : Boolean
      {
         var _loc2_:ByteArray = null;
         if(reference.data is Sound || Boolean(super.canHandle(reference)))
         {
            return true;
         }
         if(reference.data is ByteArray)
         {
            _loc2_ = reference.data as ByteArray;
            return ByteArrayUtil.startsWithBytes(_loc2_,MAGIC_NUMBERS_A) || ByteArrayUtil.startsWithBytes(_loc2_,MAGIC_NUMBERS_B);
         }
         return false;
      }
      
      override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:Function, onError:Function) : void
      {
         var _loc6_:Sound = reference.data as Sound;
         var _loc5_:ByteArray = reference.data as ByteArray;
         if(_loc5_)
         {
            try
            {
               _loc6_ = new Sound();
               _loc6_.loadCompressedDataFromByteArray(_loc5_,_loc5_.length);
            }
            catch(e:Error)
            {
               onError("Could not load sound data: " + e.message);
               return;
            }
         }
         onComplete(reference.name,_loc6_);
      }
   }
}

