package GameMasterDictionary
{
   public class GMProp extends GMItem
   {
      
      public var PropType:String;
      
      public var AssetClassName:String;
      
      public var SwfFilepath:String;
      
      public var DefaultLayer:String;
      
      public var ArchwayAlpha:Boolean;
      
      public var TileTheme:String;
      
      public function GMProp(jsonAsset:Object)
      {
         super(jsonAsset);
         PropType = jsonAsset.PropType;
         AssetClassName = jsonAsset.AssetClassName;
         SwfFilepath = jsonAsset.SwfFilepath;
         DefaultLayer = jsonAsset.DefaultLayer;
         ArchwayAlpha = jsonAsset.ArchwayAlpha == true;
         TileTheme = jsonAsset.TileTheme;
      }
   }
}

