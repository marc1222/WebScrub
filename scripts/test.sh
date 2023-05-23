echo -e 'Target: https://google.com/FUZZ
Total requests: 9733
==================================================================
ID    Response   Lines      Word         Chars          Request    
==================================================================
00001:  C=404     11 L	      72 W	   1576 Ch	  "asdfnottherexxxasdf | https://google.com/asdfnottherexxxasdf"
00002:  C=404     11 L	      72 W	   1563 Ch	  "..%3B/ | https://google.com/..%3B/"
00003:  C=404     11 L	      72 W	   1560 Ch	  "%40 | https://google.com/%40"
00004:  C=404     11 L	      72 W	   1558 Ch	  "_ | https://google.com/_"
00005:  C=404     11 L	      72 W	   1558 Ch	  "0 | https://google.com/0"
00011:  C=404     11 L	      72 W	   1559 Ch	  "05 | https://google.com/05"
00012:  C=404     11 L	      72 W	   1559 Ch	  "06 | https://google.com/06"
00008:  C=404     11 L	      72 W	   1559 Ch	  "02 | https://google.com/02"
00006:  C=404     11 L	      72 W	   1559 Ch	  "00 | https://google.com/00"
00009:  C=404     11 L	      72 W	   1559 Ch	  "03 | https://google.com/03"
00010:  C=404     11 L	      72 W	   1559 Ch	  "04 | https://google.com/04"
00013:  C=404     11 L	      72 W	   1559 Ch	  "07 | https://google.com/07"
00007:  C=404     11 L	      72 W	   1559 Ch	  "01 | https://google.com/01"
00014:  C=404     11 L	      72 W	   1559 Ch	  "08 | https://google.com/08"
00015:  C=404     11 L	      72 W	   1559 Ch	  "09 | https://google.com/09"
00025:  C=404     11 L	      72 W	   1560 Ch	  "101 | https://google.com/101"'
sleep 3
echo 'Done---------------'
