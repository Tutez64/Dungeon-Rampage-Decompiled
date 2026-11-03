package UI
{
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   
   public class CutsceneOverlay
   {
      
      private static var SkipButtonArt:Class = db_UI_skip_button_swf;
      
      private static var ColiseumAdvertArt:Class = db_UI_skip_button_swf$f3d44e943f8de259a193faafa412a2681948871216;
      
      private var mDBFacade:DBFacade;
      
      private var mSkipButton:UIButton;
      
      private var mColiseumAdvert:MovieClip;
      
      private var mColiseumAdvertButton:UIButton;
      
      public function CutsceneOverlay(dbFacade:DBFacade, skipCallback:Function, withColiseumAdvert:Boolean = true)
      {
         super();
         mDBFacade = dbFacade;
         mSkipButton = new UIButton(mDBFacade,new SkipButtonArt() as MovieClip);
         mSkipButton.root.x = 1850;
         mSkipButton.root.y = 120;
         mSkipButton.releaseCallback = skipCallback;
         if(!withColiseumAdvert)
         {
            return;
         }
         mColiseumAdvert = new ColiseumAdvertArt() as MovieClip;
         mColiseumAdvert.gotoAndStop(1);
         mColiseumAdvert.x = 250;
         mColiseumAdvert.y = 928;
         mColiseumAdvertButton = new UIButton(mDBFacade,mColiseumAdvert.button);
         mColiseumAdvertButton.releaseCallback = onColiseumAdvertClicked;
         mSkipButton.isAbove(mColiseumAdvertButton);
         mColiseumAdvertButton.isToTheLeftOf(mSkipButton);
      }
      
      public function get skipButton() : UIButton
      {
         return mSkipButton;
      }
      
      public function get coliseumAdvert() : MovieClip
      {
         return mColiseumAdvert;
      }
      
      private function onColiseumAdvertClicked() : void
      {
         mDBFacade.steamAchievementsHelper.unlockAchievement("TROJAN_HORSE");
      }
      
      public function destroy() : void
      {
         mSkipButton.destroy();
         if(mColiseumAdvertButton)
         {
            mColiseumAdvertButton.destroy();
         }
         mSkipButton = null;
         mColiseumAdvert = null;
         mColiseumAdvertButton = null;
         mDBFacade = null;
      }
   }
}

