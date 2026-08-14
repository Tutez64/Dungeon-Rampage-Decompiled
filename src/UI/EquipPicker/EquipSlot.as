package UI.EquipPicker
{
   import Brain.UI.UIObject;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   
   public class EquipSlot extends UIObject
   {
      
      private var mEquipPicker_handleItemDrop:Function;
      
      private var mEquipSlot:uint;
      
      public function EquipSlot(dbFacade:DBFacade, root:MovieClip, equipPicker_handleItemDrop:Function, equipSlot:uint)
      {
         super(dbFacade,root);
         mEquipPicker_handleItemDrop = equipPicker_handleItemDrop;
         mEquipSlot = equipSlot;
      }
      
      override public function handleDrop(dropObject:UIObject) : Boolean
      {
         return mEquipPicker_handleItemDrop(dropObject,null,mEquipSlot);
      }
   }
}

