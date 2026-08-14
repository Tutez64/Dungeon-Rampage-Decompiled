package Dungeon
{
   public class TriggerableEvent
   {
      
      public var triggerableId:uint;
      
      public var eventName:String;
      
      public function TriggerableEvent(id:uint, evtName:String)
      {
         super();
         triggerableId = id;
         eventName = evtName;
      }
   }
}

