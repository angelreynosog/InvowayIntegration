table 50100 "Ditech Web Services Setup"
{
    Caption = 'Web Services Setup Invoway', comment = 'ESM="Configuración Servicio Web Invoway"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
            Caption = 'Primary Key', comment = 'ESM="Clave Primaria"';
            DataClassification = CustomerContent;
        }
        field(2; Active; Boolean)
        {
            Caption = 'Active', comment = 'ESM="Activo"';
            DataClassification = CustomerContent;
        }
        field(3; Environment; Enum "Ditech WS Setup Environment")
        {
            Caption = 'Environment', comment = 'ESM="Entorno"';
            DataClassification = CustomerContent;
        }
        field(5; User; Text[100])
        {
            Caption = 'User', comment = 'ESM="Usuario"';
            DataClassification = CustomerContent;
        }
        field(6; Password; Text[100])
        {
            Caption = 'Password', comment = 'ESM="Contraseña"';
            DataClassification = CustomerContent;
        }
        field(7; "Company Id"; Text[100])
        {
            Caption = 'Company Id', comment = 'ESM="Id Compañía"';
            DataClassification = CustomerContent;
        }
        field(8; Decimals; Enum "Ditech WS Setup Decimals")
        {
            Caption = 'Decimals', comment = 'ESM="Decimales"';
            DataClassification = CustomerContent;
        }
        field(9; "Date Format"; Enum "Ditech WS Setup Date Format")
        {
            Caption = 'Date Format', comment = 'ESM="Formato Fecha"';
            DataClassification = CustomerContent;
        }
        field(10; "Show XML"; Boolean)
        {
            Caption = 'Show XML', comment = 'ESM="Mostrar XML"';
            DataClassification = CustomerContent;
        }
        field(11; "Web Address PO"; Text[250])
        {
            Caption = 'Web Address PO', comment = 'ESM="Dirección Web ordenes de pedidos"';
            DataClassification = CustomerContent;
        }
        field(12; "Web Address INV"; Text[250])
        {
            Caption = 'Web Address INV', comment = 'ESM="Dirección Web Entrada mercancias"';
            DataClassification = CustomerContent;
        }
        field(13; "Web Address Document"; Text[250])
        {
            Caption = 'Web Address Document', comment = 'ESM="Dirección Web Documentos"';
            DataClassification = CustomerContent;
        }
        field(14; "Web Address Admnistration"; Text[250])
        {
            Caption = 'Web Address Admnistration', comment = 'ESM="Dirección Web Administratición"';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; PrimaryKey)
        {
            Clustered = true;
        }
    }

}