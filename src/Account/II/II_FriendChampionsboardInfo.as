package Account.II
{
   import com.maccherone.json.JSON;
   import org.as3commons.collections.Map;
   
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
         updateMapnodeScore(friendLeaderboardJson);
      }
      
      public function updateMapnodeScore(friendLeaderboardJson:Object) : void
      {
         var _loc2_:* = null;
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
            _loc2_.push(com.maccherone.json.JSON.decode(_loc3_.weapon1));
            _loc2_.push(com.maccherone.json.JSON.decode(_loc3_.weapon2));
            _loc2_.push(com.maccherone.json.JSON.decode(_loc3_.weapon3));
         }
         return _loc2_;
      }
   }
}

