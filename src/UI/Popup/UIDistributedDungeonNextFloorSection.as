package UI.Popup
{
   import Account.MapnodeInfo;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphManager;
   import Brain.UI.UIButton;
   import Brain.Utils.TextUtil;
   import Collections.Map;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMMapNode;
   import StateMachine.MainStateMachine.MainStateMachine;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UIDistributedDungeonNextFloorSection
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_score_report.swf";
      
      protected static const POPUP_CLASS_NAME:String = "next_dungeon_popup";
      
      public static const FLOOR_VICTORY:String = "VICTORY";
      
      public static const FLOOR_DEFEAT:String = "DEFEAT";
      
      public static const FLOOR_ULTIMATE_RAMPAGE:String = "ULTIMATE_RAMPAGE";
      
      private var mDBFacade:DBFacade;
      
      private var mCurrentDungeon:GMMapNode;
      
      private var mTypeOfPopup:String;
      
      protected var mPopup:MovieClip;
      
      protected var mBattleButton:UIButton;
      
      private var mCallback:Function;
      
      private var mNextDungeon:GMMapNode;
      
      private var mNextDungeonIsUltimateRampage:Boolean;
      
      public function UIDistributedDungeonNextFloorSection(dbFacade:DBFacade, root:MovieClip, currentMapNode:GMMapNode, typeOfPopup:String, callback:Function)
      {
         super();
         mDBFacade = dbFacade;
         mCurrentDungeon = currentMapNode;
         mTypeOfPopup = typeOfPopup;
         mPopup = root;
         mCallback = callback;
         mBattleButton = new UIButton(dbFacade,mPopup.button_center);
         mBattleButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBattleButton.releaseCallback = buttonCallback;
         mBattleButton.enabled = false;
         mBattleButton.root.filters = [SceneGraphManager.getGrayScaleSaturationFilter(5)];
         findNextDungeon();
         if(typeOfPopup == "VICTORY")
         {
            setDungeonName(GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",mNextDungeon.Constant));
            TextUtil.setText(mPopup.dungeonXp_label,mNextDungeon.CompletionXPBonus.toString() + Locale.getString("WORLD_MAP_BONUS_XP"));
            Locale.setText(mPopup.button_center.battle_text.battle_text,"NEXT");
         }
         if(typeOfPopup == "DEFEAT")
         {
            setDungeonName(GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",currentMapNode.Constant));
            TextUtil.setText(mPopup.dungeonXp_label,mCurrentDungeon.CompletionXPBonus.toString() + Locale.getString("WORLD_MAP_BONUS_XP"));
            Locale.setText(mPopup.button_center.battle_text.battle_text,"RETRY");
         }
         if(typeOfPopup == "ULTIMATE_RAMPAGE")
         {
            setDungeonName(GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",currentMapNode.Constant));
            TextUtil.setText(mPopup.dungeonXp_label,mCurrentDungeon.CompletionXPBonus.toString() + Locale.getString("WORLD_MAP_BONUS_XP"));
            Locale.setText(mPopup.button_center.battle_text.battle_text,"RETRY");
         }
      }
      
      private static function breakAtSpace(field:TextField, name:String) : String
      {
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         field.text = name;
         if(field.numLines <= 1)
         {
            return name;
         }
         var _loc4_:Array = name.split(" ");
         var _loc3_:String = name;
         _loc5_ = _loc4_.length - 1;
         while(_loc5_ > 0)
         {
            _loc6_ = _loc4_.slice(0,_loc5_).join(" ");
            _loc7_ = _loc4_.slice(_loc5_).join(" ");
            if(!(_loc6_ == "" || _loc7_ == ""))
            {
               _loc3_ = _loc6_ + "\n" + _loc7_;
               field.text = _loc6_;
               if(field.numLines == 1)
               {
                  return _loc3_;
               }
            }
            _loc5_--;
         }
         return _loc3_;
      }
      
      private static function centerNameVertically(field:TextField) : void
      {
         var _loc2_:Number = field.height - (field.textHeight + 4) * field.scaleY;
         if(_loc2_ > 0)
         {
            field.y += _loc2_ / 2;
         }
      }
      
      public static function nextDungeonAfterWin(dbFacade:DBFacade, mapNode:GMMapNode, openNodes:Map) : GMMapNode
      {
         var _loc5_:MapnodeInfo = null;
         if(mapNode.InfiniteDungeon != null)
         {
            return mapNode;
         }
         var _loc4_:GMMapNode = null;
         for each(var _loc6_:GMMapNode in childNodesInPlayOrder(mapNode))
         {
            if(isPlayableAfterWin(dbFacade,_loc6_,openNodes))
            {
               if(_loc4_ == null)
               {
                  _loc4_ = _loc6_;
               }
               _loc5_ = openNodes.itemFor(_loc6_.Id);
               if(_loc5_ == null || _loc5_.MapnodeState != 1)
               {
                  _loc4_ = _loc6_;
                  break;
               }
            }
         }
         return _loc4_ ?? mapNode;
      }
      
      private static function childNodesInPlayOrder(mapNode:GMMapNode) : Array
      {
         var _loc4_:GMMapNode = null;
         var _loc3_:Array = [];
         for each(var _loc2_:Object in mapNode.ChildNodes)
         {
            _loc4_ = _loc2_ as GMMapNode;
            if(_loc4_ != null)
            {
               _loc3_.push(_loc4_);
            }
         }
         _loc3_.sortOn("BitIndex",16);
         return _loc3_;
      }
      
      private static function isPlayableAfterWin(dbFacade:DBFacade, node:GMMapNode, openNodes:Map) : Boolean
      {
         if(openNodes.itemFor(node.Id) != null)
         {
            return true;
         }
         return node.LevelRequirement <= dbFacade.dbAccountInfo.activeAvatarInfo.ogLevel && node.TrophyRequirement <= dbFacade.dbAccountInfo.trophies;
      }
      
      private function setDungeonName(name:String) : void
      {
         var _loc2_:TextField = mPopup.message_label;
         name = name.toUpperCase();
         TextUtil.setText(_loc2_,breakAtSpace(_loc2_,name));
         centerNameVertically(_loc2_);
      }
      
      public function destroy() : void
      {
         if(mBattleButton)
         {
            mBattleButton.destroy();
            mBattleButton = null;
         }
         mPopup = null;
         mCurrentDungeon = null;
         mNextDungeon = null;
         mCallback = null;
         mDBFacade = null;
      }
      
      public function buttonCallback() : void
      {
         var dbFacade:DBFacade = mDBFacade;
         var stateMachine:MainStateMachine = mDBFacade.mainStateMachine;
         var nextDungeonId:uint = mNextDungeon.Id;
         var nextDungeonType:String = mNextDungeon.NodeType;
         stateMachine.setOneShotReloadTownCallback(function():void
         {
            if(dbFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(nextDungeonId) == null)
            {
               Logger.warn("Play next skipped locked map node " + nextDungeonId + ", opening the world map instead");
               stateMachine.enterTownState(true);
               return;
            }
            stateMachine.enterLoadingScreenState(nextDungeonId,nextDungeonType);
         });
         mCallback();
      }
      
      public function findNextDungeon() : void
      {
         if(mTypeOfPopup != "VICTORY")
         {
            mNextDungeon = mCurrentDungeon;
            if(mTypeOfPopup == "ULTIMATE_RAMPAGE")
            {
               mNextDungeonIsUltimateRampage = true;
            }
            return;
         }
         mNextDungeon = nextDungeonAfterWin(mDBFacade,mCurrentDungeon,mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1);
         if(mNextDungeon.InfiniteDungeon)
         {
            mNextDungeonIsUltimateRampage = true;
         }
      }
      
      public function setButtonEnabled() : void
      {
         mBattleButton.root.filters = [];
         mBattleButton.enabled = true;
      }
      
      public function get battleButton() : UIButton
      {
         return mBattleButton;
      }
   }
}

