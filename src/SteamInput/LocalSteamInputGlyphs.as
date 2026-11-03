package SteamInput
{
   import Brain.AssetRepository.AssetLoader;
   import Brain.Logger.Logger;
   import flash.filesystem.File;
   import flash.utils.Dictionary;
   
   public class LocalSteamInputGlyphs
   {
      
      public static const DETECT_CONTROLLER_GLYPH:String = "";
      
      public static const PREFERENCE_XBOX_SERIES_X:String = "Xbox Series X";
      
      public static const PREFERENCE_XBOX_ONE:String = "Xbox One";
      
      public static const PREFERENCE_XBOX_360:String = "Xbox 360";
      
      public static const PREFERENCE_PS5:String = "PS5";
      
      public static const PREFERENCE_PS4:String = "PS4";
      
      public static const PREFERENCE_PS3:String = "PS3";
      
      public static const PREFERENCE_PS_VITA:String = "PS Vita";
      
      public static const PREFERENCE_PS_MOVE:String = "PS Move";
      
      public static const PREFERENCE_SWITCH:String = "Switch";
      
      public static const PREFERENCE_STEAM_DECK:String = "Steam Deck";
      
      public static const PREFERENCE_STEAM:String = "Steam";
      
      public static const PREFERENCE_AMAZON_LUNA:String = "Amazon Luna";
      
      public static const PREFERENCE_GOOGLE_STADIA:String = "Google Stadia";
      
      public static const PREFERENCE_OUYA:String = "Ouya";
      
      public static const PREFERENCE_WII:String = "Wii";
      
      public static const PREFERENCE_WII_U:String = "WiiU";
      
      public static const PREFERENCE_OCULUS:String = "Oculus";
      
      public static const PREFERENCE_VIVE:String = "Vive";
      
      public static const PREFERENCE_DEFAULT:String = "";
      
      private static const GLYPH_DIRECTORY:String = "Resources/Glyphs";
      
      private var mGlyphPathsByName:Dictionary;
      
      public function LocalSteamInputGlyphs()
      {
         super();
      }
      
      public function getGlyphPath(steamGlyphPath:String, preference:String) : String
      {
         if(steamGlyphPath == null || steamGlyphPath == "" || steamGlyphPath == "error1")
         {
            return null;
         }
         ensureGlyphIndexIsLoaded();
         var _loc3_:String = getControlFromSteamGlyphPath(steamGlyphPath);
         var _loc4_:String = getPreferredGlyphName(preference,_loc3_);
         if(_loc4_ == null)
         {
            return null;
         }
         return mGlyphPathsByName[normalise(_loc4_)];
      }
      
      private function ensureGlyphIndexIsLoaded() : void
      {
         if(mGlyphPathsByName != null)
         {
            return;
         }
         mGlyphPathsByName = new Dictionary();
         var _loc1_:File = AssetLoader.resolveFile("Resources/Glyphs");
         if(!_loc1_.exists || !_loc1_.isDirectory)
         {
            Logger.warnch("Input","LocalSteamInputGlyphs: Glyph directory not found at \'" + _loc1_.nativePath + "\'. Steam glyphs will be used.");
            return;
         }
         indexGlyphDirectory(_loc1_);
         Logger.infoch("Input","LocalSteamInputGlyphs: Indexed bundled glyphs from \'" + _loc1_.nativePath + "\'.");
      }
      
      private function indexGlyphDirectory(directory:File) : void
      {
         var _loc3_:String = null;
         for each(var _loc2_:File in directory.getDirectoryListing())
         {
            if(_loc2_.isDirectory)
            {
               indexGlyphDirectory(_loc2_);
            }
            else if(_loc2_.extension != null && _loc2_.extension.toLowerCase() == "png")
            {
               _loc3_ = normalise(_loc2_.name.substring(0,_loc2_.name.length - 4));
               if(mGlyphPathsByName[_loc3_] == null)
               {
                  mGlyphPathsByName[_loc3_] = _loc2_.nativePath;
               }
            }
         }
      }
      
      private function getControlFromSteamGlyphPath(steamGlyphPath:String) : String
      {
         var _loc5_:String = steamGlyphPath.split("?")[0];
         var _loc3_:Array = _loc5_.replace(new RegExp("\\\\","g"),"/").split("/");
         var _loc4_:String = String(_loc3_[_loc3_.length - 1]).toLowerCase().replace(/_(sm|md|lg)\.png$/,"");
         _loc4_ = _loc4_.replace(/^(shared_color_outlined_button_|shared_color_button_|shared_outlined_button_|shared_button_)/,"");
         if(_loc4_ == "a" || _loc4_ == "b" || _loc4_ == "x" || _loc4_ == "y")
         {
            return _loc4_.toUpperCase();
         }
         _loc4_ = _loc4_.replace(/^(ps_color_outlined_button_|ps_color_button_|ps_outlined_button_|ps_button_)/,"");
         if(_loc4_ == "x")
         {
            return "A";
         }
         if(_loc4_ == "circle")
         {
            return "B";
         }
         if(_loc4_ == "square")
         {
            return "X";
         }
         if(_loc4_ == "triangle")
         {
            return "Y";
         }
         var _loc2_:Object = {
            "shared_dpad":"Dpad",
            "shared_dpad_up":"Dpad_Up",
            "shared_dpad_down":"Dpad_Down",
            "shared_dpad_left":"Dpad_Left",
            "shared_dpad_right":"Dpad_Right",
            "ps_dpad":"Dpad",
            "ps_dpad_up":"Dpad_Up",
            "ps_dpad_down":"Dpad_Down",
            "ps_dpad_left":"Dpad_Left",
            "ps_dpad_right":"Dpad_Right",
            "switchpro_dpad":"Dpad",
            "switchpro_dpad_up":"Dpad_Up",
            "switchpro_dpad_down":"Dpad_Down",
            "switchpro_dpad_left":"Dpad_Left",
            "switchpro_dpad_right":"Dpad_Right",
            "xbox_lb":"LB",
            "ps_lb":"LB",
            "switchpro_l":"LB",
            "xbox_rb":"RB",
            "ps_rb":"RB",
            "switchpro_r":"RB",
            "xbox_lt":"LT",
            "switchpro_l2":"LT",
            "xbox_rt":"RT",
            "switchpro_r2":"RT",
            "shared_lstick":"Left_Stick",
            "shared_lstick_click":"Left_Stick_Click",
            "shared_rstick":"Right_Stick",
            "shared_rstick_click":"Right_Stick_Click",
            "switchpro_lstick":"Left_Stick",
            "switchpro_lstick_click":"Left_Stick_Click",
            "switchpro_rstick":"Right_Stick",
            "switchpro_rstick_click":"Right_Stick_Click",
            "xbox_button_start":"Menu",
            "xbox_button_select":"View",
            "xbox_button_share":"Share",
            "switchpro_button_plus":"Menu",
            "switchpro_button_minus":"View",
            "switchpro_button_capture":"Share"
         };
         return _loc2_[_loc4_];
      }
      
      private function getPreferredGlyphName(preference:String, control:String) : String
      {
         if(control == null)
         {
            return null;
         }
         switch(normalise(preference))
         {
            case "xboxseries":
            case "xboxseriesx":
               break;
            case "xboxone":
               return "XboxOne_" + control;
            case "xbox360":
               return "360_" + menuControl(control,"Start","Back");
            case "ps5":
               return "PS5_" + playStationControl(control);
            case "ps4":
               return "PS4_" + playStationControl(control);
            case "ps3":
               return "PS3_" + legacyPlayStationControl(control);
            case "psvita":
               return "Vita_" + vitaControl(control);
            case "psmove":
               return "PSMove_" + legacyPlayStationControl(control);
            case "switch":
               return "Switch_" + control;
            case "steamdeck":
               return "SteamDeck_" + steamDeckControl(control);
            case "steam":
               return "Steam_" + steamControl(control);
            case "amazonluna":
               return "Luna_" + control;
            case "googlestadia":
               return "Stadia_" + stadiaControl(control);
            case "ouya":
               return "Ouya_" + ouyaControl(control);
            case "wii":
               return "Wii_" + menuControl(control,"Plus","Minus");
            case "wiiu":
               return "WiiU_" + wiiUControl(control);
            case "oculus":
               return "Oculus_" + control;
            case "vive":
               return "Vive_" + control;
            default:
               return null;
         }
         return "XboxSeriesX_" + control;
      }
      
      private function playStationControl(control:String) : String
      {
         if(control == "A")
         {
            return "Cross";
         }
         if(control == "B")
         {
            return "Circle";
         }
         if(control == "X")
         {
            return "Square";
         }
         if(control == "Y")
         {
            return "Triangle";
         }
         if(control == "LB")
         {
            return "L1";
         }
         if(control == "RB")
         {
            return "R1";
         }
         if(control == "LT")
         {
            return "L2";
         }
         if(control == "RT")
         {
            return "R2";
         }
         if(control == "Menu")
         {
            return "Options";
         }
         if(control == "View")
         {
            return "Share";
         }
         return control;
      }
      
      private function steamDeckControl(control:String) : String
      {
         if(control == "LB")
         {
            return "L1";
         }
         if(control == "RB")
         {
            return "R1";
         }
         if(control == "LT")
         {
            return "L2";
         }
         if(control == "RT")
         {
            return "R2";
         }
         if(control == "View")
         {
            return "Inventory";
         }
         return control;
      }
      
      private function vitaControl(control:String) : String
      {
         if(control == "LB")
         {
            return "Bumpter_Left";
         }
         if(control == "RB")
         {
            return "Bumper_Right";
         }
         return legacyPlayStationControl(control);
      }
      
      private function legacyPlayStationControl(control:String) : String
      {
         if(control == "Menu")
         {
            return "Start";
         }
         if(control == "View")
         {
            return "Select";
         }
         return playStationControl(control);
      }
      
      private function steamControl(control:String) : String
      {
         if(control == "Left_Stick" || control == "Left_Stick_Click")
         {
            return "Stick";
         }
         return menuControl(control,"Start","Back");
      }
      
      private function stadiaControl(control:String) : String
      {
         if(control == "LB")
         {
            return "L1";
         }
         if(control == "RB")
         {
            return "R1";
         }
         if(control == "LT")
         {
            return "L2";
         }
         if(control == "RT")
         {
            return "R2";
         }
         return menuControl(control,"Menu","Select");
      }
      
      private function ouyaControl(control:String) : String
      {
         if(control == "A")
         {
            return "O";
         }
         if(control == "B")
         {
            return "A";
         }
         if(control == "X")
         {
            return "U";
         }
         return control;
      }
      
      private function wiiUControl(control:String) : String
      {
         if(control == "LB")
         {
            return "L";
         }
         if(control == "RB")
         {
            return "R";
         }
         if(control == "LT")
         {
            return "ZL";
         }
         if(control == "RT")
         {
            return "ZR";
         }
         return menuControl(control,"Plus","Minus");
      }
      
      private function menuControl(control:String, menuName:String, viewName:String) : String
      {
         if(control == "Menu")
         {
            return menuName;
         }
         if(control == "View")
         {
            return viewName;
         }
         return control;
      }
      
      private function normalise(value:String) : String
      {
         return value == null ? "" : value.toLowerCase().replace(/[^a-z0-9]/g,"");
      }
   }
}

