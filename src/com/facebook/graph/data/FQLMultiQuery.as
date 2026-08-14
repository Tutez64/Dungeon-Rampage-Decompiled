package com.facebook.graph.data
{
   import com.adobe.serialization.json.JSON;
   
   public class FQLMultiQuery
   {
      
      public var queries:Object;
      
      public function FQLMultiQuery()
      {
         super();
         this.queries = {};
      }
      
      public function add(query:String, name:String, values:Object = null) : void
      {
         var _loc4_:String = null;
         if(this.queries.hasOwnProperty(name))
         {
            throw new Error("Query name already exists, there cannot be duplicate names");
         }
         for(_loc4_ in values)
         {
            query = query.replace(new RegExp("\\{" + _loc4_ + "\\}","g"),values[_loc4_]);
         }
         this.queries[name] = query;
      }
      
      public function toString() : String
      {
         return com.adobe.serialization.json.JSON.encode(this.queries);
      }
   }
}

