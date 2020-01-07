//////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//	http2file.java
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//	This program will perform a get to a socket/port of a web server and save the retrieved output to
//	a file of your choice, or display to the standard output stream. The header of the request is always 
//  returned to the standard output stream.
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//	useage, only optional parameter is the filename
//
//	java http2file 10.20.1.131 80 /intranet/index.cfm [saveas.txt]
//
//	java http2file ipaddress port resource [filename]
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Modified	Modified by		Modification Notes
//	03/07/02	jwj				Initial version of http2file
//  10/07/02	jwj				Changed the output to a Buffered writer to cope with large documents
//
//
//
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////

import java.net.*;
import java.io.*;

class http2file {
    public static void main(String[] args) throws Exception {

		// create the local variables
		URL url ;
    	String line, strOutput, strHeader, strDataPacket, query;
    	BufferedReader dataInput;
    	StringBuffer content, header;
    	InputStream is;
    	OutputStream os;
		PrintWriter outFile;
		Socket conn;
		final String ip, path, filename;
		final int port;
		final String newline = System.getProperty("line.separator"); 

		
		try { 

			if ((args.length <3) == true) {
				throw new Exception("you need to pass the manditory parameters : IP Port URL (filename)");
			}
			
			//assign the input variables to the local vars
			try {
				ip = args[0];
				port = Integer.parseInt(args[1]);
				path = args[2];
				if (args.length == 4) 
					filename = args[3];
				else
					filename = "http2file.out";
			}
			catch (Exception e)
			{
				throw new Exception("error allocating the input parameters");
			}

		    //argument 1 of the command line is the IP that we want to retrieve
		    //argument 2 of the command line is the Port that we want to retrieve
		    //argument 3 of the command line is the URL that we want to retrieve
		    //argument 4 of the command line is the File that we want to write the output to (optional)

	      	query = "";
			boolean question = false;
			
			for (int i=0;i<path.length();i++) {
 				if (path.charAt(i) == '?')
					if (question)
			      		query = query + '&';
					else {
						question = true;
				      	query = query + path.charAt(i);
					}
				else
			    	query = query + path.charAt(i);
			}
			
			try {
	  			conn = new Socket(ip,port);
			}
			catch (Exception e)
			{
				throw new Exception("failed to open socket on ip " + ip + " and port " + port);
			}
			
			//build the packet that is to be sent
			strDataPacket = "";
			strDataPacket += "GET " + query + " HTTP/1.1";
			strDataPacket += newline;
			strDataPacket += "Host: " + ip + ":" + port ;
			strDataPacket += newline;
			strDataPacket += "Content-type: application/x-www-form-urlencoded";
			strDataPacket += newline;
			strDataPacket += "Content-Length: 0";
			strDataPacket += newline;
			strDataPacket += "Accept: */*";
			strDataPacket += newline;
			strDataPacket += newline;

			try {
				//get the output stream 
				os = conn.getOutputStream ();
  			    os.write (strDataPacket.getBytes());
				//conn.shutdownOutput(); // later version of java required 1.3 up

				//read the input stream
				is = conn.getInputStream();
				boolean startofxml = false;
				header = new StringBuffer();
				//create a data reader that is limited in size (to overcome memory problems)
				dataInput = new BufferedReader(new InputStreamReader(is));
				//create a buffered output writer (to overcome memory problems)
				outFile = new PrintWriter(new BufferedWriter(new FileWriter(filename)));
				while ((line = dataInput.readLine()) != null) {
					if (line.indexOf('<') >= 0)
				  		startofxml = true;
					if (startofxml) {
						//print out the line to a file
						outFile.println(line);
					} else {
						header.append(line);
						header.append(newline);
					}					
				}  
				//strOutput = content.toString();
				strHeader = header.toString();
				//conn.shutdownInput();   // later version of java required 1.3 up
				
				//close the session
				conn.close ();
				//flush out the buffered output
				outFile.flush();
			}
			catch (Exception e)
			{
				throw new Exception("connection to " + path + " failed");
			}		

			try {
				//print this header to the output channel
				System.out.println(strHeader);
				//prints out the content to a file or the output channel
			}
			catch (Exception e)
			{
				throw new Exception("outputing the header failed");
			}



		}
		catch (Exception e)
		{
			throw new Exception("http2file: " + e.getMessage());
		}
		
    }
}


