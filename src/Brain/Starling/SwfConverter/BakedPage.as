package Brain.Starling.SwfConverter
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.textures.ConcreteTexture;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   
   use namespace starling_internal;
   
   internal class BakedPage
   {
      
      private static const sRect:Rectangle = new Rectangle();
      
      private static const sPoint:Point = new Point();
      
      internal var texture:Texture;
      
      internal var pixels:BitmapData;
      
      internal var pool:String;
      
      internal var single:Boolean;
      
      internal var dirty:Boolean = false;
      
      internal var needsRestore:Boolean = false;
      
      internal var cells:int = 0;
      
      internal var width:int;
      
      internal var height:int;
      
      internal var rectangle:Boolean = true;
      
      internal var retiredAt:int = -1;
      
      private var mPacker:ShelfPacker;
      
      public function BakedPage()
      {
         super();
      }
      
      internal static function create(pool:String, width:int, height:int, single:Boolean, force:Boolean) : BakedPage
      {
         var _loc6_:Starling = Starling.current;
         if(_loc6_ == null || !_loc6_.contextValid)
         {
            return null;
         }
         var _loc7_:Boolean = _loc6_.profile != "baselineConstrained";
         if(!_loc7_)
         {
            width = MathUtil.getNextPowerOfTwo(width);
            height = MathUtil.getNextPowerOfTwo(height);
         }
         if(!BakeBudget.reserve(pool,width,height,force,_loc7_))
         {
            return null;
         }
         var _loc8_:BakedPage = new BakedPage();
         _loc8_.pool = pool;
         _loc8_.width = width;
         _loc8_.height = height;
         _loc8_.single = single;
         _loc8_.rectangle = _loc7_;
         _loc8_.mPacker = new ShelfPacker(width,height);
         try
         {
            _loc8_.texture = Texture.empty(width,height,true,false,false,1);
            _loc8_.texture.root.onRestore = null;
            _loc8_.pixels = new BitmapData(width,height,true,0);
            _loc8_.dirty = true;
         }
         catch(error:Error)
         {
            if(_loc8_.texture != null)
            {
               _loc8_.texture.dispose();
            }
            if(_loc8_.pixels != null)
            {
               _loc8_.pixels.dispose();
            }
            BakeBudget.unreserve(pool,width,height,_loc7_);
            return null;
         }
         return _loc8_;
      }
      
      internal function place(w:int, h:int, out:Point) : Boolean
      {
         if(w > width || h > height)
         {
            return false;
         }
         if(single)
         {
            if(cells > 0)
            {
               return false;
            }
            out.setTo(0,0);
            return true;
         }
         return mPacker.place(w,h,out);
      }
      
      internal function free(x:int, y:int, w:int) : void
      {
         if(single)
         {
            return;
         }
         mPacker.free(x,y,w);
      }
      
      internal function write(bake:BakedPicture, x:int, y:int, slotWidth:int, slotHeight:int) : void
      {
         sRect.setTo(x,y,slotWidth + 1,slotHeight + 1);
         pixels.fillRect(sRect,0);
         sPoint.setTo(x,y);
         pixels.copyPixels(bake.bitmap,bake.bitmap.rect,sPoint);
         dirty = true;
         if(Starling.current != null)
         {
            Starling.current.setRequiresRedraw();
         }
      }
      
      internal function upload() : Boolean
      {
         if(!dirty || texture == null)
         {
            return false;
         }
         if(needsRestore)
         {
            restore();
            return true;
         }
         texture.root.uploadBitmapData(pixels);
         dirty = false;
         return true;
      }
      
      internal function restore() : void
      {
         if(texture == null)
         {
            return;
         }
         var _loc1_:ConcreteTexture = texture.root;
         needsRestore = true;
         _loc1_.recreateBase();
         needsRestore = false;
         _loc1_.uploadBitmapData(pixels);
         dirty = false;
      }
      
      internal function dispose() : void
      {
         if(texture == null)
         {
            return;
         }
         texture.dispose();
         texture = null;
         pixels.dispose();
         pixels = null;
         BakeBudget.unreserve(pool,width,height,rectangle);
      }
   }
}

