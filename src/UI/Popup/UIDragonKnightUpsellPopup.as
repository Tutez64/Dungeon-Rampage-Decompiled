package UI.Popup
{
   import Account.StoreServicesController;
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.text.TextField;
   
   public class UIDragonKnightUpsellPopup extends DBUIPopup
   {
      
      private static const DRAGON_KNIGHT_POPUP_SEEN_ATTRIBUTE:String = "dragon_knight_upsell_seen";
      
      private static const DUNGEONS_NEEDED_TO_COMPLETE_BEFORE_DRAGON_KNIGHT_POPUP:uint = 40;
      
      private static var DK_UPSELL_CLASS_NAME:String = "popup_dragonKnight";
      
      private var mBuyButton:UIButton;
      
      private var mLabel:TextField;
      
      public function UIDragonKnightUpsellPopup(dbFacade:DBFacade)
      {
         super(dbFacade,Locale.getString("DRAGON_KNIGHT_UPSELL_POPUP_TITLE"),null,true,true,setUpsellAsSeen,false);
         mDBFacade.metrics.log("dragonKnightExclusiveUpsellPopupShown");
      }
      
      public static function ShouldDisplayDragonKnightUpsell(dbFacade:DBFacade) : Boolean
      {
         return false;
      }
      
      override protected function getClassName() : String
      {
         return DK_UPSELL_CLASS_NAME;
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mBuyButton = new UIButton(mDBFacade,mPopup.button_purchase);
         mBuyButton.label.text = Locale.getString("DRAGON_KNIGHT_UPSELL_POPUP_BUY_BUTTON");
         mBuyButton.releaseCallbackThis = function(param1:UIButton):void
         {
            var _this:UIButton = param1;
            mPopup.enabled = false;
            StoreServicesController.showCashPage(mDBFacade,"dragonKnightUpsell",null,function():void
            {
               _this.destroy();
            },function():void
            {
               if(mPopup)
               {
                  mPopup.enabled = true;
               }
            });
         };
      }
      
      private function setUpsellAsSeen() : void
      {
         mDBFacade.dbAccountInfo.alterAttribute("dragon_knight_upsell_seen","true");
      }
      
      override public function destroy() : void
      {
         if(mBuyButton)
         {
            mBuyButton.destroy();
            mBuyButton = null;
         }
         super.destroy();
      }
   }
}

