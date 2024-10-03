#!bin/bash
LOGFILE=log.log
ERRORLOGFILE=error.log

exec 3>&1 1>$LOGFILE 2>$ERRORLOGFILE

date -Is
#check for 2 arguments
if [ $# -lt 2 ]; then
	echo "Error. Script recieved incorrect number of arguments. Required:2 Recieved:$#" >& 3
	echo "Error. Script recieved incorrect number of arguments. Required:2 Recieved:$#" >> $LOGFILE  #refactor log-filing
fi


SITE_URL_REFERER="https://avidreaders.ru/download/voyna-i-mir-tom-1.html?f=txt"
SITE_URL_REDIRECT="https://avidreaders.ru/api/get.php?b=80843&f=txt&t=1727548193318"
NAME_TO_SAVE_ARCHIVE="gg.zip"

echo "Downloading file from $SITE_URL_REFERER."
curl -L --referer "$SITE_URL_REFERER" "$SITE_URL_REDIRECT" -o $NAME_TO_SAVE_ARCHIVE


ARCHIVE=`unzip -l $NAME_TO_SAVE_ARCHIVE | grep .txt | awk '{print $4}' `
unzip -u -o $NAME_TO_SAVE_ARCHIVE

#convert cp1251 to utf-8
iconv -f cp1251 -t utf-8 $ARCHIVE -o tmp$ARCHIVE
#cat tmp$ARCHIVE

#find top5 most used russian words
cat tmp$ARCHIVE | tr '[:upper:]' '[:lower:]' | tr -s ' ' |  tr -s '\n' ' ' | grep -oE '\b[а-яё]{6,}\b' | sort | uniq -c | sort -rn | head -5 | awk '{print $2}' > mostUsedWords$ARCHIVE


FIND_KNYAZ="князь"
FIND_GOVORIL="говорил"


if grep -Fxq "$FIND_KNYAZ" mostUsedWords$ARCHIVE
then
	curl -L -q -w "%{json}" -H "Accept: application/json" ya.ru
fi

echo '\n' >& 3

if ! grep -Fxq "$FIND_GOVORIL" mostUsedWords$ARCHIVE
then
	curl -L -q -w "%{json}" -H "Accept: application/json" google.coom
fi


curl -w '%{json}' $1 >& 3 

#Check if directory "download" exists, true - download file from $1, false create directory, log creation, download file from $1 
if [ -d "./download" ]
then
	echo "Directory ./download exists." >& 3
	wget "$2" -o "./download/tmp$2"
	#add logs
else 
	echo "Directory ./download doesn't exist." >& 3 
	wget "$2" -P "./download/tmp$2"
	echo "Created ($pwd)/download/ directory"
	#add logs
fi


ls -l ./download/tmp$2 >& 3
echo "$(cd "$(dirname "./download/tmp$2")" && pwd)/$(basename "./download/tmp$2")" >& 3
