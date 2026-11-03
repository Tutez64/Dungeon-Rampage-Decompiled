package Combat.Weapon
{
   import Actor.ActorRenderer;
   import Brain.Render.IRenderer;
   import Facade.DBFacade;
   import starling.extensions.animate.Animation;
   
   public class WeaponRenderer extends ActorRenderer
   {
      
      public static const WEAPON_DRAW_ORDER_OFFSET:Number = 0.1;
      
      private static const DIRECTION_LABEL_SUFFIXES:Array = ["_angA","_angB","_angC","_angD","_angE"];
      
      protected var mWeaponGameObject:WeaponGameObject;
      
      public function WeaponRenderer(dbFacade:DBFacade, weaponGameObject:WeaponGameObject, triggerState:Boolean)
      {
         super(dbFacade,weaponGameObject.actorGameObject,triggerState);
         mWeaponGameObject = weaponGameObject;
      }
      
      public static function weaponSwfFilePath(actorSwfFilePath:String, modelName:String) : String
      {
         return actorSwfFilePath.slice(0,actorSwfFilePath.length - 4) + "_" + modelName + ".swf";
      }
      
      override protected function syncStarlingTransform(updateCulling:Boolean = false) : void
      {
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.drawOrderOffsetY = 0.1;
         }
         super.syncStarlingTransform(updateCulling);
      }
      
      override protected function testCulled(drawX:Number, drawY:Number, scale:Number) : Boolean
      {
         var _loc4_:ActorRenderer = mActorGameObject.actorView != null ? mActorGameObject.actorView.bodyAnimRenderer : null;
         return _loc4_ != null && _loc4_.hasStarlingArt ? _loc4_.isCulled : Boolean(super.testCulled(drawX,drawY,scale));
      }
      
      public function followWielderCulling(culled:Boolean) : void
      {
         mCulled = mPendingVisible && culled;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.setVisibility(mPendingVisible,mCulled);
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
         mWeaponGameObject = null;
      }
      
      override protected function loadErrorCallback() : void
      {
      }
      
      override protected function get fallbackCategory() : String
      {
         return "WEAPON:" + mWeaponGameObject.weaponAesthetic.ModelName;
      }
      
      override protected function getSpriteSheetClassName(animName:String) : String
      {
         return mActorGameObject.actorData.assetClassName + "_" + animName + "_" + mWeaponGameObject.weaponAesthetic.ModelName + ".png";
      }
      
      override protected function get movieClipClassName() : String
      {
         return super.movieClipClassName + "_" + mWeaponGameObject.weaponAesthetic.ModelName;
      }
      
      override protected function isStarlingMultiDirectionAnim(animation:Animation) : Boolean
      {
         if(super.isStarlingMultiDirectionAnim(animation))
         {
            return true;
         }
         for each(var _loc2_:String in DIRECTION_LABEL_SUFFIXES)
         {
            if(animation.hasFrameLabelSuffix(_loc2_))
            {
               return true;
            }
         }
         return false;
      }
      
      override protected function setAnimInDictionary(animName:String, renderer:IRenderer) : void
      {
         super.setAnimInDictionary(animName,renderer);
         stop();
      }
      
      override protected function updateStarlingHitArea() : void
      {
      }
      
      override protected function get backgroundLoadTier() : int
      {
         var _loc1_:int = super.backgroundLoadTier;
         return _loc1_ == 0 ? 1 : _loc1_;
      }
      
      override protected function get swfFilePath() : String
      {
         return weaponSwfFilePath(super.swfFilePath,mWeaponGameObject.weaponAesthetic.ModelName);
      }
   }
}

