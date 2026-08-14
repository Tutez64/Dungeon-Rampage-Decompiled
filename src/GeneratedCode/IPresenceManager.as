package GeneratedCode
{
   import Brain.GameObject.GameObject;
   
   public interface IPresenceManager
   {
      
      function setNetworkComponentPresenceManager(iface:PresenceManagerNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function friendState(yesno:uint, who:uint, state:uint) : void;
   }
}

