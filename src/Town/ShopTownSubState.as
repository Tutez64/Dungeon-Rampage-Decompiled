package Town
{
   import Facade.DBFacade;
   import UI.Shop.UIShop;
   
   public class ShopTownSubState extends TownSubState
   {
      
      public static const NAME:String = "ShopTownSubState";
      
      private var mUIShop:UIShop;
      
      private var mStartAtCategoryTab:String = "";
      
      public function ShopTownSubState(dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,townStateMachine,"ShopTownSubState");
      }
      
      override public function enterState() : void
      {
         super.enterState();
         if(mUIShop)
         {
            mUIShop.refresh(mStartAtCategoryTab);
            mUIShop.animateEntry();
         }
         mTownStateMachine.townHeader.showCloseButton(true);
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("SHOP_MENU",mTownStateMachine.townHeader.determineCallback,mTownStateMachine.townHeader.closeButton,mTownStateMachine.townHeader.closeButton);
      }
      
      override protected function setupHeaderLinks() : void
      {
      }
      
      override public function exitState() : void
      {
         mDBFacade.menuNavigationController.popLayer("SHOP_MENU");
         mUIShop.processChosenAvatar();
         super.exitState();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         mUIShop.destroy();
         mUIShop = null;
      }
      
      override protected function setupState() : void
      {
         super.setupState();
         mUIShop = new UIShop(mDBFacade,mTownStateMachine.townSwf,mRootMovieClip,mTownStateMachine.townHeader);
      }
      
      public function set startAtCategoryTab(value:String) : void
      {
         mStartAtCategoryTab = value;
      }
   }
}

