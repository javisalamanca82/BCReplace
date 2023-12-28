// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

/// <summary>
/// PageExtension CustomerListExt (ID 50101) extends Record Customer List.
/// </summary>
pageextension 50000 CustomerListExt extends "Customer List"
{
    actions
    {
        addlast(processing)
        {
            action(Replace)
            {
                Caption = 'Replace';
                ApplicationArea = All;

                trigger OnAction();
                var
                    ReplacePage: Page "Replace Dialog";
                begin
                    ReplacePage.SetNewRecord(Rec, '');
                    ReplacePage.RunModal()
                end;
            }
        }
    }
}