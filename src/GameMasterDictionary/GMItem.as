package GameMasterDictionary
{
   import flash.utils.getQualifiedClassName;
   
   public class GMItem
   {
      
      public var Id:uint;
      
      public var Constant:String;
      
      private var mName:String;
      
      private var mSecurityValue:int = 0;
      
      public function GMItem(jsonAsset:Object)
      {
         super();
         Id = jsonAsset.Id;
         Constant = jsonAsset.Constant;
         mName = jsonAsset.Name;
         for each(var _loc2_:Object in jsonAsset)
         {
            if(getQualifiedClassName(_loc2_) == "int")
            {
               mSecurityValue += Math.abs(int(_loc2_)) % 17 + Math.abs(int(_loc2_)) / 19;
            }
         }
         mSecurityValue %= 541;
      }
      
      public function get Name() : String
      {
         return mName;
      }
      
      public function get SecurityValue() : int
      {
         return mSecurityValue;
      }
   }
}

