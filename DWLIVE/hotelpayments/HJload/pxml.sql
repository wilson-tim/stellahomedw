CREATE OR REPLACE Package dw.xml as

-- parse and return xml document

Procedure parse(xml       In  Bfile,
               wellFormed Out Boolean,
               error      Out Varchar2,
               retDoc     Out sys.xmldom.DOMDocument ) ;

-- Free the memory used by xml document
Procedure freedocument(doc sys.xmldom.DOMDocument);

End ;
/
show err

Create or Replace Package body xml as

 parse_error Exception;
 Pragma Exception_init(parse_error,-20100);
-- http_proxy_port varchar2(5) := '80';

----------------------------------------------------------------------------------------------
-- Parse Procedure parse an xml document and returns
--         a handle to the in-memory DOM document representation of the parsed xml.
--         error message if the document is not well formed
-- 
-- Call freedocument() when you are done using the document returned by above procedure.
----------------------------------------------------------------------------------------------
-- Changed from function to procedure to return two extra parameter - wellFormed and error

Procedure parse(xml       In  Bfile,
               wellFormed Out Boolean,
               error      Out Varchar2,
               retDoc     Out sys.xmldom.DOMDocument )  Is

 parser sys.xmlparser.Parser;
 b Bfile := xml;
 c CLOB;
 v_exist  Float;

Begin

-- JR, Added extra check if file exists then only proceed
        v_exist := sys.dbms_lob.FileExists(xml);
        
        If (xml is null) or (v_exist = 0 ) then 
                wellFormed := NULL;
                return;
        --              Error := 'File input parameter is Null'; 
        End if;

        parser := sys.xmlparser.newParser;
        dbms_lob.createtemporary(c,cache=>FALSE);
        dbms_lob.fileOpen(b);
        dbms_lob.loadFromFile(dest_lob => c,
                              src_lob => b,
                              amount => dbms_lob.getlength(b));
        dbms_lob.fileclose(b);
        sys.xmlparser.parseCLOB(parser,c);
        retDoc := sys.xmlparser.getDocument(parser);
        dbms_lob.freetemporary(c);
        sys.xmlparser.freeParser(parser);

     -- If the parse succeeds , we will get here
        wellFormed := TRUE;

Exception
        When parse_error then
                dbms_lob.freetemporary(c);
          sys.xmlparser.freeParser(parser);
                wellFormed := FALSE;
                error := SQLERRM;

End;

---------------------------------------------------------------------------------------
-- Free the Java objects associated ith an in-memory DOM tree
Procedure freeDocument(doc sys.xmldom.DOMDocument) Is

Begin
        sys.xmldom.freeDocument(doc);

End ;

End ;

/
show err






