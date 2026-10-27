package NetworkCode.Transport
{
   import flash.events.IEventDispatcher;
   import flash.utils.ByteArray;
   
   public interface IGameTransport extends IEventDispatcher
   {
      
      function connect() : void;
      
      function send(bytes:ByteArray) : void;
      
      function sendText(text:String) : void;
      
      function close() : void;
      
      function abandon() : void;
      
      function get connected() : Boolean;
      
      function get supportsSessions() : Boolean;
      
      function get name() : String;
   }
}

