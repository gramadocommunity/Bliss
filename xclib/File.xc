// File author is Ítalo Lima Marconato Matias
//
// Created on July 01 of 2019, at 12:34 BRT
// Last edited on July 06 of 2019, at 19:15 BRT

class File {
	private var id, read, write, getpos, setpos, closed = 0;			// Basic informations about the file
	
	private static native OpenFile(path : String) : Int32 = 0; 			// Native functions that communicate with the Bliss VM
	private static native CreateFile(path : String) : Int32 = 1;
	private static native CloseFile(id) = 2;
	private static native ReadFile(id, length) : Int8* = 3;	
	private static native WriteFile(id, data : Int8*) = 4;
	private static native GetFilePosition(id) : Int32 = 5;
	private static native SetFilePosition(id, off, orig) = 6;
	
	method File(id, read, write, getpos, setpos) {
		this.id = id;													// Init the basic informations about this file (the ID, and what operations we should allow)
		this.read = read;
		this.write = write;
		this.getpos = getpos;
		this.setpos = setpos;
	}
	
	public static method Open(path : String) : File {
		var id = OpenFile(path);										// Try to open the file and get the id
		
		if (id == 0) {
			return null;												// Failed :(
		}
		
		return new File(id, 1, 1, 1, 1);								// Return the file!
	}
	
	public static method Create(path : String) : File {
		var id = CreateFile(path);										// Try to create the file, open it, and get the id
		
		if (id == 0) {
			return null;												// Failed :(
		}
		
		return new File(id, 1, 1, 1, 1);								// Return the file!
	}
	
	public static method Exists(path : String) : Int8 {
		var id = OpenFile(path);										// Try to open the file
		
		if (id != 0) {
			CloseFile(id);												// This file exists, close it and return 1 (true)
			return 1;
		}
		
		return 0;														// This file doesn't exists, return 0 (false)
	}
	
	public static method ReadAll(path : String) : Int8* {
		var file : File = Open(path);									// Try to open the file
		
		if (file == null) {
			return null;												// Failed
		}
		
		var data : Int8* = file.Read(file.GetLength());					// Read the file contents
		
		file.Close();													// Close the file
		
		return data;													// Return the read data
	}
	
	public static method WriteAll(path : String, data : Int8*) {
		var file : File = Open(path);									// Try to open the file
		
		if (file == null) {
			file = Create(path);										// Failed, try to create it
			
			if (file == null) {
				return;													// Failed :(
			}
		}
		
		file.Write(data);												// Write the data
		file.Close();													// Close the file
	}
	
	public method Close {
		if (!closed && id > 2) {										// Can we close this file?
			CloseFile(id);												// Yes, close it and set the closed variable to 1
			closed = 1;
		}
	}
	
	public method Read(length) : Int8* {
		if (closed || !read) {											// We can read from this file?
			return "";													// Nope, return an empty string
		}
		
		return ReadFile(id, length);									// Redirect to the native method
	}
	
	public method Write(data : Int8*) {
		if (!closed && write) {											// We can write to this file?
			WriteFile(id, data);										// Yes, redirect to the native method!
		}
	}
	
	public method GetPosition : Int32 {
		if (closed || !getpos) {										// We can get the position of this file?
			return 0;													// Nope :(
		}
		
		return GetFilePosition(id);										// Redirect to the native method
	}
	
	public method SetPosition(off, orig) {
		if (!closed && setpos) {										// We can set the position of this file?
			SetFilePosition(id, off, orig);								// Yes, redirect to the native method!
		}
	}
	
	public method GetLength : Int32 {
		var pos = GetPosition();										// Save the current position
		SetPosition(0, 2);												// Go to the end of the file
		var len = GetPosition() + 1;									// Get the length of the file!
		SetPosition(pos, 0);											// Go back to the old position
		return len;														// And return the length
	}
}

var In : File = new File(0, 1, 0, 0, 0);								// Create the Input, Output, and Error files
var Out : File = new File(1, 0, 1, 0, 0);
var Error : File = new File(2, 0, 1, 0, 0);
