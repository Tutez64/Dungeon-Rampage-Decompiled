package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Clock.GameClock;
   import Brain.WorkLoop.Task;
   import Facade.DBFacade;
   import flash.geom.ColorTransform;
   import flash.geom.Vector3D;
   
   public class ColorShiftTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "color";
      
      private var mDuration:uint;
      
      private var mColorMul:Vector3D;
      
      private var mColorAdd:Vector3D;
      
      private var mAlphaMul:Number;
      
      private var mAlphaAdd:Number;
      
      private var mOldColorTransform:ColorTransform;
      
      private var mColorTransformTask:Task;
      
      private var mFramesElapsed:uint = 0;
      
      private var mOffsets:ColorTransform;
      
      private var mTransitionDuration:Number;
      
      public function ColorShiftTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, duration:uint, color_mul:Vector3D, color_add:Vector3D, filter_alpha:Number, add_alpha:Number, transitionDur:Number)
      {
         mDuration = duration;
         mColorMul = new Vector3D(color_mul.x,color_mul.y,color_mul.z);
         mColorAdd = new Vector3D(color_add.x,color_add.y,color_add.z);
         mAlphaMul = filter_alpha;
         mAlphaAdd = add_alpha;
         mTransitionDuration = transitionDur;
         super(actorGameObject,actorView,dbFacade);
         mOldColorTransform = new ColorTransform();
         mOffsets = new ColorTransform();
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : ColorShiftTimelineAction
      {
         var _loc5_:Number = Number(actionObj.duration);
         var _loc10_:Vector3D = new Vector3D(actionObj.filter_r,actionObj.filter_g,actionObj.filter_b);
         var _loc7_:Vector3D = new Vector3D(actionObj.add_r,actionObj.add_g,actionObj.add_b);
         var _loc6_:Number = Number(actionObj.filter_alpha);
         var _loc9_:Number = Number(actionObj.add_alpha);
         var _loc8_:Number = Number(actionObj.transitionDur);
         return new ColorShiftTimelineAction(actorGameObject,actorView,dbFacade,_loc5_,_loc10_,_loc7_,_loc6_,_loc9_,_loc8_);
      }
      
      private function CopyColorTransform(color_src:ColorTransform) : ColorTransform
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.alphaMultiplier = color_src.alphaMultiplier;
         _loc2_.alphaOffset = color_src.alphaOffset;
         _loc2_.blueMultiplier = color_src.blueMultiplier;
         _loc2_.blueOffset = color_src.blueOffset;
         _loc2_.redMultiplier = color_src.redMultiplier;
         _loc2_.redOffset = color_src.redOffset;
         _loc2_.greenMultiplier = color_src.greenMultiplier;
         _loc2_.greenOffset = color_src.greenOffset;
         return _loc2_;
      }
      
      private function CalculateColorTransformOffsets(color_src:ColorTransform, color_target:ColorTransform, duration:Number) : void
      {
         mOffsets.alphaMultiplier = (color_target.alphaMultiplier - color_src.alphaMultiplier) / duration;
         mOffsets.alphaOffset = (color_target.alphaOffset - color_src.alphaOffset) / duration;
         mOffsets.blueMultiplier = (color_target.blueMultiplier - color_src.blueMultiplier) / duration;
         mOffsets.blueOffset = (color_target.blueOffset - color_src.blueOffset) / duration;
         mOffsets.redMultiplier = (color_target.redMultiplier - color_src.redMultiplier) / duration;
         mOffsets.redOffset = (color_target.redOffset - color_src.redOffset) / duration;
         mOffsets.greenMultiplier = (color_target.greenMultiplier - color_src.greenMultiplier) / duration;
         mOffsets.greenOffset = (color_target.greenOffset - color_src.greenOffset) / duration;
      }
      
      private function AddColorTransformOffsets() : ColorTransform
      {
         var _loc1_:ColorTransform = new ColorTransform();
         var _loc2_:ColorTransform = mActorView.body.transform.colorTransform;
         _loc1_.alphaMultiplier = _loc2_.alphaMultiplier + mOffsets.alphaMultiplier;
         _loc1_.alphaOffset = _loc2_.alphaOffset + mOffsets.alphaOffset;
         _loc1_.blueMultiplier = _loc2_.blueMultiplier + mOffsets.blueMultiplier;
         _loc1_.blueOffset = _loc2_.blueOffset + mOffsets.blueOffset;
         _loc1_.redMultiplier = _loc2_.redMultiplier + mOffsets.redMultiplier;
         _loc1_.redOffset = _loc2_.redOffset + mOffsets.redOffset;
         _loc1_.greenMultiplier = _loc2_.greenMultiplier + mOffsets.greenMultiplier;
         _loc1_.greenOffset = _loc2_.greenOffset + mOffsets.greenOffset;
         return _loc1_;
      }
      
      private function SubtractColorTransformOffsets() : ColorTransform
      {
         var _loc1_:ColorTransform = new ColorTransform();
         var _loc2_:ColorTransform = mActorView.body.transform.colorTransform;
         _loc1_.alphaMultiplier = _loc2_.alphaMultiplier - mOffsets.alphaMultiplier;
         _loc1_.alphaOffset = _loc2_.alphaOffset - mOffsets.alphaOffset;
         _loc1_.blueMultiplier = _loc2_.blueMultiplier - mOffsets.blueMultiplier;
         _loc1_.blueOffset = _loc2_.blueOffset - mOffsets.blueOffset;
         _loc1_.redMultiplier = _loc2_.redMultiplier - mOffsets.redMultiplier;
         _loc1_.redOffset = _loc2_.redOffset - mOffsets.redOffset;
         _loc1_.greenMultiplier = _loc2_.greenMultiplier - mOffsets.greenMultiplier;
         _loc1_.greenOffset = _loc2_.greenOffset - mOffsets.greenOffset;
         return _loc1_;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         if(mFramesElapsed != 0)
         {
            ResetColorTransform();
         }
         mFramesElapsed = 0;
         mOldColorTransform = CopyColorTransform(new ColorTransform());
         var _loc2_:ColorTransform = new ColorTransform(mColorMul.x,mColorMul.y,mColorMul.z,mAlphaMul,mColorAdd.x,mColorAdd.y,mColorAdd.z,mAlphaAdd);
         CalculateColorTransformOffsets(mOldColorTransform,_loc2_,mTransitionDuration);
         if(mColorTransformTask)
         {
            mColorTransformTask.destroy();
            mColorTransformTask = null;
         }
         if(mWorkComponent)
         {
            mColorTransformTask = mWorkComponent.doEveryFrame(UpdateColorShift);
         }
      }
      
      public function UpdateColorShift(clock:GameClock) : void
      {
         if(mActorView && mActorView.body)
         {
            mFramesElapsed = mFramesElapsed + 1;
            if(mFramesElapsed <= mTransitionDuration)
            {
               mActorView.body.transform.colorTransform = AddColorTransformOffsets();
            }
            else if(mFramesElapsed >= mDuration - mTransitionDuration)
            {
               mActorView.body.transform.colorTransform = SubtractColorTransformOffsets();
            }
            if(mFramesElapsed > mDuration)
            {
               ResetColorTransform();
               return;
            }
            return;
         }
         ResetColorTransform();
      }
      
      private function ResetColorTransform() : void
      {
         mFramesElapsed = 0;
         if(mActorView && mActorView.body)
         {
            mActorView.body.transform.colorTransform = CopyColorTransform(mOldColorTransform);
         }
         if(mColorTransformTask)
         {
            mColorTransformTask.destroy();
            mColorTransformTask = null;
         }
      }
      
      override public function destroy() : void
      {
         if(mColorTransformTask)
         {
            mColorTransformTask.destroy();
            mColorTransformTask = null;
         }
         super.destroy();
      }
   }
}

