package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMHints
   {
      
      public var Type:String;
      
      public var MinLevel:uint;
      
      public var MaxLevel:uint;
      
      public var HintText:String;
      
      public var Constant:String;
      
      public function GMHints(jsonAsset:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         Constant = jsonAsset.Constant;
         MinLevel = uint(jsonAsset.MinLevel);
         MaxLevel = uint(jsonAsset.MaxLevel);
         Type = jsonAsset.Type;
         HintText = jsonAsset.HintText;
      }
   }
}

