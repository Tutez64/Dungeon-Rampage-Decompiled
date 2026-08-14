package Brain.StateMachine
{
   import Brain.Logger.Logger;
   
   public class StateMachine
   {
      
      protected var mCurrentState:State;
      
      public function StateMachine()
      {
         super();
      }
      
      public function get currentState() : *
      {
         return mCurrentState;
      }
      
      public function set currentState(state:State) : void
      {
         mCurrentState = state;
      }
      
      public function get currentStateName() : String
      {
         if(mCurrentState)
         {
            return mCurrentState.name;
         }
         return "";
      }
      
      public function transitionToState(nextState:State) : Boolean
      {
         if(mCurrentState)
         {
            if(!mCurrentState.running)
            {
               Logger.warn("transitionToState (" + nextState.name + ") but old state (" + mCurrentState.name + ") was not running.");
            }
            mCurrentState.exitState();
         }
         mCurrentState = nextState;
         mCurrentState.enterState();
         return true;
      }
      
      public function destroy() : void
      {
         if(mCurrentState && mCurrentState.running)
         {
            mCurrentState.exitState();
         }
         mCurrentState = null;
      }
   }
}

