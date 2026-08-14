package Account
{
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import UI.Popup.DBUIOneButtonPopup;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class FacebookAccountInfo
   {
      
      private var mDBFacade:DBFacade;
      
      private var mId:String;
      
      private var mName:String;
      
      private var mFirstName:String;
      
      private var mLastName:String;
      
      private var mGender:String;
      
      private var mLocale:String;
      
      private var mType:String;
      
      private var mProfilePic:MovieClip = new MovieClip();
      
      private var mFriends:Array;
      
      public function FacebookAccountInfo(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         loadBasicAccountInfo();
         loadProfilePic();
      }
      
      private function loadedFacebookAccountInfo(e:Event) : void
      {
         var _loc3_:URLLoader = URLLoader(e.target);
         var _loc2_:Object = com.adobe.serialization.json.JSON.decode(_loc3_.data);
         mId = _loc2_["id"];
         mName = _loc2_["name"];
         mFirstName = _loc2_["first_name"];
         mLastName = _loc2_["last_name"];
         mGender = _loc2_["gender"];
         mLocale = _loc2_["locale"];
         mType = _loc2_["type"];
      }
      
      private function popupError(event:Event) : void
      {
         Logger.warn("FacebookAccountInfo Error: " + event.toString() + " " + event.target.toString());
         var _loc2_:DBUIOneButtonPopup = new DBUIOneButtonPopup(mDBFacade,"Error","Error getting Facebook information","OK",null);
         MemoryTracker.track(_loc2_,"DBUIOneButtonPopup - created in FacebookAccountInfo.popupError()");
      }
      
      private function ignoreError(event:Event) : void
      {
      }
      
      public function cloneProfilePic() : DisplayObject
      {
         var _loc2_:Loader = null;
         var _loc1_:String = null;
         var _loc5_:URLRequest = null;
         var _loc3_:LoaderContext = null;
         var _loc4_:* = null;
         if(mDBFacade.facebookPlayerId)
         {
            _loc2_ = new Loader();
            _loc1_ = "https://graph.facebook.com/" + mDBFacade.facebookPlayerId + "/picture";
            _loc5_ = new URLRequest(_loc1_);
            _loc2_.contentLoaderInfo.addEventListener("ioError",ignoreError);
            _loc2_.contentLoaderInfo.addEventListener("securityError",ignoreError);
            _loc3_ = new LoaderContext(true);
            _loc3_.checkPolicyFile = true;
            _loc2_.load(_loc5_,_loc3_);
            return _loc2_;
         }
         return null;
      }
      
      private function loadProfilePic() : void
      {
         var _loc2_:Loader = null;
         var _loc1_:String = null;
         var _loc4_:URLRequest = null;
         var _loc3_:LoaderContext = null;
         if(mDBFacade.facebookPlayerId)
         {
            _loc2_ = new Loader();
            _loc1_ = "https://graph.facebook.com/" + mDBFacade.facebookPlayerId + "/picture";
            _loc4_ = new URLRequest(_loc1_);
            _loc2_.contentLoaderInfo.addEventListener("ioError",ignoreError);
            _loc2_.contentLoaderInfo.addEventListener("securityError",ignoreError);
            _loc3_ = new LoaderContext(true);
            _loc3_.checkPolicyFile = true;
            _loc2_.load(_loc4_,_loc3_);
            mProfilePic.addChild(_loc2_);
         }
      }
      
      private function loadBasicAccountInfo() : void
      {
         var _loc2_:URLLoader = null;
         var _loc1_:String = null;
         var _loc3_:URLRequest = null;
         if(mDBFacade.facebookController && mDBFacade.facebookController.accessToken)
         {
            _loc2_ = new URLLoader();
            _loc1_ = "https://graph.facebook.com/me?access_token=" + mDBFacade.facebookController.accessToken;
            _loc3_ = new URLRequest(_loc1_);
            _loc2_.addEventListener("ioError",popupError);
            _loc2_.addEventListener("securityError",popupError);
            _loc2_.addEventListener("complete",loadedFacebookAccountInfo);
            _loc2_.load(_loc3_);
         }
      }
      
      public function loadFriends(callback:Function = null) : void
      {
         var loader:URLLoader;
         var picUrl:String;
         var url:URLRequest;
         Logger.debug("loadFriends");
         if(mFriends)
         {
            Logger.debug("loadFriends already created: " + mFriends.length.toString());
            if(callback != null)
            {
               callback(mFriends);
            }
            return;
         }
         if(mDBFacade.facebookController && mDBFacade.facebookController.accessToken)
         {
            Logger.debug("loadFriends: calling graph api");
            loader = new URLLoader();
            picUrl = "https://graph.facebook.com/me/friends?access_token=" + mDBFacade.facebookController.accessToken;
            url = new URLRequest(picUrl);
            loader.addEventListener("ioError",popupError);
            loader.addEventListener("securityError",popupError);
            loader.addEventListener("complete",function(param1:Event):void
            {
               Logger.debug("loadFriends: graph api COMPLETE");
               loadedFriends(param1);
               if(callback != null)
               {
                  callback(mFriends);
               }
            });
            loader.load(url);
         }
         else
         {
            Logger.warn("loadFriends: no facebookAccessToken");
         }
      }
      
      private function loadedFriends(e:Event) : void
      {
         var _loc3_:URLLoader = URLLoader(e.target);
         var _loc2_:Object = com.adobe.serialization.json.JSON.decode(_loc3_.data);
         mFriends = _loc2_.data as Array;
         Logger.debug("loadedFriends: " + mFriends.length.toString());
      }
      
      public function loadFriendProfilePic(friendId:String, type:String = "square") : DisplayObject
      {
         var _loc4_:Loader = new Loader();
         var _loc3_:String = "https://graph.facebook.com/" + friendId + "/picture?type=" + type;
         var _loc6_:URLRequest = new URLRequest(_loc3_);
         _loc4_.contentLoaderInfo.addEventListener("ioError",ignoreError);
         _loc4_.contentLoaderInfo.addEventListener("securityError",ignoreError);
         var _loc5_:LoaderContext = new LoaderContext(true);
         _loc5_.checkPolicyFile = true;
         _loc4_.load(_loc6_,_loc5_);
         return _loc4_;
      }
      
      public function get id() : String
      {
         return mId;
      }
      
      public function get name() : String
      {
         return mName;
      }
      
      public function get firstName() : String
      {
         return mFirstName;
      }
      
      public function get lastName() : String
      {
         return mLastName;
      }
      
      public function get gender() : String
      {
         return mGender;
      }
      
      public function get locale() : String
      {
         return mLocale;
      }
      
      public function get type() : String
      {
         return mType;
      }
      
      public function get profilePic() : DisplayObject
      {
         return mProfilePic;
      }
   }
}

