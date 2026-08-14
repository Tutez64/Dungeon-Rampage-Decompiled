package Floor
{
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import GameMasterDictionary.GMDungeonModifier;
   
   public class DungeonModifierHelper
   {
      
      public var GMDungeonMod:GMDungeonModifier;
      
      public var NewThisFloor:Boolean;
      
      public function DungeonModifierHelper(dungeonModId:uint, newThisFloor:Boolean, dbFacade:DBFacade)
      {
         super();
         GMDungeonMod = dbFacade.gameMaster.dungeonModifierById.itemFor(dungeonModId);
         if(GMDungeonMod == null)
         {
            Logger.error("Unable to find GMDungeonModifier with ID: " + dungeonModId);
         }
         NewThisFloor = newThisFloor;
      }
   }
}

