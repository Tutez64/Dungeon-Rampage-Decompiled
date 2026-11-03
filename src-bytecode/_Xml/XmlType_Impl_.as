package _Xml
{
   public final class XmlType_Impl_
   {
      
      public static var Element:int = 0;
      
      public static var PCData:int = 1;
      
      public static var CData:int = 2;
      
      public static var Comment:int = 3;
      
      public static var DocType:int = 4;
      
      public static var ProcessingInstruction:int = 5;
      
      public static var Document:int = 6;
      
      public function XmlType_Impl_()
      {
      }
      
      public static function toString(this1:int) : String
      {
         switch(this1)
         {
            case 0:
               return "Element";
            case 1:
               return "PCData";
            case 2:
               return "CData";
            case 3:
               return "Comment";
            case 4:
               return "DocType";
            case 5:
               return "ProcessingInstruction";
            case 6:
               return "Document";
            default:
               return undefined;
         }
      }
   }
}

