package starling.text
{
   public class BitmapCharLocation
   {
      
      private static var sInstancePool:Vector.<BitmapCharLocation> = new Vector.<BitmapCharLocation>(0);
      
      private static var sVectorPool:Array = [];
      
      private static var sInstanceLoan:Vector.<BitmapCharLocation> = new Vector.<BitmapCharLocation>(0);
      
      private static var sVectorLoan:Array = [];
      
      public var char:BitmapChar;
      
      public var scale:Number;
      
      public var x:Number;
      
      public var y:Number;
      
      public var index:int;
      
      public function BitmapCharLocation(char:BitmapChar)
      {
         super();
         init(char);
      }
      
      public static function instanceFromPool(char:BitmapChar) : BitmapCharLocation
      {
         var _loc2_:BitmapCharLocation = sInstancePool.length > 0 ? sInstancePool.pop() : new BitmapCharLocation(char);
         _loc2_.init(char);
         sInstanceLoan[sInstanceLoan.length] = _loc2_;
         return _loc2_;
      }
      
      public static function vectorFromPool() : Vector.<BitmapCharLocation>
      {
         var _loc1_:Vector.<BitmapCharLocation> = sVectorPool.length > 0 ? sVectorPool.pop() : new Vector.<BitmapCharLocation>(0);
         _loc1_.length = 0;
         sVectorLoan[sVectorLoan.length] = _loc1_;
         return _loc1_;
      }
      
      public static function rechargePool() : void
      {
         var _loc1_:BitmapCharLocation = null;
         var _loc2_:Vector.<BitmapCharLocation> = undefined;
         while(sInstanceLoan.length > 0)
         {
            _loc1_ = sInstanceLoan.pop();
            _loc1_.char = null;
            sInstancePool[sInstancePool.length] = _loc1_;
         }
         while(sVectorLoan.length > 0)
         {
            _loc2_ = sVectorLoan.pop();
            _loc2_.length = 0;
            sVectorPool[sVectorPool.length] = _loc2_;
         }
      }
      
      private function init(char:BitmapChar) : BitmapCharLocation
      {
         this.char = char;
         return this;
      }
   }
}

