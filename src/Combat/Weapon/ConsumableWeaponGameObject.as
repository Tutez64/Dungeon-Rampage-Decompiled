package Combat.Weapon
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import DistributedObjects.DistributedDungeonFloor;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   import GameMasterDictionary.GMStackable;
   import GeneratedCode.ConsumableDetails;
   import GeneratedCode.WeaponDetails;
   
   public class ConsumableWeaponGameObject extends WeaponGameObject
   {
      
      public static const HEALTH_POTION_ID:uint = 70000;
      
      public static const MANA_POTION_ID:uint = 70002;
      
      public static const BUSTER_POTION_ID:uint = 70009;
      
      public static const HEALTH_SHOT_ID:uint = 70016;
      
      public static const MANA_SHOT_ID:uint = 70017;
      
      public static const BUSTER_SHOT_ID:uint = 70018;
      
      private var mDefaultWeaponDetails:WeaponDetails = new WeaponDetails();
      
      private var mConsumableDetails:ConsumableDetails;
      
      private var mConsumableAttack:GMAttack;
      
      private var mGMStackable:GMStackable;
      
      public function ConsumableWeaponGameObject(consumableDetails:ConsumableDetails, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, slot:Number)
      {
         mConsumableDetails = consumableDetails;
         mDefaultWeaponDetails.type = 40000;
         mDefaultWeaponDetails.rarity = 0;
         mDefaultWeaponDetails.requiredlevel = 1;
         mDefaultWeaponDetails.power = 1;
         mDefaultWeaponDetails.modifier1 = 0;
         mDefaultWeaponDetails.modifier2 = 0;
         mDefaultWeaponDetails.legendarymodifier = 0;
         super(mDefaultWeaponDetails,actorGameObject,actorView,dbFacade,distributedDungeonFloor,slot);
         mGMStackable = mDBFacade.gameMaster.stackableById.itemFor(mConsumableDetails.type);
         mConsumableAttack = mDBFacade.gameMaster.attackByConstant.itemFor(mGMStackable.UsageAttack);
      }
      
      override public function destroy() : void
      {
         mConsumableDetails = null;
         mDefaultWeaponDetails = null;
         mGMStackable = null;
         mConsumableAttack = null;
         super.destroy();
      }
      
      public function getConsumableAttack() : GMAttack
      {
         return mConsumableAttack;
      }
      
      public function getConsumableCount() : uint
      {
         return mConsumableDetails.count;
      }
      
      public function consume() : void
      {
         mConsumableDetails.count--;
         mDBFacade.hud.decrementConsumableCount(slot);
         if(mDBFacade.steamAchievementsManager)
         {
            mDBFacade.steamAchievementsManager.setAchievement("USE_CONSUMABLE_FIRST_TIME");
         }
         if(mConsumableDetails.count == 0)
         {
            mDBFacade.hud.totalConsumableCountReached(slot);
         }
      }
      
      public function canExecute() : Boolean
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(actorGameObject.isOwner)
         {
            _loc1_ = actorGameObject as HeroGameObjectOwner;
            switch(int(mConsumableDetails.type) - 70000)
            {
               case 0:
                  mDBFacade.hud.showText("AT_MAX_HEALTH");
                  return _loc1_.hitPoints < _loc1_.maxHitPoints;
               case 2:
                  mDBFacade.hud.showText("AT_MAX_MANA");
                  return _loc1_.manaPoints < _loc1_.maxManaPoints;
               case 9:
                  mDBFacade.hud.showText("AT_MAX_DUNGEON_BUSTER");
                  return _loc1_.dungeonBusterPoints < _loc1_.maxBusterPoints;
               case 16:
                  mDBFacade.hud.showText("AT_MAX_HEALTH");
                  return _loc1_.hitPoints < _loc1_.maxHitPoints;
               case 17:
                  mDBFacade.hud.showText("AT_MAX_MANA");
                  return _loc1_.manaPoints < _loc1_.maxManaPoints;
               case 18:
                  mDBFacade.hud.showText("AT_MAX_DUNGEON_BUSTER");
                  return _loc1_.dungeonBusterPoints < _loc1_.maxBusterPoints;
            }
         }
         return true;
      }
      
      public function getGMStackable() : GMStackable
      {
         return mGMStackable;
      }
      
      override public function isConsumable() : Boolean
      {
         return true;
      }
   }
}

