#NoEnv
#NoTrayIcon    ;无托盘图标
#SingleInstance, Ignore    ;不能双开
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1  
SetControlDelay, -1
SendMode Input
SetWorkingDir %A_ScriptDir%    ;工作目录设置为当前
OnExit, RunBeforeExit
#Include <Class_IniSaved>
global INI := new IniSaved(A_AppData "\mklinkMaker.ini")

Gui, +Resize +MinSize403x350 +E0x10  ;GUI可修改尺寸 +E0x10:拖放文件
Gui, Font,, 微软雅黑   ;字体修改
Gui, Color,, 0xCCE8CF   ;护眼绿色

Gui, Add, GroupBox, xm ym+2 w380 h183 c0072E3, 生成链接
Gui, Add, Text, xp+10 yp+25 w55 h22 Section, 链接路径:
Gui, Add, Text, y+5 wp hp, 真实路径:
Gui, Add, Edit, x+5 ys-2 w272 hp vini_GUI_ED1, % INI.Init("GUI", "ED1", "") 
Gui, Add, Edit, y+5 wp hp vini_GUI_ED2, % INI.Init("GUI", "ED2", "") 
Gui, Add, button, x+1 ys-2 w25 hp vvBTfileSelect1 ggBTfileSelect, ...
Gui, Add, button, y+5 wp hp vvBTfileSelect2 ggBTfileSelect, ...

Gui, Add, GroupBox, xs y+5 w235 h95 Section, 模式选择
Gui, Add, Radio, xp+15 yp+25 vvRGmod, mklink /h 硬链接(文件)
Gui, Add, Radio, , mklink /d 符号联接(文件夹/文件)
Gui, Add, Radio, , mklink /j 目录联接(文件夹)
Gui, Add, button, x+55 ys+8 w120 h86 vvBT1 ggBTcreate, 生成链接

Gui, Add, GroupBox, xm y+15 w380 h285 vvGB2 c0072E3, 查看链接
Gui, Add, Text, xp+10 yp+25 w55 h22 Section, 查看路径:
Gui, Add, Edit, x+5 ys-2 w272 hp vini_GUI_ED3, % INI.Init("GUI", "ED3", "")
Gui, Add, button, x+1 ys-2 w25 hp vvBTfileSelect3 ggBTfileSelect, ...
Gui, Add, button, xs y+5 w116 hp vvBT2 ggBTsearch, 搜索
Gui, Add, button, x+6 yp wp hp vvBT3 ggBTclean, 删除无效链接
Gui, Add, button, x+6 yp wp hp vvBT4 ggBTdelete, 删除选中链接
Gui, Add, ListView, xs y+5 w360 h200 vvLV1 Grid, 序号|链接路径|真实路径


Gui, Add, StatusBar,, % A_IsAdmin?"请注意,管理员权限下无法文件拖拽!":""
Gui, Show
return

;禁用/启用按键
DisableButtons:
GuiControl, Disable, vBT1
GuiControl, Disable, vBT2
GuiControl, Disable, vBT3
GuiControl, Disable, vBT4
GuiControl, Disable, vBTfileSelect1
GuiControl, Disable, vBTfileSelect2
GuiControl, Disable, vBTfileSelect3
return
EnableButtons:
GuiControl, Enable, vBT1
GuiControl, Enable, vBT2
GuiControl, Enable, vBT3
GuiControl, Enable, vBT4
GuiControl, Enable, vBTfileSelect1
GuiControl, Enable, vBTfileSelect2
GuiControl, Enable, vBTfileSelect3
return

;选择文件夹
gBTfileSelect:
	FileSelectFolder, OutputVar,, 3
	if (OutputVar == "")
		return
	ED := "ini_GUI_ED" SubStr(A_GuiControl,0,1)
	SB_SetText(ED)
	GuiControl,, % ED, % OutputVar	
return

