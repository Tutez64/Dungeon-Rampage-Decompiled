package GameMasterDictionary
{
   import Brain.Clock.GameClock;
   import DBGlobals.As3Compat;
   import DBGlobals.DBGlobal;
   import flash.Boot;
   
   public class GMOffer
   {
      
      public static var BASIC_CURRENCY:String = "BASIC";
      
      public static var PREMIUM_CURRENCY:String = "PREMIUM";
      
      public static var DLC_CURRENCY:String = "DLC";
      
      public static var SPECIAL_NEW:String = "NEW";
      
      public static var SPECIAL_FEATURED:String = "FEATURED";
      
      public static var SPECIAL_SALE:String = "SALE";
      
      public var mSpecial:String;
      
      public var mPrice:uint;
      
      public var VisibleDate:Date;
      
      public var Tab:String;
      
      public var SteamAppId:uint;
      
      public var StartDate:Date;
      
      public var SoldOutDate:Date;
      
      public var SaleTargetOfferId:uint;
      
      public var SaleTargetOffer:GMOffer;
      
      public var SaleStartDate:Date;
      
      public var SalePercentOff:uint;
      
      public var SaleOffers:Vector.<GMOffer>;
      
      public var SaleEndDate:Date;
      
      public var Rarity:String;
      
      public var OrigPriceA:uint;
      
      public var Location:String;
      
      public var LimitedQuantity:uint;
      
      public var IsCoinAltOffer:Boolean;
      
      public var IsBundle:Boolean;
      
      public var Id:uint;
      
      public var Gift:Boolean;
      
      public var EndDate:Date;
      
      public var Details:Vector.<GMOfferDetail>;
      
      public var CurrencyType:String;
      
      public var CoinOfferId:uint;
      
      public var CoinOffer:GMOffer;
      
      public var BundleSwfFilepath:String;
      
      public var BundleName:String;
      
      public var BundleIcon:String;
      
      public var BundleDescription:String;
      
      public function GMOffer(jsonAsset:Object = undefined, splitTests:* = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         BundleDescription = "";
         IsCoinAltOffer = false;
         Id = uint(jsonAsset.Id);
         CurrencyType = jsonAsset.CurrencyType;
         determinePrice(jsonAsset,splitTests);
         Tab = jsonAsset.Tab;
         Location = jsonAsset.Location;
         CoinOfferId = uint(jsonAsset.CoinOfferId);
         SaleTargetOfferId = uint(jsonAsset.SaleOffer);
         IsBundle = Boolean(jsonAsset.IsBundle);
         if(IsBundle)
         {
            BundleName = jsonAsset.BundleName;
            BundleIcon = jsonAsset.BundleIcon;
            BundleSwfFilepath = jsonAsset.BundleSwfFilepath;
            BundleDescription = jsonAsset.BundleDescription;
         }
         Rarity = jsonAsset.Rarity;
         if(As3Compat.truthy(jsonAsset.VisibleDate))
         {
            VisibleDate = GameClock.parseW3CDTF(jsonAsset.VisibleDate);
         }
         if(As3Compat.truthy(jsonAsset.StartDate))
         {
            StartDate = GameClock.parseW3CDTF(jsonAsset.StartDate);
         }
         if(As3Compat.truthy(jsonAsset.EndDate))
         {
            EndDate = GameClock.parseW3CDTF(jsonAsset.EndDate);
         }
         if(As3Compat.truthy(jsonAsset.SoldOutDate))
         {
            SoldOutDate = GameClock.parseW3CDTF(jsonAsset.SoldOutDate);
         }
         if(As3Compat.truthy(jsonAsset.SaleStartDate))
         {
            SaleStartDate = GameClock.parseW3CDTF(jsonAsset.SaleStartDate);
         }
         if(As3Compat.truthy(jsonAsset.SaleEndDate))
         {
            SaleEndDate = GameClock.parseW3CDTF(jsonAsset.SaleEndDate);
         }
         SalePercentOff = uint(jsonAsset.SalePercentOff);
         LimitedQuantity = uint(jsonAsset.LimitedQuantity);
         mSpecial = jsonAsset.Special;
         Gift = Boolean(jsonAsset.Gift);
         Details = new Vector.<GMOfferDetail>();
         SteamAppId = uint(jsonAsset.SteamAppId);
      }
      
      public function isVisible() : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc1_:Number = GameClock.getWebServerTime();
         if(VisibleDate != null)
         {
            _loc2_ = VisibleDate.getTime();
            if(_loc2_ > _loc1_)
            {
               return false;
            }
            if(SoldOutDate != null)
            {
               _loc3_ = SoldOutDate.getTime();
               if(_loc3_ < _loc1_)
               {
                  return false;
               }
            }
            else if(EndDate != null)
            {
               _loc3_ = EndDate.getTime();
               if(_loc3_ < _loc1_)
               {
                  return false;
               }
            }
            return true;
         }
         if(StartDate != null)
         {
            _loc2_ = StartDate.getTime();
            if(_loc2_ > _loc1_)
            {
               return false;
            }
            if(SoldOutDate != null)
            {
               _loc3_ = SoldOutDate.getTime();
               if(_loc3_ < _loc1_)
               {
                  return false;
               }
            }
            else if(EndDate != null)
            {
               _loc3_ = EndDate.getTime();
               if(_loc3_ < _loc1_)
               {
                  return false;
               }
            }
            return true;
         }
         return true;
      }
      
      public function isAvailableTime() : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc1_:Number = GameClock.getWebServerTime();
         if(StartDate != null)
         {
            _loc2_ = StartDate.getTime();
            if(_loc2_ > _loc1_)
            {
               return false;
            }
         }
         if(EndDate != null)
         {
            _loc2_ = EndDate.getTime();
            if(_loc2_ < _loc1_)
            {
               return false;
            }
         }
         return true;
      }
      
      public function get_percentOff() : uint
      {
         if(SaleTargetOffer != null && SalePercentOff != 0)
         {
            return SalePercentOff;
         }
         return 0;
      }
      
      public function get percentOff() : uint
      {
         return get_percentOff();
      }
      
      public function get_isSale() : Boolean
      {
         if(mSpecial != GMOffer.SPECIAL_SALE)
         {
            return mSpecial == GMOffer.SPECIAL_FEATURED;
         }
         return true;
      }
      
      public function get isSale() : Boolean
      {
         return get_isSale();
      }
      
      public function get_isOnSaleNow() : GMOffer
      {
         var _loc4_:int = 0;
         var _loc5_:* = null as GMOffer;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(SaleOffers == null)
         {
            return null;
         }
         var _loc1_:Number = GameClock.getWebServerTime();
         var _loc2_:int = 0;
         var _loc3_:int = int(SaleOffers.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc2_++;
            _loc5_ = SaleOffers[_loc4_];
            if(!(_loc5_.SaleStartDate != null && _loc5_.SaleEndDate != null))
            {
               return _loc5_;
            }
            _loc6_ = _loc5_.SaleStartDate.getTime();
            _loc7_ = _loc5_.SaleEndDate.getTime();
            if(_loc6_ < _loc1_ && _loc1_ < _loc7_)
            {
               return _loc5_;
            }
         }
         return null;
      }
      
      public function get isOnSaleNow() : GMOffer
      {
         return get_isOnSaleNow();
      }
      
      public function get_isNew() : Boolean
      {
         return mSpecial == GMOffer.SPECIAL_NEW;
      }
      
      public function get isNew() : Boolean
      {
         return get_isNew();
      }
      
      public function get_isFeatured() : Boolean
      {
         var _loc1_:GMOffer = get_isOnSaleNow();
         if(_loc1_ != null && _loc1_.mSpecial == GMOffer.SPECIAL_FEATURED)
         {
            return true;
         }
         return mSpecial == GMOffer.SPECIAL_FEATURED;
      }
      
      public function get isFeatured() : Boolean
      {
         return get_isFeatured();
      }
      
      public function get_Special() : Boolean
      {
         var _loc1_:* = null as String;
         if(get_isFeatured())
         {
            return true;
         }
         if(get_isOnSaleNow() != null && get_isSale())
         {
            return true;
         }
         _loc1_ = mSpecial;
         if(_loc1_ != null)
         {
            return _loc1_.length > 0;
         }
         return false;
      }
      
      public function get Special() : Boolean
      {
         return get_Special();
      }
      
      public function get_Price() : Number
      {
         return mPrice;
      }
      
      public function get Price() : Number
      {
         return get_Price();
      }
      
      public function getOfferItemConstant(gameMaster:GameMaster, defaultName:String = undefined, isLegendary:Boolean = false) : String
      {
         var _loc5_:* = null as GMOfferDetail;
         var _loc6_:* = null as GMHero;
         var _loc7_:* = null as GMWeaponItem;
         var _loc8_:* = null as GMWeaponAesthetic;
         var _loc9_:* = null as GMNpc;
         var _loc10_:* = null as GMSkin;
         var _loc11_:Boolean = false;
         if(defaultName == null)
         {
            defaultName = "";
         }
         var _loc4_:String = defaultName;
         if(IsBundle)
         {
            _loc4_ = BundleName.toUpperCase();
         }
         else
         {
            _loc5_ = Details[0];
            if(_loc5_.HeroId != 0)
            {
               _loc6_ = gameMaster.heroById.itemFor(_loc5_.HeroId);
               if(_loc6_ != null)
               {
                  _loc4_ = _loc6_.Constant;
               }
            }
            else if(_loc5_.WeaponId != 0)
            {
               _loc7_ = gameMaster.weaponItemById.itemFor(_loc5_.WeaponId);
               _loc8_ = _loc7_.getWeaponAesthetic(_loc5_.Level,isLegendary);
               _loc4_ = _loc8_.Constant;
            }
            else if(_loc5_.PetId != 0)
            {
               _loc9_ = gameMaster.npcById.itemFor(_loc5_.PetId);
               if(_loc9_ != null)
               {
                  _loc4_ = _loc9_.Constant;
               }
            }
            else if(_loc5_.SkinId != 0)
            {
               _loc10_ = gameMaster.getSkinByType(_loc5_.SkinId);
               if(_loc10_ != null)
               {
                  _loc4_ = _loc10_.Constant;
               }
            }
            else
            {
               _loc11_ = _loc5_.StackableId != 0;
            }
         }
         return _loc4_;
      }
      
      public function getDisplayName(gameMaster:GameMaster, defaultName:String = undefined, isLegendary:Boolean = false) : String
      {
         var _loc5_:* = null as GMOfferDetail;
         var _loc6_:* = null as GMHero;
         var _loc7_:* = null as GMWeaponItem;
         var _loc8_:* = null as GMWeaponAesthetic;
         var _loc9_:* = null as GMNpc;
         var _loc10_:* = null as GMSkin;
         if(defaultName == null)
         {
            defaultName = "";
         }
         var _loc4_:String = defaultName;
         if(IsBundle)
         {
            _loc4_ = BundleName.toUpperCase();
         }
         else
         {
            _loc5_ = Details[0];
            if(_loc5_.HeroId != 0)
            {
               _loc6_ = gameMaster.heroById.itemFor(_loc5_.HeroId);
               if(_loc6_ != null)
               {
                  _loc4_ = _loc6_.get_Name().toUpperCase();
               }
            }
            else if(_loc5_.WeaponId != 0)
            {
               _loc7_ = gameMaster.weaponItemById.itemFor(_loc5_.WeaponId);
               _loc8_ = _loc7_.getWeaponAesthetic(_loc5_.Level,isLegendary);
               _loc4_ = _loc8_.Name.toUpperCase();
            }
            else if(_loc5_.PetId != 0)
            {
               _loc9_ = gameMaster.npcById.itemFor(_loc5_.PetId);
               if(_loc9_ != null)
               {
                  _loc4_ = _loc9_.get_Name().toUpperCase();
               }
            }
            else if(_loc5_.SkinId != 0)
            {
               _loc10_ = gameMaster.getSkinByType(_loc5_.SkinId);
               if(_loc10_ != null)
               {
                  _loc4_ = _loc10_.get_Name().toUpperCase();
               }
            }
         }
         return _loc4_;
      }
      
      public function determinePrice(jsonAsset:Object, splitTests:*) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null as Array;
         var _loc5_:* = null;
         OrigPriceA = uint(jsonAsset.Price);
         mPrice = OrigPriceA;
         _loc3_ = 0;
         _loc4_ = As3Compat.values(splitTests);
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            if(_loc5_.name == "GemValue1" && CurrencyType == GMOffer.PREMIUM_CURRENCY)
            {
               mPrice = int(int(Math.ceil(mPrice * As3Compat.toFloat(_loc5_.value))));
            }
         }
         if(CurrencyType == GMOffer.PREMIUM_CURRENCY)
         {
            _loc3_ = 0;
            _loc4_ = As3Compat.values(splitTests);
            while(_loc3_ < int(_loc4_.length))
            {
               _loc5_ = _loc4_[_loc3_];
               _loc3_++;
               if(_loc5_.name == "InDungeonHealthBombSale" && Id == DBGlobal.RESSURECTION_POTION_OFFER_ID)
               {
                  mPrice = int(int(Math.ceil(mPrice * As3Compat.toFloat(_loc5_.value))));
               }
            }
         }
      }
   }
}

