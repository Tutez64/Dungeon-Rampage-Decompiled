package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMKey
   {
      
      public var OfferId:uint;
      
      public var ChestId:uint;
      
      public function GMKey(jsonAsset:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         OfferId = uint(jsonAsset.OfferId);
         ChestId = uint(jsonAsset.ChestId);
      }
   }
}

