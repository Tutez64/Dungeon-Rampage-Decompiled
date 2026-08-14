package Actor.Player.Input
{
   import flash.geom.Vector3D;
   
   public interface IMouseController
   {
      
      function init() : void;
      
      function stop() : void;
      
      function clearMovement() : void;
      
      function perFrameUpCall() : void;
      
      function set combatDisabled(disableCombat:Boolean) : void;
      
      function get potentialAttacksThisFrame() : Array;
      
      function get inputVelocity() : Vector3D;
      
      function get inputHeading() : Vector3D;
      
      function destroy() : void;
   }
}

