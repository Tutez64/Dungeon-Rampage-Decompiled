package Combat.Weapon
{
   import Actor.ActorRenderer;
   import Brain.Render.IRenderer;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   
   public class WeaponRenderer extends ActorRenderer
   {
      
      protected var mWeaponGameObject:WeaponGameObject;
      
      public function WeaponRenderer(dbFacade:DBFacade, weaponGameObject:WeaponGameObject, triggerState:Boolean)
      {
         super(dbFacade,weaponGameObject.actorGameObject,triggerState);
         mWeaponGameObject = weaponGameObject;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         mWeaponGameObject = null;
      }
      
      override protected function loadErrorCallback() : void
      {
      }
      
      override protected function getSpriteSheetClassName(animName:String) : String
      {
         return mActorGameObject.actorData.assetClassName + "_" + animName + "_" + mWeaponGameObject.weaponAesthetic.ModelName + ".png";
      }
      
      override protected function get movieClipClassName() : String
      {
         return super.movieClipClassName + "_" + mWeaponGameObject.weaponAesthetic.ModelName;
      }
      
      override protected function setAnimInDictionary(animName:String, renderer:IRenderer) : void
      {
         super.setAnimInDictionary(animName,renderer);
         stop();
      }
      
      override protected function get swfFilePath() : String
      {
         if(DBGlobal.endsWith(super.swfFilePath,".HD.swf"))
         {
            return super.swfFilePath.slice(0,super.swfFilePath.length - 7) + "_" + mWeaponGameObject.weaponAesthetic.ModelName + ".HD.swf";
         }
         return super.swfFilePath.slice(0,super.swfFilePath.length - 4) + "_" + mWeaponGameObject.weaponAesthetic.ModelName + ".swf";
      }
   }
}

