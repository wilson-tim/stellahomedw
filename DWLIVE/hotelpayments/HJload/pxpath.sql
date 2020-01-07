CREATE OR REPLACE Package DW.xpath as
  
 -- Return the value of an Xpath expression , optionally normalizing whitespace


Function valueof(node           sys.xmldom.DOMNode,
                 xpath          varchar2,
                 normalize      Boolean := FALSE) return varchar2 ;

Function valueOf(doc            sys.xmldom.DOMDocument,
                 xpath          varchar2,
                 normalize      boolean:=FALSE) return varchar2; 

-- Extract an XML fragment for set of nodes matching an xpath pattern
-- 

Function extract (doc   sys.xmldom.DOMDocument,
                 xpath          varchar2:='/',
                 normalize      boolean:=TRUE) return varchar2; 


-- Select a list of nodes matching an Xpath
-- Note : DOMDocument returned has a zero based index

Function selectNodes(node               sys.xmldom.DOMNode,
                     xpath              varchar2 ) return sys.xmldom.DOMNodeList;


Function selectNodes(doc                sys.xmldom.DOMDocument,
                    xpath       varchar2)  return sys.xmldom.DOMNodelist;



Function test(doc               sys.xmldom.DOMDocument,
              xpath             varchar2 ) return boolean ;

Function test(node              sys.xmldom.DOMDocument,
              xpath             varchar2 ) return boolean ;


End;

/
show err        
--------------------------------------------------------------------------------------------------
CREATE OR REPLACE Package body DW.xpath as

-- "casts" a document as a DOMNode
Function toNode(doc             sys.xmldom.DOMDocument) return sys.xmldom.DOMNode is
Begin
        return sys.xmldom.makeNode(doC);
End ;

--------------------------------------------------------------------------------------------------
-- Removes extraneous whitespace from a string
-- translates CR,LF, and TAB to spaces then leaves only a single space between chars.
Function normalizeWS(v varchar2) return varchar2 is
        result  varchar2(32767);
Begin
        result := rtrim(ltrim(translate(v,chr(13)||chr(8)||chr(10),' ')));
        While (instr(result,' ') > 0 ) Loop
           result := replace(result,' ',' ');
        End loop;
                
        return result;

end;

--------------------------------------------------------------------------------------------------
Function SelectAndPrint(doc     sys.xmldom.DOMDocument,
                        xpath   varchar2,
                        normalizeWhitespace boolean := true) return varchar2 is

retval   varchar2(32767);
result   varchar2(32767);
curNode  sys.xmldom.DOMNode;
nodeType NATURAL;
matches  sys.xmldom.DOMNodeList;

Begin
        If xpath = '/' then
                sys.xmldom.writeToBuffer(doc,retval);
        Else
                matches := sys.xslprocessor.selectNodes(toNode(doc),xpath);
                For i in 1..sys.xmldom.getlength(matches) Loop
                 curNode := sys.xmldom.item(matches,i-1);
                 sys.xmldom.WriteToBuffer(curNode,result);
                
                If nodetype Not in (sys.xmldom.TEXT_NODE,sys.xmldom.CDATA_SECTION_NODE) then    
                        retval := retval || rtrim(rtrim(result,chr(10)),chr(13));
                Else
                        retval := retval || result ;
                End if;
                End Loop;
        End if;

        If normalizeWhitespace then
                return normalizeWS(retval);
        Else
                return retval;
        End if;

End ;


--------------------------------------------------------------------------------------------------
Function extract(doc            sys.xmldom.DOMDocument,
                 xpath          varchar2 := '/',
                 normalize      Boolean := TRUE) return varchar2 is

Begin
        If sys.xmldom.isNull(doc) or xpath is null then return null; End if;
        
        Return selectAndPrint(doc,xpath,normalize);

End ;

--------------------------------------------------------------------------------------------------

Function valueof(node           sys.xmldom.DOMNode,
                 xpath          varchar2,
                 normalize      Boolean := FALSE) return varchar2 is
Begin
        If sys.xmldom.IsNull(node) or xpath is null then return null; end if;
        
        If normalize then
                return normalizeWS(sys.xslprocessor.valueof(node,xpath));
        Else
                return sys.xslprocessor.valueof(node,xpath);
        End if;
End;
--------------------------------------------------------------------------------------------------

Function valueof(doc             sys.xmldom.DOMDocument,
                         xpath          varchar2,
                 normalize      Boolean := FALSE) return varchar2 is
Begin
        If sys.xmldom.IsNull(doc) or xpath is null then return null; end if;
        
        return valueof(toNode(doc),xpath,normalize);
        
End;

--------------------------------------------------------------------------------------------------
Function selectNodes(node               sys.xmldom.DOMNode,
                     xpath              varchar2 ) return sys.xmldom.DOMNodeList is
Begin
        return sys.xslprocessor.selectNodes(node,xpath);
End;
--------------------------------------------------------------------------------------------------
Function selectNodes(doc                sys.xmldom.DOMDocument,
                     xpath              varchar2 ) return sys.xmldom.DOMNodeList is
Begin
        return selectNodes(tonode(doc),xpath);
End;
---------------------------------------------------------------------------------------------------
Function test(doc               sys.xmldom.DOMDocument,
              xpath             varchar2 ) return boolean is
Begin
        return sys.xmldom.getLength(selectNodes(doc,'/self::node()['||xpath||']')) > 0;
End;
---------------------------------------------------------------------------------------------------
Function test(node              sys.xmldom.DOMDocument,
              xpath             varchar2 ) return boolean is
Begin
        return sys.xmldom.getLength(selectNodes(node,'./self::node()['||xpath||']')) > 0;
End;

---------------------------------------------------------------------------------------------------

End ;           
/
show err
