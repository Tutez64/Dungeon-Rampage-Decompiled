package Brain.Starling
{
   import flash.geom.Matrix;
   import starling.display.MeshBatch;
   
   internal class StarlingBakedRun
   {
      
      public const batch:MeshBatch = new MeshBatch();
      
      public const members:Vector.<StarlingScenerySprite> = new Vector.<StarlingScenerySprite>(0);
      
      public const leadInverse:Matrix = new Matrix();
      
      public var lead:StarlingScenerySprite;
      
      public var shownCount:int = 0;
      
      public var left:Number = 0;
      
      public var top:Number = 0;
      
      public var right:Number = 0;
      
      public var bottom:Number = 0;
      
      public var first:int = -1;
      
      public var last:int = -1;
      
      public var seen:int = 0;
      
      public var violated:Boolean = false;
      
      public function StarlingBakedRun()
      {
         super();
         batch.touchable = false;
      }
      
      public function clear() : void
      {
         batch.clear();
         batch.texture = null;
         members.length = 0;
         lead = null;
         shownCount = 0;
         violated = false;
      }
      
      public function dispose() : void
      {
         batch.dispose();
         members.length = 0;
         lead = null;
      }
   }
}

