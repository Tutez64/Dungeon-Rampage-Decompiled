package GameMasterDictionary
{
   public class GMDungeonModifier
   {
      
      public var Id:uint;
      
      public var Constant:String;
      
      public var Name:String;
      
      public var Description:String;
      
      public var BuffId:uint;
      
      public var IsPlayerBuff:Boolean;
      
      public var NPCSpawnId:uint;
      
      public var NPCDeathSpawnId:uint;
      
      public var NPCDeathSpawnCharType:String;
      
      public var NPCDeathSpawnMaxGeneration:uint;
      
      public var NPCDeathSpawnChance:Number;
      
      public var NPCDeathSpawnMinCount:uint;
      
      public var NPCDeathSpawnMaxCount:uint;
      
      public var IconFilepath:String;
      
      public var IconName:String;
      
      public function GMDungeonModifier(jsonAsset:Object)
      {
         super();
         Id = jsonAsset.Id;
         Constant = jsonAsset.Constant;
         Name = jsonAsset.Name;
         Description = jsonAsset.Description;
         BuffId = jsonAsset.BuffId;
         IsPlayerBuff = jsonAsset.IsPlayerBuff;
         NPCSpawnId = jsonAsset.NPCSpawnId;
         NPCDeathSpawnId = jsonAsset.NPCDeathSpawnId;
         NPCDeathSpawnCharType = jsonAsset.NPCDeathSpawnCharType;
         NPCDeathSpawnMaxGeneration = jsonAsset.NPCDeathSpawnMaxGeneration;
         NPCDeathSpawnChance = jsonAsset.NPCDeathSpawnChance;
         NPCDeathSpawnMinCount = jsonAsset.NPCDeathSpawnMinCount;
         NPCDeathSpawnMaxCount = jsonAsset.NPCDeathSpawnMaxCount;
         IconFilepath = jsonAsset.IconFilepath;
         IconName = jsonAsset.IconName;
      }
   }
}

