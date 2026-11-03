package Effects
{
   import Actor.ActorGameObject;
   import Brain.Event.EventComponent;
   import Brain.Render.Tweens.Circ;
   import Brain.Render.Tweens.Sine;
   import Brain.Render.Tweens.TweenHandle;
   import Facade.DBFacade;
   import flash.events.Event;
   import flash.geom.Vector3D;
   
   public class LerpEffectGameObject extends EffectGameObject
   {
      
      private static const sNextPos:Vector3D = new Vector3D();
      
      private var mLerpTargetActor:ActorGameObject;
      
      private var mLerpSpeed:Number;
      
      public var mLerpTempSpeed:Number;
      
      private var mLerpTimeline:TweenHandle;
      
      private var mLerpTargetPositionVector:Vector3D;
      
      private var mLerpGlowColor:uint;
      
      private var mEventComponent:EventComponent;
      
      public function LerpEffectGameObject(facade:DBFacade, swfPath:String, className:String, playRate:Number, remoteId:uint = 0, assetLoadedCallback:Function = null, lerpToActor:ActorGameObject = null, lerpSpeed:Number = 1, lerpGlowColor:uint = 13369344)
      {
         super(facade,swfPath,className,playRate,remoteId,assetLoadedCallback);
         mLerpTargetActor = lerpToActor;
         mLerpSpeed = lerpSpeed + Math.random() * lerpSpeed / 2;
         mLerpGlowColor = lerpGlowColor;
         mLerpTargetPositionVector = new Vector3D(0,-50,0);
         mEventComponent = new EventComponent(facade);
         mEventComponent.addListener("enterFrame",update);
         mLerpTempSpeed = 0;
         mLerpTimeline = mDBFacade.mTween.createTimeline();
         mDBFacade.mTween.appendTween(mLerpTimeline,mDBFacade.mTween.tweenMaxTo(this,0.1,{
            "mLerpTempSpeed":-mLerpSpeed,
            "onComplete":function():void
            {
               mLerpTempSpeed = 0;
            }
         }));
         mDBFacade.mTween.appendTween(mLerpTimeline,mDBFacade.mTween.tweenMaxTo(this,0.65,{
            "mLerpTempSpeed":mLerpSpeed,
            "ease":Circ.easeIn
         }));
         mDBFacade.mTween.playTween(mLerpTimeline);
      }
      
      private function update(evt:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         if(mLerpTargetActor && mLerpTargetActor.hasPosition)
         {
            _loc2_ = mEffectView.positionX;
            _loc3_ = mEffectView.positionY;
            _loc5_ = mLerpTargetActor.positionX + mLerpTargetPositionVector.x - _loc2_;
            _loc7_ = mLerpTargetActor.positionY + mLerpTargetPositionVector.y - _loc3_;
            _loc6_ = mLerpTargetActor.positionZ + mLerpTargetPositionVector.z;
            _loc4_ = Math.sqrt(_loc5_ * _loc5_ + _loc7_ * _loc7_ + _loc6_ * _loc6_);
            if(_loc4_ != 0)
            {
               _loc5_ = _loc5_ / _loc4_ * mLerpTempSpeed;
               _loc7_ = _loc7_ / _loc4_ * mLerpTempSpeed;
            }
            sNextPos.x = _loc2_ + _loc5_;
            sNextPos.y = _loc3_ + _loc7_;
            mEffectView.position = sNextPos;
            if(_loc4_ < 15)
            {
               mDBFacade.mTween.tweenMaxTo(mLerpTargetActor.actorView.body,0.05,{"glowFilter":{
                  "color":mLerpGlowColor,
                  "alpha":1,
                  "blurX":15,
                  "blurY":15,
                  "remove":true,
                  "ease":Sine.easeInOut
               }});
               destroy();
            }
         }
         else
         {
            destroy();
         }
      }
      
      override public function destroy() : void
      {
         if(mEventComponent)
         {
            mEventComponent.removeListener("enterFrame");
            mEventComponent.destroy();
            mEventComponent = null;
         }
         super.destroy();
      }
   }
}

