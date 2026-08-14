package Town
{
   import Brain.Event.EventComponent;
   import Brain.UI.UIButton;
   import Events.DBAccountResponseEvent;
   import Facade.DBFacade;
   import UI.Inventory.UIInventory;
   
   public class InventoryTownSubState extends TownSubState
   {
      
      public static const NAME:String = "InventoryTownSubState";
      
      private var mUIInventory:UIInventory;
      
      private var mEventComponent:EventComponent;
      
      private var mBackButton:UIButton;
      
      private var mStartAtCategoryTab:String = "";
      
      public function InventoryTownSubState(dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,townStateMachine,"InventoryTownSubState");
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      override public function destroy() : void
      {
         if(mUIInventory)
         {
            mUIInventory.destroy();
            mUIInventory = null;
         }
         mEventComponent.destroy();
         super.destroy();
      }
      
      override protected function setupState() : void
      {
         super.setupState();
         mUIInventory = new UIInventory(mDBFacade,mTownStateMachine.townHeader);
      }
      
      public function setRevlealedState(type:uint, offerId:uint, showEquipOption:Boolean = false) : void
      {
         mUIInventory.setRevealedState(type,offerId,showEquipOption);
      }
      
      override public function enterState() : void
      {
         mRoot.addChild(mUIInventory.root);
         super.enterState();
         mTownStateMachine.townHeader.showCloseButton(true);
         if(mStartAtCategoryTab != "")
         {
            mUIInventory.currentTab = mStartAtCategoryTab;
         }
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:DBAccountResponseEvent):void
         {
            mUIInventory.refresh();
         });
         mUIInventory.refresh(true);
         mUIInventory.animateEntry();
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("INVENTORY_MENU",mTownStateMachine.townHeader.determineCallback,mTownStateMachine.townHeader.closeButton,mTownStateMachine.townHeader.closeButton);
      }
      
      override public function exitState() : void
      {
         mDBFacade.menuNavigationController.popLayer("INVENTORY_MENU");
         mRoot.removeChild(mUIInventory.root);
         mUIInventory.exitState();
         mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
         super.exitState();
      }
      
      public function set startAtCategoryTab(category:String) : void
      {
         mStartAtCategoryTab = category;
      }
   }
}

