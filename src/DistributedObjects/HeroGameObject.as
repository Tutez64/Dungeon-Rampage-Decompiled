package DistributedObjects
{
   import Actor.ActorData;
   import Actor.ActorGameObject;
   import Actor.DamageCurve;
   import Actor.HeroData;
   import Actor.Player.HeroStateMachine;
   import Actor.Player.HeroView;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Combat.Attack.AttackTimeline;
   import Combat.Weapon.ConsumableWeaponGameObject;
   import DBGlobals.DBGlobal;
   import Events.BusterPointsEvent;
   import Events.ChatEvent;
   import Events.ExperienceEvent;
   import Events.GameObjectEvent;
   import Events.HpEvent;
   import Events.LevelUpPostEvent;
   import Events.ManaEvent;
   import Events.PlayerIsTypingEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import Floor.FloorMessageView;
   import Floor.FloorView;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMSuperStat;
   import GameMasterDictionary.StatVector;
   import GeneratedCode.AttackChoreography;
   import GeneratedCode.ConsumableDetails;
   import GeneratedCode.HeroGameObjectNetworkComponent;
   import GeneratedCode.IHeroGameObject;
   import GeneratedCode.WeaponDetails;
   
   public class HeroGameObject extends ActorGameObject implements IHeroGameObject
   {
      
      public static const LEGENDARY_MOD_STAMINA:uint = 1;
      
      public static const LEGENDARY_MOD_APTITUDE:uint = 2;
      
      public static const LEGENDARY_MOD_ACCELERATION:uint = 3;
      
      public static const LEGENDARY_MOD_BEASTMASTER:uint = 4;
      
      public static const LEGENDARY_MOD_BARRIER:uint = 10;
      
      public static const LEGENDARY_MOD_COVER:uint = 11;
      
      public static const LEGENDARY_MOD_COMPREHENSION:uint = 12;
      
      private static const LEGENDARY_MOD_DEFENSE:Number = 0.5;
      
      public static const MAX_HEALTH_BOMBS_PER_DUNGEON:uint = 3;
      
      public static const MAX_PARTY_BOMBS_PER_DUNGEON:uint = 3;
      
      protected var mHeroGameObjectNetworkComponent:HeroGameObjectNetworkComponent;
      
      protected var mCanMove:Boolean = true;
      
      protected var mMana:uint;
      
      protected var mMaxBusterPoints:uint = 4294967295;
      
      protected var mBusterPoints:uint;
      
      protected var mExperiencePoints:uint;
      
      protected var mAscensionLevel:uint;
      
      protected var mHeroView:HeroView;
      
      protected var mHeroStateMachine:HeroStateMachine;
      
      protected var mPlayerID:uint;
      
      protected var mSlotPoints:Vector.<uint>;
      
      protected var mChatEventComponent:EventComponent;
      
      protected var mCanInitiateAnAttack:Boolean;
      
      protected var mHeroData:HeroData;
      
      protected var mGMSkin:GMSkin;
      
      protected var mPartyBombsUsed:uint = 0;
      
      protected var mHealthBombsUsed:uint = 0;
      
      protected var mStaminaModMultiplier:Number = 0;
      
      protected var mAptitudeModMultiplier:Number = 0;
      
      protected var mAccelerationModMultiplier:Number = 0;
      
      protected var mBeastMasterModMultiplier:Number = 0;
      
      protected var mBarrierModMultiplier:Number = 0;
      
      protected var mCoverModMultiplier:Number = 0;
      
      protected var mComprehensionModMultiplier:Number = 0;
      
      protected var mConsumableDetails:Vector.<ConsumableDetails>;
      
      protected var mConsumableWeapons:Vector.<ConsumableWeaponGameObject>;
      
      public function HeroGameObject(dbFacade:DBFacade, remoteId:uint)
      {
         super(dbFacade,remoteId);
         mWantNavCollisions = true;
         mChatEventComponent = new EventComponent(dbFacade);
         mCanInitiateAnAttack = true;
      }
      
      override protected function processJsonNavCollisions(navCollisions:Array, addFunc:Function) : void
      {
         super.processJsonNavCollisions(navCollisions,addFunc);
      }
      
      override public function get belongsToRemotePlayer() : Boolean
      {
         return !isOwner;
      }
      
      override protected function buildView() : void
      {
         var _loc1_:HeroView = new HeroView(mDBFacade,this);
         MemoryTracker.track(_loc1_,"HeroView - created in HeroGameObject.buildView()");
         view = _loc1_;
      }
      
      override public function set view(actorView:FloorView) : void
      {
         mHeroView = actorView as HeroView;
         super.view = actorView;
      }
      
      public function get heroView() : HeroView
      {
         return mHeroView;
      }
      
      override protected function buildStateMachine() : void
      {
         mHeroStateMachine = new HeroStateMachine(mDBFacade,this,this.mHeroView);
         MemoryTracker.track(mHeroStateMachine,"HeroStateMachine - created in HeroGameObject.buildStateMachine()");
         stateMachine = mHeroStateMachine;
      }
      
      public function get heroStateMachine() : HeroStateMachine
      {
         return mHeroStateMachine;
      }
      
      public function get canInitiateAnAttack() : Boolean
      {
         return mCanInitiateAnAttack;
      }
      
      public function set canInitiateAnAttack(val:Boolean) : void
      {
         mCanInitiateAnAttack = val;
      }
      
      public function setNetworkComponentDistributedPlayer(iface:HeroGameObjectNetworkComponent) : void
      {
         mHeroGameObjectNetworkComponent = iface;
      }
      
      override public function attack(attackType:uint, targetActor:ActorGameObject, attackSpeedMultiplier:Number, attackTimeline:AttackTimeline, finishedCallback:Function = null, stopCallback:Function = null, loop:Boolean = false, autoAim:Boolean = false) : void
      {
         if(mCanInitiateAnAttack)
         {
            attackTimeline.currentAttackType = attackType;
            mHeroStateMachine.enterChoreographyState(attackSpeedMultiplier,targetActor,attackTimeline,finishedCallback,stopCallback,loop,autoAim);
         }
      }
      
      override public function destroy() : void
      {
         mChatEventComponent.destroy();
         mHeroStateMachine.destroy();
         mHeroStateMachine = null;
         for each(var _loc1_:ConsumableWeaponGameObject in mConsumableWeapons)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         mConsumableWeapons = null;
         mHeroView = null;
         super.destroy();
      }
      
      override protected function determineState() : void
      {
         var _loc1_:String = mState;
         if("down" !== _loc1_)
         {
            super.determineState();
         }
         else
         {
            if(this.heroStateMachine.currentStateName == "ActorReviveState")
            {
               return;
            }
            mHeroStateMachine.enterReviveState();
         }
      }
      
      public function setState(val:String) : void
      {
         state = val;
      }
      
      public function set skinType(val:uint) : void
      {
         mGMSkin = mDBFacade.gameMaster.getSkinByType(val);
         if(mGMSkin == null)
         {
            Logger.error("Unable to find GMSkin for skin type: " + val + " Loading default skin for heroType: " + type);
            mGMSkin = mDBFacade.gameMaster.getSkinByConstant(gMHero.DefaultSkin);
            if(mGMSkin == null)
            {
               Logger.error("Unable to find default skin with constant: " + gMHero.DefaultSkin);
            }
         }
      }
      
      public function get skinType() : uint
      {
         return mGMSkin.Id;
      }
      
      override public function get gmSkin() : GMSkin
      {
         return mGMSkin;
      }
      
      override protected function buildActorData() : ActorData
      {
         mHeroData = new HeroData(mDBFacade,this,mGMSkin);
         return mHeroData;
      }
      
      public function set manaPoints(mana:uint) : void
      {
         mMana = mana;
         mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE",id,mMana,this.maxManaPoints));
      }
      
      public function get manaPoints() : uint
      {
         return mMana;
      }
      
      public function set experiencePoints(exp:uint) : void
      {
         var _loc2_:uint = mLevel;
         var _loc3_:uint = uint(actorData ? this.gMHero.getBaseLevelFromExp(mExperiencePoints) : 0);
         mExperiencePoints = exp;
         if(actorData)
         {
            this.level = this.gMHero.getLevelFromExp(mExperiencePoints,mAscensionLevel);
            if(this.gMHero.getBaseLevelFromExp(mExperiencePoints) != _loc3_)
            {
               refreshStatVector();
            }
         }
         if(mLevel != _loc2_)
         {
            mHeroView.playHeroLevelUpEffects();
            if(this is HeroGameObjectOwner)
            {
               mDBFacade.steamAchievementsHelper.updateHeroLevelStat(this.gMHero.Constant,mLevel,mAscensionLevel);
               mFacade.eventManager.dispatchEvent(new LevelUpPostEvent("LevelUpPostEvent",mLevel));
            }
         }
         mFacade.eventManager.dispatchEvent(new ExperienceEvent("ExperienceEvent_EXPERIENCE_UPDATE",id,mExperiencePoints));
      }
      
      public function set dungeonBusterPoints(val:uint) : void
      {
         mBusterPoints = val;
         mFacade.eventManager.dispatchEvent(new BusterPointsEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",id,mBusterPoints,mMaxBusterPoints));
      }
      
      public function get dungeonBusterPoints() : uint
      {
         return mBusterPoints;
      }
      
      public function get experiencePoints() : uint
      {
         return mExperiencePoints;
      }
      
      public function set ascensionLevel(val:uint) : void
      {
         mAscensionLevel = val;
      }
      
      public function get ascensionLevel() : uint
      {
         return mAscensionLevel;
      }
      
      public function set maxBusterPoints(val:uint) : void
      {
         mMaxBusterPoints = val;
         mFacade.eventManager.dispatchEvent(new BusterPointsEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",id,mBusterPoints,mMaxBusterPoints));
      }
      
      public function get maxBusterPoints() : uint
      {
         return mMaxBusterPoints;
      }
      
      public function get healthBombUsesRemaining() : int
      {
         var _loc1_:Number = 3 - mHealthBombsUsed;
         if(_loc1_ < 0)
         {
            Logger.warn("More healthbombs have been consumed than allowed in limited use dungeons.");
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function get partyBombUsesRemaining() : int
      {
         var _loc1_:Number = 3 - mPartyBombsUsed;
         if(_loc1_ < 0)
         {
            Logger.warn("More partybombs have been consumed than allowed in limited use dungeons.");
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set healthBombsUsed(val:uint) : void
      {
         mHealthBombsUsed = val;
         if(isOwner)
         {
            mDBFacade.steamAchievementsHelper.setHighestStatValueAchieved(mHealthBombsUsed,"MOST_HEALTH_BOMBS_IN_DUNGEON");
         }
      }
      
      public function set partyBombsUsed(val:uint) : void
      {
         mPartyBombsUsed = val;
      }
      
      public function canUseHealthBombs() : Boolean
      {
         if(mDistributedDungeonFloor.isInfiniteDungeon)
         {
            return mHealthBombsUsed < 3;
         }
         return true;
      }
      
      public function canUsePartyBombs() : Boolean
      {
         if(mDistributedDungeonFloor.isInfiniteDungeon)
         {
            return mPartyBombsUsed < 3;
         }
         return true;
      }
      
      override public function postGenerate() : void
      {
         processLegendaryModifiers();
         super.postGenerate();
         mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE",id,mMana,this.maxManaPoints));
         mFacade.eventManager.dispatchEvent(new BusterPointsEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",id,mBusterPoints,mMaxBusterPoints));
         mFacade.eventManager.dispatchEvent(new ExperienceEvent("ExperienceEvent_EXPERIENCE_UPDATE",id,mExperiencePoints));
         mFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE",id,mHitPoints,this.maxHitPoints));
         mChatEventComponent.addListener(GameObjectEvent.uniqueEvent("ChatEvent_INCOMING_CHAT_UPDATE",mPlayerID),function(param1:ChatEvent):void
         {
            Chat(param1.message);
         });
         mChatEventComponent.addListener(GameObjectEvent.uniqueEvent("PLAYER_IS_TYPING",mPlayerID),function(param1:PlayerIsTypingEvent):void
         {
            if(param1.subtype == "CHAT_BOX_FOCUS_IN")
            {
               ShowPlayerisTyping(true);
            }
            else
            {
               ShowPlayerisTyping(false);
            }
         });
      }
      
      public function processLegendaryModifiers() : void
      {
         mStaminaModMultiplier = 0;
         mAptitudeModMultiplier = 0;
         mAccelerationModMultiplier = 0;
         mBeastMasterModMultiplier = 0;
         mBarrierModMultiplier = 0;
         mCoverModMultiplier = 0;
         mComprehensionModMultiplier = 0;
         for each(var _loc1_:WeaponDetails in mWeaponDetails)
         {
            switch(int(_loc1_.legendarymodifier) - 1)
            {
               case 0:
                  mStaminaModMultiplier += 10 + _loc1_.requiredlevel * 0.9;
                  break;
               case 1:
                  mAptitudeModMultiplier += 10 + _loc1_.requiredlevel * 0.4;
                  break;
               case 2:
                  mAccelerationModMultiplier += 0.1;
                  break;
               case 3:
                  mBeastMasterModMultiplier += 10 + _loc1_.requiredlevel * 0.9;
                  break;
               case 9:
                  mBarrierModMultiplier = 0.5;
                  break;
               case 10:
                  mCoverModMultiplier = 0.5;
                  break;
               case 11:
                  mComprehensionModMultiplier = 0.5;
            }
         }
      }
      
      public function get beastMasterModMultiplier() : Number
      {
         return mBeastMasterModMultiplier;
      }
      
      override public function get maxHitPoints() : Number
      {
         return this.buffHandler.multiplier.maxHitPoints * (mStats.maxHitPoints + mStaminaModMultiplier);
      }
      
      override public function get maxManaPoints() : Number
      {
         return this.buffHandler.multiplier.maxManaPoints * (mStats.maxManaPoints + mAptitudeModMultiplier);
      }
      
      override public function get movementSpeed() : Number
      {
         var _loc2_:Number = mStats.movementSpeed;
         var _loc3_:Number = this.buffHandler.multiplier.movementSpeed;
         return _loc2_ * _loc3_ * (1 + mAccelerationModMultiplier);
      }
      
      public function set slotPoints(val:Vector.<uint>) : void
      {
         mSlotPoints = val;
      }
      
      public function setNetworkComponentHeroGameObject(iface:HeroGameObjectNetworkComponent) : void
      {
      }
      
      override public function set stats(value:StatVector) : void
      {
         super.stats = value;
         mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE",id,mMana,this.maxManaPoints));
      }
      
      public function set playerID(val:uint) : void
      {
         mPlayerID = val;
      }
      
      public function get playerID() : uint
      {
         return mPlayerID;
      }
      
      public function TriggerEffect(effect:String) : void
      {
      }
      
      public function get gMHero() : GMHero
      {
         return mActorData.gMActor as GMHero;
      }
      
      override protected function refreshStatVector() : void
      {
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:GMHero = gMHero;
         this.level = _loc2_.getLevelFromExp(mExperiencePoints,mAscensionLevel);
         var _loc3_:uint = _loc2_.getBaseLevelFromExp(mExperiencePoints);
         var _loc5_:StatVector = new StatVector();
         _loc7_ = 0;
         while(_loc7_ < 4)
         {
            _loc9_ = 0;
            while(_loc9_ < _loc2_.UpgradeToSlotOffset[_loc7_].length)
            {
               var _loc12_:int = _loc2_.UpgradeToSlotOffset[_loc7_][_loc9_];
               var _loc13_:Number = _loc5_.values[_loc12_] + mSlotPoints[_loc7_];
               _loc5_.values[_loc12_] = _loc13_;
               _loc9_++;
            }
            _loc7_++;
         }
         var _loc11_:StatVector = StatVector.multiply(_loc2_.Normalized_upgrades,_loc5_);
         var _loc10_:StatVector = StatVector.add(mActorData.baseValues,StatVector.multiplyScalar(mActorData.levelValues,_loc3_));
         _loc10_ = StatVector.add(_loc10_,_loc11_);
         var _loc8_:StatVector = StatVector.add(StatVector.multiply(_loc10_,mDBFacade.gameMaster.stat_BonusMultiplier),mDBFacade.gameMaster.stat_bias);
         var _loc4_:StatVector = StatVector.add(mActorData.baseValues,StatVector.multiplyScalar(mActorData.levelValues,DamageCurve.heroAttackCurve(_loc3_)));
         _loc4_ = StatVector.add(_loc4_,_loc11_);
         var _loc6_:StatVector = StatVector.add(StatVector.multiply(_loc4_,mDBFacade.gameMaster.stat_BonusMultiplier),mDBFacade.gameMaster.stat_bias);
         var _loc1_:StatVector = StatVector.clone(_loc8_);
         _loc1_.values[DBGlobal.HP_BOOST] = mActorData.hp + _loc8_.values[DBGlobal.HP_BOOST];
         _loc1_.values[DBGlobal.MP_BOOST] = mActorData.mp + _loc8_.values[DBGlobal.MP_BOOST];
         _loc1_.values[DBGlobal.MELEE_ATK] = _loc6_.values[DBGlobal.MELEE_ATK];
         _loc1_.values[DBGlobal.SHOOT_ATK] = _loc6_.values[DBGlobal.SHOOT_ATK];
         _loc1_.values[DBGlobal.MAGIC_ATK] = _loc6_.values[DBGlobal.MAGIC_ATK];
         _loc1_.values[DBGlobal.MELEE_DEF] += mBarrierModMultiplier;
         _loc1_.values[DBGlobal.SHOOT_DEF] += mCoverModMultiplier;
         _loc1_.values[DBGlobal.MAGIC_DEF] += mComprehensionModMultiplier;
         _loc1_.values[DBGlobal.MOVEMENT] = _loc2_.BaseMove * _loc8_.values[DBGlobal.MOVEMENT];
         stats = _loc1_;
      }
      
      public function IsInvulnerable() : Boolean
      {
         return buffHandler.IsInvulnerable();
      }
      
      public function setStateAndAttackChoreography(targetState:String, attackChoreography:AttackChoreography) : void
      {
         state = targetState;
         ReceiveAttackChoreography(attackChoreography);
      }
      
      public function StopChoreography() : void
      {
         if(this.stateMachine != null && this.stateMachine.currentSubState && this.stateMachine.currentSubState.name == "ActorChoreographySubState")
         {
            this.stateMachine.enterNavigationState();
         }
      }
      
      public function PartyBomb(bomberId:uint) : void
      {
         var _loc3_:HeroGameObject = mDBFacade.gameObjectManager.getReferenceFromId(bomberId) as HeroGameObject;
         var _loc4_:String = _loc3_.screenName + "\n" + Locale.getString("BOMB_DROPPER");
         var _loc2_:FloorMessageView = new FloorMessageView(mDBFacade,"",_loc4_.toLocaleUpperCase());
         MemoryTracker.track(_loc2_,"FloorMessageView - created in HeroGameObject.on_party_bomb()");
      }
      
      public function set consumableDetails(val:Vector.<ConsumableDetails>) : void
      {
         mConsumableDetails = val;
         var _loc5_:uint = 0;
         var _loc2_:uint = 0;
         var _loc4_:uint = 0;
         var _loc3_:uint = 0;
         if(val.length > 0)
         {
            _loc5_ = val[0].type;
            _loc2_ = val[0].count;
         }
         if(val.length > 1)
         {
            _loc4_ = val[1].type;
            _loc3_ = val[1].count;
         }
         if(mActorData && mDistributedDungeonFloor)
         {
            setupConsumables();
         }
      }
      
      override protected function setupConsumables() : void
      {
         var _loc4_:ConsumableWeaponGameObject = null;
         for each(var _loc2_:ConsumableWeaponGameObject in mConsumableWeapons)
         {
            if(_loc2_)
            {
               _loc2_.destroy();
            }
         }
         var _loc1_:uint = 0;
         mConsumableWeapons = new Vector.<ConsumableWeaponGameObject>();
         for each(var _loc3_:ConsumableDetails in mConsumableDetails)
         {
            if(_loc3_.type != 0)
            {
               _loc4_ = new ConsumableWeaponGameObject(_loc3_,this,mActorView,mDBFacade,mDistributedDungeonFloor,_loc1_);
               MemoryTracker.track(_loc4_,"ConsumableWeaponGameObject - created in HeroGameObject.setupConsumables()");
               mConsumableWeapons.push(_loc4_);
            }
            else
            {
               mConsumableWeapons.push(null);
            }
            _loc1_++;
         }
      }
      
      public function get consumables() : Vector.<ConsumableWeaponGameObject>
      {
         return mConsumableWeapons;
      }
      
      override public function get attackCooldownMultiplier() : Number
      {
         var _loc1_:GMSuperStat = null;
         if(gMHero.StatUpgrade3 == "MAGIC_COOLDOWN")
         {
            _loc1_ = mDBFacade.gameMaster.superStatByConstant.itemFor(gMHero.StatUpgrade3);
            return 0.01 * (mSlotPoints[2] * gMHero.AmtStat3 * _loc1_.CooldownReduction);
         }
         return buffHandler.attackCooldownMultiplier - 1;
      }
   }
}

