package Town
{
   import Facade.DBFacade;
   import UI.Training.UIHeroTraining;
   
   public class TrainTownSubState extends TownSubState
   {
      
      public static const NAME:String = "TrainTownSubState";
      
      private var mUIHeroTraining:UIHeroTraining;
      
      public function TrainTownSubState(dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,townStateMachine,"TrainTownSubState");
      }
      
      override protected function setupState() : void
      {
         super.setupState();
         mUIHeroTraining = new UIHeroTraining(mDBFacade,mTownStateMachine.townSwf,mRootMovieClip,mTownStateMachine.townHeader);
      }
      
      override public function enterState() : void
      {
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("TRAINING_MENU",mTownStateMachine.townHeader.determineCallback,mTownStateMachine.townHeader.closeButton,mTownStateMachine.townHeader.closeButton);
         super.enterState();
         if(mUIHeroTraining)
         {
            mUIHeroTraining.enableHud();
         }
         mTownStateMachine.townHeader.showCloseButton(true);
         mUIHeroTraining.animateEntry();
      }
      
      override public function destroy() : void
      {
         if(mUIHeroTraining)
         {
            mUIHeroTraining.destroy();
            mUIHeroTraining = null;
         }
         super.destroy();
      }
      
      override public function exitState() : void
      {
         mDBFacade.menuNavigationController.popLayer("TRAINING_MENU");
         if(mUIHeroTraining)
         {
            mUIHeroTraining.processChosenAvatar();
            mUIHeroTraining.disableHud();
         }
         super.exitState();
      }
   }
}

