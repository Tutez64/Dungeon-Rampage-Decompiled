package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderer;
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMDoober;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class UILootLossPopup extends DBUITwoButtonPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      protected static const POPUP_CLASS_NAME:String = "exitdungeon_popup";
      
      private static const OPTIONS_BUTTON_POSITION:Point = new Point(190,131);
      
      protected var movieClipRenderers:Vector.<MovieClipRenderer>;
      
      private var mXpLoss:uint;
      
      private var mTreasure:Vector.<uint>;
      
      private var mOptionsCallback:Function;
      
      private var mOptionsButton:ExitDungeonOptionsButton;
      
      public function UILootLossPopup(dbFacade:DBFacade, xpLoss:uint, treasure:Vector.<uint>, leftCallback:Function, rightCallback:Function, optionsCallback:Function = null)
      {
         mXpLoss = xpLoss;
         mTreasure = treasure;
         mOptionsCallback = optionsCallback;
         super(dbFacade,"EXIT_DUNGEON",Locale.getString("UI_HUD_EXIT_TITLE"),Locale.getString("UI_HUD_EXIT_MESSAGE"),Locale.getString("UI_HUD_EXIT_CONFIRM"),leftCallback,Locale.getString("UI_HUD_EXIT_CANCEL"),rightCallback);
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var treasure_icons:Array;
         var i:uint;
         var gmDoober:GMDoober;
         var gmChestItem:GMChest;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         if(mOptionsCallback != null)
         {
            mOptionsButton = new ExitDungeonOptionsButton(mDBFacade,mAssetLoadingComponent,mPopup,OPTIONS_BUTTON_POSITION,mCloseButton,mRightButton,mOptionsCallback);
         }
         movieClipRenderers = new Vector.<MovieClipRenderer>();
         mDBFacade.metrics.log("LootLossPopupPresented");
         TextUtil.setText(mPopup.XP_amount,mXpLoss.toString() + " XP");
         if(mTreasure.length == 0)
         {
            return;
         }
         treasure_icons = [mPopup.treasure_icon_01,mPopup.treasure_icon_02];
         i = 0;
         while(i < mTreasure.length)
         {
            gmDoober = mDBFacade.gameMaster.dooberById.itemFor(mTreasure[i]);
            gmChestItem = mDBFacade.gameMaster.chestsById.itemFor(gmDoober.ChestId);
            if(gmChestItem && gmChestItem.IconName)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmChestItem.IconSwf),function(param1:SwfAsset):void
               {
                  var _loc3_:Class = param1.getClass(gmChestItem.IconName);
                  var _loc2_:MovieClip = new _loc3_() as MovieClip;
                  _loc2_.scaleX = _loc2_.scaleY = 0.8;
                  treasure_icons[i].addChild(_loc2_);
                  movieClipRenderers.push(new MovieClipRenderer(mDBFacade,_loc2_));
               });
            }
            i = i + 1;
         }
      }
      
      override protected function handleInputCalledClosed() : void
      {
         if(mDBFacade.hud)
         {
            mDBFacade.hud.suppressNextExitMenuToggle();
         }
         super.handleInputCalledClosed();
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override protected function getClassName() : String
      {
         return "exitdungeon_popup";
      }
      
      override public function destroy() : void
      {
         var _loc1_:uint = 0;
         if(movieClipRenderers)
         {
            _loc1_ = 0;
            while(_loc1_ < movieClipRenderers.length)
            {
               movieClipRenderers[_loc1_].destroy();
               _loc1_++;
            }
         }
         if(mOptionsButton)
         {
            mOptionsButton.destroy();
            mOptionsButton = null;
         }
         mOptionsCallback = null;
         if(mDBFacade)
         {
            if(mDBFacade.hud)
            {
               mDBFacade.hud.clearExitMenu();
            }
         }
         movieClipRenderers = null;
         mTreasure = null;
         super.destroy();
      }
   }
}

