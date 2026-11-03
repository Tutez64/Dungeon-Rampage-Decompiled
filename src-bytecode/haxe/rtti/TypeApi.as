package haxe.rtti
{
   import haxe.Exception;
   
   public class TypeApi
   {
      
      public function TypeApi()
      {
      }
      
      public static function typeInfos(t:TypeTree) : Object
      {
         var _loc2_:* = null;
         var _loc3_:* = null as String;
         var _loc4_:* = null as String;
         var _loc5_:* = null as Array;
         var _loc6_:* = null;
         switch(t.index)
         {
            case 0:
               _loc3_ = t.params[0];
               _loc4_ = t.params[1];
               _loc5_ = t.params[2];
               throw Exception.thrown("Unexpected Package");
            case 1:
               _loc2_ = _loc6_ = t.params[0];
               break;
            case 2:
               _loc2_ = _loc6_ = t.params[0];
               break;
            case 3:
               _loc2_ = _loc6_ = t.params[0];
               break;
            case 4:
               _loc2_ = _loc6_ = t.params[0];
         }
         return _loc2_;
      }
      
      public static function isVar(t:CType) : Boolean
      {
         var _loc2_:* = null as Array;
         var _loc3_:* = null as CType;
         if(t.index == 4)
         {
            _loc2_ = t.params[0];
            _loc3_ = t.params[1];
            return false;
         }
         return true;
      }
      
      public static function leq(f:Function, l1:Array, l2:Array) : Boolean
      {
         var _loc7_:* = null as Object;
         var _loc8_:* = null as Object;
         var _loc4_:int = 0;
         var _loc5_:Array = l2;
         var _loc6_:int = 0;
         while(_loc6_ < int(l1.length))
         {
            _loc7_ = l1[_loc6_];
            _loc6_++;
            if(_loc4_ >= int(_loc5_.length))
            {
               return false;
            }
            _loc8_ = _loc5_[_loc4_++];
            if(!Boolean(f(_loc7_,_loc8_)))
            {
               return false;
            }
         }
         if(_loc4_ < int(_loc5_.length))
         {
            return false;
         }
         return true;
      }
      
      public static function rightsEq(r1:Rights, r2:Rights) : Boolean
      {
         var _loc3_:* = null as String;
         var _loc4_:* = null as String;
         if(r1 == r2)
         {
            return true;
         }
         if(r1.index == 2)
         {
            _loc3_ = r1.params[0];
            if(r2.index == 2)
            {
               _loc4_ = r2.params[0];
               return _loc3_ == _loc4_;
            }
         }
         return false;
      }
      
      public static function typeEq(t1:CType, t2:CType) : Boolean
      {
         var _loc3_:* = null as String;
         var _loc4_:* = null as Array;
         var _loc5_:* = null as String;
         var _loc6_:* = null as Array;
         var _loc7_:* = null as CType;
         var _loc8_:* = null as CType;
         switch(t1.index)
         {
            case 0:
               return t2 == CType.CUnknown;
            case 1:
               _loc3_ = t1.params[0];
               _loc4_ = t1.params[1];
               if(t2.index == 1)
               {
                  _loc5_ = t2.params[0];
                  _loc6_ = t2.params[1];
                  if(_loc3_ == _loc5_)
                  {
                     return TypeApi.leq(TypeApi.typeEq,_loc4_,_loc6_);
                  }
                  return false;
               }
               break;
            case 2:
               _loc3_ = t1.params[0];
               _loc4_ = t1.params[1];
               if(t2.index == 2)
               {
                  _loc5_ = t2.params[0];
                  _loc6_ = t2.params[1];
                  if(_loc3_ == _loc5_)
                  {
                     return TypeApi.leq(TypeApi.typeEq,_loc4_,_loc6_);
                  }
                  return false;
               }
               break;
            case 3:
               _loc3_ = t1.params[0];
               _loc4_ = t1.params[1];
               if(t2.index == 3)
               {
                  _loc5_ = t2.params[0];
                  _loc6_ = t2.params[1];
                  if(_loc3_ == _loc5_)
                  {
                     return TypeApi.leq(TypeApi.typeEq,_loc4_,_loc6_);
                  }
                  return false;
               }
               break;
            case 4:
               _loc4_ = t1.params[0];
               _loc7_ = t1.params[1];
               if(t2.index == 4)
               {
                  _loc6_ = t2.params[0];
                  _loc8_ = t2.params[1];
                  if(TypeApi.leq(function(a:Object, b:Object):Boolean
                  {
                     if(a.name == b.name && Boolean(a.opt) == Boolean(b.opt))
                     {
                        return TypeApi.typeEq(a.t,b.t);
                     }
                     return false;
                  },_loc4_,_loc6_))
                  {
                     return TypeApi.typeEq(_loc7_,_loc8_);
                  }
                  return false;
               }
               break;
            case 5:
               _loc4_ = t1.params[0];
               if(t2.index == 5)
               {
                  _loc6_ = t2.params[0];
                  return TypeApi.leq(function(a:Object, b:Object):Boolean
                  {
                     return TypeApi.fieldEq(a,b);
                  },_loc4_,_loc6_);
               }
               break;
            case 6:
               _loc7_ = t1.params[0];
               if(t2.index == 6)
               {
                  _loc8_ = t2.params[0];
                  if(_loc7_ == null != (_loc8_ == null))
                  {
                     return false;
                  }
                  if(_loc7_ != null)
                  {
                     return TypeApi.typeEq(_loc7_,_loc8_);
                  }
                  return true;
               }
               break;
            case 7:
               _loc3_ = t1.params[0];
               _loc4_ = t1.params[1];
               if(t2.index == 7)
               {
                  _loc5_ = t2.params[0];
                  _loc6_ = t2.params[1];
                  if(_loc3_ == _loc5_)
                  {
                     return TypeApi.leq(TypeApi.typeEq,_loc4_,_loc6_);
                  }
                  return false;
               }
         }
         return false;
      }
      
      public static function fieldEq(f1:Object, f2:Object) : Boolean
      {
         if(f1.name != f2.name)
         {
            return false;
         }
         if(!TypeApi.typeEq(f1.type,f2.type))
         {
            return false;
         }
         if(Boolean(f1.isPublic) != Boolean(f2.isPublic))
         {
            return false;
         }
         if(f1.doc != f2.doc)
         {
            return false;
         }
         if(!TypeApi.rightsEq(f1.get,f2.get))
         {
            return false;
         }
         if(!TypeApi.rightsEq(f1.set,f2.set))
         {
            return false;
         }
         if(f1.params == null != (f2.params == null))
         {
            return false;
         }
         if(f1.params != null && f1.params.join(":") != f2.params.join(":"))
         {
            return false;
         }
         return true;
      }
      
      public static function constructorEq(c1:Object, c2:Object) : Boolean
      {
         if(c1.name != c2.name)
         {
            return false;
         }
         if(c1.doc != c2.doc)
         {
            return false;
         }
         if(c1.args == null != (c2.args == null))
         {
            return false;
         }
         if(c1.args != null && !TypeApi.leq(function(a:Object, b:Object):Boolean
         {
            if(a.name == b.name && Boolean(a.opt) == Boolean(b.opt))
            {
               return TypeApi.typeEq(a.t,b.t);
            }
            return false;
         },c1.args,c2.args))
         {
            return false;
         }
         return true;
      }
   }
}

