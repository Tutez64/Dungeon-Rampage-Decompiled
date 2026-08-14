package GameMasterDictionary
{
   public class GMBuffColorType
   {
      
      public var Id:uint;
      
      public var ColorHex:uint;
      
      public function GMBuffColorType(jsonAsset:Object)
      {
         super();
         Id = jsonAsset.Id;
         ColorHex = jsonAsset.TextColor;
      }
   }
}

