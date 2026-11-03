package MagicWords
{
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.jsonRPC.JSONRPCService;
   import Facade.DBFacade;
   import Metrics.DrawCallGraph;
   import Metrics.GpuMemoryGraph;
   import Metrics.StarlingStatsReporter;
   import com.junkbyte.console.KeyBind;
   
   public class MagicWordManager
   {
      
      private var mDBFacade:DBFacade;
      
      private var mCheckedAdmin:Boolean = false;
      
      private var mIsAdmin:Boolean = false;
      
      private var mStarlingStatsReporter:StarlingStatsReporter;
      
      private var mGpuMemoryGraph:GpuMemoryGraph;
      
      private var mDrawCallGraph:DrawCallGraph;
      
      private var mSmallTextOverlay:SmallTextOverlay;
      
      public function MagicWordManager(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         setupClientWords();
         setupServerWords();
         Logger.bindKey(new KeyBind("`"),askForAdmin);
         mGpuMemoryGraph = new GpuMemoryGraph(dbFacade);
         mDrawCallGraph = new DrawCallGraph(dbFacade);
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
               Logger.log("AskIfAdmin: ERROR:" + param1.toString());
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
         Logger.addSlashCommand("showFps",function():void
         {
            mDBFacade.toggleFpsOverlay();
            Logger.log("Toggled FPS overlay");
         });
         Logger.addSlashCommand("showSmallText",function(param1:String = ""):void
         {
            var _loc2_:SmallTextOverlay = null;
            var _loc3_:Object = parseSmallTextOptions(param1);
            if(_loc3_ == null)
            {
               return;
            }
            if(mSmallTextOverlay != null)
            {
               _loc2_ = mSmallTextOverlay;
               mSmallTextOverlay = null;
               _loc2_.destroy();
               Logger.log("Small-text overlay off");
            }
            else
            {
               mSmallTextOverlay = new SmallTextOverlay(mDBFacade,_loc3_.minPx,_loc3_.useLowercase);
               Logger.log("Outlining visible text under " + _loc3_.minPx + "px (" + (_loc3_.useLowercase ? "lowercase" : "uppercase") + " height)");
            }
         },"Toggle text outlines: /showSmallText [px] [uppercase|lowercase] (default 9, uppercase)");
         Logger.addSlashCommand("listSmallText",function(param1:String = ""):void
         {
            var _loc2_:Object = parseSmallTextOptions(param1);
            if(_loc2_ != null)
            {
               SmallTextOverlay.logSmallText(mDBFacade,_loc2_.minPx,_loc2_.useLowercase);
            }
         },"Log small text with display paths: /listSmallText [px] [uppercase|lowercase] (default 9, uppercase)");
         Logger.addSlashCommand("showStarlingStats",function(param1:String = ""):void
         {
            var _loc2_:Array = param1.length > 0 ? param1.split(/\s+/) : [];
            var _loc4_:String = _loc2_[0] || "right";
            var _loc3_:String = _loc2_[1] || "center";
            var _loc5_:Number = Number(_loc2_[2] || 5);
            mDBFacade.starlingLayerManager.toggleStatsAt(_loc4_,_loc3_,_loc5_);
            Logger.log("Toggled Starling stats overlay (fps, memory, gpu memory, draw calls) at " + _loc4_ + "/" + _loc3_);
         },"Toggle Starling stats overlay (e.g., /showStarlingStats right center 5)");
         Logger.addSlashCommand("createStarlingReport",function():void
         {
            if(mStarlingStatsReporter == null)
            {
               mStarlingStatsReporter = new StarlingStatsReporter(mDBFacade.starlingLayerManager.starlingInstance);
            }
            mStarlingStatsReporter.toggle();
         },"Start/stop sampling Starling stats (fps, memory, gpu memory, draw calls) into StarlingReport.txt next to the game logs");
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
         Logger.addSlashCommand("getSteamAvatarImage",function(param1:int):void
         {
            var requestFunc:Function;
            var param:int = param1;
            Logger.log("Getting Steam avatar image...");
            requestFunc = JSONRPCService.getFunction("GetSteamAvatarPictureUrl",mDBFacade.rpcRoot + "account");
            requestFunc(param,function(param1:String):void
            {
               Logger.info("Result: " + param1);
            },function(param1:Error):void
            {
               Logger.info("Error: " + param1);
            });
         },"Call Steam API to get an avatar image URL from an account ID");
      }
      
      public function setupServerWords() : void
      {
         Logger.addSlashCommand("serverTime",function():void
         {
            getServerTime();
         });
         Logger.addSlashCommand("magicWordTest",function():void
         {
            runMagicWordTest();
         });
         Logger.addSlashCommand("unlockAllMapNodes",function():void
         {
            unlockAllMapNodes();
         });
         Logger.addSlashCommand("lockAllMapNodes",function():void
         {
            lockAllMapNodes();
         });
         Logger.addSlashCommand("unlockMapNodes",function(param1:String = ""):void
         {
            var _loc3_:int = 0;
            var _loc4_:int = 0;
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0])
            {
               showHelp();
               Logger.log("/unlockMapNodes startNode [endNode]");
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
               unlockMapNodes(_loc3_,_loc4_);
            }
         });
         Logger.addSlashCommand("giveGems",function(param1:String = ""):void
         {
            var _loc3_:int = 0;
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0])
            {
               showHelp();
               Logger.log("/giveGems numberGems");
               Logger.log("\tgives you gems.");
            }
            else
            {
               _loc3_ = int(_loc2_[0]);
               giveGems(_loc3_);
            }
         });
         Logger.addSlashCommand("giveCoins",function(param1:String = ""):void
         {
            var _loc3_:int = 0;
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0])
            {
               showHelp();
               Logger.log("/giveCoins numberCoins");
               Logger.log("\tgives you coins.");
            }
            else
            {
               _loc3_ = int(_loc2_[0]);
               giveCoins(_loc3_);
            }
         });
         Logger.addSlashCommand("giveXp",function(param1:String = ""):void
         {
            var _loc3_:int = 0;
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0])
            {
               showHelp();
               Logger.log("/giveXp xp");
               Logger.log("\tgives the current avatar xp");
            }
            else
            {
               _loc3_ = int(_loc2_[0]);
               giveXp(_loc3_);
            }
         });
         Logger.addSlashCommand("setAscensionLevel",function(param1:String = ""):void
         {
            var _loc3_:int = 0;
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0])
            {
               showHelp();
               Logger.log("/setAscensionLevel level");
               Logger.log("\tsets the current avatar\'s ascension level.");
            }
            else
            {
               _loc3_ = int(_loc2_[0]);
               setAscensionLevel(_loc3_);
            }
         });
         Logger.addSlashCommand("ascendAvatar",function():void
         {
            ascendAvatar();
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
            Logger.log("AskForAccountDetails: ERROR:" + param1.toString());
         });
      }
      
      public function getServerTime() : void
      {
         var requestFunc:Function = JSONRPCService.getFunction("getWebServerTimestamp",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("serverTime:" + param1);
         },function(param1:Error):void
         {
            Logger.log("serverTime: ERROR:" + param1.toString());
         });
      }
      
      public function runMagicWordTest() : void
      {
         var argsArray:Array = new Array("Test");
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("magicWordTest:" + param1);
         },function(param1:Error):void
         {
            Logger.log("magicWordTest: ERROR:" + param1.toString());
         });
      }
      
      public function unlockAllMapNodes() : void
      {
         var argsArray:Array = ["UnlockAllMapNodes",mDBFacade.dbAccountInfo.activeAvatarId];
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("unlockAllMapNodes:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("unlockAllMapNodes: ERROR:" + param1.toString());
         });
      }
      
      public function lockAllMapNodes() : void
      {
         var argsArray:Array = ["LockAllMapNodes",mDBFacade.dbAccountInfo.activeAvatarId];
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("lockAllMapNodes:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("lockAllMapNodes: ERROR:" + param1.toString());
         });
      }
      
      public function unlockMapNodes(startNode:int, endNode:int = 0) : void
      {
         var argsArray:Array;
         var requestFunc:Function;
         if(endNode < startNode)
         {
            endNode = startNode;
         }
         argsArray = ["UnlockMapNodes",mDBFacade.dbAccountInfo.activeAvatarId,startNode,endNode];
         requestFunc = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("unlockMapNodes:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("unlockMapNodes: ERROR:" + param1.toString());
         });
      }
      
      public function giveGems(numGems:int) : void
      {
         var argsArray:Array = ["GiveGems",numGems];
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("giveGems:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("giveGems: ERROR:" + param1.toString());
         });
      }
      
      public function giveCoins(numCoins:int) : void
      {
         var argsArray:Array = ["GiveCoins",numCoins];
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("giveCoins:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("giveCoins: ERROR:" + param1.toString());
         });
      }
      
      public function giveXp(xpAmount:int) : void
      {
         var argsArray:Array = ["GiveXp",mDBFacade.dbAccountInfo.activeAvatarId,xpAmount];
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("giveXp:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("giveXp: ERROR:" + param1.toString());
         });
      }
      
      public function setAscensionLevel(level:int) : void
      {
         var argsArray:Array = ["SetAscensionLevel",mDBFacade.dbAccountInfo.activeAvatarId,level];
         var requestFunc:Function = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array):void
         {
            Logger.log("setAscensionLevel:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("setAscensionLevel: ERROR:" + param1.toString());
         });
      }
      
      public function ascendAvatar() : void
      {
         var requestFunc:Function = JSONRPCService.getFunction("ascendAvatar",mDBFacade.rpcRoot + "avatarrecord");
         requestFunc(mDBFacade.dbAccountInfo.activeAvatarId,function(param1:*):void
         {
            Logger.log("ascendAvatar:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error):void
         {
            Logger.log("ascendAvatar: ERROR:" + param1.toString());
         });
      }
      
      private function parseSmallTextOptions(param:String) : Object
      {
         var _loc3_:String = null;
         var _loc2_:Array = param.match(/\S+/g) || [];
         var _loc4_:Boolean = false;
         if(_loc2_.length > 0)
         {
            _loc3_ = String(_loc2_[_loc2_.length - 1]).toLowerCase();
            if(_loc3_ == "uppercase" || _loc3_ == "lowercase")
            {
               _loc4_ = _loc3_ == "lowercase";
               _loc2_.pop();
            }
         }
         var _loc5_:Number = _loc2_.length == 0 ? 9 : Number(_loc2_[0]);
         if(_loc2_.length > 1 || !isFinite(_loc5_) || _loc5_ <= 0)
         {
            Logger.log("Usage: /showSmallText [px] [uppercase|lowercase] or /listSmallText [px] [uppercase|lowercase], px a positive number (default 9, uppercase)");
            return null;
         }
         return {
            "minPx":_loc5_,
            "useLowercase":_loc4_
         };
      }
      
      public function showHelp() : void
      {
         Logger.log("Please use the command following this format:");
         Logger.log("/command parameter [optional parameter]");
      }
   }
}

