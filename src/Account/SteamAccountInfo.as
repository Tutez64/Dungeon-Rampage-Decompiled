package Account
{
   import Brain.Logger.Logger;
   import Brain.Utils.HttpStatusEventUtils;
   import Facade.DBFacade;
   import com.greensock.TweenMax;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   
   public class SteamAccountInfo
   {
      
      public static const steamRetryDelay:Number = 0.25;
      
      public static const maxSteamRetries:Number = 80;
      
      public static var steamRetries:int = 0;
      
      public function SteamAccountInfo()
      {
         super();
      }
      
      public static function getOrCreateAccount(dbFacade:DBFacade, successCallback:Function) : void
      {
         if(!dbFacade.mUseSteamLogin)
         {
            Logger.info("Skipping logging into Steam.");
            successCallback();
            return;
         }
         spinWaitOnSteamTokenReceived(dbFacade,function():void
         {
            SteamAccountInfo.getOrCreateAccountAfterSteamTokenReceived(dbFacade,successCallback);
         });
      }
      
      public static function spinWaitOnSteamTokenReceived(dbFacade:DBFacade, successCallback:Function) : void
      {
         if(dbFacade.mSteamWebApiAuthTicket)
         {
            successCallback();
         }
         else
         {
            if(steamRetries >= 80)
            {
               Logger.fatal("Steam login ticket not received from Steam SDK after 80 attempts. Aborting. Try restarting Steam completely");
            }
            steamRetries = steamRetries + 1;
            Logger.info("Steam login ticket not received yet from Steam SDK, waiting another 0.25 seconds. [" + steamRetries + "/" + 80 + "]");
            TweenMax.delayedCall(0.25,function():void
            {
               spinWaitOnSteamTokenReceived(dbFacade,successCallback);
            });
         }
      }
      
      public static function getOrCreateAccountAfterSteamTokenReceived(dbFacade:DBFacade, successCallback:Function) : void
      {
         var apiPath:String;
         var request:URLRequest;
         var jsonHeader:URLRequestHeader;
         var requestObject:Object;
         var requestJsonString:String;
         var urlLoader:URLLoader;
         var responseStatusCode:int;
         var onResponseStatus:* = function(param1:HTTPStatusEvent):void
         {
            responseStatusCode = param1.status;
            dbFacade.initialLoginTraceId = HttpStatusEventUtils.getTraceId(param1);
         };
         var onLoadError:* = function(param1:Event):void
         {
            destroyCallbacks();
            Logger.info("[Steam] Cancelling Auth token due to failure");
            dbFacade.mSteamworks.cancelAuthTicket(dbFacade.mSteamAuthTicketHandle);
            var _loc2_:String = "[" + responseStatusCode + "] Error Logging into Dungeon Rampage Server with Steam Login. HTTP Error: " + responseStatusCode + "; TraceId: " + dbFacade.initialLoginTraceId + "; IOError: " + param1.toString();
            if(param1.target && param1.target.data)
            {
               _loc2_ += "; Response: " + param1.target.data;
            }
            if(dbFacade.mainStateMachine)
            {
               if(responseStatusCode == 0)
               {
                  dbFacade.mainStateMachine.enterSocketErrorState(1503);
               }
               else
               {
                  dbFacade.mainStateMachine.enterSocketErrorState(1500,responseStatusCode.toString());
               }
               Logger.error(_loc2_);
            }
            else
            {
               Logger.fatal(_loc2_);
            }
         };
         var onCompleted:* = function(param1:Event):void
         {
            var _loc2_:Object = null;
            if(responseStatusCode < 100 || responseStatusCode >= 400)
            {
               onLoadError(param1);
            }
            else
            {
               destroyCallbacks();
               _loc2_ = JSON.parse(param1.target.data);
               dbFacade.accountId = _loc2_.playerId;
               dbFacade.mSteamIsFlagged = _loc2_.isFlagged;
               dbFacade.mSteamIsFlaggedDueToFamilySharingOwnerIsFlagged = _loc2_.isFlaggedDueToFamilySharingOwnerIsFlagged;
               dbFacade.mSteamFlaggedUntilAfterDateString = _loc2_.flaggedUntilAfterDateString;
               dbFacade.mSteamIsFlaggedDueToFamilySharingOwnerName = _loc2_.isFlaggedDueToFamilySharingOwnerName;
               Logger.info("[Steam] Initial login successful! [" + responseStatusCode + "] " + dbFacade.initialLoginTraceId);
               Logger.info("[Steam] Steam account number is " + SteamIdConverter.convertSteamID64ToAccountId(dbFacade.mSteamUserId) + " and shorter id is https://s.team/p/" + SteamIdConverter.convertSteamID64ToSteamHex(dbFacade.mSteamUserId) + " which reverses to " + SteamIdConverter.convertSteamHexToSteamID64(SteamIdConverter.convertSteamID64ToSteamHex(dbFacade.mSteamUserId)));
               dbFacade.validationToken = _loc2_.playerToken;
               Logger.info("[Steam] Cancelling Auth token now that it is used");
               dbFacade.mSteamworks.cancelAuthTicket(dbFacade.mSteamAuthTicketHandle);
               successCallback();
            }
         };
         var destroyCallbacks:* = function():void
         {
            urlLoader.removeEventListener("httpResponseStatus",onResponseStatus);
            urlLoader.removeEventListener("ioError",onLoadError);
            urlLoader.removeEventListener("securityError",onLoadError);
            urlLoader.removeEventListener("certificateError",onLoadError);
            urlLoader.removeEventListener("complete",onCompleted);
         };
         Logger.info("Logging into server with id " + dbFacade.mSteamUserId + " and persona name " + dbFacade.mSteamPersonaName + " for app id " + dbFacade.mSteamAppId);
         if(!dbFacade.mSteamUserId || !dbFacade.mSteamPersonaName || dbFacade.mSteamAppId == 0)
         {
            Logger.fatal("Failed to get user\'s data from Steam. Maybe Steam is not running?");
         }
         apiPath = dbFacade.steamAPIRoot + "login/" + dbFacade.mSteamUserId;
         request = new URLRequest(apiPath);
         request.idleTimeout = 90000;
         request.method = "PUT";
         jsonHeader = new URLRequestHeader("Content-type","application/json");
         request.requestHeaders.push(jsonHeader);
         requestObject = {
            "steamUserId":dbFacade.mSteamUserId,
            "steamUserPersonaName":dbFacade.mSteamPersonaName,
            "steamWebApiAuthTicket":dbFacade.mSteamWebApiAuthTicket,
            "requestingSteamAppId":dbFacade.mSteamAppId
         };
         requestJsonString = JSON.stringify(requestObject);
         request.data = requestJsonString;
         urlLoader = new URLLoader();
         urlLoader.addEventListener("httpResponseStatus",onResponseStatus);
         urlLoader.addEventListener("ioError",onLoadError);
         urlLoader.addEventListener("securityError",onLoadError);
         urlLoader.addEventListener("certificateError",onLoadError);
         urlLoader.addEventListener("complete",onCompleted);
         responseStatusCode = 0;
         urlLoader.load(request);
      }
   }
}

