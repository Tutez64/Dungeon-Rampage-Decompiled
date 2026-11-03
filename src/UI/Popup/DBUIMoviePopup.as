package UI.Popup
{
   import Brain.Event.EventListeners;
   import Brain.UI.UIButton;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TextUtil;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   
   public class DBUIMoviePopup extends DBUIOneButtonPopup
   {
      
      private static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      private var mContainerMC:MovieClip = new MovieClip();
      
      private var mLoader:Loader;
      
      private var mMoviePlayer:Object;
      
      private var mWidth:Number;
      
      private var mHeight:Number;
      
      private var mPopUpClassName:String;
      
      private var mLoadingPopUp:DBUIPopup;
      
      private var mUseCurtain:Boolean = true;
      
      public function DBUIMoviePopup(dbFacade:DBFacade, popUpClassName:String, titleText:String, contentText:String, moviePath:String, centerText:String, centerCallback:Function, width:Number, height:Number, showPagination:Boolean)
      {
         mPopUpClassName = popUpClassName;
         mWidth = width;
         mHeight = height;
         mUseCurtain = !showPagination;
         super(dbFacade,"NEWS_MOVIE_POPUP",titleText,mContainerMC,centerText,centerCallback);
         TextUtil.setText(mMessage,contentText);
         if(moviePath != null && moviePath.length > 0)
         {
            mLoadingPopUp = new DBUIPopup(mDBFacade,"","LOADING",null,true,false);
            MemoryTracker.track(mLoadingPopUp,"DBUIPopup - created in DBUIMoviePopup.DBUIMoviePopup()");
            mLoader = new Loader();
            EventListeners.add(mLoader.contentLoaderInfo,"init",onLoaderInit);
            EventListeners.add(mLoader.contentLoaderInfo,"ioError",loaderIOErrorHandler);
            mLoader.load(new URLRequest(moviePath));
         }
         if(!showPagination)
         {
            mPopup.center_button_news.visible = false;
            mPopup.pagination.visible = false;
         }
         else
         {
            mPopup.center_button.visible = false;
            mCenterButton = new UIButton(mDBFacade,mPopup.center_button_news);
            mCenterButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            TextUtil.setText(mCenterButton.label,mCenterText);
            mCenterButton.releaseCallback = function():void
            {
               close(mCenterCallback);
            };
         }
      }
      
      override protected function animatedEntrance() : void
      {
         super.animatedEntrance();
      }
      
      override public function getPagination() : MovieClip
      {
         return mPopup.pagination;
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override protected function getClassName() : String
      {
         return mPopUpClassName;
      }
      
      private function loaderIOErrorHandler(e:IOErrorEvent) : void
      {
         mLoadingPopUp.destroy();
         mLoadingPopUp = null;
         destroy();
      }
      
      private function onLoaderInit(event:Event) : void
      {
         mContainerMC.addChild(mLoader);
         mLoader.x = -mWidth / 2;
         mLoader.y = -mHeight / 2;
         EventListeners.add(mLoader.content,"onReady",onPlayerReady);
         EventListeners.add(mLoader.content,"onError",onPlayerError);
         EventListeners.add(mLoader.content,"onStateChange",onPlayerStateChange);
         EventListeners.add(mLoader.content,"onPlaybackQualityChange",onVideoPlaybackQualityChange);
      }
      
      private function onPlayerReady(event:Event) : void
      {
         mLoadingPopUp.destroy();
         mLoadingPopUp = null;
         mMoviePlayer = mLoader.content;
         mMoviePlayer.setSize(mWidth,mHeight);
      }
      
      private function onPlayerError(event:Event) : void
      {
         mLoadingPopUp.destroy();
         mLoadingPopUp = null;
      }
      
      private function onPlayerStateChange(event:Event) : void
      {
      }
      
      private function onVideoPlaybackQualityChange(event:Event) : void
      {
      }
      
      override public function destroy() : void
      {
         super.destroy();
         mContainerMC = null;
         if(mLoader)
         {
            EventListeners.remove(mLoader.contentLoaderInfo,"init",onLoaderInit);
            if(mLoader.content)
            {
               EventListeners.remove(mLoader.content,"onReady",onPlayerReady);
               EventListeners.remove(mLoader.content,"onError",onPlayerError);
               EventListeners.remove(mLoader.content,"onStateChange",onPlayerStateChange);
               EventListeners.remove(mLoader.content,"onPlaybackQualityChange",onVideoPlaybackQualityChange);
               mLoader.unloadAndStop();
            }
            mLoader = null;
         }
      }
   }
}

