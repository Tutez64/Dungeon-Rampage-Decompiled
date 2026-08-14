package UI.Training
{
   import Brain.UI.UIProgressBar;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   
   public class UIStatProgressBar
   {
      
      private var mDBFacade:DBFacade;
      
      private var mProgressBar:UIProgressBar;
      
      private var mCompletedClip:MovieClip;
      
      public function UIStatProgressBar(dbFacade:DBFacade, progressClip:MovieClip, completedClip:MovieClip)
      {
         super();
         mDBFacade = dbFacade;
         mProgressBar = new UIProgressBar(mDBFacade,progressClip.training_bar);
         mProgressBar.enabled = false;
         mCompletedClip = completedClip;
         completed = false;
      }
      
      public function get progressBar() : UIProgressBar
      {
         return mProgressBar;
      }
      
      public function set value(val:Number) : void
      {
         mProgressBar.value = val;
      }
      
      public function set completed(val:Boolean) : void
      {
         mCompletedClip.visible = val;
      }
      
      public function destroy() : void
      {
         mProgressBar.destroy();
      }
   }
}

