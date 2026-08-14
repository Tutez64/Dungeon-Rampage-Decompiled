package GameMasterDictionary
{
   public class GMLegendaryModifier extends GMItem
   {
      
      public var IconName:String;
      
      public var Description:String;
      
      public function GMLegendaryModifier(jsonAsset:Object)
      {
         super(jsonAsset);
         IconName = jsonAsset.IconName;
         Description = jsonAsset.Description;
      }
   }
}

