VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Sheet2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Sub ExtractVendorInfo()
    Dim sPath As String 'path of folder containing info
    Dim sFileName As String '
    Dim wsSummary As Worksheet 'worksheet to paste data to in this workbook
    Dim wsData As Worksheet 'sheet with data to copy
    Dim wb As Workbook 'workbooks to loop thorugh
    Dim nr As Long 'next row to add the data
    
    
    'Get the worksheet to add the info to
    Set wsSummary = ThisWorkbook.Worksheets("Vendor Info")
    
    'first row is 3
    nr = 3
    
    sPath = "C:\Users\shao\Desktop\乱堆\自学\myNotes\written_test\amazon\VBA Test\" '[COLOR=#ff0000][B]Change as required[/B][/COLOR]
    
    sFileName = Dir(sPath & "Company Profile*.xlsx")
    
    Do While sFileName <> ""
        'open workbook
        Set wb = Workbooks.Open(Filename:=sPath & sFileName, ReadOnly:=True)
        'get the sheet to copy from
        Set wsData = wb.Sheets("Vendor & Factory Profile")
        'get the data
        wsSummary.Range("A" & nr).Value = wsData.Range("B2").Value
        wsSummary.Range("B" & nr).Value = wsData.Range("I2").Value
        wsSummary.Range("C" & nr).Value = wsData.Range("B3").Value
        wsSummary.Range("D" & nr).Value = wsData.Range("C4").Value
        wsSummary.Range("E" & nr).Value = wsData.Range("H4").Value
        wsSummary.Range("F" & nr).Value = wsData.Range("E4").Value
        wsSummary.Range("G" & nr).Value = wsData.Range("J4").Value
        wsSummary.Range("H" & nr).Value = wsData.Range("I3").Value '
        wsSummary.Range("I" & nr).Value = wsData.Range("B8").Value '
        ' products
        wsSummary.Range("J" & nr).Value = wsData.Range("A14").Value & "," & wsData.Range("A15").Value & "," & wsData.Range("A16").Value & _
                                                    "," & wsData.Range("A17").Value & "," & wsData.Range("A18").Value
        wsSummary.Range("K" & nr).Value = wsData.Range("A14").Value & " --- Products (" & wsData.Range("E14").Value & "); Year of Exp (" & _
                                                    wsData.Range("I14").Value & "); % of Business (" & wsData.Range("K14").Value & ")"
        wsSummary.Range("L" & nr).Value = wsData.Range("A15").Value & " --- Products (" & wsData.Range("E15").Value & "); Year of Exp (" & _
                                                    wsData.Range("I15").Value & "); % of Business (" & wsData.Range("K15").Value & ")"
        wsSummary.Range("M" & nr).Value = wsData.Range("A16").Value & " --- Products (" & wsData.Range("E16").Value & "); Year of Exp (" & _
                                                    wsData.Range("I16").Value & "); % of Business (" & wsData.Range("K16").Value & ")"
        wsSummary.Range("N" & nr).Value = wsData.Range("A16").Value & " --- Products (" & wsData.Range("E16").Value & "); Year of Exp (" & _
                                                    wsData.Range("I16").Value & "); % of Business (" & wsData.Range("K16").Value & ")"
        ' customers
        wsSummary.Range("O" & nr).Value = wsData.Range("A20").Value & " --- (Product:" & wsData.Range("D20").Value & " ; Country: " & _
                                                    wsData.Range("I20").Value & "; Qty Shipped: " & wsData.Range("J20").Value & "); % of Business (" & _
                                                    wsData.Range("K20").Value & ")"
        wsSummary.Range("P" & nr).Value = wsData.Range("A21").Value & " --- (Product:" & wsData.Range("D21").Value & " ; Country: " & _
                                                    wsData.Range("I21").Value & "; Qty Shipped: " & wsData.Range("J21").Value & "); % of Business (" & _
                                                    wsData.Range("K21").Value & ")"
        wsSummary.Range("Q" & nr).Value = wsData.Range("A22").Value & " --- (Product:" & wsData.Range("D22").Value & " ; Country: " & _
                                                    wsData.Range("I22").Value & "; Qty Shipped: " & wsData.Range("J22").Value & "); % of Business (" & _
                                                    wsData.Range("K22").Value & ")"
        wsSummary.Range("R" & nr).Value = wsData.Range("A23").Value & " --- (Product:" & wsData.Range("D23").Value & " ; Country: " & _
                                                    wsData.Range("I23").Value & "; Qty Shipped: " & wsData.Range("J23").Value & "); % of Business (" & _
                                                    wsData.Range("K23").Value & ")"
        
        wsSummary.Range("V" & nr).Value = wsData.Range("B11").Value
        If wsData.Range("B11").Value = "Yes" Then wsSummary.Range("W" & nr).Value = wsData.Range("F11").Value
        wsSummary.Range("X" & nr).Value = wsData.Range("K24").Value
        wsSummary.Range("Y" & nr).Value = wsData.Range("B10").Value
        wsSummary.Range("Z" & nr).Value = wsData.Range("F10").Value
        wsSummary.Range("AA" & nr).Value = wsData.Range("J10").Value
        'get next row
        nr = nr + 1
        'close the workbook
        wb.Close
        'get next workbook name
        sFileName = Dir
    Loop
    
    
