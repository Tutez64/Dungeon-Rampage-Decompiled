package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   import flash.geom.Vector3D;
   
   public class PlayEffectTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "effect";
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      protected var mEffectName:String;
      
      protected var mEffectPath:String;
      
      protected var mXOffset:Number;
      
      protected var mYOffset:Number;
      
      protected var mHeadingOffset:Number;
      
      protected var mHeadingOffsetAngle:Number;
      
      protected var mParentToActor:Boolean;
      
      protected var mPlayAtTarget:Boolean;
      
      protected var mBehindAvatar:Boolean;
      
      protected var mScale:Number;
      
      protected var mAutoAdjustHeading:Boolean;
      
      protected var mLoop:Boolean;
      
      protected var mLayer:String;
      
      protected var mPlayRate:Number;
      
      protected var mUseTimelineSpeed:Boolean;
      
      protected var mInsertParentName:String;
      
      protected var mInsertIconPath:String;
      
      protected var mInsertIconName:String;
      
      protected var mInsertIconClip:MovieClip;
      
      protected var mInsertParentClip:MovieClip;
      
      protected var mDoIconInsert:Boolean;
      
      public var mManaged:Boolean;
      
      protected var mInvertAngles:Boolean = false;
      
      public function PlayEffectTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, effectName:String, effectPath:String, xOffset:Number = 0, yOffset:Number = 0, headingOffset:Number = 0, headingOffsetAngle:Number = 0, playAtTarget:Boolean = false, parentToActor:Boolean = false, behindAvatar:Boolean = false, scale:Number = 1, autoAdjustHeading:Boolean = false, loop:Boolean = false, layer:String = "sorted", managed:Boolean = false, useTimelineSpeed:Boolean = false, invertAngles:Boolean = false, insertParentName:String = "", insertIconPath:String = "", insertIconName:String = "")
      {
         super(actorGameObject,actorView,dbFacade);
         mEffectName = effectName;
         mEffectPath = effectPath;
         mXOffset = xOffset;
         mYOffset = yOffset;
         mHeadingOffset = headingOffset;
         mHeadingOffsetAngle = headingOffsetAngle;
         mPlayAtTarget = playAtTarget;
         mParentToActor = parentToActor;
         mBehindAvatar = behindAvatar;
         mScale = scale;
         mAutoAdjustHeading = autoAdjustHeading;
         mLoop = loop;
         mLayer = layer != null ? layer : "sorted";
         mManaged = managed;
         if(!mScale)
         {
            mScale = 1;
         }
         mPlayRate = 1;
         mUseTimelineSpeed = false;
         if(useTimelineSpeed)
         {
            mUseTimelineSpeed = true;
         }
         mInvertAngles = invertAngles;
         mInsertParentName = insertParentName;
         mInsertIconPath = insertIconPath;
         mInsertIconName = insertIconName;
         mDoIconInsert = mInsertParentName != null && mInsertIconPath != null && mInsertIconName != null;
         if(mDoIconInsert)
         {
            mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mInsertIconPath),iconAssetLoaded(this));
         }
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : PlayEffectTimelineAction
      {
         return new PlayEffectTimelineAction(actorGameObject,actorView,dbFacade,actionObj.name,actionObj.path,actionObj.xOffset,actionObj.yOffset,actionObj.headingOffset,actionObj.headingOffsetAngle,actionObj.playAtTarget,actionObj.parentToActor,actionObj.behindAvatar,actionObj.scale,actionObj.autoAdjustHeading,actionObj.loop,actionObj.layer,actionObj.managed,actionObj.useTimelineSpeed,actionObj.invertAngles,actionObj.insertParentName,actionObj.insertIconPath,actionObj.insertIconName);
      }
      
      override public function destroy() : void
      {
         mDistributedDungeonFloor = null;
         mInsertIconClip = null;
         mInsertParentName = "";
         mInsertIconName = "";
         super.destroy();
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
      }
      
      protected function TryInsertClipIntoEffect() : void
      {
         var _loc1_:MovieClip = null;
         if(mInsertIconClip != null && mInsertParentClip != null)
         {
            if(mInsertParentClip.getChildByName(mInsertParentName) == null)
            {
               Logger.warn("mInsertParentClip.getChildByName( " + mInsertParentClip + " ) == null");
               return;
            }
            _loc1_ = MovieClip(mInsertParentClip.getChildByName(mInsertParentName));
            if(_loc1_ == null)
            {
               Logger.warn("parentNameMovieClip == null");
               return;
            }
            while(_loc1_.numChildren > 0)
            {
               _loc1_.removeChildAt(0);
            }
            _loc1_.addChild(mInsertIconClip);
         }
      }
      
      private function iconAssetLoaded(timeline_action:PlayEffectTimelineAction) : Function
      {
         return function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass(timeline_action.mInsertIconName);
            if(_loc2_ == null)
            {
               Logger.error("Unable to find class: " + timeline_action.mInsertIconName);
               return;
            }
            timeline_action.mInsertIconClip = new _loc2_();
            timeline_action.mInsertIconClip.mouseChildren = false;
            timeline_action.mInsertIconClip.mouseEnabled = false;
            timeline_action.TryInsertClipIntoEffect();
         };
      }
      
      protected function assetLoadedCallback(timeline_action:PlayEffectTimelineAction) : Function
      {
         return function(param1:MovieClip):void
         {
            timeline_action.mInsertParentClip = param1;
            timeline_action.TryInsertClipIntoEffect();
         };
      }
      
      public function calculateHeadingOffset(offset:Number, heading:Number, actorPosition:Vector3D, angleAddition:Number = 0) : Vector3D
      {
         heading += angleAddition;
         if(heading < 0)
         {
            heading = 360 + heading;
         }
         heading = convertToRadians(heading);
         var _loc5_:Vector3D = new Vector3D(0,0,0);
         _loc5_.x = actorPosition.x + offset * Math.cos(heading);
         _loc5_.y = actorPosition.y + offset * Math.sin(heading);
         return _loc5_;
      }
      
      private function convertToRadians(angle:Number) : Number
      {
         return angle * 3.141592653589793 / 180;
      }
      
      public function get useTimelineSpeed() : Boolean
      {
         return mUseTimelineSpeed;
      }
      
      public function calculatePositionBasedOnOffsets(targetActor:ActorGameObject) : Vector3D
      {
         var _loc3_:Vector3D = null;
         var _loc2_:Vector3D = new Vector3D(0,0,0);
         if(mPlayAtTarget)
         {
            _loc2_ = targetActor.position;
         }
         else
         {
            _loc3_ = new Vector3D(0,0,0);
            if(!mParentToActor)
            {
               if(mHeadingOffset)
               {
                  _loc3_ = mActorGameObject.position;
               }
               else
               {
                  _loc2_ = mActorGameObject.position;
               }
            }
            if(!mHeadingOffsetAngle)
            {
               mHeadingOffsetAngle = 0;
            }
            if(mHeadingOffset)
            {
               _loc2_ = calculateHeadingOffset(mHeadingOffset,mActorGameObject.heading,_loc3_,mHeadingOffsetAngle);
            }
         }
         if(!mYOffset)
         {
            mYOffset = 0;
         }
         if(!mXOffset)
         {
            mXOffset = 0;
         }
         _loc2_.y += mYOffset;
         _loc2_.x += mXOffset;
         return _loc2_;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         if(mPlayAtTarget && timeline.targetActor == null)
         {
            return;
         }
         mPlayRate = timeline.playSpeed;
         var _loc2_:ActorGameObject = null;
         if(mParentToActor)
         {
            _loc2_ = mActorGameObject;
         }
         var _loc3_:Vector3D = calculatePositionBasedOnOffsets(timeline.targetActor);
         var _loc4_:uint = mActorGameObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(mEffectPath),mEffectName,_loc3_,_loc2_,mBehindAvatar,mScale,0,0,0,0,false,mLayer,mManaged,mPlayRate,mDoIconInsert ? assetLoadedCallback(this) : null);
         if(mManaged)
         {
            timeline.mManagedEffects.add(_loc4_);
         }
      }
   }
}

