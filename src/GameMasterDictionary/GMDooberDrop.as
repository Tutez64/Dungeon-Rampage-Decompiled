package GameMasterDictionary
{
   public class GMDooberDrop extends GMItem
   {
      
      public var BRUTE:Boolean;
      
      public var SKELETON_WARRIOR:Boolean;
      
      public var SKELETON_ARCHER:Boolean;
      
      public var KNIGHT:Boolean;
      
      public var CASTLE_BARREL:Boolean;
      
      public var CASTLE_BOX:Boolean;
      
      public var CASTLE_SPIKES:Boolean;
      
      public var CASTLE_KINGSTATUE:Boolean;
      
      public var CASTLE_FLAG:Boolean;
      
      public var WOLF_PET:Boolean;
      
      public var WARCOW_PET:Boolean;
      
      public var DEMON_PET:Boolean;
      
      public function GMDooberDrop(jsonAsset:Object)
      {
         super(jsonAsset);
         BRUTE = jsonAsset.BRUTE;
         SKELETON_WARRIOR = jsonAsset.SKELETON_WARRIOR;
         SKELETON_ARCHER = jsonAsset.SKELETON_ARCHER;
         KNIGHT = jsonAsset.KNIGHT;
         CASTLE_BARREL = jsonAsset.CASTLE_BARREL;
         CASTLE_BOX = jsonAsset.CASTLE_BOX;
         CASTLE_SPIKES = jsonAsset.CASTLE_SPIKES;
         CASTLE_KINGSTATUE = jsonAsset.CASTLE_KINGSTATUE;
         CASTLE_FLAG = jsonAsset.CASTLE_FLAG;
         WOLF_PET = jsonAsset.WOLF_PET;
         WARCOW_PET = jsonAsset.WARCOW_PET;
         DEMON_PET = jsonAsset.DEMON_PET;
      }
   }
}

