package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMItem
   {
      
      public var mSecurityValue:int;
      
      public var mName:String;
      
      public var Id:uint;
      
      public var Constant:String;
      
      public function GMItem(jsonAsset:Object = undefined)
      {
         var _loc4_:* = null as String;
         var _loc5_:* = null;
         var _loc6_:int = 0;
         if(Boot.skip_constructor)
         {
            return;
         }
         mSecurityValue = 0;
         Id = uint(jsonAsset.Id);
         Constant = jsonAsset.Constant;
         mName = jsonAsset.Name;
         var _loc2_:int = 0;
         var _loc3_:Array = Reflect.fields(jsonAsset);
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            _loc5_ = Reflect.field(jsonAsset,_loc4_);
            if(Std.isOfType(_loc5_,int))
            {
               _loc6_ = _loc5_;
               mSecurityValue += Math.abs(_loc6_) % 17 + Math.abs(_loc6_) / 19;
            }
         }
         mSecurityValue %= 541;
      }
      
      public function get_SecurityValue() : int
      {
         return mSecurityValue;
      }
      
      public function get SecurityValue() : int
      {
         return get_SecurityValue();
      }
      
      public function get_Name() : String
      {
         return mName;
      }
      
      public function get Name() : String
      {
         return get_Name();
      }
   }
}

