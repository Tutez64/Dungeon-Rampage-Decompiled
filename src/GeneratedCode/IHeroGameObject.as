package GeneratedCode
{
   import Brain.GameObject.GameObject;
   import flash.geom.Vector3D;
   
   public interface IHeroGameObject
   {
      
      function setNetworkComponentHeroGameObject(iface:HeroGameObjectNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function set type(val:uint) : void;
      
      function set position(val:Vector3D) : void;
      
      function set heading(val:Number) : void;
      
      function set scale(val:Number) : void;
      
      function set flip(val:uint) : void;
      
      function set hitPoints(val:uint) : void;
      
      function set weaponDetails(val:Vector.<WeaponDetails>) : void;
      
      function set consumableDetails(val:Vector.<ConsumableDetails>) : void;
      
      function set healthBombsUsed(val:uint) : void;
      
      function set partyBombsUsed(val:uint) : void;
      
      function set playerID(val:uint) : void;
      
      function set state(val:String) : void;
      
      function set team(val:int) : void;
      
      function ReceiveAttackChoreography(attackChoreography:AttackChoreography) : void;
      
      function ReceiveCombatResult(combatResult:CombatResult) : void;
      
      function set skinType(val:uint) : void;
      
      function set screenName(val:String) : void;
      
      function set manaPoints(val:uint) : void;
      
      function set experiencePoints(val:uint) : void;
      
      function set slotPoints(val:Vector.<uint>) : void;
      
      function set dungeonBusterPoints(val:uint) : void;
      
      function set setAFK(val:uint) : void;
      
      function PartyBomb(bomberId:uint) : void;
      
      function setStateAndAttackChoreography(targetState:String, attackChoreography:AttackChoreography) : void;
      
      function StopChoreography() : void;
   }
}

