package Town
{
   public class MessageOfTheDay
   {
      
      public static const IMAGE_PORTRAIT:uint = 0;
      
      public static const IMAGE_LANDSCAPE:uint = 1;
      
      public static const MOVIE:uint = 2;
      
      public var type:uint;
      
      public var title:String;
      
      public var message:String;
      
      public var imageURL:String;
      
      public var mainText:String;
      
      public var mainCallback:Function;
      
      public var webText:String;
      
      public var webURL:String;
      
      public function MessageOfTheDay(LayoutType:String, TitleText:String, MessageText:String, ImageURL:String, MainText:String, MainCallback:Function, WebText:String, WebURL:String)
      {
         super();
         if(LayoutType == "IMAGE_PORTRAIT")
         {
            type = 0;
         }
         else if(LayoutType == "IMAGE_LANDSCAPE")
         {
            type = 1;
         }
         else if(LayoutType == "MOVIE")
         {
            type = 2;
         }
         title = TitleText;
         message = MessageText;
         imageURL = ImageURL;
         mainText = MainText;
         mainCallback = MainCallback;
         webText = WebText;
         webURL = WebURL;
      }
   }
}

