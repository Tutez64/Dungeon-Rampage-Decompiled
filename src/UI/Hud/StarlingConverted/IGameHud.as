package UI.Hud.StarlingConverted
{
   import Actor.Buffs.BuffGameObject;
   import DistributedObjects.HeroGameObjectOwner;
   import DistributedObjects.NPCGameObject;
   import UI.UIChatLog;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public interface IGameHud
   {
      
      function show() : void;
      
      function hide() : void;
      
      function destroy() : void;
      
      function detachHero() : void;
      
      function initializeHud(heroOwner:HeroGameObjectOwner) : void;
      
      function refreshHUD() : void;
      
      function get ownedHero() : HeroGameObjectOwner;
      
      function get chatLog() : UIChatLog;
      
      function useFlashChatBar(value:Boolean) : void;
      
      function get floaterTextClass() : Class;
      
      function get teamLootDestination() : Vector3D;
      
      function get profileDestination() : Vector3D;
      
      function get coinsDestination() : Vector3D;
      
      function get expDestination() : Vector3D;
      
      function get crowdDestination() : Vector3D;
      
      function offScreenPicChange(playerId:int, picType:String) : void;
      
      function initControllerIcon(inActionName:String, inOwner:MovieClip, iconPosition:Vector3D, iconScale:Point) : void;
      
      function removeControllerIcons(inOwner:MovieClip) : void;
      
      function showHealthFullMessage() : void;
      
      function showManaFullMessage() : void;
      
      function registerPet(petNPC:NPCGameObject) : void;
      
      function unregisterPet(petNPC:NPCGameObject) : void;
      
      function openTeamLoot(chestId:uint) : void;
      
      function hideStacks() : void;
      
      function setBasicCurrency(basicCurrency:int) : void;
      
      function bulgeXpBar() : void;
      
      function bulgeProfileBox() : void;
      
      function hideBustSign() : void;
      
      function setWeaponHighlight(currentWeaponIndex:int) : void;
      
      function hideNotEnoughMana() : void;
      
      function showNotEnoughMana() : void;
      
      function isInCooldown() : void;
      
      function startCooldown(currentWeaponIndex:int, cooldownTime:Number) : void;
      
      function stopCooldown(currentWeaponIndex:int) : void;
      
      function startConsumableCooldown(currentWeaponIndex:int, cooldownTime:Number) : void;
      
      function stopConsumableCooldown(currentWeaponIndex:int) : void;
      
      function decrementConsumableCount(slot:uint) : void;
      
      function totalConsumableCountReached(slot:uint) : void;
      
      function showText(localeTextName:String) : void;
      
      function showBuffDisplay(buffGO:BuffGameObject) : void;
      
      function updateBuffInstance(updatedBuffGO:BuffGameObject) : void;
      
      function handleMenuButtonPressed(index:uint) : void;
      
      function clearExitMenu() : void;
      
      function suppressNextExitMenuToggle() : void;
   }
}

