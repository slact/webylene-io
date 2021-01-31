
//let FCGI take care of the writing:
Object setSlot("write", method(cgi write(call evalArgs reduce(a, b, a .. b))))
Sequence setSlot("print", method(cgi write(getSlot("self") asUTF8)))

if(File hasSlot("_write") not)
	File _write := File getSlot("write")

File write := method(	
	if(self path == "<standard output>", FastCGI performWithArgList("write", call evalArgs)	, File performWithArgList("_write", call evalArgs))
)

//now, mess with the language a bit
/*
block := Block clone setMessage(
	message(
		args := call message arguments
		body := args pop
		self Block clone setMessage(body) setArgumentNames(args map(name)) setScope(call target) setIsActivatable(true)
	)
) setIsActivatable(true)
*/

OperatorTable operators removeAt("'")
' := method(
    arg := call message next
    call message setNext(arg next)
    arg setNext
    call target getSlot(arg name)
)

Number isInteger := method(self		
 ceil == self) //yeech. 
Map do(
	index := 0;
	put := method(optionalKey, value,
		if(call message argCount == 1,
			self index := self index + 1
			self atPut(self index, optionalKey)
		,
			self atPut(optionalKey, value)
		)
		self
	)
			
	if(Map getSlot("atPut") type == "CFunction",
		uncheckedAtPut := Map getSlot("atPut"))

	atPut := method(key, value, 
		keyNum := key asNumber
		if((keyNum isNan not) and (keyNum isInteger) and (self index < keyNum),
			self index = keyNum)
		self uncheckedAtPut(key asString , value)
		self
	)
			
	mergeWith := method(anotherMap,
		anotherMap foreach(k, v, 
			if((k asNumber isInteger) and (self hasKey(k) not), 
				self put(v)
			,
				self atPut(k, v)
			)
		)
		self
	)

	mergeRecursivelyWith := method(object,
		object ?foreach(k, v, 
			if((v type == self ?at(k) type) and list("Map", "List") contains(v type),
				self at(k) mergeRecursivelyWith(v)
			,
				if((k asNumber isInteger) and (self hasKey(k asString) not), 
					self put(v)
				,
					self atPut(k, v)
				)
			)
		)
		self
	)
		
	printContents := method(
		self print
		self foreach(k, v,
			"  #{k alignLeft(25)}= #{v}" interpolate println)
	)
)

List mergeRecursivelyWith := method(object, 
	self := self union(object)
)

Object union := method(obj,
	if(obj hasSlot("foreachSlot") not,
		//some crappy type checking
		obj := obj asObject
	) 
	obj foreachSlot(name, val,
		self setSlot(name, val)
	)
	self
)
Object mergeWith := Object getSlot("union")

//CGI stuff
CGI request := method(
	_memoize := Map clone //reset GET & POST internal cache
	getParameters mergeWith(postParameters) mergeWith(cookies)
)

CGI GET := CGI getParameters
CGI POST := CGI postParameters
CGI REQUEST := CGI request
CGI COOKIE := CGI cookies




