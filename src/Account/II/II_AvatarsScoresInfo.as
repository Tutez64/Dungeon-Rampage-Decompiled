package Account.II
{
   import org.as3commons.collections.Map;
   
   public class II_AvatarsScoresInfo
   {
      
      public var avatarIdToAvatarScore:Map;
      
      public var nodeIdToScore:Map;
      
      public function II_AvatarsScoresInfo(avatarScoresInfoJson:Object)
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         super();
         avatarIdToAvatarScore = new Map();
         for each(_loc3_ in avatarScoresInfoJson)
         {
            _loc2_ = int(_loc3_.avatar_id);
            if(avatarIdToAvatarScore.hasKey(_loc2_))
            {
               avatarIdToAvatarScore.itemFor(_loc2_).updateMapnodeScore(_loc3_);
            }
            else
            {
               avatarIdToAvatarScore.add(_loc2_,new II_AvatarMapnodeScore(_loc3_));
            }
         }
      }
   }
}

