page 50100 "Ditech Web Services Setup"
{
    Caption = 'Web Services Setup Invoway', comment = 'ESM="Configuración Servicio Web Invoway"';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Ditech Web Services Setup";


    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Active; Rec.Active)
                {
                    ToolTip = 'Specifies the value of the Active field.', comment = 'ESP="Especifica el valor para el campo Activo."';
                    ApplicationArea = All;
                }
                field(Environment; Rec.Environment)
                {
                    ToolTip = 'Specifies the value of the Environment field.', comment = 'ESP="Especifica el valor para el campo Entorno."';
                    ApplicationArea = All;
                }
                field(Decimals; Rec.Decimals)
                {
                    ToolTip = 'Specifies the value of the Decimals field.', comment = 'ESP="Especifica el valor para el campo Decimales."';
                    ApplicationArea = All;
                }
                field("Date Format"; Rec."Date Format")
                {
                    ToolTip = 'Specifies the value of the Date Format field.', comment = 'ESP="Especifica el valor para el campo Formato Fecha."';
                    ApplicationArea = All;
                }
                field("Show XML"; Rec."Show XML")
                {
                    ToolTip = 'Specifies the value of the Show XML field.', comment = 'ESP="Especifica el valor para el campo Mostrar XML."';
                    ApplicationArea = All;
                }
            }
            group(Credencial)
            {
                field("Company Id"; Rec."Company Id")
                {
                    ToolTip = 'Specifies the value of the Company Id field.', comment = 'ESP="Especifica el valor para el campo Id compañia."';
                    ApplicationArea = All;
                }
                field(User; Rec.User)
                {
                    ToolTip = 'Specifies the value of the User field.', comment = 'ESP="Especifica el valor para el campo Usuario."';
                    ApplicationArea = All;
                }
                field(Password; Rec.Password)
                {
                    ToolTip = 'Specifies the value of the Password field.', comment = 'ESP="Especifica el valor para el campo Contraseña."';
                    ExtendedDatatype = Masked;
                    ApplicationArea = All;
                }
                field("Web Address PO"; Rec."Web Address PO")
                {
                    ToolTip = 'Specifies the value of the Web Address PO field.', comment = 'ESP="Especifica el valor para el campo Dirección Web orden de compra."';
                    ApplicationArea = All;
                }
                field("Web Address INV"; Rec."Web Address INV")
                {
                    ToolTip = 'Specifies the value of the Web Address INV field.', comment = 'ESP="Especifica el valor para el campo Dirección Web Entrada inventario."';
                    ApplicationArea = All;
                }
                field("Web Address Document"; Rec."Web Address Document")
                {
                    ToolTip = 'Specifies the value of the Web Address Document field.', comment = 'ESP="Especifica el valor para el campo Dirección Web Documentos."';
                    ApplicationArea = All;
                }
                field("Web Address Admnistration"; Rec."Web Address Admnistration")
                {
                    ToolTip = 'Specifies the value of the Web Address Admnistration field.', comment = 'ESP="Especifica el valor para el campo Dirección Web Administración."';
                    ApplicationArea = All;
                }
            }
        }
    }
}