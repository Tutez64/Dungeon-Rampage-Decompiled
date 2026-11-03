package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMProp extends GMItem
   {
      
      public var TileTheme:String;
      
      public var SwfFilepath:String;
      
      public var PropType:String;
      
      public var DefaultLayer:String;
      
      public var AssetClassName:String;
      
      public var ArchwayAlpha:Boolean;
      
      public function GMProp(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            PropType = jsonAsset.PropType;
            AssetClassName = jsonAsset.AssetClassName;
            SwfFilepath = jsonAsset.SwfFilepath;
            DefaultLayer = jsonAsset.DefaultLayer;
            ArchwayAlpha = Boolean(jsonAsset.ArchwayAlpha) == true;
            TileTheme = jsonAsset.TileTheme;
         }
      }
   }
}

