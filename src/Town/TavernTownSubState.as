package Town
{
   import Brain.Event.EventComponent;
   import Events.DBAccountResponseEvent;
   import Facade.DBFacade;
   import UI.Tavern.UITavern;
   
   public class TavernTownSubState extends TownSubState
   {
      
      private static const NAME:String = "TavernTownSubState";
      
      private var mTavernUI:UITavern;
      
      private var mEventComponent:EventComponent;
      
      public function TavernTownSubState(dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,townStateMachine,"TavernTownSubState");
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      override public function destroy() : void
      {
         if(mTavernUI)
         {
            mTavernUI.destroy();
            mTavernUI = null;
         }
         mEventComponent.destroy();
         super.destroy();
      }
      
      override protected function setupState() : void
      {
         super.setupState();
         mTavernUI = new UITavern(mDBFacade,mRootMovieClip,mTownStateMachine.townHeader);
      }
      
      override public function enterState() : void
      {
         super.enterState();
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:DBAccountResponseEvent):void
         {
            mTavernUI.refresh();
         });
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("TAVERN_MENU",mTownStateMachine.townHeader.determineCallback,mTavernUI.getDefaultMenuNavigationObject());
         mTavernUI.refresh();
         mTownStateMachine.townHeader.showCloseButton(true);
         mTavernUI.animateEntry();
      }
      
      override protected function setupHeaderLinks() : void
      {
         super.setupHeaderLinks();
      }
      
      override public function exitState() : void
      {
         mTavernUI.processChosenAvatar();
         mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
         mDBFacade.menuNavigationController.popLayer("TAVERN_MENU");
         mTavernUI.resetHeaderLinks();
         super.exitState();
      }
   }
}