End Sub



Sub ExtractFactoryInfo()
    Dim sPath As String 'path of folder containing info
    Dim sFileName As String '
    Dim wsSummary As Worksheet 'worksheet to paste data to in this workbook
    Dim wsData As Worksheet 'sheet with data to copy
    Dim wb As Workbook 'workbooks to loop thorugh
    Dim nr As Long 'next row to add the data
    Dim i As Integer
    
    
    'Get the worksheet to add the info to
    Set wsSummary = ThisWorkbook.Worksheets("Factory Info")
    
    'first row is 4
    nr = 4
    
    sPath = "C:\Users\shao\Desktop\乱堆\自学\myNotes\written_test\amazon\VBA Test\" '[COLOR=#ff0000][B]Change as required[/B][/COLOR]
    
    sFileName = Dir(sPath & "Company Profile*.xlsx")
    
    Do While sFileName <> ""
        'open workbook
        Set wb = Workbooks.Open(Filename:=sPath & sFileName, ReadOnly:=True)
        'get the sheet to copy from
        Set wsData = wb.Sheets("Vendor & Factory Profile")
        i = 0
        Do While Not IsEmpty(wsData.Range("B" & 29 + 15 * i))
            'get the data
            wsSummary.Range("A" & nr).Value = wsData.Range("B2").Value
            wsSummary.Range("B" & nr).Value = wsData.Range("B" & 29 + 15 * i).Value
            wsSummary.Range("C" & nr).Value = wsData.Range("I" & 29 + 15 * i).Value
            'If Me.Controls("Check Box 36").Value = 1 Then
            '    wsSummary.Range("D" & nr).Value = wsData.Range("G" & 28 + 15 * i).Value
            'Else
            '    wsSummary.Range("D" & nr).Value = wsData.Range("H" & 28 + 15 * i).Value
            wsSummary.Range("E" & nr).Value = wsData.Range("B" & 30 + 15 * i).Value
            wsSummary.Range("F" & nr).Value = wsData.Range("C" & 31 + 15 * i).Value
            wsSummary.Range("G" & nr).Value = wsData.Range("H" & 31 + 15 * i).Value
            wsSummary.Range("H" & nr).Value = wsData.Range("E" & 31 + 15 * i).Value '
            wsSummary.Range("I" & nr).Value = wsData.Range("J" & 31 + 15 * i).Value '
            wsSummary.Range("J" & nr).Value = wsData.Range("I" & 30 + 15 * i).Value
            '
            wsSummary.Range("K" & nr).Value = wsData.Range("B" & 32 + 15 * i).Value
            wsSummary.Range("L" & nr).Value = wsData.Range("E" & 32 + 15 * i).Value
            wsSummary.Range("M" & nr).Value = wsData.Range("G" & 32 + 15 * i).Value
            wsSummary.Range("N" & nr).Value = wsData.Range("I" & 32 + 15 * i).Value
            wsSummary.Range("O" & nr).Value = wsData.Range("K" & 32 + 15 * i).Value
            
            '
            wsSummary.Range("P" & nr).Value = wsData.Range("B" & 33 + 15 * i).Value
            wsSummary.Range("Q" & nr).Value = wsData.Range("E" & 33 + 15 * i).Value
            wsSummary.Range("R" & nr).Value = wsData.Range("G" & 33 + 15 * i).Value
            wsSummary.Range("S" & nr).Value = wsData.Range("I" & 33 + 15 * i).Value
            wsSummary.Range("T" & nr).Value = wsData.Range("K" & 33 + 15 * i).Value
            '
            wsSummary.Range("U" & nr).Value = wsData.Range("B" & 34 + 15 * i).Value
            wsSummary.Range("V" & nr).Value = wsData.Range("E" & 34 + 15 * i).Value
            wsSummary.Range("W" & nr).Value = wsData.Range("G" & 34 + 15 * i).Value
            wsSummary.Range("X" & nr).Value = wsData.Range("I" & 34 + 15 * i).Value
            wsSummary.Range("Y" & nr).Value = wsData.Range("K" & 34 + 15 * i).Value
            'category
            wsSummary.Range("Z" & nr).Value = wsData.Range("A" & 37 + 15 * i).Value & " --- Products (" & wsData.Range("B" & 37 + 15 * i).Value & "); Year of Exp (" & _
                                              wsData.Range("D" & 37 + 15 * i).Value & "); % of Business (" & wsData.Range("E" & 37 + 15 * i).Value & ")"
            wsSummary.Range("AA" & nr).Value = wsData.Range("A" & 38 + 15 * i).Value & " --- Products (" & wsData.Range("B" & 38 + 15 * i).Value & "); Year of Exp (" & _
                                               wsData.Range("D" & 38 + 15 * i).Value & "); % of Business (" & wsData.Range("E" & 38 + 15 * i).Value & ")"
            wsSummary.Range("AB" & nr).Value = wsData.Range("A" & 39 + 15 * i).Value & " --- Products (" & wsData.Range("B" & 39 + 15 * i).Value & "); Year of Exp (" & _
                                               wsData.Range("D" & 39 + 15 * i).Value & "); % of Business (" & wsData.Range("E" & 39 + 15 * i).Value & ")"
            ' EXPORT  NA40%; EU 40%; JP 10%; AUS/NEW Z 5%; IND 0%;  Others 5%
            wsSummary.Range("AC" & nr).Value = "NA " & wsData.Range("F" & 37 + 15 * i).Value & "; EU " & wsData.Range("G" & 37 + 15 * i).Value & "; JP" & _
                                                wsData.Range("H" & 37 + 15 * i).Value & "; AUS/NEW Z " & wsData.Range("I" & 37 + 15 * i).Value & "; IND " & _
                                                wsData.Range("G" & 37 + 15 * i).Value & "; Others " & wsData.Range("K" & 37 + 15 * i).Value
            wsSummary.Range("AD" & nr).Value = "NA " & wsData.Range("F" & 38 + 15 * i).Value & "; EU " & wsData.Range("G" & 38 + 15 * i).Value & "; JP" & _
                                                wsData.Range("H" & 38 + 15 * i).Value & "; AUS/NEW Z " & wsData.Range("I" & 38 + 15 * i).Value & "; IND " & _
                                                wsData.Range("G" & 38 + 15 * i).Value & "; Others " & wsData.Range("K" & 38 + 15 * i).Value
            wsSummary.Range("AE" & nr).Value = "NA " & wsData.Range("F" & 39 + 15 * i).Value & "; EU " & wsData.Range("G" & 39 + 15 * i).Value & "; JP" & _
                                                wsData.Range("H" & 39 + 15 * i).Value & "; AUS/NEW Z " & wsData.Range("I" & 39 + 15 * i).Value & "; IND " & _
                                                wsData.Range("G" & 39 + 15 * i).Value & "; Others " & wsData.Range("K39").Value
            wsSummary.Range("AF" & nr).Value = wsData.Range("C" & 37 + 15 * i).Value
            wsSummary.Range("AG" & nr).Value = wsData.Range("A" & 37 + 15 * i).Value
            wsSummary.Range("AH" & nr).Value = wsData.Range("F" & 37 + 15 * i).Value
            wsSummary.Range("AI" & nr).Value = wsData.Range("G" & 37 + 15 * i).Value
            wsSummary.Range("AJ" & nr).Value = wsData.Range("H" & 37 + 15 * i).Value
            wsSummary.Range("AK" & nr).Value = wsData.Range("I" & 37 + 15 * i).Value
            wsSummary.Range("AL" & nr).Value = wsData.Range("J" & 37 + 15 * i).Value
            wsSummary.Range("AM" & nr).Value = wsData.Range("K" & 37 + 15 * i).Value
            'get next row
            nr = nr + 1
            i = i + 1
            
        Loop
        'close the workbook
        wb.Close
        'get next workbook name
        sFileName = Dir
    Loop
    
    
