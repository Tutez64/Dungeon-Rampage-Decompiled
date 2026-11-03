package Box2D.Common
{
   import haxe.Exception;
   
   public class b2Settings
   {
      
      public static var VERSION:String = "2.1alpha";
      
      public static var USHRT_MAX:int = 65535;
      
      public static var b2_maxManifoldPoints:int = 2;
      
      public static var b2_aabbExtension:Number = 0.1;
      
      public static var b2_aabbMultiplier:Number = 2;
      
      public static var b2_polygonRadius:Number = 0.01;
      
      public static var b2_linearSlop:Number = 0.005;
      
      public static var b2_toiSlop:Number = 0.04;
      
      public static var b2_maxTOIContactsPerIsland:int = 32;
      
      public static var b2_maxTOIJointsPerIsland:int = 32;
      
      public static var b2_velocityThreshold:Number = 1;
      
      public static var b2_maxLinearCorrection:Number = 0.2;
      
      public static var b2_maxTranslation:Number = 2;
      
      public static var b2_maxTranslationSquared:Number = 4;
      
      public static var b2_contactBaumgarte:Number = 0.2;
      
      public static var b2_timeToSleep:Number = 0.5;
      
      public static var b2_linearSleepTolerance:Number = 0.01;
      
      public static var b2_pi:Number = Math.PI;
      
      public static var b2_angularSlop:Number = 0.011111111111111112 * Math.PI;
      
      public static var b2_maxAngularCorrection:Number = 0.044444444444444446 * Math.PI;
      
      public static var b2_maxRotation:Number = 0.5 * Math.PI;
      
      public static var b2_maxRotationSquared:Number = 0.5 * Math.PI * (0.5 * Math.PI);
      
      public static var b2_angularSleepTolerance:Number = 0.011111111111111112 * Math.PI;
      
      public function b2Settings()
      {
      }
      
      public static function b2MixFriction(friction1:Number, friction2:Number) : Number
      {
         return Math.sqrt(friction1 * friction2);
      }
      
      public static function b2MixRestitution(restitution1:Number, restitution2:Number) : Number
      {
         if(restitution1 > restitution2)
         {
            return restitution1;
         }
         return restitution2;
      }
      
      public static function b2Assert(a:Boolean) : void
      {
         if(!a)
         {
            throw Exception.thrown("Assertion Failed");
         }
      }
      
      public static function B2MixFriction(friction1:Number, friction2:Number) : Number
      {
         return b2Settings.b2MixFriction(friction1,friction2);
      }
      
      public static function B2MixRestitution(restitution1:Number, restitution2:Number) : Number
      {
         return b2Settings.b2MixRestitution(restitution1,restitution2);
      }
      
      public static function B2Assert(a:Boolean) : void
      {
         b2Settings.b2Assert(a);
      }
   }
}

