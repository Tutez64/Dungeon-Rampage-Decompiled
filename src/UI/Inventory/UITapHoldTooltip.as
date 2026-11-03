package UI.Inventory
{
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UITapHoldTooltip extends MovieClip
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mRoot:MovieClip;
      
      protected var mTitle:TextField;
      
      protected var mDescription:TextField;
      
      public function UITapHoldTooltip(dbFacade:DBFacade, templateClass:Class)
      {
         super();
         mDBFacade = dbFacade;
         mRoot = new templateClass();
         this.addChild(mRoot);
         mTitle = mRoot.title_label;
         mDescription = mRoot.charge_description_label;
         mRoot.scaleX = mRoot.scaleY = UIWeaponTooltip.tooltipScale(mDescription,1.55);
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         this.removeChild(mRoot);
         mRoot = null;
      }
      
      public function setValues(name:String, desc:String) : void
      {
         TextUtil.setText(mTitle,name.toUpperCase());
         TextUtil.setText(mDescription,desc);
      }
   }
}

