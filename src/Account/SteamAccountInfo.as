package Account
{
   import Brain.Event.EventListeners;
   import Brain.Logger.Logger;
   import Brain.Utils.HttpStatusEventUtils;
   import Facade.DBFacade;
   import com.amanitadesign.steam.SteamEvent;
   import com.amanitadesign.steam.SteamResults;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.utils.describeType;
   
   public class SteamAccountInfo
   {
      
      public static const steamRetryDelay:Number = 0.25;
      
      public static const steamWarnAfterRetries:int = 240;
      
      public static const waitingForSteamText:String = "WAITING FOR STEAM...";
      
      private static const showWaitingAfterRetries:int = 4;
      
      public static var steamRetries:int = 0;
      
      public function SteamAccountInfo()
      {
         super();
      }
      
      public static function startSteam(dbFacade:DBFacade) : void
      {
         var ticketRequest:uint;
         try
         {
            if(!dbFacade.mSteamworks.init())
            {
               Logger.warn("STEAMWORKS API is NOT available");
               dbFacade.mSteamLoginFailure = "the Steamworks API did not start";
            }
            else
            {
               Logger.info("STEAMWORKS API is available\n");
               EventListeners.add(dbFacade.mSteamworks,SteamEvent.STEAM_RESPONSE,function(param1:SteamEvent):void
               {
                  if(param1.req_type == 33)
                  {
                     onWebApiTicketResponse(dbFacade,param1.response);
                  }
               });
               dbFacade.mSteamUserId = dbFacade.mSteamworks.getUserID();
               Logger.info("STEAMWORKS User ID: " + dbFacade.mSteamUserId);
               dbFacade.mSteamAppId = dbFacade.mSteamworks.getAppID();
               Logger.info("STEAMWORKS App ID: " + dbFacade.mSteamAppId);
               dbFacade.mSteamPersonaName = dbFacade.mSteamworks.getPersonaName();
               Logger.info("STEAMWORKS Persona name: " + dbFacade.mSteamPersonaName);
               ticketRequest = uint(dbFacade.mSteamworks.getAuthTicketForWebApi());
               Logger.info("[Steam] Requested the login ticket, handle " + ticketRequest);
               if(ticketRequest == 0)
               {
                  dbFacade.mSteamLoginFailure = "the login ticket request failed";
               }
            }
         }
         catch(e:Error)
         {
            dbFacade.mSteamLoginFailure = "Steamworks error: " + e.message;
            Logger.warn("*** STEAMWORKS ERROR ***");
            Logger.error(e.message,e);
         }
      }
      
      private static function onWebApiTicketResponse(dbFacade:DBFacade, result:int) : void
      {
         var _loc3_:String = null;
         Logger.info("[Steam] RESPONSE_OnGetAuthTicketForWebApiResponse: " + steamResultName(result));
         if(result != 1)
         {
            dbFacade.mSteamLoginFailure = "Steam returned " + steamResultName(result) + " for the login ticket";
            return;
         }
         try
         {
            _loc3_ = dbFacade.mSteamworks.getAuthTicketForWebApiResultHexString();
            if(!_loc3_)
            {
               dbFacade.mSteamLoginFailure = "Steam returned OK but no login ticket";
               return;
            }
            dbFacade.mSteamAuthTicketHandle = dbFacade.mSteamworks.getAuthTicketForWebApiResultHandle();
            dbFacade.mSteamWebApiAuthTicket = _loc3_;
         }
         catch(e:Error)
         {
            dbFacade.mSteamLoginFailure = "Steamworks error reading the login ticket: " + e.message;
         }
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
            if(dbFacade.loadingStateLeft)
            {
               Logger.info("Stopped waiting for the Steam login ticket: the game left the loading state");
               return;
            }
            if(dbFacade.mSteamLoginFailure)
            {
               Logger.fatal("Could not log in through Steam: " + dbFacade.mSteamLoginFailure.replace(/\.+$/,"") + ". Make sure Steam is running, logged in and online, then restart the game");
               return;
            }
            steamRetries = steamRetries + 1;
            dbFacade.mTween.delayedCall(0.25,function():void
            {
               spinWaitOnSteamTokenReceived(dbFacade,successCallback);
            });
            if(steamRetries >= 4)
            {
               dbFacade.setLoadingBarText("WAITING FOR STEAM...");
            }
            if(steamRetries == 240)
            {
               Logger.warn("Steam login ticket not received after 60 seconds. Steam may be offline or reconnecting to its servers; still waiting");
            }
            if(steamRetries <= 240 || steamRetries % 240 == 0)
            {
               Logger.info("Steam login ticket not received yet from Steam SDK, waiting another 0.25 seconds. [" + steamRetries + "]");
            }
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
               dbFacade.mSteamAvatarUrl = _loc2_.steamAvatarUrl;
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
            EventListeners.remove(urlLoader,"httpResponseStatus",onResponseStatus);
            EventListeners.remove(urlLoader,"ioError",onLoadError);
            EventListeners.remove(urlLoader,"securityError",onLoadError);
            EventListeners.remove(urlLoader,"certificateError",onLoadError);
            EventListeners.remove(urlLoader,"complete",onCompleted);
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
         EventListeners.add(urlLoader,"httpResponseStatus",onResponseStatus);
         EventListeners.add(urlLoader,"ioError",onLoadError);
         EventListeners.add(urlLoader,"securityError",onLoadError);
         EventListeners.add(urlLoader,"certificateError",onLoadError);
         EventListeners.add(urlLoader,"complete",onCompleted);
         responseStatusCode = 0;
         urlLoader.load(request);
      }
      
      public static function steamResultName(result:int) : String
      {
         var _loc3_:String = null;
         for each(var _loc2_:XML in describeType(SteamResults).constant)
         {
            _loc3_ = String(_loc2_.@name);
            if(SteamResults[_loc3_] == result)
            {
               return _loc3_ + " (" + result + ")";
            }
         }
         return String(result);
      }
   }
}

