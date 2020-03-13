;执行Bat指令
StrRunAsBat(ByRef str)
{
	tempBatPath := A_ScriptDir "\ahkBat_" A_Now ".bat"
	FileAppend, %str%, %tempBatPath%
	RunWait, %tempBatPath%,, Hide    ;隐藏运行批处理文件
	FileDelete, %tempBatPath%
}



;~ FileAppend, % "`r`nmklink /j " AccountR[i] "\SavedVariables " AccountL "\SavedVariables", ahkmklink.bat    ;账号\SavedVariables  的目录联接
;~ FileAppend, % "`r`nmklink /h " AccountR[i] "\config-cache.wtf " AccountL "\config-cache.wtf", ahkmklink.bat    ;账号设置  的文件硬连接
;~ FileAppend, % "`r`nmklink /h " AccountR[i] "\bindings-cache.wtf " AccountL "\bindings-cache.wtf", ahkmklink.bat    ;账号按键  的文件硬连接
;~ FileAppend, % "`r`nmklink /h " AccountR[i] "\macros-cache.txt " AccountL "\macros-cache.txt", ahkmklink.bat    ;账号宏  的文件硬连接