package UI.Popup
{
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
         super(dbFacade,_loc3_,_loc2_);
         mPopup.message_label1.text = Locale.getString("INFINITE_MAP_POPUP_MESSAGE_LABEL_1");
         mPopup.message_label2.text = Locale.getString("INFINITE_MAP_POPUP_MESSAGE_LABEL_2");
         mPopup.message_label3.text = Locale.getString("INFINITE_MAP_POPUP_MESSAGE_LABEL_3");
         mPopup.message_label4.text = Locale.getString("INFINITE_MAP_POPUP_MESSAGE_LABEL_4");
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

