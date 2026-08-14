package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Combat.Weapon.WeaponGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import GameMasterDictionary.GMWeaponAesthetic;
   import flash.geom.Vector3D;
   
   public class PlayEffectAttackTimelineAction extends PlayEffectTimelineAction
   {
      
      public static const TYPE:String = "attackEffect";
      
      public static const SWING_RIGHT:String = "attack_swingRight";
      
      public static const SWING_LEFT:String = "attack_swingLeft";
      
      public static const SWORD_TRAIL_DEFAULT_PREFIX:String = "db_fx_attack";
      
      protected var mActorPos:Vector3D;
      
      protected var mChargeTime:Number;
      
      protected var mWeapon:WeaponGameObject;
      
      protected var mRegisterChargeEffectCallback:Function;
      
      public function PlayEffectAttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, weapon:WeaponGameObject, registerChargeEffectCallback:Function, effectName:String, effectPath:String, xOffset:Number = 0, yOffset:Number = 0, headingOffset:Number = 0, headingOffsetAngle:Number = 0, playAtTarget:Boolean = false, parentToActor:Boolean = false, behindAvatar:Boolean = false, scale:Number = 1, autoAdjustHeading:Boolean = false, loop:Boolean = false, layer:String = "sorted", managed:Boolean = false, useTimelineSpeed:Boolean = false, invertAngles:Boolean = false, insertParentName:String = "", insertIconPath:String = "", insertIconName:String = "")
      {
         super(actorGameObject,actorView,dbFacade,effectName,effectPath,xOffset,yOffset,headingOffset,headingOffsetAngle,playAtTarget,parentToActor,behindAvatar,scale,autoAdjustHeading,loop,layer,managed,useTimelineSpeed,invertAngles,insertParentName,insertIconPath,insertIconName);
         mDistributedDungeonFloor = distributedDungeonFloor;
         mWeapon = weapon;
         var _loc26_:Number = mWeapon != null ? mWeapon.collisionScale() : 1;
         mScale *= _loc26_;
         mXOffset *= _loc26_;
         mYOffset *= _loc26_;
         mRegisterChargeEffectCallback = registerChargeEffectCallback;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, actionObj:Object, weapon:WeaponGameObject, registerChargeEffectCallback:Function) : PlayEffectAttackTimelineAction
      {
         return new PlayEffectAttackTimelineAction(actorGameObject,actorView,dbFacade,distributedDungeonFloor,weapon,registerChargeEffectCallback,actionObj.name,actionObj.path,actionObj.xOffset,actionObj.yOffset,actionObj.headingOffset,actionObj.headingOffsetAngle,actionObj.playAtTarget,actionObj.parentToActor,actionObj.behindAvatar,actionObj.scale,actionObj.autoAdjustHeading,actionObj.loop,actionObj.layer,actionObj.managed,actionObj.useTimelineSpeed,actionObj.invertAngles,actionObj.insertParentName,actionObj.insertIconPath,actionObj.insertIconName);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         var _loc5_:GMWeaponAesthetic = null;
         if(mPlayAtTarget && timeline.targetActor == null)
         {
            return;
         }
         if(useTimelineSpeed)
         {
            mPlayRate = timeline.playSpeed;
         }
         var _loc3_:ActorGameObject = null;
         if(mParentToActor)
         {
            _loc3_ = mActorGameObject;
         }
         var _loc4_:Vector3D = calculatePositionBasedOnOffsets(timeline.targetActor);
         var _loc10_:String = mEffectName.substring();
         var _loc7_:Number = mActorGameObject.heading;
         var _loc2_:Number = 0;
         var _loc9_:Number = 0;
         if(mAutoAdjustHeading)
         {
            _loc2_ = _loc7_;
         }
         var _loc6_:Object = {};
         if(mInvertAngles)
         {
            _loc7_ += 180;
         }
         if(mEffectName.indexOf("_angle") >= 0)
         {
            if(mActorGameObject.currentWeapon)
            {
               _loc5_ = mActorGameObject.currentWeapon.weaponAesthetic;
            }
            if(_loc5_ && _loc5_.SwordTrailOverride)
            {
               _loc10_ = _loc10_.replace("db_fx_attack",_loc5_.SwordTrailOverride);
            }
            _loc6_ = convertAngleForEffectName(_loc7_);
            _loc10_ += _loc6_.string;
            if(_loc10_.indexOf("swing_angle") >= 0)
            {
               if(mActorGameObject.actorView.currentAnim == "attack_swingRight")
               {
                  _loc10_ += "_right";
               }
               else
               {
                  _loc10_ += "_left";
               }
            }
         }
         if(_loc6_.flip)
         {
            _loc9_ = 180;
         }
         var _loc8_:uint = 0;
         _loc10_ = mDBFacade.customSkinVisualsOverrideHandler.customSkinBusterVisualOverrider(_loc10_,mActorGameObject);
         _loc8_ = mActorGameObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(mEffectPath),_loc10_,_loc4_,_loc3_,mBehindAvatar,mScale,0,0,_loc9_,_loc2_,mLoop,mLayer,mManaged,mPlayRate,mDoIconInsert ? assetLoadedCallback(this) : null);
         if(mManaged)
         {
            timeline.mManagedEffects.add(_loc8_);
         }
      }
      
      public function convertAngleForEffectName(angle:int) : Object
      {
         var _loc3_:Object = {
            "string":"",
            "flip":true
         };
         if(angle < 0)
         {
            angle = 360 + angle;
         }
         var _loc2_:int = angle % 45;
         if(_loc2_ > 22)
         {
            angle += 45 - _loc2_;
         }
         else
         {
            angle -= _loc2_;
         }
         if(angle == 0 || angle == 360)
         {
            _loc3_.string = "180";
         }
         else if(angle == 45)
         {
            _loc3_.string = "135";
         }
         else if(angle == 315)
         {
            _loc3_.string = "225";
         }
         else
         {
            _loc3_.flip = false;
            _loc3_.string = angle.toString();
         }
         return _loc3_;
      }
      
      override public function destroy() : void
      {
         mRegisterChargeEffectCallback = null;
         mWeapon = null;
         super.destroy();
      }
   }
}

