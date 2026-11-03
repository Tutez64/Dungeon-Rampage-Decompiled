package Account.II
{
   import Collections.Map;
   
   public class II_AvatarsScoresInfo
   {
      
      public var avatarIdToAvatarScore:Map;
      
      public function II_AvatarsScoresInfo(avatarScoresInfoJson:Object)
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         super();
         avatarIdToAvatarScore = new Map();
         for each(_loc3_ in avatarScoresInfoJson)
         {
            _loc2_ = int(_loc3_.avatar_id);
            if(avatarIdToAvatarScore.hasKey(_loc2_))
            {
               avatarIdToAvatarScore.itemFor(_loc2_).updateMapNodeScore(_loc3_);
            }
            else
            {
               avatarIdToAvatarScore.add(_loc2_,new II_AvatarMapNodeScore(_loc3_));
            }
         }
      }
   }
}

