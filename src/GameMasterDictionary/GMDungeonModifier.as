package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMDungeonModifier
   {
      
      public var Name:String;
      
      public var NPCSpawnId:uint;
      
      public var NPCDeathSpawnMinCount:uint;
      
      public var NPCDeathSpawnMaxGeneration:uint;
      
      public var NPCDeathSpawnMaxCount:uint;
      
      public var NPCDeathSpawnId:uint;
      
      public var NPCDeathSpawnCharType:String;
      
      public var NPCDeathSpawnChance:Number;
      
      public var IsPlayerBuff:Boolean;
      
      public var Id:uint;
      
      public var IconName:String;
      
      public var IconFilepath:String;
      
      public var Description:String;
      
      public var Constant:String;
      
      public var BuffId:uint;
      
      public function GMDungeonModifier(jsonAsset:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         Id = uint(jsonAsset.Id);
         Constant = jsonAsset.Constant;
         Name = jsonAsset.Name;
         Description = jsonAsset.Description;
         BuffId = uint(jsonAsset.BuffId);
         IsPlayerBuff = Boolean(jsonAsset.IsPlayerBuff);
         NPCSpawnId = uint(jsonAsset.NPCSpawnId);
         NPCDeathSpawnId = uint(jsonAsset.NPCDeathSpawnId);
         NPCDeathSpawnCharType = jsonAsset.NPCDeathSpawnCharType;
         NPCDeathSpawnMaxGeneration = uint(jsonAsset.NPCDeathSpawnMaxGeneration);
         NPCDeathSpawnChance = Number(jsonAsset.NPCDeathSpawnChance);
         NPCDeathSpawnMinCount = uint(jsonAsset.NPCDeathSpawnMinCount);
         NPCDeathSpawnMaxCount = uint(jsonAsset.NPCDeathSpawnMaxCount);
         IconFilepath = jsonAsset.IconFilepath;
         IconName = jsonAsset.IconName;
      }
   }
}

