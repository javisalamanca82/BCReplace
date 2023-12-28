/// <summary>
/// Codeunit Replace Management (ID 50100).
/// </summary>
codeunit 50100 ReplaceManagement
{
    /// <summary>
    /// GetRecord.
    /// </summary>
    /// <param name="Field">VAR Field</param>
    /// <param name="MyRecord">VAR Variant.</param>
    /// <param name="RecRef">VAR RecordRef.</param>
    /// <param name="FieldNoFilter">Text.</param>
    procedure GetFieldRecord(var Field: Record Field; var MyRecord: Variant; var RecRef: RecordRef; FieldNoFilter: Text)
    var
        NotRecordErr: Label 'Replace functionality only works with objects type Record.';
    begin
        if not MyRecord.IsRecord then
            Error(NotRecordErr);

        RecRef.GetTable(MyRecord);
        Field.FilterGroup(2);
        Field.SetRange(TableNo, RecRef.Number);
        Field.SetFilter("No.", FieldNoFilter);
        Field.SetRange(Class, Field.Class::Normal);
        Field.Setfilter(
            Type,
            '%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11',
            Field.Type::Boolean,
            Field.Type::Code,
            Field.Type::Date,
            Field.Type::DateTime,
            Field.Type::DateFormula,
            Field.Type::Decimal,
            Field.Type::Duration,
            Field.Type::Integer,
            Field.Type::Option,
            Field.Type::Text,
            Field.Type::Time);
        Field.FilterGroup(0);
    end;

    /// <summary>
    /// OnFieldCaptionLookUp.
    /// </summary>
    /// <param name="Field">VAR Record Field.</param>
    /// <param name="RecRef">VAR RecordRef.</param>
    /// <param name="FieldRef">FieldREf.</param>
    /// <param name="NewValueAsText">VAR Text.</param>
    procedure OnFieldCaptionLookUp(var Field: Record Field; var RecRef: RecordRef; var FieldRef: FieldREf; var NewValueAsText: Text)
    var
        IsPKErr: Label 'Field %1 is part of the Primary Key of the record and cannot be replaced.';
    begin
        if Page.RunModal(Page::"Fields Lookup", Field) IN [Action::OK, Action::LookupOK, Action::Yes] then begin
            If ConfigValidateManagement.IsKeyField(Field.TableNo, Field."No.") then
                Error(IsPKErr, Field."Field Caption");
            FieldRef := RecRef.Field(Field."No.");
        end;
        Field.SetRange("Field Caption");
    end;

    /// <summary>
    /// OnFieldCaptionValidate.
    /// </summary>
    /// <param name="Field">VAR Record Field.</param>
    /// <param name="RecRef">VAR RecordRef.</param>
    /// <param name="FieldRef">VAR FieldREf.</param>
    /// <param name="NewValueAsText">VAR Text.</param>
    procedure OnFieldCaptionValidate(var Field: Record Field; var RecRef: RecordRef; var FieldRef: FieldREf; var NewValueAsText: Text)
    var
        FilterTxt: Text;
    begin
        FilterTxt := '*' + Field."Field Caption" + '*';
        Field.SetFilter("Field Caption", FilterTxt);
        OnFieldCaptionLookUp(Field, RecRef, FieldRef, NewValueAsText);
    end;


    /// <summary>
    /// OnValidateNewValueAsText.
    /// </summary>
    /// <param name="FieldRef">VAR FieldRef.</param>
    /// <param name="NewValueAsText">Text.</param>
    procedure OnValidateNewValueAsText(var FieldRef: FieldRef; NewValueAsText: Text)
    var
        EvaluateErr: Text;
    begin
        EvaluateErr := ConfigValidateManagement.EvaluateValueWithValidate(FieldRef, NewValueAsText, false);
        if EvaluateErr <> '' then
            Error(EvaluateErr);
    end;

    /// <summary>
    /// ReplaceRecords.
    /// </summary>
    /// <param name="CloseAction">Action.</param>
    /// <param name="RecRef">VAR RecordRef.</param>
    /// <param name="FieldNo">Integer, NewValueAsText.</param>
    /// <param name="NewValueAsText">Text.</param>
    procedure ReplaceRecords(CloseAction: Action; var RecRef: RecordRef; FieldNo: Integer; NewValueAsText: Text)
    var
        TotalRecords: Integer;
        i: Integer;
        FieldRef: FieldRef;
        Window: Dialog;
        ConfirmMsg: Label '%1 records are going to be replaced. Are you sure you want to continue?';
        ProgressBarMsg: Label 'Replacing records... @1@@@@@@@@@';
    begin
        if not (CloseAction in [Action::OK, Action::LookupOK, Action::Yes]) then
            exit;

        if NewValueAsText = '' then
            exit;

        TotalRecords := RecRef.Count;
        if not Confirm(ConfirmMsg, false, TotalRecords) then
            exit;

        Window.Open(ProgressBarMsg);
        RecRef.CurrentKeyIndex(1);
        if RecRef.FindSet() then
            repeat
                i += 1;
                Window.Update(1, Round(TotalRecords / i * 10000, 1));
                FieldRef := RecRef.Field(FieldNo);
                if Format(FieldRef.Value) <> NewValueAsText then begin
                    ConfigValidateManagement.ValidateFieldValue(RecRef, FieldRef, NewValueAsText, false, GlobalLanguage);
                    RecRef.Modify(true);
                end;
            until RecRef.Next() = 0;
        Window.Close();
    end;

    var
        ConfigValidateManagement: Codeunit "Config. Validate Management";
}