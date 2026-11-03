package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMLegendaryModifier extends GMItem
   {
      
      public var IconName:String;
      
      public var Description:String;
      
      public function GMLegendaryModifier(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            IconName = jsonAsset.IconName;
            Description = jsonAsset.Description;
         }
      }
   }
}

