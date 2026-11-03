package GameMasterDictionary
{
   import Brain.Logger.Logger;
   import DBGlobals.DBGlobal;
   import flash.Boot;
   import haxe.Log;
   
   public class StatVector
   {
      
      public static var slotCount:uint = 14;
      
      public var values:Vector.<Number>;
      
      public function StatVector()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         values = new Vector.<Number>(14,true);
      }
      
      public static function clone(s1:StatVector) : StatVector
      {
         var _loc5_:int = 0;
         var _loc2_:StatVector = new StatVector();
         var _loc3_:int = 0;
         var _loc4_:int = int(StatVector.slotCount);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            _loc2_.values[_loc5_] = s1.values[_loc5_];
         }
         return _loc2_;
      }
      
      public static function multiply(s1:StatVector, s2:StatVector) : StatVector
      {
         var _loc6_:int = 0;
         var _loc7_:* = null as Vector.<Number>;
         var _loc3_:StatVector = StatVector.clone(s1);
         var _loc4_:int = 0;
         var _loc5_:int = int(StatVector.slotCount);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc7_ = _loc3_.values;
            _loc7_[_loc6_] = _loc7_[_loc6_] * s2.values[_loc6_];
         }
         return _loc3_;
      }
      
      public static function multiplyScalar(s1:StatVector, s2:Number) : StatVector
      {
         var _loc6_:int = 0;
         var _loc7_:* = null as Vector.<Number>;
         var _loc3_:StatVector = StatVector.clone(s1);
         var _loc4_:int = 0;
         var _loc5_:int = int(StatVector.slotCount);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc7_ = _loc3_.values;
            _loc7_[_loc6_] = _loc7_[_loc6_] * s2;
         }
         return _loc3_;
      }
      
      public static function add(s1:StatVector, s2:StatVector) : StatVector
      {
         var _loc6_:int = 0;
         var _loc7_:* = null as Vector.<Number>;
         var _loc3_:StatVector = StatVector.clone(s1);
         var _loc4_:int = 0;
         var _loc5_:int = int(StatVector.slotCount);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc7_ = _loc3_.values;
            _loc7_[_loc6_] = _loc7_[_loc6_] + s2.values[_loc6_];
         }
         return _loc3_;
      }
      
      public function set_data(val:Vector.<Number>) : Vector.<Number>
      {
         values = val;
         return val;
      }
      
      public function set data(value:Vector.<Number>) : void
      {
         set_data(value);
      }
      
      public function setConstant(val:int) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = int(StatVector.slotCount);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc2_++;
            values[_loc4_] = val;
         }
      }
      
      public function get_movementSpeed() : Number
      {
         return values[DBGlobal.MOVEMENT];
      }
      
      public function get movementSpeed() : Number
      {
         return get_movementSpeed();
      }
      
      public function get_maxManaPoints() : Number
      {
         return values[DBGlobal.MP_BOOST];
      }
      
      public function get maxManaPoints() : Number
      {
         return get_maxManaPoints();
      }
      
      public function get_maxHitPoints() : Number
      {
         return values[DBGlobal.HP_BOOST];
      }
      
      public function get maxHitPoints() : Number
      {
         return get_maxHitPoints();
      }
      
      public function getSpeed(type:String) : Number
      {
         if(type == "MELEE")
         {
            return values[DBGlobal.MELEE_SPD];
         }
         if(type == "SHOOT" || type == "SHOOTING")
         {
            return values[DBGlobal.SHOOT_SPD];
         }
         if(type == "MAGIC")
         {
            return values[DBGlobal.MAGIC_SPD];
         }
         return 1;
      }
      
      public function destroy() : void
      {
         values = null;
      }
      
      public function SetFromJSON(jsonAsset:*, prefix:String = undefined) : void
      {
         var _loc5_:int = 0;
         var _loc6_:* = null;
         var _loc7_:Number = NaN;
         if(prefix == null)
         {
            prefix = "";
         }
         var _loc3_:int = 0;
         var _loc4_:int = int(DBGlobal.StatNames.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            _loc6_ = Reflect.field(jsonAsset,prefix + DBGlobal.StatNames[_loc5_]);
            if(_loc6_ == null)
            {
               Logger.error("StatVector Reading JSON Value " + prefix + DBGlobal.StatNames[_loc5_] + "Not Found Continuing ?");
            }
            _loc7_ = _loc6_;
            values[_loc5_] = _loc7_;
         }
      }
      
      public function DebugPrint() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = int(StatVector.slotCount);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            Log.trace(DBGlobal.StatNames[_loc3_] + " " + values[_loc3_],{
               "fileName":"../DungeonBusters/Client/GameMasterProjectHaxe/src/gamemasterdictionary/StatVector.hx",
               "lineNumber":107,
               "className":"gamemasterdictionary.StatVector",
               "methodName":"DebugPrint"
            });
         }
      }
   }
}

