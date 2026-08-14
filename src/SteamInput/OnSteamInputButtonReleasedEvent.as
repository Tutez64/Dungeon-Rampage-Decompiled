package SteamInput
{
   import flash.events.Event;
   
   public class OnSteamInputButtonReleasedEvent extends Event
   {
      
      public static const TYPE:String = "OnSteamInputButtonReleasedEvent";
      
      public var actionName:String;
      
      public function OnSteamInputButtonReleasedEvent(actionName:String)
      {
         this.actionName = actionName;
         super("OnSteamInputButtonReleasedEvent");
      }
   }
}

