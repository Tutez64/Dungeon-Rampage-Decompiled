package com.maccherone.json
{
   public class JSONTokenizer
   {
      
      private var ch:String;
      
      private var loc:int;
      
      private var jsonString:String;
      
      private var strict:Boolean;
      
      private var obj:Object;
      
      public function JSONTokenizer(s:String, strict:Boolean)
      {
         super();
         jsonString = s;
         this.strict = strict;
         loc = 0;
         nextChar();
      }
      
      private function skipComments() : void
      {
         if(ch == "/")
         {
            nextChar();
            switch(ch)
            {
               case "/":
                  do
                  {
                     nextChar();
                  }
                  while(ch != "\n" && ch != "");
                  nextChar();
                  break;
               case "*":
                  nextChar();
                  while(true)
                  {
                     if(ch == "*")
                     {
                        nextChar();
                        if(ch == "/")
                        {
                           break;
                        }
                     }
                     else
                     {
                        nextChar();
                     }
                     if(ch == "")
                     {
                        parseError("Multi-line comment not closed");
                     }
                  }
                  nextChar();
                  break;
               default:
                  parseError("Unexpected " + ch + " encountered (expecting \'/\' or \'*\' )");
            }
         }
      }
      
      private function isDigit(ch:String) : Boolean
      {
         return ch >= "0" && ch <= "9";
      }
      
      public function getNextToken() : JSONToken
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc1_:JSONToken = new JSONToken();
         skipIgnored();
         switch(ch)
         {
            case "{":
               _loc1_.type = JSONTokenType.LEFT_BRACE;
               _loc1_.value = "{";
               nextChar();
               break;
            case "}":
               _loc1_.type = JSONTokenType.RIGHT_BRACE;
               _loc1_.value = "}";
               nextChar();
               break;
            case "[":
               _loc1_.type = JSONTokenType.LEFT_BRACKET;
               _loc1_.value = "[";
               nextChar();
               break;
            case "]":
               _loc1_.type = JSONTokenType.RIGHT_BRACKET;
               _loc1_.value = "]";
               nextChar();
               break;
            case ",":
               _loc1_.type = JSONTokenType.COMMA;
               _loc1_.value = ",";
               nextChar();
               break;
            case ":":
               _loc1_.type = JSONTokenType.COLON;
               _loc1_.value = ":";
               nextChar();
               break;
            case "t":
               _loc2_ = "t" + nextChar() + nextChar() + nextChar();
               if(_loc2_ == "true")
               {
                  _loc1_.type = JSONTokenType.TRUE;
                  _loc1_.value = true;
                  nextChar();
               }
               else
               {
                  parseError("Expecting \'true\' but found " + _loc2_);
               }
               break;
            case "f":
               _loc3_ = "f" + nextChar() + nextChar() + nextChar() + nextChar();
               if(_loc3_ == "false")
               {
                  _loc1_.type = JSONTokenType.FALSE;
                  _loc1_.value = false;
                  nextChar();
               }
               else
               {
                  parseError("Expecting \'false\' but found " + _loc3_);
               }
               break;
            case "n":
               _loc4_ = "n" + nextChar() + nextChar() + nextChar();
               if(_loc4_ == "null")
               {
                  _loc1_.type = JSONTokenType.NULL;
                  _loc1_.value = null;
                  nextChar();
               }
               else
               {
                  parseError("Expecting \'null\' but found " + _loc4_);
               }
               break;
            case "N":
               _loc5_ = "N" + nextChar() + nextChar();
               if(_loc5_ == "NaN")
               {
                  _loc1_.type = JSONTokenType.NAN;
                  _loc1_.value = NaN;
                  nextChar();
               }
               else
               {
                  parseError("Expecting \'NaN\' but found " + _loc5_);
               }
               break;
            case "\"":
               _loc1_ = readString();
               break;
            default:
               if(isDigit(ch) || ch == "-")
               {
                  _loc1_ = readNumber();
               }
               else
               {
                  if(ch == "")
                  {
                     return null;
                  }
                  parseError("Unexpected " + ch + " encountered");
               }
         }
         return _loc1_;
      }
      
      private function skipWhite() : void
      {
         while(isWhiteSpace(ch))
         {
            nextChar();
         }
      }
      
      private function isWhiteSpace(ch:String) : Boolean
      {
         return ch == " " || ch == "\t" || ch == "\n" || ch == "\r";
      }
      
      public function parseError(message:String) : void
      {
         throw new JSONParseError(message,loc,jsonString);
      }
      
      private function readString() : JSONToken
      {
         var _loc3_:String = null;
         var _loc4_:* = 0;
         var _loc1_:String = "";
         nextChar();
         while(ch != "\"" && ch != "")
         {
            if(ch == "\\")
            {
               nextChar();
               switch(ch)
               {
                  case "\"":
                     _loc1_ += "\"";
                     break;
                  case "/":
                     _loc1_ += "/";
                     break;
                  case "\\":
                     _loc1_ += "\\";
                     break;
                  case "b":
                     _loc1_ += "\b";
                     break;
                  case "f":
                     _loc1_ += "\f";
                     break;
                  case "n":
                     _loc1_ += "\n";
                     break;
                  case "r":
                     _loc1_ += "\r";
                     break;
                  case "t":
                     _loc1_ += "\t";
                     break;
                  case "u":
                     _loc3_ = "";
                     _loc4_ = 0;
                     while(_loc4_ < 4)
                     {
                        if(!isHexDigit(nextChar()))
                        {
                           parseError(" Excepted a hex digit, but found: " + ch);
                        }
                        _loc3_ += ch;
                        _loc4_++;
                     }
                     _loc1_ += String.fromCharCode(parseInt(_loc3_,16));
                     break;
                  default:
                     _loc1_ += "\\" + ch;
               }
            }
            else
            {
               _loc1_ += ch;
            }
            nextChar();
         }
         if(ch == "")
         {
            parseError("Unterminated string literal");
         }
         nextChar();
         var _loc2_:JSONToken = new JSONToken();
         _loc2_.type = JSONTokenType.STRING;
         _loc2_.value = _loc1_;
         return _loc2_;
      }
      
      private function nextChar() : String
      {
         return ch = jsonString.charAt(loc++);
      }
      
      private function skipIgnored() : void
      {
         var _loc1_:int = 0;
         do
         {
            _loc1_ = loc;
            skipWhite();
            skipComments();
         }
         while(_loc1_ != loc);
      }
      
      private function isHexDigit(ch:String) : Boolean
      {
         var _loc2_:String = ch.toUpperCase();
         return isDigit(ch) || _loc2_ >= "A" && _loc2_ <= "F";
      }
      
      private function readNumber() : JSONToken
      {
         var _loc3_:JSONToken = null;
         var _loc1_:String = "";
         if(ch == "-")
         {
            _loc1_ += "-";
            nextChar();
         }
         if(!isDigit(ch))
         {
            parseError("Expecting a digit");
         }
         if(ch == "0")
         {
            _loc1_ += ch;
            nextChar();
            if(isDigit(ch))
            {
               parseError("A digit cannot immediately follow 0");
            }
            else if(!strict && ch == "x")
            {
               _loc1_ += ch;
               nextChar();
               if(isHexDigit(ch))
               {
                  _loc1_ += ch;
                  nextChar();
               }
               else
               {
                  parseError("Number in hex format require at least one hex digit after \"0x\"");
               }
               while(isHexDigit(ch))
               {
                  _loc1_ += ch;
                  nextChar();
               }
            }
         }
         else
         {
            while(isDigit(ch))
            {
               _loc1_ += ch;
               nextChar();
            }
         }
         if(ch == ".")
         {
            _loc1_ += ".";
            nextChar();
            if(!isDigit(ch))
            {
               parseError("Expecting a digit");
            }
            while(isDigit(ch))
            {
               _loc1_ += ch;
               nextChar();
            }
         }
         if(ch == "e" || ch == "E")
         {
            _loc1_ += "e";
            nextChar();
            if(ch == "+" || ch == "-")
            {
               _loc1_ += ch;
               nextChar();
            }
            if(!isDigit(ch))
            {
               parseError("Scientific notation number needs exponent value");
            }
            while(isDigit(ch))
            {
               _loc1_ += ch;
               nextChar();
            }
         }
         var _loc2_:Number = Number(_loc1_);
         if(isFinite(_loc2_) && !isNaN(_loc2_))
         {
            _loc3_ = new JSONToken();
            _loc3_.type = JSONTokenType.NUMBER;
            _loc3_.value = _loc2_;
            return _loc3_;
         }
         parseError("Number " + _loc2_ + " is not valid!");
         return null;
      }
   }
}

