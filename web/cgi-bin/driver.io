// this allows you to use this as a driver file, and then run
// .io files under your document root.
FastCGI foreachRequest(	
		cgi := CGI clone
		e := try(doFile(cgi pathTranslated))
		e catch(Exception, FastCGI write(
			"<pre>ERROR:\n" ..
			e coroutine backTraceString .. 
			"</pre>"))
)