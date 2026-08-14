package Facade
{
   import Actor.ActorRenderer;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.JsonAsset;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMWeaponItem;
   
   public class TrickleCacheLoader
   {
      
      public function TrickleCacheLoader()
      {
         super();
      }
      
      public static function swfAsset(name:String, dbFacade:DBFacade) : void
      {
         var trash_AssetLoadingComponent:AssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         trash_AssetLoadingComponent.getSwfAsset(name,function(param1:SwfAsset):void
         {
         });
      }
      
      public static function tilelibrary(name:String, dbFacade:DBFacade) : void
      {
         var makeCallback:Function;
         var trash_AssetLoadingComponent:AssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         if(dbFacade.getTileLibraryJson(name) == null)
         {
            makeCallback = function(param1:String):Function
            {
               var path:String = param1;
               return function(param1:JsonAsset):void
               {
                  dbFacade.AddTileLibraryJson(path,param1);
               };
            };
            loadJsonHelperFunction(trash_AssetLoadingComponent,DBFacade.buildFullDownloadPath(name),makeCallback(name));
         }
      }
      
      private static function loadJsonHelperFunction(assetLoader:AssetLoadingComponent, path:String, successCallback:Function) : void
      {
         assetLoader.getJsonAsset(path,successCallback,function():void
         {
            Logger.error("Unable to load tileLibrary from path: " + path);
         },false);
      }
      
      public static function loadNPCSpriteSheet(gmNPC:GMNpc, dbFacade:DBFacade, weaponsNames:Vector.<String>) : void
      {
         ActorRenderer.cache_loadSpriteSheetAsset(dbFacade,DBFacade.buildFullDownloadPath(gmNPC.SwfFilepath),gmNPC.SpriteHeight,gmNPC.SpriteWidth,gmNPC.AssetType,weaponsNames);
      }
      
      public static function loadHeroSpriteSheet(dbFacade:DBFacade, gmSkin:GMSkin, weaponsNames:Vector.<String> = null) : void
      {
         if(weaponsNames == null)
         {
            weaponsNames = new Vector.<String>();
         }
         var _loc4_:GMHero = dbFacade.gameMaster.heroByConstant.itemFor(gmSkin.ForHero);
         ActorRenderer.cache_loadSpriteSheetAsset(dbFacade,DBFacade.buildFullDownloadPath(gmSkin.SwfFilepath),gmSkin.SpriteHeight,gmSkin.SpriteWidth,gmSkin.AssetType,weaponsNames);
      }
      
      public static function loadHero(dbFacade:DBFacade, skinType:uint) : void
      {
         var _loc5_:GMSkin = null;
         var _loc4_:GMSkin = dbFacade.gameMaster.getSkinByType(skinType);
         var _loc3_:GMHero = dbFacade.gameMaster.getHeroByConstant(_loc4_.ForHero);
         if(_loc3_.Id == 106 && !dbFacade.gameMaster.isSkinTypeADefaultSkin(_loc4_.Id))
         {
            _loc5_ = dbFacade.gameMaster.getSkinByConstant(_loc3_.DefaultSkin);
            loadHeroSpriteSheet(dbFacade,_loc5_);
         }
         loadHeroSpriteSheet(dbFacade,_loc4_);
      }
      
      public static function swfVector(files:Vector.<String>, dbFacade:DBFacade) : void
      {
         var _loc4_:* = 0;
         var _loc3_:String = null;
         _loc4_ = 0;
         while(_loc4_ < files.length)
         {
            _loc3_ = files[_loc4_];
            swfAsset(_loc3_,dbFacade);
            _loc4_++;
         }
      }
      
      public static function npcVector(cacheNpc:Vector.<uint>, dbFacade:DBFacade) : void
      {
         var _loc5_:* = 0;
         var _loc7_:* = 0;
         var _loc3_:GMNpc = null;
         var _loc6_:* = undefined;
         var _loc4_:GMWeaponItem = null;
         _loc5_ = 0;
         while(_loc5_ < cacheNpc.length)
         {
            _loc7_ = cacheNpc[_loc5_];
            _loc3_ = dbFacade.gameMaster.npcById.itemFor(_loc7_);
            if(_loc3_ != null)
            {
               if(_loc3_.SwfFilepath == null || _loc3_.SwfFilepath == "null")
               {
                  Logger.info("NPC with Costant: " + _loc3_.Constant + " does not contain a SwfFilePath.");
               }
               else
               {
                  _loc6_ = new Vector.<String>();
                  if(_loc3_.Weapon1 && _loc3_.Weapon1.length > 0)
                  {
                     _loc4_ = dbFacade.gameMaster.weaponItemByConstant.itemFor(_loc3_.Weapon1);
                     if(_loc4_ != null)
                     {
                        if(_loc4_.WeaponAestheticList == null)
                        {
                           Logger.error("Unable to find aesthetics for npc weapon: " + _loc3_.Weapon1);
                           return;
                        }
                        _loc6_.push(_loc4_.WeaponAestheticList[0].ModelName);
                     }
                  }
                  loadNPCSpriteSheet(_loc3_,dbFacade,_loc6_);
               }
            }
            else
            {
               trace(" No Npc Found For ",_loc7_);
            }
            _loc5_++;
         }
      }
   }
}

