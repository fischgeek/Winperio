; =================================================================================
; Function:     AutoXYWH
;   Move and resize control automatically when GUI resized.
; Parameters:
;   ctrl_list  - ControlID list separated by "|".
;                ControlID can be a control HWND, associated variable name or ClassNN.
;   Attributes - Can be one or more of x/y/w/h  followed by fractions
;   Redraw     - True to redraw controls
; Examples:
;   AutoXYWH("Btn1|Btn2", "xy")
;   AutoXYWH(hEdit      , "w0.5 h0.75")
; ---------------------------------------------------------------------------------
; Release date: 2014-6-25           http://ahkscript.org/boards/viewtopic.php?t=1079
; Author      : tmplinshi (mod by toralf)
; requires AHK version : 1.1.13.01+
; =================================================================================
AutoXYWH(ctrl_list, Attributes="wh", Redraw = False){
    static cInfo := {}
    Loop, Parse, ctrl_list, |
    {
        ctrl := A_Gui ":" A_LoopField
        If ( cInfo[ctrl].x = "" ){
            GuiControlGet, i, %A_Gui%:Pos, %A_LoopField%
            a := RegExReplace(Attributes, "i)[^xywh]")  
            fx := fy := fw := fh := 0
            Loop, Parse, a
                If !RegExMatch(Attributes, "i)" A_LoopField "\s*\K[\d.-]+", f%A_LoopField%)
                  f%A_LoopField% := 1
            cInfo[ctrl] := { x:ix, fx:fx, y:iy, fy:fy, w:iw, fw:fw, h:ih, fh:fh, gw:A_GuiWidth, gh:A_GuiHeight, a:StrSplit(a) }
        }Else If ( cInfo[ctrl].a.1) {
            x := (A_GuiWidth  - cInfo[ctrl].gw) * cInfo[ctrl].fx + cInfo[ctrl].x
            y := (A_GuiHeight - cInfo[ctrl].gh) * cInfo[ctrl].fy + cInfo[ctrl].y
            w := (A_GuiWidth  - cInfo[ctrl].gw) * cInfo[ctrl].fw + cInfo[ctrl].w
            h := (A_GuiHeight - cInfo[ctrl].gh) * cInfo[ctrl].fh + cInfo[ctrl].h
            For i, a in cInfo[ctrl]["a"]
                Options .= a %a% A_Space
            GuiControl, % A_Gui ":" (Redraw ? "MoveDraw" : "Move"), % A_LoopField, % Options
        }
    }
}