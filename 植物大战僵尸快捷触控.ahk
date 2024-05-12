full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
  try
  {
    if A_IsCompiled
      Run *RunAs "%A_ScriptFullPath%" /restart
    else
      Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
  }
  ExitApp
}

Process, Priority, , Realtime
#MenuMaskKey vkE8
#WinActivateForce
#InstallKeybdHook
#InstallMouseHook
#Persistent
#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 2000
#KeyHistory 2000
SendMode Input
SetBatchLines -1
SetKeyDelay -1, 50
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window

STOPMOD:=0

IfExist, %A_ScriptDir%\设置.ini ;如果配置文件存在则读取
{
  IniRead, X1, 设置.ini, 设置, X1
  IniRead, X2, 设置.ini, 设置, X2
  IniRead, Y, 设置.ini, 设置, Y
}
else
{
  X1:=0
  IniWrite, %X1%, 设置.ini, 设置, X1
  X2:=0
  IniWrite, %X2%, 设置.ini, 设置, X2
  Y:=0
  IniWrite, %Y%, 设置.ini, 设置, Y
}
SoundPlay, Speech On.wav
MsgBox, , 杂交版快捷触控, 黑钨重工出品 免费开源 请勿商用 侵权必究`n请搭配Winlator的输入控制使用,导入icp文件后再打开模拟器`n长按数字1设置左边卡槽位置`n长按数字4设置右边卡槽位置`n`n使用教程:`n可以使用外接键盘`n数字4 左键`n数字5 暂停快速种植模式
return

NewLeft(){
  global
  MouseGetPos, X1, Y
  IniWrite, %X1%, 设置.ini, 设置, X1
  IniWrite, %Y%, 设置.ini, 设置, Y
  SoundPlay, Speech On.wav
  return
}

NewRight(){
  global
  MouseGetPos, X2, Y
  IniWrite, %X2%, 设置.ini, 设置, X2
  SoundPlay, Speech On.wav
  return
}

