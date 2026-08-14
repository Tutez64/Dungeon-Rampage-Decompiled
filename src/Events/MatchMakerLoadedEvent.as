package Events
{
   import DistributedObjects.MatchMaker;
   import flash.events.Event;
   
   public class MatchMakerLoadedEvent extends Event
   {
      
      public static const EVENT_NAME:String = "MATCH_MAKER_LOADED";
      
      private var mMatchMaker:MatchMaker;
      
      public function MatchMakerLoadedEvent(matchMaker:MatchMaker, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("MATCH_MAKER_LOADED",bubbles,cancelable);
         mMatchMaker = matchMaker;
      }
      
      public function get matchMaker() : MatchMaker
      {
         return mMatchMaker;
      }
   }
}

