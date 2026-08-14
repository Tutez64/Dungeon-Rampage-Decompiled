package GameMasterDictionary
{
   import Brain.Clock.GameClock;
   
   public class GMOffer
   {
      
      public static const BASIC_CURRENCY:String = "BASIC";
      
      public static const PREMIUM_CURRENCY:String = "PREMIUM";
      
      public static const DLC_CURRENCY:String = "DLC";
      
      private static const SPECIAL_NEW:String = "NEW";
      
      private static const SPECIAL_FEATURED:String = "FEATURED";
      
      private static const SPECIAL_SALE:String = "SALE";
      
      private var mPrice:uint;
      
      public var Id:uint;
      
      public var CurrencyType:String;
      
      public var Tab:String;
      
      public var Location:String;
      
      public var CoinOfferId:uint;
      
      public var CoinOffer:GMOffer;
      
      public var IsCoinAltOffer:Boolean = false;
      
      public var VisibleDate:Date;
      
      public var StartDate:Date;
      
      public var EndDate:Date;
      
      public var SoldOutDate:Date;
      
      public var SaleTargetOfferId:uint;
      
      public var SaleTargetOffer:GMOffer;
      
      public var SaleOffers:Vector.<GMOffer>;
      
      public var SalePercentOff:uint;
      
      public var SaleStartDate:Date;
      
      public var SaleEndDate:Date;
      
      public var LimitedQuantity:uint;
      
      private var mSpecial:String;
      
      public var Gift:Boolean;
      
      public var IsBundle:Boolean;
      
      public var BundleName:String;
      
      public var BundleIcon:String;
      
      public var BundleSwfFilepath:String;
      
      public var BundleDescription:String = "";
      
      public var Rarity:String;
      
      public var OrigPriceA:uint;
      
      public var Details:Vector.<GMOfferDetail>;
      
      public var SteamAppId:uint;
      
      public function GMOffer(jsonAsset:Object, splitTests:Object)
      {
         super();
         Id = jsonAsset.Id;
         CurrencyType = jsonAsset.CurrencyType;
         this.determinePrice(jsonAsset,splitTests);
         Tab = jsonAsset.Tab;
         Location = jsonAsset.Location;
         CoinOfferId = jsonAsset.CoinOfferId;
         SaleTargetOfferId = jsonAsset.SaleOffer;
         IsBundle = jsonAsset.IsBundle;
         if(IsBundle)
         {
            BundleName = jsonAsset.BundleName;
            BundleIcon = jsonAsset.BundleIcon;
            BundleSwfFilepath = jsonAsset.BundleSwfFilepath;
            BundleDescription = jsonAsset.BundleDescription;
         }
         Rarity = jsonAsset.Rarity;
         if(jsonAsset.VisibleDate)
         {
            VisibleDate = GameClock.parseW3CDTF(jsonAsset.VisibleDate);
         }
         if(jsonAsset.StartDate)
         {
            StartDate = GameClock.parseW3CDTF(jsonAsset.StartDate);
         }
         if(jsonAsset.EndDate)
         {
            EndDate = GameClock.parseW3CDTF(jsonAsset.EndDate);
         }
         if(jsonAsset.SoldOutDate)
         {
            SoldOutDate = GameClock.parseW3CDTF(jsonAsset.SoldOutDate);
         }
         if(jsonAsset.SaleStartDate)
         {
            SaleStartDate = GameClock.parseW3CDTF(jsonAsset.SaleStartDate);
         }
         if(jsonAsset.SaleEndDate)
         {
            SaleEndDate = GameClock.parseW3CDTF(jsonAsset.SaleEndDate);
         }
         SalePercentOff = jsonAsset.SalePercentOff;
         LimitedQuantity = jsonAsset.LimitedQuantity;
         mSpecial = jsonAsset.Special;
         Gift = jsonAsset.Gift;
         Details = new Vector.<GMOfferDetail>();
         SteamAppId = jsonAsset.SteamAppId;
      }
      
      public function get percentOff() : uint
      {
         if(SaleTargetOffer && SalePercentOff)
         {
            return SalePercentOff;
         }
         return 0;
      }
      
      public function get Special() : Boolean
      {
         if(isFeatured)
         {
            return true;
         }
         if(this.isOnSaleNow && this.isSale)
         {
            return true;
         }
         return Boolean(mSpecial);
      }
      
      public function isVisible() : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc7_:Number = GameClock.getWebServerTime();
         if(VisibleDate)
         {
            _loc3_ = VisibleDate.getTime();
            if(_loc3_ > _loc7_)
            {
               return false;
            }
            if(SoldOutDate)
            {
               _loc2_ = SoldOutDate.getTime();
               if(_loc2_ < _loc7_)
               {
                  return false;
               }
            }
            else if(EndDate)
            {
               _loc5_ = EndDate.getTime();
               if(_loc5_ < _loc7_)
               {
                  return false;
               }
            }
            return true;
         }
         if(StartDate)
         {
            _loc4_ = StartDate.getTime();
            if(_loc4_ > _loc7_)
            {
               return false;
            }
            if(SoldOutDate)
            {
               _loc6_ = SoldOutDate.getTime();
               if(_loc6_ < _loc7_)
               {
                  return false;
               }
            }
            else if(EndDate)
            {
               _loc1_ = EndDate.getTime();
               if(_loc1_ < _loc7_)
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
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = GameClock.getWebServerTime();
         if(StartDate)
         {
            _loc1_ = StartDate.getTime();
            if(_loc1_ > _loc3_)
            {
               return false;
            }
         }
         if(EndDate)
         {
            _loc2_ = EndDate.getTime();
            if(_loc2_ < _loc3_)
            {
               return false;
            }
         }
         return true;
      }
      
      public function get isFeatured() : Boolean
      {
         var _loc1_:GMOffer = isOnSaleNow;
         if(_loc1_ && _loc1_.mSpecial == "FEATURED")
         {
            return true;
         }
         return mSpecial == "FEATURED";
      }
      
      public function get isNew() : Boolean
      {
         return mSpecial == "NEW";
      }
      
      public function get isSale() : Boolean
      {
         return mSpecial == "SALE" || mSpecial == "FEATURED";
      }
      
      public function get isOnSaleNow() : GMOffer
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(!this.SaleOffers)
         {
            return null;
         }
         var _loc4_:Number = GameClock.getWebServerTime();
         for each(var _loc1_:GMOffer in this.SaleOffers)
         {
            if(!(_loc1_.SaleStartDate && _loc1_.SaleEndDate))
            {
               return _loc1_;
            }
            _loc2_ = _loc1_.SaleStartDate.getTime();
            _loc3_ = _loc1_.SaleEndDate.getTime();
            if(_loc2_ < _loc4_ && _loc4_ < _loc3_)
            {
               return _loc1_;
            }
         }
         return null;
      }
      
      private function determinePrice(jsonAsset:Object, splitTests:Object) : void
      {
         var _loc3_:* = null;
         OrigPriceA = jsonAsset.Price;
         mPrice = OrigPriceA;
         for each(_loc3_ in splitTests)
         {
            if(_loc3_.name == "GemValue1" && CurrencyType == "PREMIUM")
            {
               mPrice = Math.ceil(mPrice * _loc3_.value);
            }
         }
         if(CurrencyType == "PREMIUM")
         {
            for each(_loc3_ in splitTests)
            {
               if(_loc3_.name == "InDungeonHealthBombSale" && Id == 51304)
               {
                  mPrice = Math.ceil(mPrice * Number(_loc3_.value));
               }
            }
         }
      }
      
      public function getDisplayName(gameMaster:GameMaster, defaultName:String = "", isLegendary:Boolean = false) : String
      {
         var _loc10_:GMOfferDetail = null;
         var _loc6_:GMHero = null;
         var _loc4_:GMWeaponItem = null;
         var _loc5_:GMWeaponAesthetic = null;
         var _loc7_:GMNpc = null;
         var _loc9_:GMSkin = null;
         var _loc8_:String = defaultName;
         if(this.IsBundle)
         {
            _loc8_ = this.BundleName.toUpperCase();
         }
         else
         {
            _loc10_ = this.Details[0];
            if(_loc10_.HeroId)
            {
               _loc6_ = gameMaster.heroById.itemFor(_loc10_.HeroId);
               if(_loc6_)
               {
                  _loc8_ = _loc6_.Name.toUpperCase();
               }
            }
            else if(_loc10_.WeaponId)
            {
               _loc4_ = gameMaster.weaponItemById.itemFor(_loc10_.WeaponId);
               _loc5_ = _loc4_.getWeaponAesthetic(_loc10_.Level,isLegendary);
               _loc8_ = _loc5_.Name.toUpperCase();
            }
            else if(_loc10_.PetId)
            {
               _loc7_ = gameMaster.npcById.itemFor(_loc10_.PetId);
               if(_loc7_)
               {
                  _loc8_ = _loc7_.Name.toUpperCase();
               }
            }
            else if(_loc10_.SkinId)
            {
               _loc9_ = gameMaster.getSkinByType(_loc10_.SkinId);
               if(_loc9_)
               {
                  _loc8_ = _loc9_.Name.toUpperCase();
               }
            }
         }
         return _loc8_;
      }
      
      public function getOfferItemConstant(gameMaster:GameMaster, defaultName:String = "", isLegendary:Boolean = false) : String
      {
         var _loc10_:GMOfferDetail = null;
         var _loc7_:GMHero = null;
         var _loc4_:GMWeaponItem = null;
         var _loc5_:GMWeaponAesthetic = null;
         var _loc8_:GMNpc = null;
         var _loc9_:GMSkin = null;
         var _loc6_:String = defaultName;
         if(this.IsBundle)
         {
            _loc6_ = this.BundleName.toUpperCase();
         }
         else
         {
            _loc10_ = this.Details[0];
            if(_loc10_.HeroId)
            {
               _loc7_ = gameMaster.heroById.itemFor(_loc10_.HeroId);
               if(_loc7_)
               {
                  _loc6_ = _loc7_.Constant;
               }
            }
            else if(_loc10_.WeaponId)
            {
               _loc4_ = gameMaster.weaponItemById.itemFor(_loc10_.WeaponId);
               _loc5_ = _loc4_.getWeaponAesthetic(_loc10_.Level,isLegendary);
               _loc6_ = _loc5_.Constant;
            }
            else if(_loc10_.PetId)
            {
               _loc8_ = gameMaster.npcById.itemFor(_loc10_.PetId);
               if(_loc8_)
               {
                  _loc6_ = _loc8_.Constant;
               }
            }
            else if(_loc10_.SkinId)
            {
               _loc9_ = gameMaster.getSkinByType(_loc10_.SkinId);
               if(_loc9_)
               {
                  _loc6_ = _loc9_.Constant;
               }
            }
            else if(!_loc10_.StackableId)
            {
            }
         }
         return _loc6_;
      }
      
      public function get Price() : Number
      {
         return mPrice;
      }
   }
}

