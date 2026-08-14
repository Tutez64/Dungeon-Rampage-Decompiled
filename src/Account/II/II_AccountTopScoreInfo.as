package Account.II
{
   import org.as3commons.collections.Map;
   
   public class II_AccountTopScoreInfo
   {
      
      public var accountIdToTopScoreMapnodeInfo:Map;
      
      public function II_AccountTopScoreInfo(topScoreJson:Object)
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         super();
         accountIdToTopScoreMapnodeInfo = new Map();
         for each(_loc3_ in topScoreJson)
         {
            _loc2_ = int(_loc3_.account_id);
            if(accountIdToTopScoreMapnodeInfo.hasKey(_loc2_))
            {
               accountIdToTopScoreMapnodeInfo.itemFor(_loc2_).updateMapnodeScore(_loc3_);
            }
            else
            {
               accountIdToTopScoreMapnodeInfo.add(_loc2_,new II_FriendChampionsboardInfo(_loc3_));
            }
         }
      }
   }
}

