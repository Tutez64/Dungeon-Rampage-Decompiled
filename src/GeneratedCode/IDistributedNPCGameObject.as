package GeneratedCode
{
   import Brain.GameObject.GameObject;
   import flash.geom.Vector3D;
   
   public interface IDistributedNPCGameObject
   {
      
      function setNetworkComponentDistributedNPCGameObject(iface:DistributedNPCGameObjectNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function set type(val:uint) : void;
      
      function set level(val:uint) : void;
      
      function set position(val:Vector3D) : void;
      
      function set heading(val:Number) : void;
      
      function set scale(val:Number) : void;
      
      function set flip(val:uint) : void;
      
      function set hitPoints(val:uint) : void;
      
      function set weaponDetails(val:Vector.<WeaponDetails>) : void;
      
      function set state(val:String) : void;
      
      function set team(val:int) : void;
      
      function set layer(val:int) : void;
      
      function set remoteTriggerState(val:uint) : void;
      
      function set masterId(val:uint) : void;
      
      function ReceiveAttackChoreography(attackChoreography:AttackChoreography) : void;
      
      function ReceiveCombatResult(combatResult:CombatResult) : void;
      
      function ReceiveTimelineAction(timelineAction:String) : void;
   }
}

