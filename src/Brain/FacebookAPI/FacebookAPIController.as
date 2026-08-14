package Brain.FacebookAPI
{
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import com.facebook.graph.Facebook;
   import flash.external.ExternalInterface;
   
   public class FacebookAPIController
   {
      
      protected var mAccessToken:String = "";
      
      protected var mScope:String;
      
      protected var mUserId:String = "";
      
      public function FacebookAPIController(facade:Facade, fbAppID:String)
      {
         super();
         var _loc3_:Object = {
            "appId":fbAppID,
            "status":true,
            "cookie":true,
            "xfbml":true,
            "frictionlessRequests":true,
            "oauth":true
         };
         Logger.debug("Initing app: " + fbAppID.toString());
         if(ExternalInterface.available)
         {
            Facebook.addJSEventListener("auth.authResponseChange",onAuthResponseChange);
            Facebook.init(fbAppID,handleInit,_loc3_);
         }
      }
      
      public function get accessToken() : String
      {
         return mAccessToken;
      }
      
      public function get fbUserId() : String
      {
         return mUserId;
      }
      
      private function onAuthResponseChange(response:Object) : void
      {
         Logger.debug("Auth response Changed");
      }
      
      protected function handleLogin(successCallback:Function) : void
      {
         Facebook.login((function():*
         {
            var detectLogin:Function;
            return detectLogin = function(param1:Object, param2:Object):void
            {
               if(param1)
               {
                  Logger.debug("Logged in to FB");
                  mAccessToken = param1.accessToken;
                  successCallback();
               }
               else
               {
                  Logger.debug("Login Failed ");
               }
            };
         })(),{"scope":mScope});
      }
      
      protected function handleInit(success:Object, fail:Object) : void
      {
         if(success)
         {
            Logger.debug("Init Success ");
            if(success.accessToken)
            {
               mAccessToken = success.accessToken;
            }
         }
         else
         {
            Logger.debug("Init Failed");
         }
      }
      
      protected function detectLogin(success:Object, fail:Object) : void
      {
         if(success)
         {
            Logger.debug("Logged in to FB");
            mAccessToken = success.accessToken;
         }
         else
         {
            Logger.debug("Login Failed ");
         }
      }
      
      protected function feedPost(feedName:String = " ", feedCaption:String = " ", feedDescription:String = " ", feedLink:String = "", feedPicLink:String = "", feedDisplay:String = "dialog", callback:Function = null, feedReceiverId:String = "", feedPropertiesArray:Object = null, feedActions:Object = null) : void
      {
         var _loc11_:Object = {
            "name":feedName,
            "link":feedLink,
            "picture":feedPicLink,
            "caption":feedCaption,
            "description":feedDescription,
            "to":feedReceiverId,
            "properties":feedPropertiesArray,
            "actions":feedActions
         };
         Facebook.ui("feed",_loc11_,callback,feedDisplay);
      }
      
      protected function friendRequests(requestMessage:String, requestTitle:String = "Invite Friends", requestDisplay:String = "dialog", callback:Function = null, requestFilters:Array = null, requestData:Object = null, requestMaxRecipients:String = "50", facebookId:String = "", excludeIds:Array = null) : void
      {
         var _loc10_:Object = {
            "message":requestMessage,
            "title":requestTitle,
            "filters":requestFilters,
            "max_recipients":requestMaxRecipients,
            "data":requestData,
            "to":facebookId,
            "exclude_ids":excludeIds
         };
         Facebook.ui("apprequests",_loc10_,callback,requestDisplay);
      }
      
      protected function postAchievement(fbID:String, params:Object, achievementCallback:Function = null) : void
      {
         var _loc4_:String = "/" + fbID + "/achievements";
         Facebook.api(_loc4_,achievementCallback,params,"POST");
      }
   }
}

