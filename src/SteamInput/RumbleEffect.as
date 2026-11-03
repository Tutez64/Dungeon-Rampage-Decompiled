package SteamInput
{
   public class RumbleEffect
   {
      
      public static const MENU_SELECTION:RumbleEffect = new RumbleEffect("MenuSelection",0,0.1,0.1);
      
      public static const DUNGEON_BUSTER:RumbleEffect = new RumbleEffect("DungeonBuster",1,1,3);
      
      public static const BERSERKER_MODE:RumbleEffect = new RumbleEffect("BerserkerMode",0.9,0.9,1);
      
      public static const PLAYER_TAKING_DAMAGE:RumbleEffect = new RumbleEffect("PlayerTakingDamage",0.3,0.5,0.2);
      
      public static const PLAYER_DEALING_DAMAGE:RumbleEffect = new RumbleEffect("PlayerDealingDamage",0.5,0.3,0.2);
      
      public static const PLAYER_BIG_ATTACK:RumbleEffect = new RumbleEffect("PlayerBigAttack",0,0,0.2);
      
      public static const PLAYER_MISS_ATTACK:RumbleEffect = new RumbleEffect("PlayerMiss",0.1,0,0.05);
      
      public static const PLAYER_LOW_HEALTH:RumbleEffect = new RumbleEffect("PlayerLowHealth",0.1,0.1,0.1);
      
      public static const ABILITY_CHARGING:RumbleEffect = new RumbleEffect("AbilityCharging",0.2,0.2,1);
      
      public static const PLAYER_LEVEL_UP:RumbleEffect = new RumbleEffect("PlayerLevelUp",0.5,0.8,0.5);
      
      public static const PLAYER_REVIVING_PARTY:RumbleEffect = new RumbleEffect("PlayerRevivingParty",0.8,0.8,1);
      
      public static const PLAYER_REVIVING_INDIVIDUAL:RumbleEffect = new RumbleEffect("PlayerRevivingIndividual",0.8,0.5,0.5);
      
      public static const BOSS_FIGHT_END:RumbleEffect = new RumbleEffect("BossFightEnd",0.8,0.8,0.5);
      
      public static const PICKING_UP_ITEM:RumbleEffect = new RumbleEffect("PickingUpItem",0.1,0,0.1);
      
      private var mName:String;
      
      private var mLeftIntensity:Number;
      
      private var mRightIntensity:Number;
      
      private var mDurationSeconds:Number;
      
      public function RumbleEffect(name:String, leftIntensity:Number, rightIntensity:Number, durationSeconds:Number)
      {
         super();
         mName = name;
         mLeftIntensity = clampIntensity(leftIntensity);
         mRightIntensity = clampIntensity(rightIntensity);
         mDurationSeconds = durationSeconds > 0 ? durationSeconds : 0;
      }
      
      private static function clampIntensity(intensity:Number) : Number
      {
         if(intensity <= 0)
         {
            return 0;
         }
         return intensity < 1 ? intensity : 1;
      }
      
      public function get name() : String
      {
         return mName;
      }
      
      public function get leftIntensity() : Number
      {
         return mLeftIntensity;
      }
      
      public function get rightIntensity() : Number
      {
         return mRightIntensity;
      }
      
      public function get durationSeconds() : Number
      {
         return mDurationSeconds;
      }
      
      public function scaled(multiplier:Number) : RumbleEffect
      {
         return new RumbleEffect(mName,mLeftIntensity * multiplier,mRightIntensity * multiplier,mDurationSeconds);
      }
      
      public function withDuration(durationSeconds:Number) : RumbleEffect
      {
         return new RumbleEffect(mName,mLeftIntensity,mRightIntensity,durationSeconds);
      }
   }
}

