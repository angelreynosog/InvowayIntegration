enum 50100 "Ditech WS Setup Environment"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Comment = 'ESP=" "';
    }
    value(1; "Live")
    {
        Caption = 'Live', Comment = 'ESP="Producción"';
    }
    value(2; "Test")
    {
        Caption = 'Test', Comment = 'ESP="Pruebas"';
    }
}