End Sub


Sub ExtractContactInfo()
    Dim sPath As String 'path of folder containing info
    Dim sFileName As String '
    Dim wsSummary As Worksheet 'worksheet to paste data to in this workbook
    Dim wsData As Worksheet 'sheet with data to copy
    Dim wb As Workbook 'workbooks to loop thorugh
    Dim nr As Long 'next row to add the data
    Dim i As Integer
    
    'Get the worksheet to add the info to
    Set wsSummary = ThisWorkbook.Worksheets("Contact Info")
    
    'first row is 3
    nr = 5
    
    sPath = "C:\Users\shao\Desktop\乱堆\自学\myNotes\written_test\amazon\VBA Test\" '[COLOR=#ff0000][B]Change as required[/B][/COLOR]
    
    sFileName = Dir(sPath & "Company Profile*.xlsx")
    
    Do While sFileName <> ""
        'open workbook
        Set wb = Workbooks.Open(Filename:=sPath & sFileName, ReadOnly:=True)
        'get the sheet to copy from
        Set wsData = wb.Sheets("Vendor & Factory Profile")
        'get the data
        
        For i = 0 To 2:
            wsSummary.Range("A" & nr + i).Value = wsData.Range("B2").Value
            wsSummary.Range("B" & nr + i).Value = wsData.Range("B" & 5 + i).Value
            If InStr(1, wsSummary.Range("E" & nr + i), "Director") Then
                wsSummary.Range("C" & nr + i).Value = "No"
                wsSummary.Range("D" & nr + i).Value = "TRUE"
            ElseIf InStr(1, wsSummary.Range("E" & nr + i), "Manager") Then
                wsSummary.Range("C" & nr + i).Value = "Yes"
                wsSummary.Range("D" & nr + i).Value = "FALSE"
            Else
                wsSummary.Range("C" & nr + i).Value = "No"
                wsSummary.Range("D" & nr + i).Value = "FALSE"
            End If
            
            
            wsSummary.Range("E" & nr + i).Value = wsData.Range("E" & 5 + i).Value
            wsSummary.Range("F" & nr + i).Value = wsData.Range("G" & 5 + i).Value
            wsSummary.Range("G" & nr + i).Value = wsData.Range("I" & 5 + i).Value
            wsSummary.Range("H" & nr + i).Value = wsData.Range("K" & 5 + i).Value
        Next
        
        'get next company
        nr = nr + 3
        
        'close the workbook
        wb.Close
        'get next workbook name
        sFileName = Dir
    Loop
    
    
End Sub