Class 后台 {
  ;-- 类开始，使用类的命名空间可防止变量名、函数名污染
  获取控件句柄(WinTitle, Control="") {
    tmm:=A_TitleMatchMode, dhw:=A_DetectHiddenWindows
    SetTitleMatchMode, 2
    DetectHiddenWindows, On
    ControlGet, hwnd, Hwnd,, %Control%, %WinTitle%
    DetectHiddenWindows, %dhw%
    SetTitleMatchMode, %tmm%
    return, hwnd
  }
  点击左键(hwnd, x, y) {
    return, this.Click_PostMessage(hwnd, x, y, "L")
  }
  点击右键(hwnd, x, y) {
    return, this.Click_PostMessage(hwnd, x, y, "R")
  }
  移动鼠标(hwnd, x, y) {
    return, this.Click_PostMessage(hwnd, x, y, 0)
  }
  Click_PostMessage(hwnd, x, y, flag="L") {
    static WM_MOUSEMOVE:=0x200
      , WM_LBUTTONDOWN:=0x201, WM_LBUTTONUP:=0x202
      , WM_RBUTTONDOWN:=0x204, WM_RBUTTONUP:=0x205
    ;---------------------
    VarSetCapacity(pt,16,0), DllCall("GetWindowRect", "ptr",hwnd, "ptr",&pt)
    , ScreenX:=x+NumGet(pt,"int"), ScreenY:=y+NumGet(pt,4,"int")
    Loop {
      NumPut(ScreenX,pt,"int"), NumPut(ScreenY,pt,4,"int")
      , DllCall("ScreenToClient", "ptr",hwnd, "ptr",&pt)
      , x:=NumGet(pt,"int"), y:=NumGet(pt,4,"int")
      , id:=DllCall("ChildWindowFromPoint", "ptr",hwnd, "int64",y<<32|x, "ptr")
      if (id=hwnd or !id)
        Break
      else hwnd:=id
    }
    ;---------------------
    if (flag=0)
      PostMessage, WM_MOUSEMOVE, 0, (y<<16)|x,, ahk_id %hwnd%
    else if InStr(flag,"L")=1
    {
      PostMessage, WM_LBUTTONDOWN, 0, (y<<16)|x,, ahk_id %hwnd%
      PostMessage, WM_LBUTTONUP, 0, (y<<16)|x,, ahk_id %hwnd%
    }
    else if InStr(flag,"R")=1
    {
      PostMessage, WM_RBUTTONDOWN, 0, (y<<16)|x,, ahk_id %hwnd%
      PostMessage, WM_RBUTTONUP, 0, (y<<16)|x,, ahk_id %hwnd%
    }
  }
  发送按键(hwnd, key) {
    static WM_KEYDOWN:=0x100, WM_KEYUP:=0x101
      , WM_SYSKEYDOWN:=0x104, WM_SYSKEYUP:=0x105, KEYEVENTF_KEYUP:=0x2
    Alt:=Ctrl:=Shift:=0
    if InStr(key,"!")
      Alt:=1, key:=StrReplace(key,"!")
    if InStr(key,"^")
    {
      Ctrl:=1, key:=StrReplace(key,"^")
      this.Send_keybd_event("Ctrl")
      Sleep, 100
    }
    if InStr(key,"+")
    {
      Shift:=1, key:=StrReplace(key,"+")
      this.Send_keybd_event("Shift")
      Sleep, 100
    }
    this.Send_PostMessage(hwnd, Alt=1 ? WM_SYSKEYDOWN : WM_KEYDOWN, key)
    Sleep, 100
    this.Send_PostMessage(hwnd, Alt=1 ? WM_SYSKEYUP : WM_KEYUP, key)
    if (Shift=1)
      this.Send_keybd_event("Shift", KEYEVENTF_KEYUP)
    if (Ctrl=1)
      this.Send_keybd_event("Ctrl", KEYEVENTF_KEYUP)
  }
  Send_PostMessage(hwnd, msg, key) {
    static WM_KEYDOWN:=0x100, WM_KEYUP:=0x101
      , WM_SYSKEYDOWN:=0x104, WM_SYSKEYUP:=0x105
    VK:=GetKeyVK(Key), SC:=GetKeySC(Key)
    flag:=msg=WM_KEYDOWN ? 0
      : msg=WM_KEYUP ? 0xC0
      : msg=WM_SYSKEYDOWN ? 0x20
      : msg=WM_SYSKEYUP ? 0xE0 : 0
    PostMessage, msg, VK, (count:=1)|(SC<<16)|(flag<<24),, ahk_id %hwnd%
  }
  Send_keybd_event(key, msg=0) {
    static KEYEVENTF_KEYUP:=0x2
    VK:=GetKeyVK(Key), SC:=GetKeySC(Key)
    DllCall("keybd_event", "int",VK, "int",SC, "int",msg, "int",0)
  }
  ;-- 类结束
}

~1::
JS:=A_TickCount
Loop
{
  Sleep 30
  if (A_TickCount-JS>2000)
  {
    NewLeft()
    Break
  }
  if !GetKeyState("1", "P")
  {
    Break
  }
}
return

~4::
Send {LButton Down}
JS:=A_TickCount
Loop
{
  Sleep 30
  if (A_TickCount-JS>2000)
  {
    NewRight()
    Break
  }
  if !GetKeyState("4", "P")
  {
    Break
  }
}
Send {LButton Up}
return

~5::
if (STOPMOD=0)
{
  STOPMOD:=1
  Send {Esc}
}
else
{
  STOPMOD:=0
  Send {Esc}
}
return

~q::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1, Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, q
return

~w::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*1), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, w
return

~e::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*2), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, e
return

~r::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*3), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, r
return

~t::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*4), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, t
return

~a::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*5), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, a
return

~s::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*6), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, s
return

~d::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*7), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, d
return

~f::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*8), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, f
return

~g::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*9), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, g
return

~z::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*10), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, z
return

~x::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*11), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, x
return

~c::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X1+Round(Abs((X2-X1))/13*12), Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, c
return

~v::
BlockInput, On
if (STOPMOD=1)
{
  Send {Esc}
  Sleep 50
}
MouseGetPos, , , WinID
后台.点击左键(WinID, X2, Y)
Sleep 50
Send {LButton}
if (STOPMOD=1)
{
  Sleep 10
  Send {Esc}
}
BlockInput, Off
KeyWait, v
return