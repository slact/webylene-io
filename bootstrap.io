
//language first

doFile(method(call message label) call pathComponent .. "/io.io")

//start debugging
//Profiler start

//okay, cool.
webylene := Object clone do(
	path := method(call message label) call pathComponent
	
	type := "webylene"
	
	forward := method(
		slotName := call message name
		
		importMagic := import(slotName)
		
		if(importMagic == nil,
			Importer import(call)
		,
			self setSlot(slotName, importMagic clone)
			self getSlot(slotName)
		)
	)
	
	import := method(objectName,
	//custom scope-sensitive file importer.
		folders := list("/objects/core", "/objects", "/objects/plugins")
		folders foreach(folder,
			path := Path with((self path) .. folder, objectName .. ".io") asSymbol
			if(File with(path) exists,
				doFile(path)
				return getSlot(objectName)
			)
		)
		nil
	)
	
	importFile := method(path,
		objectName := path fileName beforeSeq(".io")
		if(webylene hasSlot(objectName) not,
			doFile(path)
			getSlot(objectName)
		)
	)
)

setSlot("W", webylene)  //some shorthand

webylene core := webylene import("core")  //DO NOT CLONE, will lead to race condition in init
webylene core init

//Profiler stop
//Profiler output print 