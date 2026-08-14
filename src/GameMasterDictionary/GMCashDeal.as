package GameMasterDictionary
{
   public class GMCashDeal
   {
      
      public var Id:uint;
      
      public var Name:String;
      
      public var Currency:String;
      
      public var Partner:String;
      
      private var mPrice:Number;
      
      public var Value:uint;
      
      public var Bonus:uint;
      
      public var Default:uint;
      
      public var ImageURL:String;
      
      public var ProductURL:String;
      
      public var SplitTest:String;
      
      public var Description:String;
      
      public var DragonKnightBonus:Boolean;
      
      public function GMCashDeal(jsonAsset:Object, SplitTests:Object)
      {
         super();
         Id = jsonAsset.Id;
         Name = jsonAsset.Name;
         mPrice = jsonAsset.Price;
         Value = jsonAsset.Value;
         Bonus = jsonAsset.Bonus;
         ImageURL = jsonAsset.ImageURL;
         ProductURL = jsonAsset.ProductURL;
         Description = jsonAsset.Description;
         Currency = jsonAsset.Currency;
         Partner = jsonAsset.Partner;
         Default = jsonAsset.Default;
         SplitTest = jsonAsset.SplitTest;
         DragonKnightBonus = jsonAsset.DragonKnightBonus as Boolean;
      }
      
      public function get Price() : Number
      {
         return mPrice;
      }
   }
}

