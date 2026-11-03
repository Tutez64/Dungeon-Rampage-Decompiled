package gamemasterdictionary._GMHero
{
   import flash.Boot;
   
   public class ExpToLevel
   {
      
      public var mTotalStatPoints:uint;
      
      public var mLevel:uint;
      
      public var mExperience:uint;
      
      public function ExpToLevel(level:uint = 0, experience:uint = 0, totalStatPoints:uint = 0)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         mLevel = level;
         mExperience = experience;
         mTotalStatPoints = totalStatPoints;
      }
   }
}

