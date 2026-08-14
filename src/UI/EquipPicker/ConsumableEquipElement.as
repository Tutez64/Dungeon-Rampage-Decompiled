package UI.EquipPicker
{
   import Account.ItemInfo;
   import Account.StackableInfo;
   import Facade.DBFacade;
   import GameMasterDictionary.GMStackable;
   import flash.display.MovieClip;
   
   public class ConsumableEquipElement extends AvatarEquipElement
   {
      
      private var mStackableInfo:StackableInfo;
      
      public function ConsumableEquipElement(dbFacade:DBFacade, keyLabel:String, root:MovieClip, tooltipClass:Class, unequipCallback:Function, handleDropCallback:Function, equipSlot:uint, clickedEquipedWeaponCallback:Function = null, equipResponseCallback:Function = null, allowEquipmentSwapping:Boolean = false)
      {
         super(dbFacade,keyLabel,root,tooltipClass,unequipCallback,handleDropCallback,equipSlot,clickedEquipedWeaponCallback,equipResponseCallback,allowEquipmentSwapping);
         mRoot.textx.visible = false;
         mRoot.quantity.visible = false;
      }
      
      override public function clear() : void
      {
         super.clear();
         mRoot.textx.visible = false;
         mRoot.quantity.visible = false;
      }
      
      public function init(gmStackable:GMStackable, slot:uint, count:uint) : void
      {
         var _loc4_:ItemInfo = null;
         clear();
         mStackableInfo = new StackableInfo(mDBFacade,null,gmStackable);
         stackableInfo.setPropertiesAsConsumable(gmStackable.Id,slot,count);
         mItemInfo = stackableInfo;
         if(mItemInfo != null)
         {
            mRoot.frame.alpha = 1;
            loadItemIcon();
            _loc4_ = mItemInfo as ItemInfo;
            if(!_loc4_)
            {
            }
            draggable = true;
         }
         else
         {
            mRoot.frame.alpha = 0;
            draggable = false;
         }
         mRoot.textx.visible = true;
         mRoot.quantity.visible = true;
         mRoot.quantity.text = count.toString();
      }
      
      public function get stackableInfo() : StackableInfo
      {
         return mStackableInfo;
      }
      
      override protected function resetDragUnequipFunc() : void
      {
         mUnequipCallback(mItemInfo,mEquipSlot,mEquipResponseCallback);
      }
   }
}

