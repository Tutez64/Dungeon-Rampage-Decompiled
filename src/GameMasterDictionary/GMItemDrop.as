package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMItemDrop extends GMItem
   {
      
      public var Frostgard_Tier7:Boolean;
      
      public var Frostgard_Tier6:Boolean;
      
      public var Frostgard_Tier5:Boolean;
      
      public var Frostgard_Tier4:Boolean;
      
      public var Frostgard_Tier3:Boolean;
      
      public var Frostgard_Tier2:Boolean;
      
      public var Frostgard_Tier1:Boolean;
      
      public var Forbidden_Pagoda_Tier7:Boolean;
      
      public var Forbidden_Pagoda_Tier6:Boolean;
      
      public var Forbidden_Pagoda_Tier5:Boolean;
      
      public var Forbidden_Pagoda_Tier4:Boolean;
      
      public var Forbidden_Pagoda_Tier3:Boolean;
      
      public var Forbidden_Pagoda_Tier2:Boolean;
      
      public var Forbidden_Pagoda_Tier1:Boolean;
      
      public var Everywhere:Boolean;
      
      public var Cretaceous_Park_Tier7:Boolean;
      
      public var Cretaceous_Park_Tier6:Boolean;
      
      public var Cretaceous_Park_Tier5:Boolean;
      
      public var Cretaceous_Park_Tier4:Boolean;
      
      public var Cretaceous_Park_Tier3:Boolean;
      
      public var Cretaceous_Park_Tier2:Boolean;
      
      public var Cretaceous_Park_Tier1:Boolean;
      
      public function GMItemDrop(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
         }
      }
   }
}

