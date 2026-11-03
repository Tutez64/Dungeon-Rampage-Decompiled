package Actor.StarlingConvertedOverlay
{
   import Brain.Starling.SwfConverter.BakedCell;
   import flash.display.DisplayObject;
   
   internal class TagPart
   {
      
      public var source:DisplayObject;
      
      public var hide:Vector.<DisplayObject>;
      
      public var shared:Boolean;
      
      public var wantContent:String;
      
      public var wantScale:Number = 0;
      
      public var cell:BakedCell;
      
      public var cellContent:String;
      
      public var cellScale:Number = 0;
      
      public function TagPart(source:DisplayObject, hide:Vector.<DisplayObject> = null, shared:Boolean = false)
      {
         super();
         this.source = source;
         this.hide = hide;
         this.shared = shared;
      }
      
      public function get current() : Boolean
      {
         return wantContent == null ? cell == null : cell != null && cell.alive && cellContent == wantContent && cellScale > 0 && Math.abs(wantScale / cellScale - 1) <= 0.005;
      }
      
      public function get usable() : Boolean
      {
         return wantContent == null || cell != null && cell.alive && cellContent == wantContent;
      }
      
      public function get drawn() : Boolean
      {
         return wantContent != null && cell != null && cellContent == wantContent && cell.alive && !cell.isEmpty;
      }
   }
}

