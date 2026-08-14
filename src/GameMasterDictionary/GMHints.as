package GameMasterDictionary
{
   public class GMHints
   {
      
      public var Constant:String;
      
      public var MinLevel:uint;
      
      public var MaxLevel:uint;
      
      public var Type:String;
      
      public var HintText:String;
      
      public function GMHints(jsonAsset:Object)
      {
         super();
         Constant = jsonAsset.Constant;
         MinLevel = jsonAsset.MinLevel;
         MaxLevel = jsonAsset.MaxLevel;
         Type = jsonAsset.Type;
         HintText = jsonAsset.HintText;
      }
   }
}

