template := Object clone do(
	type := "template"
	
	init := method(
		webylene event addAfterListener("loadConfig", 
			block(
				//discover templates
				//...too lazy to discover anything. 
			
				//load 'em on in!
				self settings := Object clone do(
					templates := cf("templates")
					layouts := cf("layouts")
				)
				
				
				//take care of any shorthand there may be
				settings templates foreach(key, val,
					if(val type == "Sequence", settings templates atPut(key, Map clone atPut("path", val)))
				)
			
				//settings templates printContents println
			) setScope(self)
		)
	)
	
	out := method(templateName, locals,
		if( hasLocalSlot("locals") not, locals := call sender thisContext )
		pageOut(templateName, locals) print
	)
	
	pageOut := method(templateName, locals, 
		if(settings templates hasKey(templateName) not, Exception raise("no such template '#{templateName}'" interpolate))
		
		if(locals == nil, locals := Object clone)
		
		/* 
			INCOMPLETE: layout picking logic
		*/
		layout := settings layouts at("default")
		
		settings templates at(templateName) print
		if((templateData := settings templates at(templateName) at("data")),
			locals mergeWith(templateData)
		)
		if((settings templates at(templateName) at("stub")) or (settings templates at(templateName) at("standalone")) or (layout isNil),
		
			include(settings templates at(templateName), locals);
		,
			//what layout should i use?
			locals child := settings templates at(templateName) //let the page layout know what to include
			
			list("css","js") foreach(ref,
				if(locals getSlot(ref) == nil, locals setSlot(ref, list()))
				locals setSlot(
					ref, locals getSlot(ref) union(
						if((templateRefs := settings templates at(templateName) at(ref)) == nil, list(), templateRefs)) union(
							if((layoutRefs := settings templates at(layout) at(ref)) == nil, list(), layoutRefs)))
				
			)
			include(layout, locals)
		)
	)
	
	include := method(templateName, locals,
		File with( webylene path .. "/templates/" .. (settings templates at(templateName) at("path"))) contents interpolate(locals)
	)
)