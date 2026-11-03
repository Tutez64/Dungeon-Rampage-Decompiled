package Town
{
   import Brain.Event.EventComponent;
   import Events.DBAccountResponseEvent;
   import Facade.DBFacade;
   import UI.Skills.UISkills;
   
   public class SkillsTownSubState extends TownSubState
   {
      
      public static const NAME:String = "SkillsTownSubState";
      
      private var mUISkills:UISkills;
      
      private var mEventComponent:EventComponent;
      
      public function SkillsTownSubState(dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,townStateMachine,"SkillsTownSubState");
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      override public function destroy() : void
      {
         if(mUISkills)
         {
            mUISkills.destroy();
            mUISkills = null;
         }
         mEventComponent.destroy();
         super.destroy();
      }
      
      override protected function setupState() : void
      {
         super.setupState();
         mUISkills = new UISkills(mDBFacade,mRootMovieClip,mTownStateMachine.townHeader);
      }
      
      override protected function setupHeaderLinks() : void
      {
         super.setupHeaderLinks();
         mUISkills.setupHeaderLinks();
      }
      
      override public function enterState() : void
      {
         super.enterState();
         mUISkills.activate();
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:DBAccountResponseEvent):void
         {
            mUISkills.refresh(false);
         });
         mTownStateMachine.townHeader.showCloseButton(true);
         super.resetHeaderLinks();
         setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("SKILLS_MENU",mTownStateMachine.townHeader.determineCallback,mTownStateMachine.townHeader.closeButton,mTownStateMachine.townHeader.closeButton,mUISkills.selectPreviousHero,mUISkills.selectNextHero);
         mUISkills.refresh();
      }
      
      override public function exitState() : void
      {
         mUISkills.processChosenAvatar();
         mUISkills.deactivate();
         mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
         mDBFacade.menuNavigationController.popLayer("SKILLS_MENU");
         super.exitState();
      }
   }
}

