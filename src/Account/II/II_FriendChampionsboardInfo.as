package Account.II
{
   import Collections.Map;
   import Json.JsonCodec;
   
   public class II_FriendChampionsboardInfo
   {
      
      public var nodeIdToScore:Map;
      
      public var nodeIdToActiveSkin:Map;
      
      private var mNodeIdToFriendInfoJson:Map;
      
      public function II_FriendChampionsboardInfo(friendLeaderboardJson:Object)
      {
         super();
         nodeIdToScore = new Map();
         nodeIdToActiveSkin = new Map();
         mNodeIdToFriendInfoJson = new Map();
         updateMapNodeScore(friendLeaderboardJson);
      }
      
      public function updateMapNodeScore(friendLeaderboardJson:Object) : void
      {
         nodeIdToScore.add(friendLeaderboardJson.mapnode_id,friendLeaderboardJson.score);
         nodeIdToActiveSkin.add(friendLeaderboardJson.mapnode_id,friendLeaderboardJson.active_skin);
         mNodeIdToFriendInfoJson.add(friendLeaderboardJson.mapnode_id,friendLeaderboardJson);
      }
      
      public function getWeaponsForNodeId(nodeId:uint) : Vector.<Object>
      {
         var _loc3_:Object = null;
         var _loc2_:Vector.<Object> = new Vector.<Object>();
         if(mNodeIdToFriendInfoJson.hasKey(nodeId))
         {
            _loc3_ = mNodeIdToFriendInfoJson.itemFor(nodeId);
            _loc2_.push(JsonCodec.decode(_loc3_.weapon1));
            _loc2_.push(JsonCodec.decode(_loc3_.weapon2));
            _loc2_.push(JsonCodec.decode(_loc3_.weapon3));
         }
         return _loc2_;
      }
   }
}

