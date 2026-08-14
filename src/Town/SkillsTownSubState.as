package Town
{
   import Facade.DBFacade;
   
   public class SkillsTownSubState extends TownSubState
   {
      
      public static const NAME:String = "SkillsTownSubState";
      
      public function SkillsTownSubState(dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,townStateMachine,"SkillsTownSubState");
      }
      
      override protected function setupState() : void
      {
         super.setupState();
      }
      
      override public function enterState() : void
      {
         super.enterState();
         mTownStateMachine.townHeader.showCloseButton(true);
      }
   }
}

