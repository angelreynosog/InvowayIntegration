table 50102 "Ditech Tracking WS"
{
    Caption = 'Tracking WS', comment = 'ESP="Trazabilidad Web Services"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "WS Type"; Enum "Ditech Type WS")
        {
            Caption = 'Type WS', comment = 'ESP="Tipo Servicio Web"';
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.', comment = 'ESP="No. Documento"';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.', comment = 'ESP="No. Línea"';
            DataClassification = CustomerContent;
        }
        field(4; "Code WS"; Text[10])
        {
            Caption = 'Code WS', comment = 'ESP="Código WS"';
            DataClassification = CustomerContent;
        }
        field(5; "Message WS"; Text[1500])
        {
            Caption = 'Message WS', comment = 'ESP="Mensaje WS"';
            DataClassification = CustomerContent;
        }
        field(6; "Process Date Time"; DateTime)
        {
            Caption = 'Process Date Time', comment = 'ESP="Fecha y hora proceso"';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "WS Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

}