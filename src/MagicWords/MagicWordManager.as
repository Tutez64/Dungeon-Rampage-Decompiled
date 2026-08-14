package MagicWords
{
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.jsonRPC.JSONRPCService;
   import Facade.DBFacade;
   import com.junkbyte.console.KeyBind;
   
   public class MagicWordManager
   {
      
      private var mDBFacade:DBFacade;
      
      private var mCheckedAdmin:Boolean = false;
      
      private var mIsAdmin:Boolean = false;
      
      public function MagicWordManager(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         setupClientWords();
         setupPhpServerWords();
         Logger.bindKey(new KeyBind("`"),askForAdmin);
      }
      
      public function askForAdmin() : void
      {
         var askForAdminFunc:Function;
         if(!mCheckedAdmin)
         {
            askForAdminFunc = JSONRPCService.getFunction("AskIfAdmin",mDBFacade.rpcRoot + "webMagicWord");
            askForAdminFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,mDBFacade.demographics,function(param1:int):void
            {
               if(param1)
               {
                  mIsAdmin = true;
                  Logger.enableCommandLine();
                  Logger.displayConsole();
                  Logger.log("Setting Console Commands for admin. Push the CL button on top of this frame for the commandline.");
               }
               else
               {
                  Logger.log("You are not an admin.");
               }
               mCheckedAdmin = true;
            },function(param1:Error):void
            {
               Logger.log("PhpTime: ERROR:" + param1.toString());
            });
         }
         else if(mIsAdmin)
         {
            if(Logger.isConsoleVisible())
            {
               Logger.hideConsole();
            }
            else
            {
               Logger.displayConsole();
            }
         }
      }
      
      public function setupClientWords() : void
      {
         Logger.addSlashCommand("listAccountId",function():void
         {
            var _loc1_:int = int(mDBFacade.accountId);
            Logger.log("" + _loc1_);
         });
         Logger.addSlashCommand("helpCommands",function():void
         {
            Logger.log("These are the magic words:");
            Logger.listSlashCommands();
         });
         Logger.addSlashCommand("test3",function(param1:String = ""):void
         {
            var _loc2_:Array = param1.split(/\s+/);
            Logger.log("" + _loc2_);
         });
         Logger.addSlashCommand("showCollisions",function(param1:String = ""):void
         {
            Logger.log("showing Collisions");
            mDBFacade.showCollisions = true;
         });
         Logger.addSlashCommand("setClockOffset",function(param1:String = ""):void
         {
            var _loc5_:Number = NaN;
            var _loc3_:Number = NaN;
            var _loc4_:Number = NaN;
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0])
            {
               showHelp();
               Logger.log("/setClockOffset days [hours] [minutes]");
               Logger.log("\tsets the offset for the webserver time.");
            }
            else
            {
               _loc5_ = Number(_loc2_[0]);
               _loc3_ = 0;
               _loc4_ = 0;
               if(_loc2_.length >= 2)
               {
                  _loc3_ = Number(_loc2_[1]);
               }
               if(_loc2_.length >= 3)
               {
                  _loc4_ = Number(_loc2_[2]);
               }
               GameClock.setUserWebOffset(_loc5_,_loc3_,_loc4_);
            }
         });
      }
      
      public function setupPhpServerWords() : void
      {
         Logger.addSlashCommand("PhpTime",function():void
         {
            PhpTime();
         });
         Logger.addSlashCommand("PhpTest",function():void
         {
            PhpTest();
         });
         Logger.addSlashCommand("PhpUnlockAllMapNodes",function():void
         {
            PhpUnlockAllMapNodes();
         });
         Logger.addSlashCommand("PhpLockAllMapNodes",function():void
         {
            PhpLockAllMapNodes();
         });
         Logger.addSlashCommand("PhpUnlockMapNodes",function(param1:String = ""):void
         {
            var _loc3_:int = 0;
            var _loc4_:int = 0;
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0])
            {
               showHelp();
               Logger.log("/PhpUnlockMapNodes startNode [endNode]");
               Logger.log("\tunlocks map nodes from the start node to the end node");
            }
            else
            {
               _loc3_ = int(_loc2_[0]);
               _loc4_ = 0;
               if(_loc2_.length >= 2)
               {
                  _loc4_ = int(_loc2_[1]);
               }
               PhpUnlockMapNodes(_loc3_,_loc4_);
            }
         });
         Logger.addSlashCommand("PhpGiveGems",function(param1:String = ""):void
         {
            var _loc3_:int = 0;
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0])
            {
               showHelp();
               Logger.log("/PhpGiveGems numberGems");
               Logger.log("\tgives you gems.");
            }
            else
            {
               _loc3_ = int(_loc2_[0]);
               PhpGiveGems(_loc3_);
            }
         });
         Logger.addSlashCommand("PhpGiveCoins",function(param1:String = ""):void
         {
            var _loc3_:int = 0;
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0])
            {
               showHelp();
               Logger.log("/PhpGiveCoins numberCoins");
               Logger.log("\tgives you coins.");
            }
            else
            {
               _loc3_ = int(_loc2_[0]);
               PhpGiveCoins(_loc3_);
            }
         });
         Logger.addSlashCommand("PhpGiveXp",function(param1:String = ""):void
         {
            var _loc3_:int = 0;
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0])
            {
               showHelp();
               Logger.log("/PhpGiveXp xp");
               Logger.log("\tgives the current avatar xp");
            }
            else
            {
               _loc3_ = int(_loc2_[0]);
               PhpGiveXp(_loc3_);
            }
         });
      }
      
      public function AskForAccountDetailsRefresh() : void
      {
         var useAccountBoosterFunc:Function = JSONRPCService.getFunction("AskForAccountDetails",mDBFacade.rpcRoot + "webMagicWord");
         useAccountBoosterFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,mDBFacade.demographics,function(param1:*):void
         {
            Logger.log("Got new account details");
            mDBFacade.dbAccountInfo.parseResponse(param1);
         },function(param1:Error):void
         {
            Logger.log("PhpTime: ERROR:" + param1.toString());
         });
      }
      
      public function PhpTime() : void
      {
         var requestFunc:Function = JSONRPCService.getFunction("getWebServerTimestamp",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("PhpTime:" + param1);
         },function(param1:Error):void
         {
            Logger.log("PhpTime: ERROR:" + param1.toString());
         });
      }
      
      public function PhpTest() : void
      {
         var argsArray:Array = new Array("Test");
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("PhpTest:" + param1);
         },function(param1:Error):void
         {
            Logger.log("PhpTest: ERROR:" + param1.toString());
         });
      }
      
      public function PhpUnlockAllMapNodes() : void
      {
         var argsArray:Array = new Array("UnlockAllMapNodes",mDBFacade.dbAccountInfo.activeAvatarId);
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("UnlockAllMapNodes:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("UnlockAllMapNodes: ERROR:" + param1.toString());
         });
      }
      
      public function PhpLockAllMapNodes() : void
      {
         var argsArray:Array = new Array("LockAllMapNodes",mDBFacade.dbAccountInfo.activeAvatarId);
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("LockAllMapNodes:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("LockAllMapNodes: ERROR:" + param1.toString());
         });
      }
      
      public function PhpUnlockMapNodes(startNode:int, endNode:int = 0) : void
      {
         var argsArray:Array;
         var requestFunc:Function;
         if(endNode < startNode)
         {
            endNode = startNode;
         }
         argsArray = new Array("UnlockMapNodes",mDBFacade.dbAccountInfo.activeAvatarId,startNode,endNode);
         requestFunc = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("UnlockMapNodes:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("UnlockMapNodes: ERROR:" + param1.toString());
         });
      }
      
      public function PhpGiveGems(numGems:int) : void
      {
         var argsArray:Array = new Array("GiveGems",numGems);
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("GiveGems:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("GiveGems: ERROR:" + param1.toString());
         });
      }
      
      public function PhpGiveCoins(numCoins:int) : void
      {
         var argsArray:Array = new Array("GiveCoins",numCoins);
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("GiveCoins:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("GiveCoins: ERROR:" + param1.toString());
         });
      }
      
      public function PhpGiveXp(xpAmount:int) : void
      {
         var argsArray:Array = new Array("GiveXp",mDBFacade.dbAccountInfo.activeAvatarId,xpAmount);
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("GiveXp:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("GiveXp: ERROR:" + param1.toString());
         });
      }
      
      public function showHelp() : void
      {
         Logger.log("Please use the command following this format:");
         Logger.log("/command parameter [optional parameter]");
      }
   }
}

