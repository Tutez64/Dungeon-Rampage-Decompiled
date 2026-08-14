package UI.Inventory
{
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMWeaponItem;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UIWeaponDescTooltip extends MovieClip
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mRoot:MovieClip;
      
      protected var mDescription:TextField;
      
      public function UIWeaponDescTooltip(dbFacade:DBFacade, templateClass:Class)
      {
         super();
         mDBFacade = dbFacade;
         mRoot = new templateClass();
         this.addChild(mRoot);
         mDescription = mRoot.description_label;
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         this.removeChild(mRoot);
         mRoot = null;
      }
      
      public function place(x:int, y:int) : void
      {
         mRoot.x = x;
         mRoot.y = y;
      }
      
      public function setWeaponItem(gmWeapon:GMWeaponItem, level:uint, isLegendary:Boolean = false) : void
      {
         mDescription.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_DESCRIPTION",gmWeapon.getWeaponAesthetic(level,isLegendary).WeaponItemConstant);
      }
   }
}

