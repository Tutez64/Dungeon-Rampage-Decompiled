package Effects
{
   import Actor.ActorGameObject;
   import Brain.GameObject.GameObject;
   import Facade.DBFacade;
   
   public class CustomSkinVisualsOverrideHandler
   {
      
      private static const DARK_MAGE_SKIN_ID:uint = 168;
      
      private var mDBFacade:DBFacade;
      
      public function CustomSkinVisualsOverrideHandler(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
      }
      
      public function customSkinVFXVisualsOverrider(vfxName:String, attackerId:uint) : String
      {
         var _loc4_:GameObject = null;
         var _loc3_:ActorGameObject = null;
         if(attackerId != 0)
         {
            _loc4_ = mDBFacade.gameObjectManager.getReferenceFromId(attackerId);
            _loc3_ = _loc4_ as ActorGameObject;
            if(_loc3_ && _loc3_.gmSkin && _loc3_.gmSkin.Id == 168)
            {
               if(vfxName == "db_fx_shockStun")
               {
                  return "db_fx_darkShockStun";
               }
            }
         }
         return vfxName;
      }
      
      public function customSkinBusterVisualOverrider(effectName:String, actorGameObject:ActorGameObject) : String
      {
         if(actorGameObject.gmSkin)
         {
            if(actorGameObject.gmSkin.Id == 168)
            {
               if(effectName == "sorcerer_db")
               {
                  return "sorcerer_dark_db";
               }
               if(effectName == "db_fx_knockback_sorcerer")
               {
                  return "db_fx_knockback_sorcerer_dark";
               }
               if(effectName == "Thunderbolt")
               {
                  return "thunderbolt_dark";
               }
               if(effectName == "ShockNova")
               {
                  return "ShockNova_dark";
               }
               if(effectName == "db_fx_charge_release")
               {
                  return "db_fx_charge_release_dark";
               }
               if(effectName == "db_fx_magicCircle")
               {
                  return "db_fx_magicCircle_dark";
               }
            }
         }
         return effectName;
      }
      
      public function customSkinProjectileVisualOverrider(effectName:String, skinId:uint) : String
      {
         if(skinId == 168)
         {
            return effectName + "_dark";
         }
         return effectName;
      }
   }
}

