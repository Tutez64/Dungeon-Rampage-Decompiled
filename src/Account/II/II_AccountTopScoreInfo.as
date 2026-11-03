package Account.II
{
   import Collections.Map;
   
   public class II_AccountTopScoreInfo
   {
      
      public var accountIdToTopScoreMapNodeInfo:Map;
      
      public function II_AccountTopScoreInfo(topScoreJson:Object)
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         super();
         accountIdToTopScoreMapNodeInfo = new Map();
         for each(_loc3_ in topScoreJson)
         {
            _loc2_ = int(_loc3_.account_id);
            if(accountIdToTopScoreMapNodeInfo.hasKey(_loc2_))
            {
               accountIdToTopScoreMapNodeInfo.itemFor(_loc2_).updateMapNodeScore(_loc3_);
            }
            else
            {
               accountIdToTopScoreMapNodeInfo.add(_loc2_,new II_FriendChampionsboardInfo(_loc3_));
            }
         }
      }
   }
}

