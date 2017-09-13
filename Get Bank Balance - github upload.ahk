;Best viewed in Notepad++ with the AHK syntax file installed.
;This file runs through AutoHotkey a highly versatile freeware scripting program.
;
; AutoHotkey Version: 1.1.26.1
; Language:       English
; Platform:       Windows 10
; Author:         staid03
; Version   Date        Author       Comments
;     0.1   13-SEP-17   staid03      Initial
;
; Script Function:
;    Pull up bank home page and capture current balance
;
; Note: Identifying bank details have been removed.
;		This is a personal use script uploaded to demonstrate my coding.
;		This was created in about 90 mins this morning (13th September 2017)
;		after I woke up.
;		I was thinking about a problem, last week, where I wanted to be able
;		to pull up my current bank balance quickly each day. I am not sure this
;		is the solution I need but it was a good idea to flesh out and it was
;		fun to code.


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance , force

formattime , atime ,, yyyyMMddHHmmss
extractf = bank_extract_%atime%.txt
Browser = "Browser.exe"								;details redacted
Banksite = https://www.mybank.com/logon				;details redacted
LogonWin = MyBank - Log on to MyBank				;details redacted
HomeWin = MyBank - Home								;details redacted
sleepmin = 200
primaryAccount = regular account					;details redacted


main:
{
	run , %Browser% %Banksite%			;run browser with bank URL
	windowwaiting(LogonWin)				;wait for browser to load URL
	enterCredentials()		;redacted
	send , {enter}						;when loaded, press {enter} to logon
	windowwaiting(HomeWin)				;wait for browser to logon
	send , ^a							;select all the text in the page
	sleeper(sleepmin)					;wait a short period of time
	send , ^c							;copy all selected text (whole page)
	sleeper(sleepmin)					;wait a short period of time
	fileappend , %clipboard% , %extractf%	;paste all page text into an extract file. Retaining file in case of future reference although probably not necessary.
	send , !{F4}						;close broswer (and page)
	balance := getbalance(extractf, primaryAccount)		;get balance of concerned account
	logmessage = Balance is %balance%		;create message for log file with balance in it
	loginfo(logmessage)						;log balance to log file
	msgbox ,,, Balance is %balance% , 5	;display balance on screen
}
return

windowwaiting(windowname)					;function to wait for window to load. Parse name of window that is being waited on.
{
	winwaitactive , %windowname% ,, 10		;wait 10 seconds for window to load - if it loads sooner then it will move onto the next item
	if Errorlevel							;if window doesn't load create error message for the log
	{
		logmessage = %A_ScriptName% - failed to activate %windowname%
		loginfo(logmessage)					;call log function and parse message to it
		return								;script ends here if it failed to load window
	}
	sleeper(1000)
	ifwinnotactive , %windowname%
	{
		logmessage = %A_ScriptName% - %windowname% was not active
		loginfo(logmessage)					;call log function and parse message to it
		return								;script ends here if it failed to find window active
	}
}
return

sleeper(sleeptime)							;sleep function with time parsed to it
{
	sleep , %sleeptime%
}
return

getbalance(extractf, primaryAccount)
{
	balance = 0								;set a value in case nothing is found....
	loop , read , %extractf%				;loop through extract line by line
	{
		ifnotinstring , a_loopreadline , %primaryAccount%		;if desired string isn't found, keep going
		{
			continue
		}
		else
		{
			stringsplit , a , a_loopreadline , %a_space%		;if desired string is found, chop up the line into sections where there are spaces
			stringsplit , b , a7 , $							;the bank balance is found in the 7th space division but this variable needs to be split into sections by $ sign
			balance = %b3%										;the bank balance is found in the section after the 3rd $ sign
		}
	}
	return balance												;return the balance
}
return

loginfo(logmessage)												;log the message parsed
{
	logf = get_bank_balance_log.log								;identify the log file
	formattime , ltime ,, yyyyMMddHHmmss						;get current DateTimeStamp for logging
	fileappend , %ltime% - %logmessage% , %logf%				;append DateTimeStamp and log message to log
}
return 
