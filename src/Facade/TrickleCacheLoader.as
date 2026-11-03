package Facade
{
   import Account.AvatarInfo;
   import Account.Consumable;
   import Account.DBAccountInfo;
   import Account.ItemInfo;
   import Account.PetInfo;
   import Actor.ActorData;
   import Actor.ActorRenderer;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.JsonAsset;
   import Brain.AssetRepository.StarlingAssetMapper;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Combat.Weapon.WeaponRenderer;
   import DBGlobals.DBGlobal;
   import GameMasterDictionary.GMActor;
   import GameMasterDictionary.GMAttack;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMProjectile;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMStackable;
   import GameMasterDictionary.GMWeaponAesthetic;
   import GameMasterDictionary.GMWeaponItem;
   import GameMasterDictionary.GameMaster;
   import GeneratedCode.HeroPreloadLook;
   import GeneratedCode.WeaponDetails;
   import flash.filesystem.File;
   
   public class TrickleCacheLoader
   {
      
      private static const STARLING_LIBRARY_SWFS:Vector.<String> = new <String>["Resources/Art2D/Doobers/db_items_doobers.swf","Resources/Art2D/projectiles/db_projectiles_library.swf"];
      
      private static const STARLING_COMMON_SWFS:Vector.<String> = new <String>["Resources/Art2D/Environments/shared/props/db_prop_shared_library.swf","Resources/Art2D/Doobers/db_items_doobers.swf","Resources/Art2D/projectiles/db_projectiles_library.swf","Resources/Art2D/FX/db_fx_library.swf"];
      
      public function TrickleCacheLoader()
      {
         super();
      }
      
      public static function queueHeroKitStarlingAtlases(dbFacade:DBFacade) : void
      {
         if(dbFacade.assetLoadingComponent == null)
         {
            return;
         }
         for each(var _loc2_:String in starlingAtlasPaths(dbFacade,null))
         {
            dbFacade.assetLoadingComponent.queueStarlingAssetsForPath(_loc2_);
         }
      }
      
      public static function queueHeroLookAtlases(dbFacade:DBFacade, look:HeroPreloadLook, isBackground:Boolean) : void
      {
         var _loc8_:GMHero = null;
         var _loc13_:GMWeaponItem = null;
         var _loc20_:Boolean = false;
         var _loc4_:GMWeaponAesthetic = null;
         var _loc6_:GMStackable = null;
         var _loc23_:GMNpc = null;
         var _loc19_:AssetLoadingComponent = dbFacade.assetLoadingComponent;
         if(_loc19_ == null || look == null)
         {
            return;
         }
         var _loc17_:GameMaster = dbFacade.gameMaster;
         var _loc11_:GMSkin = _loc17_.getSkinByType(look.skinType);
         if(_loc11_ == null)
         {
            _loc8_ = _loc17_.heroById.itemFor(look.heroType);
            _loc11_ = _loc8_ != null ? _loc17_.getSkinByConstant(_loc8_.DefaultSkin) : null;
         }
         var _loc21_:Vector.<GMWeaponItem> = new Vector.<GMWeaponItem>();
         var _loc16_:Vector.<String> = new Vector.<String>();
         for each(var _loc14_:WeaponDetails in look.weapons)
         {
            _loc13_ = _loc14_.type != 0 ? _loc17_.weaponItemById.itemFor(_loc14_.type) : null;
            if(_loc13_ != null)
            {
               _loc20_ = _loc14_.legendarymodifier > 0 && _loc17_.legendaryModifiersById.itemFor(_loc14_.legendarymodifier) != null;
               _loc4_ = _loc13_.getWeaponAesthetic(_loc14_.requiredlevel,_loc20_);
               if(_loc4_ != null)
               {
                  _loc21_.push(_loc13_);
                  _loc16_.push(_loc4_.ModelName);
               }
            }
         }
         var _loc9_:Vector.<GMStackable> = new Vector.<GMStackable>();
         for each(var _loc10_:uint in look.consumableTypes)
         {
            _loc6_ = _loc10_ != 0 ? _loc17_.stackableById.itemFor(_loc10_) : null;
            if(_loc6_ != null)
            {
               _loc9_.push(_loc6_);
            }
         }
         var _loc5_:Vector.<GMNpc> = new Vector.<GMNpc>();
         for each(var _loc22_:uint in look.petTypes)
         {
            _loc23_ = _loc17_.npcById.itemFor(_loc22_);
            if(_loc23_ != null)
            {
               _loc5_.push(_loc23_);
            }
         }
         var _loc12_:Function = dbFacade.timelineFactory != null ? dbFacade.timelineFactory.getTimelineJson : null;
         var _loc18_:Vector.<String> = collectStarlingAtlasPaths(_loc17_,_loc12_,_loc11_,_loc21_,_loc16_,_loc9_,_loc5_,null);
         var _loc7_:Object = isBackground ? heroLookAtlasTiers(_loc17_,_loc12_,_loc11_,_loc21_,_loc16_,_loc9_,_loc5_) : {};
         for each(var _loc15_:String in _loc18_)
         {
            _loc19_.queueStarlingAssetsForPath(_loc15_,null,false,isBackground,_loc7_.hasOwnProperty(_loc15_) ? int(_loc7_[_loc15_]) : 2);
         }
      }
      
      public static function heroLookAtlasTiers(gameMaster:GameMaster, timelineJson:Function, gmSkin:GMSkin, weapons:Vector.<GMWeaponItem>, weaponModels:Vector.<String>, consumables:Vector.<GMStackable>, pets:Vector.<GMNpc>) : Object
      {
         var _loc8_:String = null;
         var _loc12_:String = null;
         var _loc10_:Object = {};
         var _loc11_:Vector.<String> = collectStarlingAtlasPaths(gameMaster,timelineJson,gmSkin,weapons,weaponModels,consumables,new Vector.<GMNpc>(),null);
         for each(_loc8_ in collectStarlingAtlasPaths(gameMaster,timelineJson,null,new Vector.<GMWeaponItem>(),new Vector.<String>(),new Vector.<GMStackable>(),pets,null))
         {
            if(_loc11_.indexOf(_loc8_) == -1)
            {
               _loc10_[_loc8_] = 4;
            }
         }
         if(gmSkin != null && gmSkin.SwfFilepath && gmSkin.SwfFilepath != "null")
         {
            _loc12_ = DBFacade.buildFullDownloadPath(gmSkin.SwfFilepath);
            _loc10_[_loc12_] = 0;
            for each(var _loc9_:String in weaponModels)
            {
               _loc10_[WeaponRenderer.weaponSwfFilePath(_loc12_,_loc9_)] = 1;
            }
         }
         return _loc10_;
      }
      
      public static function queueCommonStarlingAtlases(dbFacade:DBFacade) : void
      {
         if(dbFacade.assetLoadingComponent == null)
         {
            return;
         }
         for each(var _loc2_:String in STARLING_COMMON_SWFS)
         {
            dbFacade.assetLoadingComponent.queueResidentStarlingAssetsForPath(DBFacade.buildFullDownloadPath(_loc2_));
         }
      }
      
      public static function starlingAtlasPaths(dbFacade:DBFacade, cacheNpc:Vector.<uint>) : Vector.<String>
      {
         var _loc8_:GMWeaponAesthetic = null;
         var _loc4_:GMStackable = null;
         var _loc12_:GameMaster = dbFacade.gameMaster;
         var _loc3_:DBAccountInfo = dbFacade.dbAccountInfo;
         var _loc10_:AvatarInfo = _loc3_.activeAvatarInfo;
         var _loc15_:Vector.<GMWeaponItem> = new Vector.<GMWeaponItem>();
         var _loc11_:Vector.<String> = new Vector.<String>();
         for each(var _loc5_:ItemInfo in _loc3_.inventoryInfo.getEquipedItemsOnAvatar(_loc10_.id))
         {
            _loc8_ = _loc5_.gmWeaponItem ? _loc5_.gmWeaponAesthetic : null;
            if(_loc8_ != null)
            {
               _loc15_.push(_loc5_.gmWeaponItem);
               _loc11_.push(_loc8_.ModelName);
            }
         }
         var _loc6_:Vector.<GMStackable> = new Vector.<GMStackable>();
         for each(var _loc13_:Consumable in _loc10_.equippedConsumables)
         {
            _loc4_ = _loc13_.stackId != 0 ? _loc12_.stackableById.itemFor(_loc13_.stackId) : null;
            if(_loc4_ != null)
            {
               _loc6_.push(_loc4_);
            }
         }
         var _loc14_:Vector.<GMNpc> = new Vector.<GMNpc>();
         for each(var _loc16_:PetInfo in _loc3_.inventoryInfo.getEquipedPetsOnAvatar(_loc10_.id))
         {
            _loc14_.push(_loc16_.gmNpc);
         }
         var _loc7_:GMSkin = _loc12_.getSkinByType(_loc10_.skinId);
         var _loc9_:Function = dbFacade.timelineFactory != null ? dbFacade.timelineFactory.getTimelineJson : null;
         return collectStarlingAtlasPaths(_loc12_,_loc9_,_loc7_,_loc15_,_loc11_,_loc6_,heroKitPets(_loc12_,_loc7_,_loc14_),cacheNpc);
      }
      
      public static function heroKitPets(gameMaster:GameMaster, gmSkin:GMSkin, equippedPets:Vector.<GMNpc>) : Vector.<GMNpc>
      {
         var _loc4_:Vector.<GMNpc> = new Vector.<GMNpc>();
         var _loc5_:GMHero = gmSkin != null ? gameMaster.getHeroByConstant(gmSkin.ForHero) : null;
         var _loc6_:GMNpc = _loc5_ != null && _loc5_.Pet ? gameMaster.npcByConstant.itemFor(_loc5_.Pet) : null;
         if(_loc6_ != null)
         {
            _loc4_.push(_loc6_);
         }
         for each(var _loc7_:GMNpc in equippedPets)
         {
            _loc4_.push(_loc7_);
         }
         return _loc4_;
      }
      
      public static function collectStarlingAtlasPaths(gameMaster:GameMaster, timelineJson:Function, gmSkin:GMSkin, weapons:Vector.<GMWeaponItem>, weaponModels:Vector.<String>, consumables:Vector.<GMStackable>, pets:Vector.<GMNpc>, cacheNpc:Vector.<uint>) : Vector.<String>
      {
         var gmHero:GMHero;
         var defaultSkin:GMSkin;
         var weapon:GMWeaponItem;
         var stackable:GMStackable;
         var pet:GMNpc;
         var npcId:uint;
         var librarySwf:String;
         var paths:Vector.<String> = new Vector.<String>();
         var add:Function = function(param1:String):void
         {
            if(param1 && paths.indexOf(param1) == -1 && StarlingAssetMapper.getActorAtlasFile(param1) != null)
            {
               paths.push(param1);
            }
         };
         var addActor:Function = function(param1:String, param2:Vector.<String>):void
         {
            if(!param1 || param1 == "null")
            {
               return;
            }
            var _loc3_:String = DBFacade.buildFullDownloadPath(param1);
            add(_loc3_);
            for each(var _loc4_:String in param2)
            {
               add(WeaponRenderer.weaponSwfFilePath(_loc3_,_loc4_));
            }
         };
         var addAttack:Function = function(param1:GMAttack):void
         {
            var _loc4_:GMProjectile = null;
            if(param1 == null)
            {
               return;
            }
            if(param1.Projectile)
            {
               _loc4_ = gameMaster.projectileByConstant.itemFor(param1.Projectile);
               if(_loc4_ != null && _loc4_.SwfFilepath)
               {
                  add(DBFacade.buildFullDownloadPath(_loc4_.SwfFilepath));
               }
            }
            var _loc2_:Object = timelineJson != null ? timelineJson(param1.AttackTimeline) : null;
            if(_loc2_ == null || _loc2_.frames == null)
            {
               return;
            }
            for each(var _loc5_:Object in _loc2_.frames)
            {
               for each(var _loc3_:Object in _loc5_.actions)
               {
                  if(_loc3_ != null)
                  {
                     if(_loc3_.attackEffectPath && _loc3_.attackEffectName)
                     {
                        add(DBFacade.buildFullDownloadPath(_loc3_.attackEffectPath));
                     }
                     if((_loc3_.type == "effect" || _loc3_.type == "attackEffect") && _loc3_.path && _loc3_.name)
                     {
                        add(DBFacade.buildFullDownloadPath(_loc3_.path));
                     }
                  }
               }
            }
         };
         var addWeaponAttacks:Function = function(param1:GMWeaponItem):void
         {
            if(param1 == null)
            {
               return;
            }
            for each(var _loc3_:String in param1.AttackArray)
            {
               if(_loc3_ == null)
               {
                  break;
               }
               addAttack(gameMaster.attackByConstant.itemFor(_loc3_));
            }
            for each(var _loc2_:String in [param1.HoldingAttack,param1.ChargeAttack])
            {
               if(_loc2_)
               {
                  addAttack(gameMaster.attackByConstant.itemFor(_loc2_));
               }
            }
         };
         var addNpc:Function = function(param1:GMNpc):void
         {
            var _loc2_:GMWeaponItem = null;
            if(param1 == null)
            {
               return;
            }
            var _loc4_:Vector.<String> = new Vector.<String>();
            for each(var _loc3_:String in [param1.Weapon1,param1.Weapon2,param1.Weapon3,param1.Weapon4,param1.Weapon5])
            {
               _loc2_ = _loc3_ ? gameMaster.weaponItemByConstant.itemFor(_loc3_) : null;
               if(_loc2_ != null && _loc2_.WeaponAestheticList != null && _loc2_.WeaponAestheticList.length > 0)
               {
                  _loc4_.push(_loc2_.WeaponAestheticList[0].ModelName);
               }
            }
            addActor(param1.SwfFilepath,_loc4_);
            for each(_loc3_ in [param1.Weapon1,param1.Weapon2,param1.Weapon3,param1.Weapon4,param1.Weapon5])
            {
               addWeaponAttacks(_loc3_ ? gameMaster.weaponItemByConstant.itemFor(_loc3_) : null);
            }
         };
         if(gmSkin != null)
         {
            addActor(gmSkin.SwfFilepath,weaponModels);
            gmHero = gameMaster.getHeroByConstant(gmSkin.ForHero);
            if(gmHero != null && gmHero.Id == DBGlobal.GHOST_SAMURAI_TYPE_ID && !gameMaster.isSkinTypeADefaultSkin(gmSkin.Id))
            {
               defaultSkin = gameMaster.getSkinByConstant(gmHero.DefaultSkin);
               if(defaultSkin != null)
               {
                  addActor(defaultSkin.SwfFilepath,new Vector.<String>());
               }
            }
         }
         for each(weapon in weapons)
         {
            addWeaponAttacks(weapon);
         }
         for each(stackable in consumables)
         {
            if(stackable != null && stackable.UsageAttack)
            {
               addAttack(gameMaster.attackByConstant.itemFor(stackable.UsageAttack));
            }
         }
         for each(pet in pets)
         {
            addNpc(pet);
         }
         for each(npcId in cacheNpc)
         {
            addNpc(gameMaster.npcById.itemFor(npcId));
         }
         for each(librarySwf in STARLING_LIBRARY_SWFS)
         {
            add(DBFacade.buildFullDownloadPath(librarySwf));
         }
         return paths;
      }
      
      public static function starlingPropAtlasClassNames(dbFacade:DBFacade, cacheNpc:Vector.<uint>, floorBiomeKey:String) : Object
      {
         var _loc4_:GMNpc = null;
         var _loc6_:String = null;
         var _loc11_:String = null;
         var _loc7_:Array = null;
         var _loc5_:Array = null;
         var _loc10_:Object = {};
         if(floorBiomeKey == null)
         {
            return _loc10_;
         }
         for each(var _loc9_:uint in cacheNpc)
         {
            _loc4_ = dbFacade.gameMaster.npcById.itemFor(_loc9_);
            if(!(_loc4_ == null || !_loc4_.SwfFilepath || _loc4_.SwfFilepath == "null"))
            {
               _loc6_ = DBFacade.buildFullDownloadPath(_loc4_.SwfFilepath);
               if(StarlingAssetMapper.isPropLibraryPath(_loc6_))
               {
                  _loc11_ = StarlingAssetMapper.getBiomeKeyFromPath(_loc6_);
                  if(!(_loc11_ != floorBiomeKey && _loc11_ != "shared"))
                  {
                     _loc7_ = _loc10_[_loc6_];
                     if(_loc7_ == null)
                     {
                        _loc7_ = [];
                        _loc10_[_loc6_] = _loc7_;
                     }
                     _loc5_ = _loc4_.CharType == GMActor.CHAR_TYPE_PROP ? ActorRenderer.propAtlasClassNames(_loc4_,true).concat(ActorRenderer.propAtlasClassNames(_loc4_,false)) : ActorRenderer.npcAtlasClassNames(_loc4_.AssetClassName).concat([ActorData.offMovieClipClassName(_loc4_.AssetClassName)]);
                     for each(var _loc8_:String in _loc5_)
                     {
                        if(_loc8_ && _loc7_.indexOf(_loc8_) == -1)
                        {
                           _loc7_.push(_loc8_);
                        }
                     }
                  }
               }
            }
         }
         return _loc10_;
      }
      
      public static function swfAsset(name:String, dbFacade:DBFacade) : void
      {
         var trash_AssetLoadingComponent:AssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         trash_AssetLoadingComponent.getSwfAsset(name,function(param1:SwfAsset):void
         {
         });
      }
      
      public static function tileLibrary(name:String, dbFacade:DBFacade) : void
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
      
      public static function swfVector(files:Vector.<String>, dbFacade:DBFacade) : void
      {
         var _loc4_:uint = 0;
         var _loc3_:String = null;
         _loc4_ = 0;
         while(_loc4_ < files.length)
         {
            _loc3_ = files[_loc4_];
            if(!StarlingAssetMapper.isArt3DPath(_loc3_))
            {
               swfAsset(_loc3_,dbFacade);
            }
            _loc4_++;
         }
      }
      
      public static function queueBossAtlases(dbFacade:DBFacade, cacheNpc:Vector.<uint>) : void
      {
         var _loc3_:GMNpc = null;
         var _loc4_:String = null;
         var _loc5_:File = null;
         if(dbFacade.assetLoadingComponent == null)
         {
            return;
         }
         for each(var _loc6_:uint in cacheNpc)
         {
            _loc3_ = dbFacade.gameMaster.npcById.itemFor(_loc6_);
            if(!(_loc3_ == null || !_loc3_.IsBoss || !_loc3_.SwfFilepath || _loc3_.SwfFilepath == "null"))
            {
               _loc4_ = DBFacade.buildFullDownloadPath(_loc3_.SwfFilepath);
               _loc5_ = StarlingAssetMapper.getActorAtlasFile(_loc4_,true);
               if(_loc5_ != null)
               {
                  dbFacade.assetLoadingComponent.queueStarlingAssets(StarlingAssetMapper.getActorAtlasKeyFromPath(_loc4_),null,false,[_loc5_]);
                  dbFacade.assetLoadingComponent.markStarlingKeyUsed(_loc3_.AssetClassName + "_idle");
               }
            }
         }
      }
   }
}

