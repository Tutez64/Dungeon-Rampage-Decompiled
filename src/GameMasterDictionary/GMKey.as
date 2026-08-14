package GameMasterDictionary
{
   public class GMKey
   {
      
      public var OfferId:uint;
      
      public var ChestId:uint;
      
      public function GMKey(jsonAsset:Object)
      {
         super();
         OfferId = jsonAsset.OfferId;
         ChestId = jsonAsset.ChestId;
      }
   }
}

