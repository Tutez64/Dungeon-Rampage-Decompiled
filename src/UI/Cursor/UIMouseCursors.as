package UI.Cursor
{
   import Brain.MouseCursor.MouseCursorManager;
   import Combat.Weapon.WeaponGameObject;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   
   public class UIMouseCursors
   {
      
      public static const ARROW:String = "ARROW";
      
      public static const POINT:String = "POINT";
      
      public static const HAND:String = "HAND";
      
      public static const DRAG:String = "DRAG";
      
      public static const SWORD:String = "SWORD";
      
      public static const BOW:String = "BOW";
      
      public static const STAFF:String = "STAFF";
      
      private static var ArrowArt:Class = db_UI_cursors_swf_2;
      
      private static var PointArt:Class = db_UI_cursors_swf$c12ba094d1b838815d2550f1d60f1c5b904251893;
      
      private static var HandArt:Class = db_UI_cursors_swf$c12ba094d1b838815d2550f1d60f1c5b1019661057;
      
      private static var DragArt:Class = db_UI_cursors_swf$c12ba094d1b838815d2550f1d60f1c5b1019411263;
      
      private static var SwordArt:Class = db_UI_cursors_swf$c12ba094d1b838815d2550f1d60f1c5b903334214;
      
      private static var BowArt:Class = db_UI_cursors_swf;
      
      private static var StaffArt:Class = db_UI_cursors_swf$c12ba094d1b838815d2550f1d60f1c5b902912549;
      
      public function UIMouseCursors()
      {
         super();
      }
      
      public static function register(dbFacade:DBFacade) : void
      {
         var _loc2_:MouseCursorManager = dbFacade.mouseCursorManager;
         _loc2_.registerMouseCursor("ARROW",new ArrowArt());
         _loc2_.registerMouseCursor("POINT",new PointArt());
         _loc2_.registerMouseCursor("HAND",new HandArt());
         _loc2_.registerMouseCursor("DRAG",new DragArt());
         _loc2_.registerMouseCursor("SWORD",new SwordArt());
         _loc2_.registerMouseCursor("BOW",new BowArt());
         _loc2_.registerMouseCursor("STAFF",new StaffArt());
         _loc2_.defaultMouseCursor = "ARROW";
      }
      
      public static function setDefault(dbFacade:DBFacade, name:String) : void
      {
         dbFacade.mouseCursorManager.defaultMouseCursor = name;
      }
      
      public static function forWeapon(dbFacade:DBFacade, weapon:WeaponGameObject) : String
      {
         if(weapon == null || !dbFacade.featureFlags.getFlagValue("want-weapon-cursors"))
         {
            return "SWORD";
         }
         if(weapon.weaponData.ClassType == DBGlobal.SHOOTING_ITEM_CATEGORY)
         {
            return "BOW";
         }
         if(weapon.weaponData.ClassType == DBGlobal.MAGIC_ITEM_CATEGORY)
         {
            return "STAFF";
         }
         return "SWORD";
      }
   }
}

