package StateMachine.MainStateMachine
{
   import Brain.Event.EventComponent;
   import Brain.StateMachine.State;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.MemoryUtil;
   import Events.DBAccountLoadedEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import UI.Popup.DBUIPopup;
   
   public class ReloadTownState extends State
   {
      
      public static const NAME:String = "ReloadTownState";
      
      protected var mDBFacade:DBFacade;
      
      protected var mPopup:DBUIPopup;
      
      protected var mEventComponent:EventComponent;
      
      public function ReloadTownState(dbFacade:DBFacade, finishedCallback:Function = null)
      {
         super("ReloadTownState",finishedCallback);
         mDBFacade = dbFacade;
      }
      
      override public function enterState() : void
      {
         super.enterState();
         mPopup = new DBUIPopup(mDBFacade,Locale.getString("RELOAD_TOWN_POPUP_TITLE"),null,false);
         MemoryTracker.track(mPopup,"DBUIPopup - created in ReloadTownState.enterState()");
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener("DB_ACCOUNT_INFO_LOADED",accountLoaded);
         mDBFacade.dbAccountInfo.getUsersFullAccountInfo();
         mDBFacade.dbAccountInfo.checkFriendsHash();
         MemoryUtil.pauseForGCWithLogging("ReloadTownState: ");
         mDBFacade.ClearCachedTileLibraryJson();
      }
      
      override public function exitState() : void
      {
         mPopup.destroy();
         mPopup = null;
         mEventComponent.destroy();
         mEventComponent = null;
         super.exitState();
      }
      
      protected function accountLoaded(dbAccountLoadedEvent:DBAccountLoadedEvent) : void
      {
         if(mFinishedCallback != null)
         {
            mFinishedCallback();
         }
      }
   }
}

