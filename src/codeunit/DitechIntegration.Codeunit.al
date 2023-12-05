codeunit 50100 "Ditech Integration"
{


    procedure ExecuteEInvoice(RecordRef: RecordRef; DocType: Integer)
    var
        FileName: Text;
    begin

        if not DitechWebServicesSetup.Get() then
            exit;
        if not CompanyInformation.Get() then
            exit;
        if not GeneralLedgerSetup.Get() then
            exit;

        case DocType of
            1:
                begin
                    RecordRef.SetTable(PurchaseHeader);

                    if not Vendor.Get(PurchaseHeader."Pay-to Vendor No.") then
                        exit;

                    PurchaseHeader.CalcFields(Amount, "Amount Including VAT");
                    DocumentNo := PurchaseHeader."No.";
                    PostingDate := PurchaseHeader."Posting Date";
                    DueDate := PurchaseHeader."Due Date";
                    VendorNo := PurchaseHeader."Pay-to Vendor No.";
                    if PurchaseHeader."Currency Code" <> '' then
                        CurrencyCode := PurchaseHeader."Currency Code"
                    else
                        CurrencyCode := GeneralLedgerSetup."LCY Code";
                    StatusPO := Format(PurchaseHeader.Status);
                    InvAmount := PurchaseHeader.Amount;
                    indIlimitado := 'N';
                    indImpuesto := GetTax(DocumentNo, PostingDate);
                end;
            2:
                begin
                    RecordRef.SetTable(PurchRcptHeader);

                    if not Vendor.Get(PurchRcptHeader."Pay-to Vendor No.") then
                        exit;

                    DocumentNo := PurchRcptHeader."No.";
                    PostingDate := PurchRcptHeader."Posting Date";
                    DueDate := PurchRcptHeader."Due Date";
                    VendorNo := PurchRcptHeader."Pay-to Vendor No.";
                    VendorOrderNo := PurchRcptHeader."Vendor Order No.";
                    VendorShipmentNo := PurchRcptHeader."Vendor Shipment No.";
                    OrderNo := PurchRcptHeader."Order No.";
                    if PurchRcptHeader."Currency Code" <> '' then
                        CurrencyCode := PurchRcptHeader."Currency Code"
                    else
                        CurrencyCode := GeneralLedgerSetup."LCY Code";
                    indIlimitado := 'N';
                end;
        end;

        if DitechWebServicesSetup.Active then begin
            ValidateFields(DocType, VendorNo);
            CreateXMLStructure(DocType);
            CallWebServices(DocType);
            DownloadFileXML();
        end;
    end;

    local procedure ValidateFields(DocType: Integer; VendorNo: Code[20])
    begin
        if not DitechWebServicesSetup.Get() then
            exit;
        if not CompanyInformation.Get() then
            exit;
        if not Vendor.Get(VendorNo) then
            exit;

        DitechWebServicesSetup.TestField(User);
        DitechWebServicesSetup.TestField(Password);
        DitechWebServicesSetup.TestField("Company Id");
        case DocType of
            1:
                DitechWebServicesSetup.TestField("Web Address PO");
            2:
                DitechWebServicesSetup.TestField("Web Address INV");
        end;

        PostCode.Get(Vendor."Post Code", Vendor.City);
    end;

    local procedure CreateXMLStructure(DocType: Integer)
    begin
        case DocType of
            1:
                begin
                    TextBuilder.Clear();
                    TextBuilder.Append('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pos="poService">');
                    TextBuilder.Append('<soapenv:Body>');
                    TextBuilder.Append('<pos:setPO>');
                    TextBuilder.Append('<pos:request>');
                    TextBuilder.Append('<idFiscalCliente>' + CompanyInformation."VAT Registration No." + '</idFiscalCliente>');
                    TextBuilder.Append('<pedido>');
                    TextBuilder.Append('<divisa>' + CurrencyCode + '</divisa>');
                    TextBuilder.Append('<estado>' + StatusPO + '</estado>');
                    TextBuilder.Append('<fechaFin>' + SetDateFormat(DueDate) + '</fechaFin>');
                    TextBuilder.Append('<fechaInicio>' + SetDateFormat(PostingDate) + '</fechaInicio>');
                    TextBuilder.Append('<idPedido>' + DocumentNo + '</idPedido>');
                    TextBuilder.Append('<importe>' + SetAmountFormat(InvAmount) + '</importe>');
                    TextBuilder.Append('<indIlimitado>' + indIlimitado + '</indIlimitado>');
                    TextBuilder.Append('<indImpuesto>' + indImpuesto + '</indImpuesto>');
                    TextBuilder.Append('<indMultiProv>' + '' + '</indMultiProv>');
                    TextBuilder.Append('<lineas>');
                    case DocType of
                        1:
                            begin
                                SelectLines(DocType);
                                LineNo := 0;
                                repeat
                                    LineNo += 1;
                                    TextBuilder.Append('<linea>');
                                    TextBuilder.Append('<codigoImpuestoLinea>' + '' + '</codigoImpuestoLinea>');
                                    TextBuilder.Append('<descripcion>' + PurchaseLine.Description + '</descripcion>');
                                    TextBuilder.Append('<numeroLinea>' + Format(LineNo) + '</numeroLinea>');
                                    TextBuilder.Append('<porcentajeImpuestoLinea>' + SetAmountFormat(PurchaseLine."VAT %") + '</porcentajeImpuestoLinea>');
                                    TextBuilder.Append('<precioUnidad>' + SetAmountFormat(PurchaseLine.Amount) + '</precioUnidad>');
                                    TextBuilder.Append('<referenciaItem>' + PurchaseLine."No." + '</referenciaItem>');
                                    TextBuilder.Append('<totalLinea>' + SetAmountFormat(PurchaseLine."Amount Including VAT") + '</totalLinea>');
                                    TextBuilder.Append('<unidadesLinea>' + SetAmountFormat(PurchaseLine.Quantity) + '</unidadesLinea>');
                                    TextBuilder.Append('<unidadesLinea>' + SetAmountFormat(PurchaseLine."Amount Including VAT" - PurchaseLine.Amount) + '</unidadesLinea>');
                                    TextBuilder.Append('</linea>');
                                until PurchaseLine.Next() = 0;
                            end;
                    end;
                    TextBuilder.Append('</lineas>');
                    TextBuilder.Append('<proveedor>');
                    TextBuilder.Append('<ciudadProveedor>' + PostCode.City + '</ciudadProveedor>');
                    TextBuilder.Append('<codigoCategoria>' + '' + '</codigoCategoria>');
                    TextBuilder.Append('<codigoPostalProveedor>' + Vendor."Post Code" + '</codigoPostalProveedor>');
                    TextBuilder.Append('<codigoProveedorERP>' + Vendor."No." + '</codigoProveedorERP>');
                    TextBuilder.Append('<dcProveedor>' + '' + '</dcProveedor>');
                    TextBuilder.Append('<departamentoProveedor>' + PostCode.County + '</departamentoProveedor>');
                    TextBuilder.Append('<direccionProveedor>' + Vendor.Address + ' ' + Vendor."Address 2" + '</direccionProveedor>');
                    TextBuilder.Append('<emailProveedor>' + Vendor."E-Mail" + '</emailProveedor>');
                    TextBuilder.Append('<idProveedor>' + Vendor."No." + '</idProveedor>');
                    TextBuilder.Append('<nombreProveedor>' + Vendor.Name + ' ' + Vendor."Name 2" + '</nombreProveedor>');
                    TextBuilder.Append('<paisProveedor>' + Vendor."Country/Region Code" + '</paisProveedor>');
                    TextBuilder.Append('<telefonoProveedor>' + Vendor."Phone No." + '</telefonoProveedor>');
                    TextBuilder.Append('<tipoDocumentoIdProveedor>' + '' + '</tipoDocumentoIdProveedor>');
                    TextBuilder.Append('<tipoPersonaProveedor>' + '' + '</tipoPersonaProveedor>');
                    TextBuilder.Append('</proveedor>');
                    TextBuilder.Append('<saldo>' + SetAmountFormat(InvAmount) + '</saldo>');
                    TextBuilder.Append('<tipoPedido>' + '' + '</tipoPedido>');
                    TextBuilder.Append('<unidadOrganizativa>' + '' + '</unidadOrganizativa>');
                    TextBuilder.Append('</pedido>');
                    TextBuilder.Append('</pos:request>');
                    TextBuilder.Append('</pos:setPO>');
                    TextBuilder.Append('</soapenv:Body>');
                    TextBuilder.Append('</soapenv:Envelope>');
                end;

            2:
                begin
                    TextBuilder.Clear();
                    TextBuilder.Append('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:good="goodsReceiptService">');
                    TextBuilder.Append('<soapenv:Body>');
                    TextBuilder.Append('<good:setGR>');
                    TextBuilder.Append('<good:request>');
                    TextBuilder.Append('<idFiscalCliente>' + CompanyInformation."VAT Registration No." + '</idFiscalCliente>');
                    TextBuilder.Append('<entrada>');
                    TextBuilder.Append('<divisa>' + CurrencyCode + '</divisa>');
                    TextBuilder.Append('<documentoProveedor>' + VendorOrderNo + '</documentoProveedor>');
                    TextBuilder.Append('<documentoTrasporte>' + VendorShipmentNo + '</documentoTrasporte>');
                    TextBuilder.Append('<fecha>' + SetDateFormat(PostingDate) + '</fecha>');
                    TextBuilder.Append('<idEntrada>' + DocumentNo + '</idEntrada>');
                    TextBuilder.Append('<idPedido>' + OrderNo + '</idPedido>');
                    TextBuilder.Append('<indImpuestos>' + indIlimitado + '</indImpuestos>');
                    TextBuilder.Append('<lineas>');
                    case DocType of
                        2:
                            begin
                                SelectLines(DocType);
                                LineNo := 0;
                                repeat
                                    LineNo += 1;
                                    TextBuilder.Append('<linea>');
                                    TextBuilder.Append('<numeroLinea>' + Format(PurchRcptLine."Line No.") + '</numeroLinea>');
                                    TextBuilder.Append('<referenciaItem>' + PurchRcptLine."No." + '</referenciaItem>');
                                    TextBuilder.Append('<descripcion>' + PurchRcptLine.Description + '</descripcion>');
                                    TextBuilder.Append('<unidadesLinea>' + SetAmountFormat(PurchRcptLine.Quantity) + '</unidadesLinea>');
                                    TextBuilder.Append('<precioUnidad>' + SetAmountFormat(PurchRcptLine."Unit Price (LCY)") + '</precioUnidad>');
                                    TextBuilder.Append('<totalLinea>' + SetAmountFormat(PurchRcptLine.Quantity * PurchRcptLine."Unit Price (LCY)") + '</totalLinea>');
                                    TextBuilder.Append('</linea>');
                                until PurchRcptLine.Next() = 0;
                            end;
                    end;
                    TextBuilder.Append('</lineas>');
                    TextBuilder.Append('<proveedor>');
                    TextBuilder.Append('<ciudadProveedor>' + PostCode.City + '</ciudadProveedor>');
                    TextBuilder.Append('<codigoCategoria>' + '' + '</codigoCategoria>');
                    TextBuilder.Append('<codigoPostalProveedor>' + Vendor."Post Code" + '</codigoPostalProveedor>');
                    TextBuilder.Append('<codigoProveedorERP>' + Vendor."No." + '</codigoProveedorERP>');
                    TextBuilder.Append('<dcProveedor>' + '' + '</dcProveedor>');
                    TextBuilder.Append('<departamentoProveedor>' + PostCode.County + '</departamentoProveedor>');
                    TextBuilder.Append('<direccionProveedor>' + Vendor.Address + ' ' + Vendor."Address 2" + '</direccionProveedor>');
                    TextBuilder.Append('<emailProveedor>' + Vendor."E-Mail" + '</emailProveedor>');
                    TextBuilder.Append('<idProveedor>' + Vendor."No." + '</idProveedor>');
                    TextBuilder.Append('<nombreProveedor>' + Vendor.Name + ' ' + Vendor."Name 2" + '</nombreProveedor>');
                    TextBuilder.Append('<paisProveedor>' + Vendor."Country/Region Code" + '</paisProveedor>');
                    TextBuilder.Append('<telefonoProveedor>' + Vendor."Phone No." + '</telefonoProveedor>');
                    TextBuilder.Append('<tipoDocumentoIdProveedor>' + '' + '</tipoDocumentoIdProveedor>');
                    TextBuilder.Append('<tipoPersonaProveedor>' + '' + '</tipoPersonaProveedor>');
                    TextBuilder.Append('</proveedor>');
                    TextBuilder.Append('<totalEntrada>' + Format(LineNo) + '</totalEntrada>');
                    TextBuilder.Append('<unidadOrganizativa>' + '' + '</unidadOrganizativa>');
                    TextBuilder.Append('</entrada>');
                    TextBuilder.Append('</good:request>');
                    TextBuilder.Append('</good:setGR>');
                    TextBuilder.Append('</soapenv:Body>');
                    TextBuilder.Append('</soapenv:Envelope>');
                end;
        end;
    end;

    local procedure CallWebServices(DocType: Integer)
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        HttpContent: HttpContent;
        ResponseText: Text;
    begin
        if DitechWebServicesSetup."Show XML" then
            Message(TextBuilder.ToText());

        HttpContent.WriteFrom(TextBuilder.ToText());
        HttpContent.GetHeaders(Headers);
        Headers.Remove('Content-type');
        Headers.Add('Content-type', 'text/xml');
        case DocType of
            1:
                begin
                    Headers.Add('SOAPAction', 'setPO');
                    HttpRequestMessage.Content := HttpContent;
                    HttpRequestMessage.SetRequestUri(DitechWebServicesSetup."Web Address PO");
                end;
            2:
                begin
                    Headers.Add('SOAPAction', 'setGR');
                    HttpRequestMessage.Content := HttpContent;
                    HttpRequestMessage.SetRequestUri(DitechWebServicesSetup."Web Address INV");
                end;

        end;
        HttpRequestMessage.Method := 'POST';

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            HttpResponseMessage.Content().ReadAs(ResponseText);
            InsertTracking(DocumentNo, DocType, ResponseText);
            if DitechWebServicesSetup."Show XML" then
                Message(ResponseText);
        end else
            InsertTracking(DocumentNo, DocType, '<b:string>Error de conexión WS</b:string>');
    end;

    local procedure SetDateFormat(DateNoFormat: Date): Text[20]
    var
        ValueText: Text;
        DateDummy: Date;
        DayText: Text[2];
        MonthText: Text[2];
        Day: Integer;
        Month: Integer;
        Year: Integer;
    begin

        Evaluate(ValueText, Format(DateNoFormat));

        if ValueText <> '' then begin
            Evaluate(DateDummy, ValueText);
            Day := Date2DMY(DateDummy, 1);
            Month := Date2DMY(DateDummy, 2);
            Year := Date2DMY(DateDummy, 3);

            if Day < 10 then
                Evaluate(DayText, '0' + Format(Day))
            else
                Evaluate(DayText, Format(Day));

            if Month < 10 then
                Evaluate(MonthText, '0' + Format(Month))
            else
                Evaluate(MonthText, Format(Month));

            case DitechWebServicesSetup."Date Format" of
                DitechWebServicesSetup."Date Format"::"DD-MM-YYYY":
                    ValueText := (DayText + '-' + MonthText + '-' + Format(Year));

                DitechWebServicesSetup."Date Format"::"DD-MM-YY":
                    ValueText := (DayText + '-' + MonthText + '-' + Format(CopyStr(Format(Year), StrLen(Format(Year)) - 1, StrLen(Format(Year)))));

                DitechWebServicesSetup."Date Format"::"MM-DD-YYYY":
                    ValueText := (MonthText + '-' + DayText + '-' + Format(Year));

                DitechWebServicesSetup."Date Format"::"MM-DD-YY":
                    ValueText := (MonthText + '-' + DayText + '-' + Format(CopyStr(Format(Year), StrLen(Format(Year)) - 1, StrLen(Format(Year)))));

                DitechWebServicesSetup."Date Format"::"YYYY-MM-DD":
                    ValueText := (Format(Year) + '-' + MonthText + '-' + DayText);
            end;
        end;

        exit(CopyStr(ValueText, 1, 20));
    end;

    local procedure SetAmountFormat(AmountNoFormat: Decimal): Text[20]
    var
        Dec: Decimal;
        ValueText: Text[20];
        DecimalSeparatorTxt: Text[1];
        ThousandSeparatorTxt: Text[1];
        IntegerText: Text[20];
        DecimalText: Text[20];
        Dec2Lbl: Label '00';
        Dec3Lbl: Label '000';
        Dec4Lbl: Label '0000';
        Dec5Lbl: Label '00000';
        Dec6Lbl: Label '000000';
    begin

        Dec := SetDecimals();
        AmountNoFormat := Round(AmountNoFormat, Dec);
        Evaluate(ValueText, Format(AmountNoFormat));
        DecimalSeparatorTxt := CopyStr(DelChr(Format(1 / 10), '=', '01'), 1, 1);

        if DecimalSeparatorTxt = '.' then
            ThousandSeparatorTxt := ','
        else
            ThousandSeparatorTxt := '.';

        if StrPos(ValueText, DecimalSeparatorTxt) <> 0 then begin
            IntegerText := CopyStr(CopyStr(ValueText, 1, StrPos(ValueText, DecimalSeparatorTxt) - 1), 1, 20);
            DecimalText := CopyStr(ValueText, StrPos(ValueText, DecimalSeparatorTxt), StrLen(ValueText));
        end else begin
            IntegerText := ValueText;
            case DitechWebServicesSetup.Decimals of
                DitechWebServicesSetup.Decimals::"2":
                    DecimalText := Dec2Lbl;
                DitechWebServicesSetup.Decimals::"3":
                    DecimalText := Dec3Lbl;
                DitechWebServicesSetup.Decimals::"4":
                    DecimalText := Dec4Lbl;
                DitechWebServicesSetup.Decimals::"5":
                    DecimalText := Dec5Lbl;
                DitechWebServicesSetup.Decimals::"6":
                    DecimalText := Dec6Lbl;
            end;
        end;
        ValueText := CopyStr(DelChr(IntegerText, '=', ThousandSeparatorTxt) + '.' + DelChr(DecimalText, '=', DecimalSeparatorTxt), 1, 20);
        exit(ValueText);
    end;

    local procedure SetDecimals() Dec: Decimal
    begin
        case DitechWebServicesSetup.Decimals of
            DitechWebServicesSetup.Decimals::"2":
                Dec := 1 / 100;
            DitechWebServicesSetup.Decimals::"3":
                Dec := 1 / 1000;
            DitechWebServicesSetup.Decimals::"4":
                Dec := 1 / 10000;
            DitechWebServicesSetup.Decimals::"5":
                Dec := 1 / 100000;
            DitechWebServicesSetup.Decimals::"6":
                Dec := 1 / 1000000;
        end;
        exit(Dec);
    end;

    local procedure GetTax(DocumentNo: Code[20]; PostingDate: Date): Text[1]
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.Reset();
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", DocumentNo);
        VATEntry.SetRange("Posting Date", PostingDate);
        VATEntry.SetRange(Type, VATEntry.Type::Purchase);
        if not VATEntry.IsEmpty then
            exit('S')
        else
            exit('N');
    end;

    local procedure SelectLines(DocType: Integer)
    begin
        case DocType of
            1:
                begin
                    PurchaseLine.Reset();
                    PurchaseLine.SetRange(PurchaseLine."Document No.", PurchaseHeader."No.");
                    PurchaseLine.SetFilter(Quantity, '<>%1', 0);
                    PurchaseLine.FindSet();
                end;
            2:
                begin
                    PurchRcptLine.Reset();
                    PurchRcptLine.SetRange(PurchRcptLine."Document No.", PurchRcptHeader."No.");
                    PurchRcptLine.SetFilter(Quantity, '<>%1', 0);
                    PurchRcptLine.FindSet();
                end;
        end;
    end;

    local procedure InsertTracking(DocumentNo: Code[20]; DocType: Integer; ResponseText: Text)
    var
        DitechTrackingWS: Record "Ditech Tracking WS";
        DitechTypeWS: Enum "Ditech Type WS";
        CodeWS: Text;
        MessageWS: Text;

    begin
        CodeWS := GetResponse(ResponseText, '<code>', '</code>', 10);
        MessageWS := GetResponse(ResponseText, '<message>>', '</message>>', 1500);

        DitechTrackingWS.Init();
        DitechTrackingWS."WS Type" := Enum::"Ditech Type WS".FromInteger(DocType);
        DitechTrackingWS."Document No." := DocumentNo;
        DitechTrackingWS."Line No." := ValidateLineTracking(DocumentNo);
        DitechTrackingWS."Code WS" := CopyStr(CodeWS, 1, 10);
        DitechTrackingWS."Message WS" := CopyStr(MessageWS, 1, 1500);
        DitechTrackingWS."Process Date Time" := CurrentDateTime;
        DitechTrackingWS.Insert();
    end;

    local procedure GetResponse(XML: Text; TAGIni: Text[100]; TAGFin: Text[100]; Len: Integer): Text
    var
        String: Text;
        PosIni: Integer;
        PosFin: Integer;
    begin
        PosIni := StrPos(XML, TAGini) + StrLen(TAGini);
        PosFin := StrPos(XML, TAGfin) - PosIni;
        if (PosIni <> 0) and (PosFin > 0) then begin
            String := CopyStr(XML, PosIni, PosFin);
            exit(CopyStr(String, 1, Len));
        end;
        exit('');
    end;

    local procedure ValidateLineTracking(DocumentNo: Code[20]): Integer
    var
        DitechTrackingWS: Record "Ditech Tracking WS";
        LineNo: Integer;
    begin
        Clear(LineNo);
        DitechTrackingWS.Reset();
        DitechTrackingWS.SetCurrentKey("Document No.", "Line No.");
        DitechTrackingWS.SetRange("Document No.", DocumentNo);
        if DitechTrackingWS.FindLast() then
            LineNo := DitechTrackingWS."Line No." + 10000
        else
            LineNo := 10000;
        exit(LineNo);
    end;

    local procedure DownloadFileXML()
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        FileName: Text;
    begin
        FileName := 'POServices' + Format(CurrentDateTime) + '.xml';
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(TextBuilder.ToText());
        TempBlob.CreateInStream(InStream);
        DownloadFromStream(InStream, '', '', '', FileName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure OnAfterPostPurchaseDoc(PurchRcpHdrNo: Code[20])
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        RecordRef: RecordRef;
    begin

        if PurchRcpHdrNo <> '' then
            if PurchRcptHeader.Get(PurchRcpHdrNo) then
                if not PurchRcptHeader."Ditech Invoway Timbrado" then
                    ExecuteEInvoice(RecordRef, 2);
    end;


    var
        DitechWebServicesSetup: Record "Ditech Web Services Setup";
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchRcptHeader: record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        Vendor: Record Vendor;
        PostCode: Record "Post Code";
        TextBuilder: TextBuilder;
        DocumentNo: Code[20];
        VendorNo: Code[20];
        CurrencyCode: Code[10];
        VendorOrderNo: Code[35];
        VendorShipmentNo: Code[35];
        OrderNo: Code[20];
        StatusPO: Text[20];
        indIlimitado: Text[1];
        indImpuesto: Text[1];
        LineNo: Integer;
        PostingDate: Date;
        DueDate: Date;
        InvAmount: Decimal;

}