package haxe.xml._Access
{
   public final class HasNodeAccess_Impl_
   {
      
      public function HasNodeAccess_Impl_()
      {
      }
      
      public static function resolve(this1:Xml, name:String) : Boolean
      {
         return Boolean(this1.elementsNamed(name).hasNext());
      }
   }
}

