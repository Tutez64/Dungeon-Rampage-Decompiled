package UI.Popup
{
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import Facade.Locale;
   
   public class DBUIUltimateRampagePopup extends DBUIPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_map.swf";
      
      protected static const POPUP_CLASS_NAME:String = "ultimate_rampage_popup";
      
      public function DBUIUltimateRampagePopup(dbFacade:DBFacade)
      {
         var _loc3_:String = Locale.getString("INFINITE_MAP_POPUP_TITLE");
         var _loc2_:String = Locale.getString("INFINITE_MAP_POPUP_MESSAGE");
         super(dbFacade,"ULTIMATE_RAMPAGE_POPUP",_loc3_,_loc2_);
         Locale.setText(mPopup.message_label1,"INFINITE_MAP_POPUP_MESSAGE_LABEL_1");
         Locale.setText(mPopup.message_label2,"INFINITE_MAP_POPUP_MESSAGE_LABEL_2");
         Locale.setText(mPopup.message_label3,"INFINITE_MAP_POPUP_MESSAGE_LABEL_3");
         Locale.setText(mPopup.message_label4,"INFINITE_MAP_POPUP_MESSAGE_LABEL_4",null,1.55);
         TextUtil.fitToField(mPopup.message_label4);
      }
      
      override protected function getClassName() : String
      {
         return "ultimate_rampage_popup";
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_map.swf";
      }
   }
}

