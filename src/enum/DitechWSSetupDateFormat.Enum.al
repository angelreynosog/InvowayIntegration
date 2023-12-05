enum 50102 "Ditech WS Setup Date Format"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Comment = 'ESP=" "';
    }
    value(1; "DD-MM-YYYY")
    {
        Caption = 'DD-MM-YYYY', Comment = 'ESP="DD-MM-YYYY"';
    }
    value(2; "DD-MM-YY")
    {
        Caption = 'DD-MM-YY', Comment = 'ESP="DD-MM-YY"';
    }
    value(3; "MM-DD-YYYY")
    {
        Caption = 'MM-DD-YYYY', Comment = 'ESP="MM-DD-YYYY"';
    }
    value(4; "MM-DD-YY")
    {
        Caption = 'MM-DD-YY', Comment = 'ESP="MM-DD-YY"';
    }
    value(5; "YYYY-MM-DD")
    {
        Caption = 'YYYY-MM-DD', Comment = 'ESP="YYYY-MM-DD"';
    }
}