package UI.Hud
{
   import Account.BoosterInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIObject;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import UI.*;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class UIStacksHud
   {
      
      private static const STACK_TOOLTIP_DELAY:Number = 0.5;
      
      protected var mDBFacade:DBFacade;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mWorkComponent:LogicalWorkComponent;
      
      private var mStacksUI:Vector.<UIObject>;
      
      private var mStackTimersUI:Vector.<CountdownTextTimer>;
      
      private var mTooltipAPos:Point;
      
      private var mTooltipBPos:Point;
      
      private var mTooltipCPos:Point;
      
      private var mUIRootClass:Class;
      
      private var mUIRoot:MovieClip;
      
      private var mBoosterTimeOutTimer:Timer;
      
      private var mFirstTime:Boolean = true;
      
      public function UIStacksHud(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIStacksHud");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"UIStacksHud");
      }
      
      public function initializeHud(rootClass:Class) : void
      {
         mUIRootClass = rootClass;
         mUIRoot = new mUIRootClass();
         mUIRoot.x = 480;
         mUIRoot.y = 55;
         mTooltipAPos = new Point(mUIRoot.potion_slot_A.tooltip.x,mUIRoot.potion_slot_A.tooltip.y);
         mTooltipBPos = new Point(mUIRoot.potion_slot_B.tooltip.x,mUIRoot.potion_slot_B.tooltip.y);
         mTooltipCPos = new Point(mUIRoot.potion_slot_C.tooltip.x,mUIRoot.potion_slot_C.tooltip.y);
      }
      
      public function setupStacksUI() : void
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         checkBoosters();
      }
      
      private function createStacks() : void
      {
         var _loc1_:* = null;
         mStacksUI = new <UIObject>[new UIObject(mDBFacade,mUIRoot.potion_slot_A),new UIObject(mDBFacade,mUIRoot.potion_slot_B),new UIObject(mDBFacade,mUIRoot.potion_slot_C)];
         mStackTimersUI = new <CountdownTextTimer>[null,null,null];
         for each(_loc1_ in mStacksUI)
         {
            _loc1_.enabled = false;
            _loc1_.dontKillMyChildren = true;
         }
      }
      
      private function checkBoosters() : void
      {
         var _loc2_:BoosterInfo = null;
         var _loc3_:BoosterInfo = null;
         removeStacks();
         resetTooltipPos();
         createStacks();
         if(mDBFacade.dbAccountInfo && 0)
         {
            _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.findHighestBoosterXP();
            if(_loc2_ != null)
            {
               setupBooster(_loc2_,0);
            }
            _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.findHighestBoosterGold();
            if(_loc3_ != null)
            {
               setupBooster(_loc3_,1);
            }
         }
         if(mBoosterTimeOutTimer != null)
         {
            mBoosterTimeOutTimer.stop();
            mBoosterTimeOutTimer = null;
         }
         var _loc1_:int = mDBFacade.dbAccountInfo.inventoryInfo.timeTillNextBoosterExpire();
      }
      
      private function handleBoosterTimeUp(event:TimerEvent) : void
      {
         checkBoosters();
      }
      
      private function setupBooster(boosterInfo:BoosterInfo, slot:uint) : void
      {
         var xpStack:UIObject;
         if(boosterInfo != null)
         {
            xpStack = mStacksUI[slot];
            xpStack.enabled = true;
            xpStack.tooltipDelay = 0.5;
            xpStack.tooltip.title_label.text = GameMasterLocale.getGameMasterSubString("STACKABLE_NAME",boosterInfo.StackInfo.Constant).toUpperCase();
            xpStack.tooltip.description_label.text = Locale.getString("TIME_REMAINING") + boosterInfo.getDisplayTimeLeft();
            mStackTimersUI[slot] = new CountdownTextTimer(xpStack.tooltip.description_label,boosterInfo.getEndDate(),GameClock.getWebServerDate,checkBoosters,Locale.getString("BOOSTER_REMAINING"),"",Locale.getString("EXPIRED"));
            mStackTimersUI[slot].start();
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(boosterInfo.StackInfo.UISwfFilepath),function(param1:SwfAsset):void
            {
               var _loc2_:Class = param1.getClass(boosterInfo.StackInfo.IconName);
               if(_loc2_ == null)
               {
                  return;
               }
               var _loc3_:MovieClip = new _loc2_();
               _loc3_.scaleX = _loc3_.scaleY = 80 / 100;
               mStacksUI[slot].root.graphic.addChildAt(_loc3_,0);
            });
         }
      }
      
      public function hide() : void
      {
         if(mUIRoot)
         {
            mSceneGraphComponent.removeChild(mUIRoot);
         }
      }
      
      public function show() : void
      {
         if(mUIRoot)
         {
            mSceneGraphComponent.addChild(mUIRoot,105);
         }
      }
      
      private function resetTooltipPos() : void
      {
         mUIRoot.potion_slot_A.tooltip.x = mTooltipAPos.x;
         mUIRoot.potion_slot_A.tooltip.y = mTooltipAPos.y;
         mUIRoot.potion_slot_B.tooltip.x = mTooltipBPos.x;
         mUIRoot.potion_slot_B.tooltip.y = mTooltipBPos.y;
         mUIRoot.potion_slot_C.tooltip.x = mTooltipCPos.x;
         mUIRoot.potion_slot_C.tooltip.y = mTooltipCPos.y;
      }
      
      private function removeStacks() : void
      {
         var _loc2_:* = null;
         var _loc1_:* = null;
         if(mStacksUI)
         {
            for each(_loc2_ in mStacksUI)
            {
               if(_loc2_.root.graphic.numChildren > 0)
               {
                  _loc2_.root.graphic.removeChildAt(0);
               }
               _loc2_.destroy();
            }
            mStacksUI = null;
         }
         if(mStackTimersUI)
         {
            for each(_loc1_ in mStackTimersUI)
            {
               if(_loc1_ != null)
               {
                  _loc1_.destroy();
               }
            }
            mStackTimersUI = null;
         }
      }
      
      public function destroy() : void
      {
         hide();
         removeStacks();
         mUIRoot = null;
         if(mWorkComponent)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mDBFacade = null;
      }
   }
}

