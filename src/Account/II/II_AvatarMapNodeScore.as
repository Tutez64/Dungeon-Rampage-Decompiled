package Account.II
{
   import Collections.Map;
   
   public class II_AvatarMapNodeScore
   {
      
      public var nodeIdToScore:Map;
      
      public function II_AvatarMapNodeScore(mapNodeScoresJson:Object)
      {
         super();
         nodeIdToScore = new Map();
         updateMapNodeScore(mapNodeScoresJson);
      }
      
      public function updateMapNodeScore(mapNodeScoresJson:Object) : void
      {
         nodeIdToScore.add(int(mapNodeScoresJson.mapnode_id),int(mapNodeScoresJson.score));
      }
   }
}

