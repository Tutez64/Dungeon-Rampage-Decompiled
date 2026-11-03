package SteamInput
{
   import flash.events.Event;
   
   public class UnboundActionEvent extends Event
   {
      
      public static const PRESSED:String = "UnboundActionEvent.PRESSED";
      
      public static const RELEASED:String = "UnboundActionEvent.RELEASED";
      
      public var actionName:String;
      
      public function UnboundActionEvent(type:String, actionName:String)
      {
         super(type);
         this.actionName = actionName;
      }
      
      public static function isAction(event:Event, actionName:String) : Boolean
      {
         var _loc3_:UnboundActionEvent = event as UnboundActionEvent;
         return _loc3_ != null && _loc3_.actionName == actionName;
      }
      
      override public function clone() : Event
      {
         return new UnboundActionEvent(type,actionName);
      }
   }
}

