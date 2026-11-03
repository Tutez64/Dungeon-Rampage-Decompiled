package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMBuffColorType
   {
      
      public var Id:uint;
      
      public var ColorHex:uint;
      
      public function GMBuffColorType(jsonAsset:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         Id = uint(jsonAsset.Id);
         ColorHex = uint(jsonAsset.TextColor);
      }
   }
}

