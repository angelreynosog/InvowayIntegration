pageextension 50100 "Ditech Purchase Order List" extends "Purchase Order List"
{
    actions
    {
        addlast(processing)
        {
            group("Ditech Purchase Orden Invoway")
            {
                Caption = 'Purchase Orden Invoway', comment = 'ESP="Orden compra Invoway"';
                Image = ElectronicRegister;

                action("Ditech Send E-Document")
                {
                    Caption = 'Purchase Orden', comment = 'ESP="Orden compra"';
                    ToolTip = 'Allows you to the Purchase Orden.', comment = 'ESP="Permite realizar el Orden compra."';
                    Image = ElectronicDoc;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        if Confirm(Text001Lbl) then begin
                            RecordRef.GetTable(Rec);
                            DitechIntegration.ExecuteEInvoice(RecordRef, 1);
                        end;
                    end;
                }
            }
        }
    }

    var

        DitechIntegration: Codeunit "Ditech Integration";
        RecordRef: RecordRef;
        Text001Lbl: Label 'Do you want to send this document electronically?', comment = 'ESP="¿Desea enviar este documento electrónico?"';
}