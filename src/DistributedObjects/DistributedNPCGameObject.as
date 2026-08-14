package DistributedObjects
{
   import Brain.GameObject.GameObject;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import GameMasterDictionary.StatVector;
   import GeneratedCode.AttackChoreography;
   import GeneratedCode.CombatResult;
   import GeneratedCode.DistributedNPCGameObjectNetworkComponent;
   import GeneratedCode.IDistributedNPCGameObject;
   import GeneratedCode.WeaponDetails;
   import flash.geom.Vector3D;
   
   public class DistributedNPCGameObject extends GameObject implements IDistributedNPCGameObject
   {
      
      protected var mNPCGameObject:NPCGameObject;
      
      public function DistributedNPCGameObject(facade:DBFacade, remoteId:uint = 0)
      {
         super(facade,0);
         mNPCGameObject = new NPCGameObject(facade,remoteId);
         MemoryTracker.track(mNPCGameObject,"NPCGameObject - created in DistributedNPCGameObject.constructor()");
      }
      
      override public function getTrueObject() : GameObject
      {
         return mNPCGameObject;
      }
      
      public function setNetworkComponentDistributedNPCGameObject(iface:DistributedNPCGameObjectNetworkComponent) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.setNetworkComponentDistributedNPCGameObject(iface);
         }
      }
      
      public function set state(state:String) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.state = state;
            if(state == "dead")
            {
               mNPCGameObject.hasOwnership = true;
               mNPCGameObject = null;
            }
         }
      }
      
      public function postGenerate() : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.postGenerate();
         }
      }
      
      public function set type(val:uint) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.type = val;
         }
      }
      
      public function set level(val:uint) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.level = val;
         }
      }
      
      public function set position(val:Vector3D) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.position = val;
         }
      }
      
      public function set heading(val:Number) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.heading = val;
         }
      }
      
      public function set scale(val:Number) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.scale = val;
         }
      }
      
      public function set flip(val:uint) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.flip = val;
         }
      }
      
      public function set hitPoints(val:uint) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.hitPoints = val;
         }
      }
      
      public function set weaponDetails(val:Vector.<WeaponDetails>) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.weaponDetails = val;
         }
      }
      
      public function set stats(val:StatVector) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.stats = val;
         }
      }
      
      public function set masterId(val:uint) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.masterId = val;
         }
      }
      
      public function ReceiveAttackChoreography(attackChoreography:AttackChoreography) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.ReceiveAttackChoreography(attackChoreography);
         }
      }
      
      public function ReceiveTimelineAction(timelineAction:String) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.ReceiveTimelineAction(timelineAction);
         }
      }
      
      public function ReceiveCombatResult(combatResult:CombatResult) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.ReceiveCombatResult(combatResult);
         }
      }
      
      override public function destroy() : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.destroy();
            mNPCGameObject = null;
         }
         super.destroy();
      }
      
      public function set layer(val:int) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.layer = val;
         }
      }
      
      public function set team(val:int) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.team = val;
         }
      }
      
      public function set remoteTriggerState(val:uint) : void
      {
         if(mNPCGameObject)
         {
            mNPCGameObject.remoteTriggerState = val;
         }
      }
   }
}

