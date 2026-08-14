package Metrics
{
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import flash.events.Event;
   
   public class PixelTracker
   {
      
      public function PixelTracker()
      {
         super();
      }
      
      public static function tutorialComplete(dbFacade:DBFacade) : void
      {
      }
      
      public static function purchaseEvent(dbFacade:DBFacade, creditsValue:uint) : void
      {
      }
      
      public static function nodeCompleted(dbFacade:DBFacade) : void
      {
      }
      
      public static function nodeIndexCompleted(dbFacade:DBFacade, dungeonIndex:uint) : void
      {
      }
      
      public static function logMapNodeUnlocked(dbFacade:DBFacade, mapNodeIndex:uint) : void
      {
      }
      
      public static function wallPost(dbFacade:DBFacade) : void
      {
      }
      
      public static function invitedFriend(dbFacade:DBFacade) : void
      {
      }
      
      public static function returnDAU(dbFacade:DBFacade) : void
      {
      }
      
      public static function visitedStore(dbFacade:DBFacade) : void
      {
      }
      
      public static function completeHandler(e:Event) : void
      {
         Logger.debug("Tracker completeHandler" + e.toString());
      }
      
      public static function securityErrorHandler(e:Event) : void
      {
         Logger.warn("Tracker securityErrorHandler: " + e.toString());
      }
      
      public static function ioErrorHandler(e:Event) : void
      {
         Logger.warn("Tracker ioErrorHandler: " + e.toString());
      }
   }
}

