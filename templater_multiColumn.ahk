;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
; TO-DO
;  Add counters that can be used on the template

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

columns := 2
maxcolumns :=5
colwidth := 200 ; widht of each column
gosub, showMainGui
Return

showMainGui:
    Loop, %maxcolumns%
        Menu, Columns, add, %A_Index%, columnmanager    

    Menu, MenuBar, Add, &Columns , :Columns
    Menu, Operations, add, Remove one column, Reload
    Menu, Operations, add, Fill column with numbers, fillCol
    Menu, MenuBar, Add, &Operations , :Operations

    gui, mainGui:new
    gui, mainGui:Default
    Gui, Menu,MenuBar
    Gui, Add, Text,, Template
    Gui, Add, Edit, vTemplate w400
    Gui, Add, Text,, Input
    loop, %columns%
    {
        xpos := A_Index = 1 ? 0 : colwidth
        Gui, Add, Edit, vcol%A_Index% w200 R15 XP+%xpos%, col%A_Index%
    }
    Gui, Add, Edit, vOutput w400 R15 yp+215 xs

    Gui, Add, Button, gSave w200 xs, OK
    Gui, Add, Button, xp+210 yp gGuiClose w200, Close

    Gui, +Resize
    Gui, Show
return

Reload:
columns -= 1
gosub, showMainGui
return

Save:
Gui, Submit, NoHide
result =
    colvalues := Object()
	Loop, %columns%	{	
		colvalues.push(StrSplit(col%a_index%,"`n","`r"))
        longerList:= longerList < colvalues[A_Index].MaxIndex() ? colvalues[A_Index].MaxIndex() : longerList
    }

        loop, %longerList%{
            replaced := template
            index := A_Index 
            loop, %columns%{
                colstring := "$" . A_Index ; the placeholder of the column
                replaced := StrReplace(replaced,colstring,colvalues[A_Index][index])
            }
        result .= replaced . "`n"
        }
guiControl,,Output, %result%
Clipboard := result
return

fillCol:
columnslist =
loop,%columns%
    columnslist .= A_Index . (A_Index > 1 ? "|" : "||")
    Gui, colEditor:New,, range editor
    Gui, colEditor:Default
    Gui,+ToolWindow
    Gui,Add,GroupBox,x170 y10 w300 h50,Range
    Gui,Add,Edit,x260 y30 w50 h21 vRangeStart, 1
    Gui,Add,Edit,x390 y30 w50 h21 vRangeEnd, 100
    Gui,Add,Text,x320 y30 w60 h13,End value:
    Gui,Add,Text,x180 y30 w80 h13,Starting value:
    Gui,Add,Button,x100 y20 w60 h40 gRangeFill,Fill Column
    Gui,Add,GroupBox,x10 y10 w80 h50 0x2000 Wrap,Target column
    Gui,Add,DropDownList,x20 y30 w50 vselected_col,%columnslist%
    Gui,Show,x536 y349 w490 h71 AutoSize,
return

RangeFill:
gui,submit,
Loop, %RangeEnd%
{ 
    result .= RangeStart "`n"
    RangeStart +=1
}
    guiControl,mainGui:,col%selected_col%, %result%
return

columnmanager(ItemName, ItemPos, MenuName){
    global
    Loop, %maxcolumns%
        Menu, %MenuName%, UnCheck, %A_Index%
      
    if( itemname > columns)
        loop, %itemname%
            if( A_Index > columns){
                GuiControlGet, prevcol,Pos,col%columns%
                Gui, mainGui:Add, Edit, vcol%A_Index% w200 R15 Y%prevcolY% xp+%prevcolW% , col%A_Index%
                columns +=1
                gui, show, AutoSize
            }
            
    Menu, %MenuName%, Check, %ItemName%
return
}

mainGuiGuisize:
 gui, mainGui:Default
 AutoXYWH("0.5w y","OK")
 AutoXYWH("y 0.5x","Close")
 AutoXYWH("wh","Output")
 AutoXYWH("w","Template")

return

GuiClose:
ExitApp
return

; =================================================================================
; Function: AutoXYWH
;   Move and resize control automatically when GUI resizes.
; Parameters:
;   DimSize - Can be one or more of x/y/w/h  optional followed by a fraction
;             add a '*' to DimSize to 'MoveDraw' the controls rather then just 'Move', this is recommended for Groupboxes
;   cList   - variadic list of ControlIDs
;             ControlID can be a control HWND, associated variable name, ClassNN or displayed text.
;             The later (displayed text) is possible but not recommend since not very reliable 
; Examples:
;   AutoXYWH("xy", "Btn1", "Btn2")
;   AutoXYWH("w0.5 h 0.75", hEdit, "displayed text", "vLabel", "Button1")
;   AutoXYWH("*w0.5 h 0.75", hGroupbox1, "GrbChoices")
; ---------------------------------------------------------------------------------
; Release date: 2014-7-03          
; Author      : tmplinshi (mod by toralf)
; requires AHK version : 1.1.13.01+
; =================================================================================
AutoXYWH(DimSize, cList*){       ; http://ahkscript.org/boards/viewtopic.php?t=1079
  static cInfo := {}
  For i, ctrl in cList {
    ctrlID := A_Gui ":" ctrl
    If ( cInfo[ctrlID].x = "" ){
        GuiControlGet, i, %A_Gui%:Pos, %ctrl%
        GuiControlGet, Hwnd, %A_Gui%:Hwnd, %ctrl%
        MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
        fx := fy := fw := fh := 0
        For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]")))
            If !RegExMatch(DimSize, "i)" dim "\s*\K[\d.-]+", f%dim%)
              f%dim% := 1
        cInfo[ctrlID] := { x:ix, fx:fx, y:iy, fy:fy, w:iw, fw:fw, h:ih, fh:fh, gw:A_GuiWidth, gh:A_GuiHeight, a:a , m:MMD}
    }Else If ( cInfo[ctrlID].a.1) {
        dgx := dgw := A_GuiWidth  - cInfo[ctrlID].gw  , dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
        For i, dim in cInfo[ctrlID]["a"]
            Options .= dim (dg%dim% * cInfo[ctrlID]["f" dim] + cInfo[ctrlID][dim]) A_Space
        GuiControl, % A_Gui ":" cInfo[ctrlID].m , % ctrl, % Options
} } }