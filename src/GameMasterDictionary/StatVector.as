package GameMasterDictionary
{
   import Brain.Logger.Logger;
   import DBGlobals.DBGlobal;
   
   public class StatVector
   {
      
      public static var slotCount:uint = 15;
      
      public var values:Vector.<Number>;
      
      public function StatVector()
      {
         super();
         values = new Vector.<Number>(15,true);
      }
      
      public static function clone(s1:StatVector) : StatVector
      {
         var _loc3_:* = 0;
         var _loc2_:StatVector = new StatVector();
         _loc3_ = 0;
         while(_loc3_ < slotCount)
         {
            _loc2_.values[_loc3_] = s1.values[_loc3_];
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function multiply(s1:StatVector, s2:StatVector) : StatVector
      {
         var _loc4_:* = 0;
         var _loc3_:StatVector = StatVector.clone(s1);
         _loc4_ = 0;
         while(_loc4_ < slotCount)
         {
            _loc3_.values[_loc4_] *= s2.values[_loc4_];
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function multiplyScalar(s1:StatVector, s2:Number) : StatVector
      {
         var _loc4_:* = 0;
         var _loc3_:StatVector = StatVector.clone(s1);
         _loc4_ = 0;
         while(_loc4_ < slotCount)
         {
            _loc3_.values[_loc4_] *= s2;
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function add(s1:StatVector, s2:StatVector) : StatVector
      {
         var _loc4_:* = 0;
         var _loc3_:StatVector = StatVector.clone(s1);
         _loc4_ = 0;
         while(_loc4_ < slotCount)
         {
            _loc3_.values[_loc4_] += s2.values[_loc4_];
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function setConstant(val:int) : void
      {
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < slotCount)
         {
            values[_loc2_] = val;
            _loc2_++;
         }
      }
      
      public function SetFromJSON(jsonAsset:Object, prefix:String = "") : void
      {
         var _loc3_:* = 0;
         _loc3_ = 0;
         while(_loc3_ < DBGlobal.StatNames.length)
         {
            if(jsonAsset[prefix + DBGlobal.StatNames[_loc3_]] == null)
            {
               Logger.error("StatVector Reading JSON Value " + prefix + DBGlobal.StatNames[_loc3_] + "Not Found Continuing ?");
            }
            values[_loc3_] = jsonAsset[prefix + DBGlobal.StatNames[_loc3_]];
            _loc3_++;
         }
      }
      
      public function destroy() : void
      {
         values = null;
      }
      
      public function set data(val:Vector.<Number>) : void
      {
         values = val;
      }
      
      public function get maxHitPoints() : Number
      {
         return values[0];
      }
      
      public function get maxManaPoints() : Number
      {
         return values[1];
      }
      
      public function get movementSpeed() : Number
      {
         return values[13];
      }
      
      public function getSpeed(type:String) : Number
      {
         if(type == "MELEE")
         {
            return values[8];
         }
         if(type == "SHOOT" || type == "SHOOTING")
         {
            return values[9];
         }
         if(type == "MAGIC")
         {
            return values[10];
         }
         return 1;
      }
      
      public function DebugPrint() : void
      {
         var _loc1_:* = 0;
         _loc1_ = 0;
         while(_loc1_ < slotCount)
         {
            trace(DBGlobal.StatNames[_loc1_],this.values[_loc1_]);
            _loc1_++;
         }
      }
   }
}

