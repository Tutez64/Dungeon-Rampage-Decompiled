package com.facebook.graph.utils
{
   public class FQLMultiQueryParser implements IResultParser
   {
      
      public function FQLMultiQueryParser()
      {
         super();
      }
      
      public function parse(data:Object) : Object
      {
         var _loc3_:String = null;
         var _loc2_:Object = {};
         for(_loc3_ in data)
         {
            _loc2_[data[_loc3_].name] = data[_loc3_].fql_result_set;
         }
         return _loc2_;
      }
   }
}

