package SteamInput
{
   public class MenuControlsActionSetData
   {
      
      public static const actionSetName:String = "MenuControls";
      
      public static const movementActionName:String = "menu_movement";
      
      public static const upActionName:String = "menu_up";
      
      public static const downUpActionName:String = "menu_down";
      
      public static const leftUpActionName:String = "menu_left";
      
      public static const rightUpActionName:String = "menu_right";
      
      public static const selectActionName:String = "menu_select";
      
      public static const cancelActionName:String = "menu_cancel";
      
      public static const returnActionName:String = "menu_return";
      
      public function MenuControlsActionSetData()
      {
         super();
      }
      
      public static function gatherAnalogActionNames() : Vector.<String>
      {
         var _loc1_:Vector.<String> = new Vector.<String>();
         _loc1_.push("menu_movement");
         return _loc1_;
      }
      
      public static function gatherDigitalActionNames() : Vector.<String>
      {
         var _loc1_:Vector.<String> = new Vector.<String>();
         _loc1_.push("menu_up");
         _loc1_.push("menu_down");
         _loc1_.push("menu_left");
         _loc1_.push("menu_right");
         _loc1_.push("menu_select");
         _loc1_.push("menu_cancel");
         _loc1_.push("menu_return");
         return _loc1_;
      }
   }
}

