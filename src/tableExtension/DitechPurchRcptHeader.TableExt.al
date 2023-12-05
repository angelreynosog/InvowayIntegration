tableextension 50100 "Ditech Purch Rcpt Header" extends "Purch. Rcpt. Header"
{
    fields
    {
        field(50100; "Ditech Invoway Timbrado"; Boolean)
        {
            Caption = 'Invoway Timbrado';
            DataClassification = CustomerContent;
        }
        field(50101; "Ditech Invoway Error"; Text[500])
        {
            Caption = 'Invoway Error';
            DataClassification = CustomerContent;
        }
    }
}
