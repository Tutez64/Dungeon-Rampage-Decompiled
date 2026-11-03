package Combat.Weapon
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.AssetRepository.StarlingAssetMapper;
   import Brain.GameObject.GameObject;
   import Brain.Utils.MemoryTracker;
   import Collections.Map;
   import Combat.Attack.AttackTimeline;
   import DistributedObjects.DistributedDungeonFloor;
   import DistributedObjects.NPCGameObject;
   import Effects.EffectGameObject;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   import GameMasterDictionary.GMLegendaryModifier;
   import GameMasterDictionary.GMModifier;
   import GameMasterDictionary.GMProjectile;
   import GameMasterDictionary.GMRarity;
   import GameMasterDictionary.GMWeaponAesthetic;
   import GameMasterDictionary.GMWeaponItem;
   import GeneratedCode.WeaponDetails;
   
   public class WeaponGameObject extends GameObject
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mActorGameObject:ActorGameObject;
      
      protected var mActorView:ActorView;
      
      protected var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      protected var mAttackTimelineMap:Map;
      
      protected var mWeaponDetails:WeaponDetails;
      
      protected var mGMWeapon:GMWeaponItem;
      
      protected var mGMRarity:GMRarity;
      
      protected var mSlot:Number;
      
      private var mAttackSpeedModifier:Vector.<Number>;
      
      private var mManaModifier:Number = 1;
      
      private var mChains:Number = 0;
      
      private var mPierces:Number = 0;
      
      private var mCooldownReduction:Number = 1;
      
      private var mChargeReduction:Number = 1;
      
      private var mCollisionScale:Number = 1;
      
      private var mPreloadedEffectKeys:Object = {};
      
      protected var mWeaponView:WeaponView;
      
      protected var mModifiers:Vector.<GMModifier>;
      
      protected var mLegendaryModifier:GMLegendaryModifier;
      
      protected var mWeaponAesthetic:GMWeaponAesthetic;
      
      public function WeaponGameObject(weaponDetails:WeaponDetails, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, slot:Number)
      {
         super(dbFacade);
         mSlot = slot;
         mDBFacade = dbFacade;
         mAttackSpeedModifier = new Vector.<Number>();
         mAttackSpeedModifier.push(1);
         mAttackSpeedModifier.push(1);
         mAttackSpeedModifier.push(1);
         mWeaponDetails = weaponDetails;
         mGMRarity = mDBFacade.gameMaster.rarityById.itemFor(mWeaponDetails.rarity);
         mActorGameObject = actorGameObject;
         mModifiers = new Vector.<GMModifier>();
         if(mWeaponDetails.modifier1 > 0)
         {
            mModifiers.push(mDBFacade.gameMaster.modifiersById.itemFor(mWeaponDetails.modifier1));
         }
         if(mWeaponDetails.modifier2 > 0)
         {
            mModifiers.push(mDBFacade.gameMaster.modifiersById.itemFor(mWeaponDetails.modifier2));
         }
         if(mWeaponDetails.legendarymodifier > 0)
         {
            mLegendaryModifier = mDBFacade.gameMaster.legendaryModifiersById.itemFor(mWeaponDetails.legendarymodifier);
         }
         updateStatsForModifiers();
         updateStatsForLegendaryModifier();
         mGMWeapon = mDBFacade.gameMaster.weaponItemById.itemFor(mWeaponDetails.type);
         mActorView = actorView;
         mDistributedDungeonFloor = distributedDungeonFloor;
         mAttackTimelineMap = new Map();
         mWeaponAesthetic = mGMWeapon.getWeaponAesthetic(requiredLevel,mLegendaryModifier != null);
         mWeaponView = new WeaponView(mDBFacade,this);
         MemoryTracker.track(mWeaponView,"WeaponView - created in WeaponGameObject.constructor()");
         preloadProjectileAssets();
      }
      
      protected function preloadProjectileAssets() : void
      {
         if(mDBFacade.assetLoadingComponent == null || mDBFacade.starlingLayerManager == null)
         {
            return;
         }
         for each(var _loc1_:String in mGMWeapon.AttackArray)
         {
            if(_loc1_ == null)
            {
               break;
            }
            preloadProjectileAssetsForAttackConstant(_loc1_);
         }
         if(mGMWeapon.HoldingAttack)
         {
            preloadProjectileAssetsForAttackConstant(mGMWeapon.HoldingAttack);
         }
         if(mGMWeapon.ChargeAttack)
         {
            preloadProjectileAssetsForAttackConstant(mGMWeapon.ChargeAttack);
         }
      }
      
      protected function preloadProjectileAssetsForAttackConstant(attackConstant:String) : void
      {
         var _loc2_:GMAttack = mDBFacade.gameMaster.attackByConstant.itemFor(attackConstant);
         if(_loc2_ == null)
         {
            return;
         }
         preloadProjectileAssetsForAttack(_loc2_);
      }
      
      protected function preloadProjectileAssetsForAttack(gmAttack:GMAttack) : void
      {
         var _loc3_:GMProjectile = null;
         if(gmAttack.Projectile)
         {
            _loc3_ = mDBFacade.gameMaster.projectileByConstant.itemFor(gmAttack.Projectile);
            if(_loc3_ != null && _loc3_.SwfFilepath)
            {
               mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(DBFacade.buildFullDownloadPath(_loc3_.SwfFilepath),null,false,isBackgroundLoad,backgroundLoadTier);
            }
         }
         if(mDBFacade.timelineFactory == null)
         {
            return;
         }
         var _loc4_:Object = mDBFacade.timelineFactory.getTimelineJson(gmAttack.AttackTimeline);
         if(_loc4_ == null || _loc4_.frames == null)
         {
            return;
         }
         for each(var _loc5_:Object in _loc4_.frames)
         {
            for each(var _loc2_:Object in _loc5_.actions)
            {
               if(_loc2_ != null)
               {
                  if(_loc2_.attackEffectPath && _loc2_.attackEffectName)
                  {
                     queueEffectAtlas(DBFacade.buildFullDownloadPath(_loc2_.attackEffectPath),_loc2_.attackEffectName);
                  }
                  if((_loc2_.type == "effect" || _loc2_.type == "attackEffect") && _loc2_.path && _loc2_.name)
                  {
                     preloadEffectAsset(_loc2_);
                  }
               }
            }
         }
      }
      
      private function preloadEffectAsset(action:Object) : void
      {
         var effectName:String;
         var fullPath:String = DBFacade.buildFullDownloadPath(action.path);
         var poolKey:String = fullPath + ":" + action.name;
         if(mPreloadedEffectKeys[poolKey])
         {
            return;
         }
         mPreloadedEffectKeys[poolKey] = true;
         if(action.managed)
         {
            queueEffectAtlas(fullPath,action.name);
            return;
         }
         effectName = action.name;
         queueEffectAtlas(fullPath,effectName,function():void
         {
            prewarmEffectPool(fullPath,effectName);
         });
      }
      
      private function queueEffectAtlas(fullPath:String, effectName:String, onComplete:Function = null) : void
      {
         if(StarlingAssetMapper.isPropLibraryPath(fullPath))
         {
            mDBFacade.assetLoadingComponent.queueStarlingAssetsForProps(fullPath,[effectName],onComplete,isBackgroundLoad,backgroundLoadTier);
         }
         else
         {
            mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(fullPath,onComplete,false,isBackgroundLoad,backgroundLoadTier);
         }
      }
      
      private function get isBackgroundLoad() : Boolean
      {
         return mActorGameObject != null && mActorGameObject.belongsToRemotePlayer;
      }
      
      private function get backgroundLoadTier() : int
      {
         return mActorGameObject is NPCGameObject ? 4 : 2;
      }
      
      private function prewarmEffectPool(swfPath:String, className:String) : void
      {
         if(className.indexOf("_angle") >= 0)
         {
            return;
         }
         if(mDBFacade == null || mDBFacade.effectPool == null)
         {
            return;
         }
         var _loc3_:EffectGameObject = mDBFacade.effectPool.checkout(mDBFacade,swfPath,className,null,null) as EffectGameObject;
         if(_loc3_ != null)
         {
            mDBFacade.effectPool.checkin(_loc3_);
         }
      }
      
      public function updateStatsForModifiers() : void
      {
         for each(var _loc1_:GMModifier in mModifiers)
         {
            mAttackSpeedModifier[0] *= _loc1_.MELEE_SPD;
            mAttackSpeedModifier[1] *= _loc1_.SHOOT_SPD;
            mAttackSpeedModifier[2] *= _loc1_.MAGIC_SPD;
            mManaModifier *= _loc1_.MP_COST;
            mChains += _loc1_.CHAIN;
            mPierces += _loc1_.PIERCE;
            mCooldownReduction *= _loc1_.COOLDOWN_REDUC;
            mChargeReduction *= _loc1_.CHARGE_REDUC;
            mCollisionScale *= _loc1_.INCREASE_COLLISION;
         }
      }
      
      public function updateStatsForLegendaryModifier() : void
      {
         if(!mLegendaryModifier)
         {
         }
      }
      
      public function finalWeaponSpeedWithModifiers(speedModifierIndex:int) : Number
      {
         return attackSpeedModifier(speedModifierIndex) * this.weaponData.Speed;
      }
      
      public function attackSpeedModifier(index:int) : Number
      {
         if(index >= 0 && index < 3)
         {
            return mAttackSpeedModifier[index];
         }
         return 1;
      }
      
      public function get manaCostModifier() : Number
      {
         return mManaModifier;
      }
      
      public function get weaponView() : WeaponView
      {
         return mWeaponView;
      }
      
      public function get actorGameObject() : ActorGameObject
      {
         return mActorGameObject;
      }
      
      public function get weaponData() : GMWeaponItem
      {
         return mGMWeapon;
      }
      
      public function get weaponAesthetic() : GMWeaponAesthetic
      {
         return mWeaponAesthetic;
      }
      
      public function get modifierList() : Vector.<GMModifier>
      {
         return mModifiers;
      }
      
      public function get legendaryModifier() : GMLegendaryModifier
      {
         return mLegendaryModifier;
      }
      
      public function get name() : String
      {
         return mWeaponAesthetic.Name;
      }
      
      override public function destroy() : void
      {
         mDBFacade = null;
         mActorGameObject = null;
         mActorView = null;
         mDistributedDungeonFloor = null;
         mGMWeapon = null;
         mAttackTimelineMap.clear();
         mAttackTimelineMap = null;
         mPreloadedEffectKeys = null;
         mWeaponView.destroy();
         mWeaponView = null;
         mModifiers = null;
         super.destroy();
      }
      
      public function get weaponType() : uint
      {
         return mWeaponDetails.type;
      }
      
      public function get power() : uint
      {
         return mWeaponDetails.power;
      }
      
      public function get slot() : int
      {
         return this.mSlot;
      }
      
      public function get requiredLevel() : int
      {
         return mWeaponDetails.requiredlevel;
      }
      
      public function get rarity() : int
      {
         return mWeaponDetails.rarity;
      }
      
      public function get gmRarity() : GMRarity
      {
         return mGMRarity;
      }
      
      public function chains() : Number
      {
         return mChains;
      }
      
      public function pierces() : Number
      {
         return mPierces;
      }
      
      public function cooldownReduction() : Number
      {
         return mCooldownReduction;
      }
      
      public function chargeReduction() : Number
      {
         return mChargeReduction;
      }
      
      public function collisionScale() : Number
      {
         return mCollisionScale;
      }
      
      public function getAttackTimeline(attackType:uint) : AttackTimeline
      {
         var _loc2_:String = findTimelineNameFromAttackType(attackType);
         var _loc3_:AttackTimeline = mAttackTimelineMap.itemFor(_loc2_);
         if(!_loc3_)
         {
            _loc3_ = mDBFacade.timelineFactory.createAttackTimeline(_loc2_,this,mActorGameObject,mDistributedDungeonFloor);
            mAttackTimelineMap.add(_loc2_,_loc3_);
         }
         return _loc3_;
      }
      
      protected function findTimelineNameFromAttackType(attackType:uint) : String
      {
         var _loc2_:GMAttack = mDBFacade.gameMaster.attackById.itemFor(attackType);
         if(_loc2_ == null)
         {
            return "";
         }
         return _loc2_.AttackTimeline;
      }
      
      public function isConsumable() : Boolean
      {
         return false;
      }
   }
}

