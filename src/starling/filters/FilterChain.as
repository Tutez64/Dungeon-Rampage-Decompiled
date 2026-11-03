package starling.filters
{
   import starling.events.Event;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   import starling.utils.Padding;
   
   public class FilterChain extends FragmentFilter
   {
      
      private static var sPadding:Padding = new Padding();
      
      private var _filters:Vector.<FragmentFilter>;
      
      public function FilterChain(... rest)
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:FragmentFilter = null;
         super();
         _filters = new Vector.<FragmentFilter>(0);
         _loc4_ = 0;
         _loc3_ = int(rest.length);
         while(_loc4_ < _loc3_)
         {
            _loc2_ = rest[_loc4_] as FragmentFilter;
            if(!_loc2_)
            {
               throw new ArgumentError("pass only fragment filters to the constructor");
            }
            addFilterAt(_loc2_,_loc4_);
            _loc4_++;
         }
         updatePadding();
         addEventListener("enterFrame",onEnterFrame);
      }
      
      override public function dispose() : void
      {
         for each(var _loc1_:FragmentFilter in _filters)
         {
            _loc1_.dispose();
         }
         _filters.length = 0;
         super.dispose();
      }
      
      override protected function setRequiresRedraw() : void
      {
         updatePadding();
         super.setRequiresRedraw();
      }
      
      override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null, input3:Texture = null) : Texture
      {
         var _loc7_:Texture = null;
         var _loc10_:Texture = null;
         var _loc8_:int = 0;
         var _loc9_:int = int(_filters.length);
         if(_loc9_ > 0)
         {
            _loc7_ = input0;
            _loc8_ = 0;
            while(_loc8_ < _loc9_)
            {
               _loc10_ = _loc7_;
               _loc7_ = _filters[_loc8_].process(painter,helper,_loc10_);
               if(_loc8_)
               {
                  helper.putTexture(_loc10_);
               }
               _loc8_++;
            }
            return _loc7_;
         }
         return super.process(painter,helper,input0,input1,input2,input3);
      }
      
      override public function get numPasses() : int
      {
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:int = int(_filters.length);
         _loc1_ = 0;
         while(_loc1_ < _loc2_)
         {
            _loc3_ += _filters[_loc1_].numPasses;
            _loc1_++;
         }
         return _loc3_ || 1;
      }
      
      public function getFilterAt(index:int) : FragmentFilter
      {
         if(index < 0)
         {
            index += numFilters;
         }
         return _filters[index];
      }
      
      public function addFilter(filter:FragmentFilter) : void
      {
         addFilterAt(filter,_filters.length);
      }
      
      public function addFilterAt(filter:FragmentFilter, index:int) : void
      {
         _filters.insertAt(index,filter);
         filter.addEventListener("change",setRequiresRedraw);
         setRequiresRedraw();
      }
      
      public function removeFilter(filter:FragmentFilter, dispose:Boolean = false) : FragmentFilter
      {
         var _loc3_:int = getFilterIndex(filter);
         if(_loc3_ != -1)
         {
            removeFilterAt(_loc3_,dispose);
         }
         return filter;
      }
      
      public function removeFilterAt(index:int, dispose:Boolean = false) : FragmentFilter
      {
         var _loc3_:FragmentFilter = _filters.removeAt(index) as FragmentFilter;
         _loc3_.removeEventListener("change",setRequiresRedraw);
         if(dispose)
         {
            _loc3_.dispose();
         }
         setRequiresRedraw();
         return _loc3_;
      }
      
      public function getFilterIndex(filter:FragmentFilter) : int
      {
         return _filters.indexOf(filter);
      }
      
      private function updatePadding() : void
      {
         var _loc2_:Padding = null;
         sPadding.setTo();
         for each(var _loc1_:FragmentFilter in _filters)
         {
            _loc2_ = _loc1_.padding;
            if(_loc2_.left > sPadding.left)
            {
               sPadding.left = _loc2_.left;
            }
            if(_loc2_.right > sPadding.right)
            {
               sPadding.right = _loc2_.right;
            }
            if(_loc2_.top > sPadding.top)
            {
               sPadding.top = _loc2_.top;
            }
            if(_loc2_.bottom > sPadding.bottom)
            {
               sPadding.bottom = _loc2_.bottom;
            }
         }
         this.padding.copyFrom(sPadding);
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(_filters.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            _filters[_loc2_].dispatchEvent(event);
            _loc2_++;
         }
      }
      
      public function get numFilters() : int
      {
         return _filters.length;
      }
   }
}

