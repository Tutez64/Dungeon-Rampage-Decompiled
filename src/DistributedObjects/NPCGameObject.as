package DistributedObjects
{
   import Actor.ActorGameObject;
   import Actor.NPC.NPCView;
   import Actor.StateMachine.ActorMacroStateMachine;
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Dungeon.NavCollider;
   import Facade.DBFacade;
   import Floor.FloorView;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMPlayerScale;
   import GeneratedCode.DistributedNPCGameObjectNetworkComponent;
   import GeneratedCode.IDistributedNPCGameObject;
   
   public class NPCGameObject extends ActorGameObject implements IDistributedNPCGameObject
   {
      
      protected var mNPCGameObjectNetworkComponent:DistributedNPCGameObjectNetworkComponent;
      
      protected var mGmNpc:GMNpc;
      
      protected var mNPCView:NPCView;
      
      private var mMasterId:uint;
      
      private var mMasterIsUser:Boolean = false;
      
      protected var mTriggerState:Boolean = true;
      
      protected var mOffNavCollisions:Vector.<NavCollider>;
      
      public function NPCGameObject(dbFacade:DBFacade, remoteId:uint)
      {
         super(dbFacade,remoteId);
         mOffNavCollisions = new Vector.<NavCollider>();
      }
      
      override public function init() : void
      {
         mGmNpc = this.mDBFacade.gameMaster.npcById.itemFor(this.type);
         super.init();
         this.createOffNavCollisions(this.actorData.constant);
         this.triggerState = this.triggerState;
         tryRegisterPet();
         mArchwayAlpha = mGmNpc.ArchwayAlpha;
         initializeToFirstValidWeapon();
      }
      
      override public function get maxHitPoints() : Number
      {
         var _loc1_:Number = 1;
         if(this.distributedDungeonFloor)
         {
            _loc1_ = GMPlayerScale.HPBoostByPlayers.itemFor(this.distributedDungeonFloor.numHeroes);
         }
         return super.maxHitPoints * _loc1_;
      }
      
      override public function get usePetUI() : Boolean
      {
         return this.gmNpc.UsePetUI;
      }
      
      override public function get hasShowHealNumbers() : Boolean
      {
         return this.gmNpc.ShowHealNumbers;
      }
      
      private function tryRegisterPet() : void
      {
         if(isPet && usePetUI && mMasterIsUser)
         {
            mDBFacade.hud.registerPet(this);
         }
      }
      
      public function get isUsingTeleportAI() : Boolean
      {
         return mGmNpc.UseTeleportAI;
      }
      
      public function get gmNpc() : GMNpc
      {
         return mGmNpc;
      }
      
      override public function get isAttackable() : Boolean
      {
         return mGmNpc.IsAttackable && this.triggerState;
      }
      
      override public function get isNavigable() : Boolean
      {
         return mGmNpc.IsNavigable;
      }
      
      public function setNetworkComponentDistributedNPCGameObject(iface:DistributedNPCGameObjectNetworkComponent) : void
      {
         mNPCGameObjectNetworkComponent = iface;
      }
      
      override protected function buildView() : void
      {
         var _loc1_:NPCView = new NPCView(mDBFacade,this);
         MemoryTracker.track(_loc1_,"NPCView - created in NPCGameObject.buildView()");
         view = _loc1_;
      }
      
      override protected function buildStateMachine() : void
      {
         var _loc1_:ActorMacroStateMachine = new ActorMacroStateMachine(mDBFacade,this,this.mActorView);
         MemoryTracker.track(_loc1_,"ActorMacroStateMachine - created in NPCGameObject.buildStateMachine()");
         stateMachine = _loc1_;
      }
      
      override public function set view(actorView:FloorView) : void
      {
         mNPCView = actorView as NPCView;
         super.view = actorView;
      }
      
      override public function destroy() : void
      {
         mActorStateMachine.destroy();
         mActorStateMachine = null;
         for each(var _loc1_:NavCollider in mOffNavCollisions)
         {
            _loc1_.destroy();
         }
         mOffNavCollisions = null;
         mNPCView = null;
         mGmNpc = null;
         mNPCGameObjectNetworkComponent = null;
         super.destroy();
      }
      
      public function weapon_down(weapon:int) : void
      {
      }
      
      public function weapon_up(weapon:int) : void
      {
      }
      
      override public function get navCollisions() : Vector.<NavCollider>
      {
         if(mTriggerState)
         {
            return mNavCollisions;
         }
         return mOffNavCollisions;
      }
      
      protected function createOffNavCollisions(constant:String) : void
      {
         var _loc2_:Array = mDistributedDungeonFloor.dungeonFloorFactory.tileFactory.propFactory.getNavCollisionTriggerOffJson(constant);
         if(_loc2_)
         {
            this.processJsonNavCollisions(_loc2_,this.addOffNavCollision);
            this.offNavCollidersActive = false;
         }
      }
      
      public function addOffNavCollision(value:NavCollider) : void
      {
         if(!mWantNavCollisions)
         {
            Logger.warn("adding nav collision but wantNavCollision == false. Ignoring.");
            return;
         }
         mOffNavCollisions.push(value);
      }
      
      public function removeOffNavColliders() : void
      {
         for each(var _loc1_:NavCollider in mOffNavCollisions)
         {
            _loc1_.destroy();
         }
         mOffNavCollisions = new Vector.<NavCollider>();
      }
      
      public function get triggerState() : Boolean
      {
         return mTriggerState;
      }
      
      public function set offNavCollidersActive(value:Boolean) : void
      {
         for each(var _loc2_:NavCollider in mOffNavCollisions)
         {
            _loc2_.active = value;
         }
      }
      
      public function set triggerState(value:Boolean) : void
      {
         mNPCView.triggerState = value;
         mTriggerState = value;
         if(mTriggerState)
         {
            this.navCollidersActive = true;
            this.offNavCollidersActive = false;
         }
         else
         {
            this.navCollidersActive = false;
            this.offNavCollidersActive = true;
         }
      }
      
      public function set remoteTriggerState(val:uint) : void
      {
         triggerState = val > 0;
      }
      
      override public function get isBlocking() : Boolean
      {
         return super.isBlocking || mGmNpc.blocksNatively();
      }
      
      override public function get maximumDotForBlocking() : Number
      {
         return mGmNpc.BlockingDotProduct > super.maximumDotForBlocking ? mGmNpc.BlockingDotProduct : super.maximumDotForBlocking;
      }
      
      public function set masterId(val:uint) : void
      {
         mMasterId = val;
         checkIfMasterIsUser(mMasterId);
         if(this.isInitialized)
         {
            tryRegisterPet();
         }
      }
      
      private function checkIfMasterIsUser(masterId:uint) : void
      {
         var _loc4_:ActorGameObject = null;
         var _loc2_:Boolean = false;
         var _loc3_:GameObject = mDBFacade.gameObjectManager.getReferenceFromId(masterId);
         if(_loc3_ != null)
         {
            _loc4_ = _loc3_ as ActorGameObject;
            if(_loc4_ != null)
            {
               if(_loc4_.isOwner)
               {
                  _loc2_ = true;
               }
            }
         }
         mMasterIsUser = _loc2_;
      }
      
      public function masterIsUser() : Boolean
      {
         return mMasterIsUser;
      }
      
      public function get masterId() : uint
      {
         return mMasterId;
      }
   }
}

