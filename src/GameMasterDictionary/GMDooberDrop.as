package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMDooberDrop extends GMItem
   {
      
      public var WOLF_PET:Boolean;
      
      public var WARCOW_PET:Boolean;
      
      public var SKELETON_WARRIOR:Boolean;
      
      public var SKELETON_ARCHER:Boolean;
      
      public var KNIGHT:Boolean;
      
      public var DEMON_PET:Boolean;
      
      public var CASTLE_SPIKES:Boolean;
      
      public var CASTLE_KINGSTATUE:Boolean;
      
      public var CASTLE_FLAG:Boolean;
      
      public var CASTLE_BOX:Boolean;
      
      public var CASTLE_BARREL:Boolean;
      
      public var BRUTE:Boolean;
      
      public function GMDooberDrop(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            BRUTE = Boolean(jsonAsset.BRUTE);
            SKELETON_WARRIOR = Boolean(jsonAsset.SKELETON_WARRIOR);
            SKELETON_ARCHER = Boolean(jsonAsset.SKELETON_ARCHER);
            KNIGHT = Boolean(jsonAsset.KNIGHT);
            CASTLE_BARREL = Boolean(jsonAsset.CASTLE_BARREL);
            CASTLE_BOX = Boolean(jsonAsset.CASTLE_BOX);
            CASTLE_SPIKES = Boolean(jsonAsset.CASTLE_SPIKES);
            CASTLE_KINGSTATUE = Boolean(jsonAsset.CASTLE_KINGSTATUE);
            CASTLE_FLAG = Boolean(jsonAsset.CASTLE_FLAG);
            WOLF_PET = Boolean(jsonAsset.WOLF_PET);
            WARCOW_PET = Boolean(jsonAsset.WARCOW_PET);
            DEMON_PET = Boolean(jsonAsset.DEMON_PET);
         }
      }
   }
}

