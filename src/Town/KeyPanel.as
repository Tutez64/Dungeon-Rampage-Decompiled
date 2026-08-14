package Town
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import Facade.Locale;
   import UI.Inventory.Chests.ChestKeySlot;
   import flash.display.MovieClip;
   
   public class KeyPanel
   {
      
      public static const KEY_PANEL_CLASS_NAME:String = "header_key_inventory";
      
      private static const KEY_PANEL_OPENED_EVENT:String = "KeyPanelOpened";
      
      private static const KEY_PANEL_ADD_BUTTON_CLICKED_EVENT:String = "KeyPanelAddButtonClicked";
      
      private var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mRoot:MovieClip;
      
      private var mStateCreated:String;
      
      private var mChestKeySlots:Vector.<ChestKeySlot>;
      
      private var mBuyButton:UIButton;
      
      private var mBuyKeysCallback:Function;
      
      private var mCloseButton:UIButton;
      
      private var mCloseCallBack:Function;
      
      public function KeyPanel(dbFacade:DBFacade, assetLoadingComponent:AssetLoadingComponent, buyCallBack:Function, closeCallBack:Function, stateCreated:String)
      {
         super();
         mDBFacade = dbFacade;
         mAssetLoadingComponent = assetLoadingComponent;
         mBuyKeysCallback = buyCallBack;
         mCloseCallBack = closeCallBack;
         mStateCreated = stateCreated;
         mChestKeySlots = new Vector.<ChestKeySlot>();
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"KeyPanel");
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),swfLoaded);
         var _loc6_:Object = {};
         _loc6_.mainGameState = mStateCreated;
         mDBFacade.metrics.log("KeyPanelOpened",_loc6_);
      }
      
      private function swfLoaded(swfAsset:SwfAsset) : void
      {
         var _loc2_:Class = swfAsset.getClass("header_key_inventory");
         mRoot = new _loc2_() as MovieClip;
         mSceneGraphComponent.addChild(mRoot,105);
         mRoot.x = 563;
         mRoot.y = 93;
         setupUI();
      }
      
      private function setupUI() : void
      {
         var i:int;
         var slotMC:MovieClip;
         mRoot.label.text = Locale.getString("KEYS_OWNED");
         i = 0;
         while(i < 4)
         {
            slotMC = mRoot.getChildByName("slot_" + i.toString()) as MovieClip;
            mChestKeySlots.push(new ChestKeySlot(mDBFacade,slotMC,mDBFacade.dbAccountInfo.inventoryInfo.keys[i],mAssetLoadingComponent,true));
            i = i + 1;
         }
         mBuyButton = new UIButton(mDBFacade,mRoot.buy);
         mBuyButton.label.text = Locale.getString("ADD");
         mBuyButton.releaseCallback = function():void
         {
            var _loc1_:Object = {};
            _loc1_.mainGameState = mStateCreated;
            mDBFacade.metrics.log("KeyPanelAddButtonClicked",_loc1_);
            mBuyKeysCallback();
         };
         mCloseButton = new UIButton(mDBFacade,mRoot.close);
         mCloseButton.releaseCallback = mCloseCallBack;
      }
      
      public function refresh() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            mChestKeySlots[_loc1_].refresh(mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc1_]);
            _loc1_++;
         }
      }
      
      public function disableBuyButton() : void
      {
         mBuyButton.label.text = Locale.getString("CLOSE");
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mChestKeySlots.length)
         {
            mChestKeySlots[_loc1_].destroy();
            _loc1_++;
         }
         mChestKeySlots.splice(0,mChestKeySlots.length);
         mSceneGraphComponent.removeChild(mRoot);
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mAssetLoadingComponent = null;
         mRoot = null;
      }
   }
}

