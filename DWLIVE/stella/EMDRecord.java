/*
 * EMDRecord.java
 *
 * Created on 14 August 2018, 11:33
 */

package uk.co.firstchoice.stella;

/**
 * object definition to store a record from air input file
 * 
 * @author Tim Wilson
 */
public class EMDRecord {

	/** Creates a new instance of Class */
	public EMDRecord() {
	}

	/** document identifier */
	public String docID = "";

	/** selling fare amount */
	public String sellingFareAmount = "";
        
        /** remaining tax */
        public String remainingTax = "";
        
        /** airline code */
        public String airline = "";
        
        /** ticket number */
        public String ticketNo = "";

}
