core := Object clone do(
	type := "core"
	init := method(
		cgi header("content-type", "text/plain")
			
		webylene event fire("start")
		webylene event start("load")
			//load config
			webylene event start("loadConfig")
				self loadConfig("config/", "io")
				self loadConfig("config/", "yaml")
				//webylene event fire("configLoaded")
			webylene event finish("loadConfig")
			
			//load core objects
			webylene event start("loadCore")
				self loadObjects("objects/core")
				//webylene event fire("coreLoaded")
			webylene event finish("loadCore")
			
			//load plugin objects
			webylene event start("loadPlugins")
				self loadObjects("objects/plugins")
				//webylene event fire("pluginsLoaded")
			webylene event finish("loadPlugins")
		webylene event finish("load")
	
		webylene event start("ready")
			webylene event fire("route")
			//webylene event fire("shutdown")	
		webylene event finish("ready")
	)
	
	webylene config := Map clone
	
	loadConfig := method(relativePath, extension, 
		
		loadFile := Object clone do(
			yaml	:= method(path, 
				conf := YAML load(File with(path) contents)
				if(conf ?at("env") ?at(webylene env) isNil not,	
					conf mergeRecursivelyWith(conf at("env") at(webylene env))
					conf removeAt("env")
				)
				webylene config mergeRecursivelyWith(conf)
			)
			io		:= method(path, doFile(path))
		)
		
		if(loadFile getSlot(extension) isNil,
			Exception raise("Config loader doesn't know what to do with the  '.#{extension}' extension." interpolate)
		)
		Directory with(W path .. "/" .. relativePath) filesWithExtension(extension) foreach(file, 
			loadFile getSlot(extension) call(file path)
		)
	)
	
	loadObjects := method(relativePath,
		Directory with(W path .. "/" .. relativePath) filesWithExtension("io") foreach(file,
			imported := webylene importFile(file path)
			if(imported != false,
				webylene setSlot(file name beforeSeq(".io"), webylene importFile(file path) clone)
			)
		)
		self
	)
)

//shorthand
Object cf := method(
	config := webylene config
	if(call argCount == 1 and call evalArgAt(0) type == "List",
		call message setArguments(call evalArgAt(0)))
	call evalArgs foreach(arg, 
		switch(
			config type == "Map", config = config at(arg asString),
			config type == "List",  config = config at(arg asNumber),
			config = config at(arg)
		)
	)
	config
)