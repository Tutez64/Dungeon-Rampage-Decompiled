package
{
   import flash.Boot;
   import haxe.Exception;
   
   public class EReg
   {
      
      public static var escapeRe:RegExp = /[.*+?^${}()|[\]\\]/g;
      
      public var result:*;
      
      public var r:RegExp;
      
      public function EReg(r:String = undefined, opt:String = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         this.r = new RegExp(r,opt);
      }
      
      public static function escape(s:String) : String
      {
         return s.replace(EReg.escapeRe,"\\$&");
      }
      
      public function split(s:String) : Array
      {
         var _loc2_:String = "#__delim__#";
         var _loc3_:String = s.replace(r,_loc2_);
         return _loc3_.split(_loc2_);
      }
      
      public function replace(s:String, by:String) : String
      {
         return s.replace(r,by);
      }
      
      public function matchedRight() : String
      {
         if(result == null)
         {
            throw Exception.thrown("No string matched");
         }
         var _loc1_:Number = int(result.index) + result[0].length;
         var _loc2_:String = result.input;
         return _loc2_.substr(_loc1_,_loc2_.length - _loc1_);
      }
      
      public function matchedPos() : Object
      {
         if(result == null)
         {
            throw Exception.thrown("No string matched");
         }
         return {
            "pos":int(result.index),
            "len":result[0].length
         };
      }
      
      public function matchedLeft() : String
      {
         if(result == null)
         {
            throw Exception.thrown("No string matched");
         }
         var _loc1_:String = result.input;
         return _loc1_.substr(0,result.index);
      }
      
      public function matched(n:int) : String
      {
         if(result != null && n >= 0 && n < int(result.length))
         {
            return result[n];
         }
         throw Exception.thrown("EReg::matched");
      }
      
      public function matchSub(s:String, pos:int, len:int = -1) : Boolean
      {
         var _loc4_:Boolean = false;
         if(r.global)
         {
            r.lastIndex = pos;
            result = r.exec(len < 0 ? s : s.substr(0,pos + len));
            _loc4_ = result != null;
            if(_loc4_)
            {
               result.input = s;
            }
            return _loc4_;
         }
         _loc4_ = match(len < 0 ? s.substr(pos) : s.substr(pos,len));
         if(_loc4_)
         {
            result.input = s;
            var _temp_3:* = result;
            _temp_3.index = _temp_3.index + pos;
         }
         return _loc4_;
      }
      
      public function match(s:String) : Boolean
      {
         if(r.global)
         {
            r.lastIndex = 0;
         }
         result = r.exec(s);
         return result != null;
      }
      
      public function map(s:String, f:Function) : String
      {
         var _loc6_:* = null;
         var _loc3_:* = 0;
         var _loc4_:String = "";
         var _loc5_:Boolean = true;
         while(_loc3_ < s.length)
         {
            if(!matchSub(s,_loc3_))
            {
               _loc4_ += Std.string(s.substr(_loc3_));
               break;
            }
            _loc6_ = matchedPos();
            _loc4_ += Std.string(s.substr(_loc3_,int(_loc6_.pos) - _loc3_));
            _loc4_ = _loc4_ + Std.string(f(this));
            if(int(_loc6_.len) == 0)
            {
               _loc4_ += Std.string(s.substr(int(_loc6_.pos),1));
               _loc3_ = int(_loc6_.pos) + 1;
            }
            else
            {
               _loc3_ = int(_loc6_.pos) + int(_loc6_.len);
            }
            _loc5_ = false;
            if(!r.global)
            {
               break;
            }
         }
         if(!r.global && _loc3_ > 0 && _loc3_ < s.length)
         {
            _loc4_ += Std.string(s.substr(_loc3_));
         }
         return _loc4_;
      }
   }
}

