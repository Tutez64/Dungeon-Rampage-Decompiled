package UI.Inventory
{
   import Account.InventoryBaseInfo;
   import Account.ItemInfo;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Facade.Locale;
   import UI.Popup.DBUITwoButtonPopup;
   import flash.display.MovieClip;
   
   public class UISellItemPopup extends DBUITwoButtonPopup
   {
      
      protected static const POPUP_CLASS_NAME:String = "item_popup";
      
      private var mInfo:InventoryBaseInfo;
      
      public function UISellItemPopup(dbFacade:DBFacade, titleText:String, info:InventoryBaseInfo, leftText:String, leftCallback:Function, rightText:String, rightCallback:Function, allowClose:Boolean = true, closeCallback:Function = null)
      {
         mInfo = info;
         super(dbFacade,titleText,null,leftText,leftCallback,rightText,rightCallback,allowClose,closeCallback);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function getClassName() : String
      {
         return "item_popup";
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var itemInfo:ItemInfo;
         var swfPath:String;
         var iconName:String;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         itemInfo = mInfo as ItemInfo;
         mPopup.power.visible = itemInfo != null;
         if(itemInfo)
         {
            mPopup.power.attack_label.text = Locale.getString("POWER");
            mPopup.power.label.text = itemInfo.power.toString();
         }
         swfPath = mInfo.uiSwfFilepath;
         iconName = mInfo.iconName;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(iconName);
            if(_loc3_ == null)
            {
               Logger.error("Unable to get iconClass for iconName: " + iconName);
               return;
            }
            var _loc2_:MovieClip = new _loc3_();
            _loc2_.scaleX = _loc2_.scaleY = 70 / mInfo.iconScale;
            mPopup.item_icon.addChild(_loc2_);
         });
         mPopup.coin.visible = true;
         mPopup.coin.mouseEnabled = false;
         mPopup.coin.mouseChildren = false;
         mPopup.price.text = mInfo.sellCoins.toString();
         mPopup.price.mouseEnabled = false;
      }
   }
}

