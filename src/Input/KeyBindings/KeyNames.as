package Input.KeyBindings
{
   public class KeyNames
   {
      
      private static const NAMES:Object = buildNames();
      
      public function KeyNames()
      {
         super();
      }
      
      public static function displayName(keyCode:int) : String
      {
         if(keyCode == 0)
         {
            return "";
         }
         if(keyCode >= 65 && keyCode <= 90)
         {
            return String.fromCharCode(keyCode);
         }
         if(keyCode >= 48 && keyCode <= 57)
         {
            return String.fromCharCode(keyCode);
         }
         if(keyCode >= 96 && keyCode <= 105)
         {
            return "NUM " + (keyCode - 96);
         }
         if(keyCode >= 112 && keyCode <= 126)
         {
            return "F" + (keyCode - 112 + 1);
         }
         if(NAMES.hasOwnProperty(keyCode))
         {
            return NAMES[keyCode];
         }
         return "KEY " + keyCode;
      }
      
      private static function buildNames() : Object
      {
         var _loc1_:Object = {};
         _loc1_[8] = "BACKSPACE";
         _loc1_[9] = "TAB";
         _loc1_[13] = "ENTER";
         _loc1_[16] = "SHIFT";
         _loc1_[17] = "CTRL";
         _loc1_[18] = "ALT";
         _loc1_[20] = "CAPS LOCK";
         _loc1_[27] = "ESC";
         _loc1_[32] = "SPACE";
         _loc1_[33] = "PAGE UP";
         _loc1_[34] = "PAGE DOWN";
         _loc1_[35] = "END";
         _loc1_[36] = "HOME";
         _loc1_[37] = "LEFT";
         _loc1_[38] = "UP";
         _loc1_[39] = "RIGHT";
         _loc1_[40] = "DOWN";
         _loc1_[45] = "INSERT";
         _loc1_[46] = "DELETE";
         _loc1_[107] = "NUM +";
         _loc1_[109] = "NUM -";
         _loc1_[106] = "NUM *";
         _loc1_[111] = "NUM /";
         _loc1_[110] = "NUM .";
         _loc1_[108] = "NUM ENTER";
         _loc1_[186] = ";";
         _loc1_[187] = "=";
         _loc1_[188] = ",";
         _loc1_[189] = "-";
         _loc1_[190] = ".";
         _loc1_[191] = "/";
         _loc1_[192] = "`";
         _loc1_[219] = "[";
         _loc1_[220] = "\\";
         _loc1_[221] = "]";
         _loc1_[222] = "\'";
         return _loc1_;
      }
   }
}

