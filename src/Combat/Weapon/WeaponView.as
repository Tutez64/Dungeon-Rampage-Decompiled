package Combat.Weapon
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.GameObject.View;
   import Brain.Render.ActorSpriteSheetRenderer;
   import Brain.Utils.ColorMatrix;
   import Brain.WorkLoop.PreRenderWorkComponent;
   import Facade.DBFacade;
   import GameMasterDictionary.GMWeaponAesthetic;
   import flash.display.DisplayObject;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   
   public class WeaponView extends View
   {
      
      protected var mWeaponGameObject:WeaponGameObject;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mPreRenderWorkComponent:PreRenderWorkComponent;
      
      protected var mWeaponAnimRenderer:ActorSpriteSheetRenderer;
      
      protected var mWeaponRenderer:WeaponRenderer;
      
      protected var mDBFacade:DBFacade;
      
      public function WeaponView(facade:DBFacade, weaponGameObject:WeaponGameObject)
      {
         mDBFacade = facade;
         super(facade);
         mWeaponGameObject = weaponGameObject;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade,"WeaponView");
         if(mWeaponGameObject.weaponAesthetic.ModelName)
         {
            mWeaponRenderer = new WeaponRenderer(mDBFacade,mWeaponGameObject,true);
            mWeaponRenderer.loadAssets();
            mWeaponGameObject.actorGameObject.actorView.body.addChild(mWeaponRenderer);
            applyColorAndGlow(mWeaponRenderer);
         }
      }
      
      protected function applyColorAndGlow(node:DisplayObject) : void
      {
         var _loc3_:ColorMatrix = null;
         var _loc2_:GMWeaponAesthetic = mWeaponGameObject.weaponAesthetic;
         if(_loc2_.HasColor)
         {
            node.transform.colorTransform = new ColorTransform(_loc2_.ItemR,_loc2_.ItemG,_loc2_.ItemB,1,_loc2_.ItemRAdd,_loc2_.ItemGAdd,_loc2_.ItemBAdd,0);
            _loc3_ = new ColorMatrix();
            _loc3_.setMultiplicators(_loc2_.ItemR,_loc2_.ItemG,_loc2_.ItemB,1);
            _loc3_.adjustBrightness(_loc2_.ItemRAdd,_loc2_.ItemGAdd,_loc2_.ItemBAdd);
            mWeaponRenderer.applyColorFilter(_loc3_.matrix);
         }
         if(_loc2_.HasGlow)
         {
            node.filters = [new GlowFilter(_loc2_.GlowColor,1,_loc2_.GlowDist,_loc2_.GlowDist,_loc2_.GlowStr)];
            mWeaponRenderer.setPersistentGlowFilter(_loc2_.GlowColor,_loc2_.GlowStr,_loc2_.GlowDist);
         }
         if(mWeaponGameObject.gmRarity.HasGlow)
         {
            node.filters = [new GlowFilter(mWeaponGameObject.gmRarity.GlowColor,1,mWeaponGameObject.gmRarity.GlowDist,mWeaponGameObject.gmRarity.GlowDist,mWeaponGameObject.gmRarity.GlowStr)];
            mWeaponRenderer.setPersistentGlowFilter(mWeaponGameObject.gmRarity.GlowColor,mWeaponGameObject.gmRarity.GlowStr,mWeaponGameObject.gmRarity.GlowDist);
         }
      }
      
      protected function removeColorAndGlow(node:DisplayObject) : void
      {
         var _loc2_:GMWeaponAesthetic = mWeaponGameObject.weaponAesthetic;
         if(_loc2_.HasColor)
         {
            node.transform.colorTransform = new ColorTransform();
            mWeaponRenderer.clearColorFilter();
         }
         if(_loc2_.HasGlow)
         {
            node.filters = [];
            mWeaponRenderer.clearPersistentGlowFilter();
         }
      }
      
      public function get weaponRenderer() : WeaponRenderer
      {
         return mWeaponRenderer;
      }
      
      override public function destroy() : void
      {
         if(mWeaponRenderer)
         {
            mWeaponRenderer.destroy();
            mWeaponRenderer = null;
         }
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mPreRenderWorkComponent.destroy();
         mPreRenderWorkComponent = null;
         mWeaponGameObject = null;
         mDBFacade = null;
         super.destroy();
      }
   }
}

