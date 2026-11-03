package SteamInput
{
   import Facade.DBFacade;
   import com.amanitadesign.steam.FRESteamWorks;
   import flash.utils.getTimer;
   
   public class ControllerRumble
   {
      
      private static const MAX_MOTOR_SPEED:uint = 65535;
      
      private static const MILLISECONDS_PER_SECOND:Number = 1000;
      
      protected var mDBFacade:DBFacade;
      
      private var mSteamworks:FRESteamWorks;
      
      private var mActiveRumbles:Vector.<ActiveRumble> = new Vector.<ActiveRumble>();
      
      private var mIsEnabled:Boolean = true;
      
      private var mLastSentLeftSpeed:uint = 0;
      
      private var mLastSentRightSpeed:uint = 0;
      
      public function ControllerRumble(dbFacade:DBFacade, steamworks:FRESteamWorks)
      {
         super();
         mDBFacade = dbFacade;
         mSteamworks = steamworks;
      }
      
      private static function toMotorSpeed(intensity:Number) : uint
      {
         return uint(intensity * 65535);
      }
      
      public function play(effect:RumbleEffect) : void
      {
         if(!mIsEnabled || effect == null || effect.durationSeconds <= 0 || !mDBFacade.featureFlags.getFlagValue("want-controller-rumble"))
         {
            return;
         }
         if(effect.leftIntensity <= 0 && effect.rightIntensity <= 0)
         {
            return;
         }
         mActiveRumbles.push(new ActiveRumble(effect,getTimer() + effect.durationSeconds * 1000));
      }
      
      public function stopAll() : void
      {
         mActiveRumbles.length = 0;
      }
      
      public function update(connectedControllers:Vector.<SteamController>) : void
      {
         var _loc4_:int = 0;
         var _loc5_:ActiveRumble = null;
         var _loc6_:Number = getTimer();
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         _loc4_ = mActiveRumbles.length - 1;
         while(_loc4_ >= 0)
         {
            _loc5_ = mActiveRumbles[_loc4_];
            if(_loc6_ >= _loc5_.endTimeMs)
            {
               mActiveRumbles.removeAt(_loc4_);
            }
            else
            {
               if(_loc5_.effect.leftIntensity > _loc2_)
               {
                  _loc2_ = _loc5_.effect.leftIntensity;
               }
               if(_loc5_.effect.rightIntensity > _loc3_)
               {
                  _loc3_ = _loc5_.effect.rightIntensity;
               }
            }
            _loc4_--;
         }
         sendToControllers(connectedControllers,toMotorSpeed(_loc2_),toMotorSpeed(_loc3_));
      }
      
      public function forgetHardwareState() : void
      {
         mLastSentLeftSpeed = 0;
         mLastSentRightSpeed = 0;
      }
      
      public function get isEnabled() : Boolean
      {
         return mIsEnabled;
      }
      
      public function set isEnabled(value:Boolean) : void
      {
         if(mIsEnabled == value)
         {
            return;
         }
         mIsEnabled = value;
         if(!mIsEnabled)
         {
            stopAll();
         }
      }
      
      private function sendToControllers(connectedControllers:Vector.<SteamController>, leftSpeed:uint, rightSpeed:uint) : void
      {
         if(leftSpeed == mLastSentLeftSpeed && rightSpeed == mLastSentRightSpeed)
         {
            return;
         }
         mLastSentLeftSpeed = leftSpeed;
         mLastSentRightSpeed = rightSpeed;
         for each(var _loc4_:SteamController in connectedControllers)
         {
            mSteamworks.triggerVibration(_loc4_.controllerHandle,leftSpeed,rightSpeed);
         }
      }
   }
}

import SteamInput.RumbleEffect;

class ActiveRumble
{
   
   public var effect:RumbleEffect;
   
   public var endTimeMs:Number;
   
   public function ActiveRumble(effect:RumbleEffect, endTimeMs:Number)
   {
      super();
      this.effect = effect;
      this.endTimeMs = endTimeMs;
   }
}
