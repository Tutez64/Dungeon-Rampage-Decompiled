package SteamInput
{
   import flash.events.Event;
   
   public class ControllerConnectionChangedEvent extends Event
   {
      
      public static const TYPE:String = "ControllerConnectionChangedEvent";
      
      public var isControllerConnected:Boolean;
      
      public function ControllerConnectionChangedEvent(inIsControllerConnected:Boolean)
      {
         this.isControllerConnected = inIsControllerConnected;
         super("ControllerConnectionChangedEvent");
      }
   }
}

