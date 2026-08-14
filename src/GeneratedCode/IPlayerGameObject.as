package GeneratedCode
{
   import Brain.GameObject.GameObject;
   
   public interface IPlayerGameObject
   {
      
      function setNetworkComponentPlayerGameObject(iface:PlayerGameObjectNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function set screenName(val:String) : void;
      
      function Chat(text:String) : void;
      
      function ShowPlayerIsTyping(value:uint) : void;
   }
}

