package SteamInput
{
   import flash.events.Event;
   
   public class OnSteamInputButtonPressedEvent extends Event
   {
      
      public static const TYPE:String = "OnSteamInputButtonPressedEvent";
      
      public var actionName:String;
      
      public function OnSteamInputButtonPressedEvent(actionName:String)
      {
         this.actionName = actionName;
         super("OnSteamInputButtonPressedEvent");
      }
   }
}

