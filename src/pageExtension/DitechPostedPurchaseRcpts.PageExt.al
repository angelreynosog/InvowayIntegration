pageextension 50101 "Ditech Posted Purchase Rcpts" extends "Posted Purchase Receipts"
{
    layout
    {
        addafter("No. Printed")
        {
            field("Ditech Invoway Timbrado"; Rec."Ditech Invoway Timbrado")
            {
                ToolTip = 'Indica si el documento esta timbrado en Invoway';
                Editable = true;
            }
            field("Ditech Invoway Error"; Rec."Ditech Invoway Error")
            {
                ToolTip = 'Indica el error al timbrar';
            }
        }
        // falta suscribir para que cuando se registre, se genere y probar con webservice directamente
    }
    actions
    {

        addafter(Dimensions)
        {
            action("Ditech Stamping")
            {
                ApplicationArea = All;
                Caption = 'Stamping Manual';
                ;
                ToolTip = 'Ejecuta el timbrado manual con Invoway';
                Visible = Not Rec."Ditech Invoway Timbrado";
                Image = Export;
                trigger OnAction()
                begin
                    if Confirm(Text001Lbl) then begin
                        RecordRef.GetTable(Rec);
                        DitechIntegration.ExecuteEInvoice(RecordRef, 2);
                    end;
                end;
            }
        }
    }

    var

        DitechIntegration: Codeunit "Ditech Integration";
        RecordRef: RecordRef;
        Text001Lbl: Label 'Do you want to send this document electronically?', comment = 'ESP="¿Desea enviar este documento electrónico?"';
}