;生成链接
gBTcreate:
	SB_SetText("开始生成")
	Gui, Submit, NoHide
	Switch vRGmod
	{
	Case 1: mod := "/h"
	Case 2: mod := "/d"
		if !A_IsAdmin
		{
			SB_SetText("mklink /d 需要管理员权限,请以管理员身份重新运行软件")
			return
		}
	Case 3: mod := "/j"
	Default:
		SB_SetText("请选择连接模式")
		return
	}
	gosub, DisableButtons
	r := RunMklink(mod, ini_GUI_ED1, ini_GUI_ED2, true)
	SB_SetText("mklink " mod " 链接生成" (r==1?"成功":"失败"))
	gosub, EnableButtons
return

;搜索文件夹
gBTsearch:
	Gui, Submit, NoHide
	if !InStr(FileExist(ini_GUI_ED3), "D")
	{
		SB_SetText("请将文件/文件夹拖入地址框")
		return
	}
	gosub, DisableButtons
	SB_SetText("开始搜索")
	i := 0
	LV_Delete()
	Loop, Files, % RTrim(ini_GUI_ED3,"\") "\*", FDR
	{
		if (mod(A_index,200) == 0)
			SB_SetText(A_LoopFileFullPath)
		if IsReparsePoint(A_LoopFileFullPath) 
		{
			i++
			LV_Add(, i, A_LoopFileFullPath, GetRealPath(A_LoopFileFullPath))
		}
	}
	SB_SetText("搜索结束")
	gosub, EnableButtons
return

;删除无效链接
gBTclean:
	Gui, Submit, NoHide
	gosub, DisableButtons
	SB_SetText("开始删除")
	i := 0
	Loop % LV_GetCount()
	{
		rowIndex := A_index - i
		LV_GetText(linkPath, rowIndex , 2)
		LV_GetText(realPath, rowIndex , 3)
		if (linkPath <> "" and realPath == "")
		{
			i++
			FileOrFolderDelete(linkPath)
			LV_Delete(rowIndex)
		}
	}
	SB_SetText("删除结束")
	gosub, EnableButtons
return

;删除选中链接
gBTdelete:
	Gui, Submit, NoHide
	selects := []
	selectsTxt := ""
	RowNumber := 0  ; 这样使得首次循环从列表的顶部开始搜索.
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(Text, RowNumber, 2)
		selects.push({RowIndex:RowNumber, path:Text})
		selectsTxt .= Text "`n"
	}
	if (selects.count() == 0)
	{
		SB_SetText("未选择任何链接")
		return
	}
	MsgBox, 49,, % "确定删除下列链接?`n" selectsTxt, 30
	IfMsgBox OK
	{
		gosub, DisableButtons
		SB_SetText("删除清理")
		i := maxi := selects.count()
		loop % maxi
		{
			FileOrFolderDelete(selects[i].path)
			LV_Delete(selects[i].RowIndex)
			i--
		}
		SB_SetText("删除结束")
		gosub, EnableButtons
	}
return

;拖进文件夹
GuiDropFiles:
	Switch A_GuiControl
	{
	Case "ini_GUI_ED1","ini_GUI_ED2": 
		GuiControl,, % A_GuiControl, % A_GuiEvent	
	Case "ini_GUI_ED3": 
		if InStr(FileExist(A_GuiEvent), "D")
			GuiControl,, % A_GuiControl, % A_GuiEvent	
		else
			SB_SetText("请将文件夹拖入地址框")
	Default:
		SB_SetText("请将文件/文件夹拖入地址框")
	}
return

;改变GUI尺寸时调整控件
GuiSize:
	AutoXYWH("wh", "vGB2")
	AutoXYWH("wh", "vLV1") 
	AutoXYWH("w", "ini_GUI_ED3") 
	AutoXYWH("x", "vBTfileSelect3") 
return

;关闭GUI时退出
GuiClose:
ExitApp

;退出前运行
RunBeforeExit:
	Gui, Submit, NoHide
	INI.SaveAll()
ExitApp