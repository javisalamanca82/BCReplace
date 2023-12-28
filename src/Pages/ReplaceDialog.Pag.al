/// <summary>
/// Page Replace Dialog (ID 50100).
/// </summary>
page 50000 "Replace Dialog"
{
    Caption = 'Replace';
    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(FieldNo; Field."Field Caption")
                {
                    Caption = 'Replace Field';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ReplaceManagement.OnFieldCaptionValidate(Field, RecRef, FieldRef, NewValueAsText);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        ReplaceManagement.OnFieldCaptionLookUp(Field, RecRef, FieldRef, NewValueAsText);
                    end;
                }
                field(NewValueAsText; NewValueAsText)
                {
                    Caption = 'New value as Text';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ReplaceManagement.OnValidateNewValueAsText(FieldRef, NewValueAsText);
                    end;
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        ReplaceManagement.ReplaceRecords(CloseAction, RecRef, Field."No.", NewValueAsText);
    end;

    /// <summary>
    /// GetRecord.
    /// </summary>
    /// <param name="MyRecord">VAR Variant.</param>
    /// <param name="FieldNoFilter">Text.</param>
    procedure SetNewRecord(MyRecord: Variant; FieldNoFilter: Text)
    begin
        ReplaceManagement.GetFieldRecord(Field, MyRecord, RecRef, FieldNoFilter);
    end;

    var
        Field: Record Field;
        ReplaceManagement: Codeunit ReplaceManagement;
        NewValueAsText: Text;
        RecRef: RecordRef;
        FieldRef: FieldRef;
}