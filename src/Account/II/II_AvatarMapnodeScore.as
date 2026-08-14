package Account.II
{
   import org.as3commons.collections.Map;
   
   public class II_AvatarMapnodeScore
   {
      
      public var nodeIdToScore:Map;
      
      public function II_AvatarMapnodeScore(mapnodeScoresJson:Object)
      {
         super();
         nodeIdToScore = new Map();
         updateMapnodeScore(mapnodeScoresJson);
      }
      
      public function updateMapnodeScore(mapnodeScoresJson:Object) : void
      {
         var _loc2_:* = null;
         nodeIdToScore.add(int(mapnodeScoresJson.mapnode_id),int(mapnodeScoresJson.score));
      }
   }
}

