router := Object clone do(

	init := method(
		webylene event addListener("route", 
			block(route(System getEnvironmentVariable("SCRIPT_URI")))
		)
		webylene event addAfterListener("loadConfig", 
			block(
				self settings := cf("router")
			) setScope(self)
		) 
	)
	
	parseurl := method(uri, 
		regexMatch := Regex with("(?P<scheme>(?:http|ftp)s?)://(?:(?P<userinfo>\w+(?::\w+)?)@)?(?P<hostname>[^/:]+)(:(?P<port>[0-9]+))?(?P<path>/[^?#]*)?(?:\\?(?P<query>[^#]*))?(?:#(?P<fragment>.*))?") matchesFor(uri) last
		namedCaptures := Map clone
		regexMatch ?names foreach(name, namedCaptures atPut(name, regexMatch at(name)))
		namedCaptures
	)
	
	route := method(uri,
		url := parseurl(uri) at("path")
		settings at("routes") foreach(route,
			route := parser parseRoute(route)
			if(walkPath(url, route at("path")),
				return arriveAtDestination(route)
			)
		)
		
		//no route matched. 404 that sucker.
		route404()
	)
	
	route404 := method(arriveAtDestination(parser parseRoute(Map clone atPut("path", " ") atPut("ref", "404") atPut("destination", settings at("404")))))
	
	arriveAtDestination := method(route, 
		cgi REQUEST mergeWith(route at("destination") at("param"))
		self currentRoute := route
		
		webylene event fire("arriveAtDestination")
		
		Lobby doFile(webylene path cloneAppendPath(settings at("destinations") at("location")) cloneAppendPath(route at("destination") at("script") asString) .. (settings at("destinations") at("extension")))
	)
	
	walkPath := method(url, path,
	//see if the path matches
		match := Object clone do(
			url := false
			param := true
		)
		
		//TODO: this whole thing's kind of ugly. prettify later.
		request := cgi REQUEST
		path at("param") foreach(param, val,
		//path params. it's an or.
			if(request at(param) != val, 
				match param = false
				break
			)
		)	
		path at("url") foreach(furl,
		//path urls. it's an and.
			//(url .. " === " .. ("^" .. furl .. "$")) println
			if(
				if(oughtToRegex(furl), 
					if(regexMatch := ("^" .. furl .. "$") asRegex matchesFor(url) last,
						//expand named regex captures into REQUEST parameters
						regexMatch names foreach(name, if(name != nil, cgi REQUEST atPut(name, regexMatch at(name))))
					)
				,
					url slice(1) == furl
				),
				
				match url = true
				break
			)
		)
		
		return((match url) and (match param))
		
	)
	
	oughtToRegex := method(urlPattern,
		urlPattern beginsWithSeq("|") not
	)
	
	parser := Object clone do(
	
		knownParams := list("title", "ref")
		
		destination := method(contents, 
			if(contents type == "Map") then(
				//expanded destination notation
				if(contents hasKey("param") not,
					contents atPut("param", Map clone))
				if(contents hasKey("script") not,
					Exception raise("Destination script path not set. that's bad. check config/routes.yaml")
				)
			) elseif(contents type == "Sequence" or contents type == "Number") then(
				contents := Map clone atPut("script", contents) atPut("param", Map clone)
			) else(Exception raise("Couldn't parse route destination: expected to be a Map or Sequence, but was a #{contents type}" interpolate))
			contents
		)
		
		pathUrl := method(url,
			if(url type == "Sequence") then(
				return list(url)
			) elseif(url type == "List") then(
				return url
			) else(
				Exception raise("Couldn't parse route path URL: expected a Sequence or a List, found #{url type}. Check your config/routes.yaml" interpolate)
			)
		)
		
		path := method(contents,
			//contents println
			if(contents type == "Map") then(
				if(contents hasKey("url") not,	//no url. can't do anything about that, error out.
					Exception raise("Couldn't parse route path: path explicitly stated, but no url given")
				)
				contents atPut("url", pathUrl(contents at("url")))
				if(contents hasKey("param") not, contents atPut("param", Map clone))
			) else(  //it's a shorthand
				contents :=  Map clone atPut("url", pathUrl(contents)) atPut("param", Map clone)
			)
			contents
		)
		
		param := method(contents, 
			if(contents type != "Map",
				Exception raise("Couldn't make sense of params"))
			contents)
			
		extractBaseParam := method(contents, 
			param := Map clone
			self knownParams foreach(key, 
				if(contents hasKey(key), 
					param atPut(key, contents at(key))
					call evalArgAt(0) removeAt(key)
				)
			)
			param
		)
		
		parseRoute := method(contents,
			route := Map clone
			if(contents type == "Map",
				baseParam := extractBaseParam(contents)
				route atPut("path", path(if(contents hasKey("path"), contents at("path"), contents values at(0))))
				route atPut("destination", destination(if(contents hasKey("destination"), contents at("destination"), contents keys at(0))))
				route atPut("param", param(baseParam mergeRecursivelyWith(contents at("param"))))
			,
				Exception raise("expected route to be type Map, found #{contents type} instead" interpolate)
			)
			route
		)		
	)
	
	type := "router"
)