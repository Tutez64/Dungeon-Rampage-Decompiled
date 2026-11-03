package starling.utils
{
   public function execute(func:Function, ... rest) : void
   {
      var _loc4_:int = 0;
      var _loc3_:int = 0;
      if(func != null)
      {
         _loc3_ = func.length;
         _loc4_ = int(rest.length);
         while(_loc4_ < _loc3_)
         {
            rest[_loc4_] = null;
            _loc4_++;
         }
         switch(_loc3_)
         {
            case 0:
               func();
               break;
            case 1:
               func(rest[0]);
               break;
            case 2:
               func(rest[0],rest[1]);
               break;
            case 3:
               func(rest[0],rest[1],rest[2]);
               break;
            case 4:
               func(rest[0],rest[1],rest[2],rest[3]);
               break;
            case 5:
               func(rest[0],rest[1],rest[2],rest[3],rest[4]);
               break;
            case 6:
               func(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
               break;
            case 7:
               func(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
               break;
            default:
               func.apply(null,rest.slice(0,_loc3_));
         }
      }
   }
}

