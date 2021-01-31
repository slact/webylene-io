event := Object clone do(

	activeEvents := list()
	active := method(eventName, activeEvents contains(eventName))
	
	finishedEvents := list()
	finished := method(eventName, finishedEvents contains(eventName))

	fire := method(event,
		//todo: make coroutiney
		start(event)
		finish(event)
		self
	)
	
	start := method(event,
		//activeEvents println
		//cgi write("starting #{event}\n" interpolate)
		if(activeEvents contains(event),
			Exception raise("tried starting event #{event}, but it's already active.\n" interpolate))
		activeEvents push(event)
		handlers perform(event) start ?foreach(call)
		handlers perform(event) during ?foreach(call)
		self
	)
	
	finish := method(event, 
		//"finishing #{event}\n" interpolate print
		if(activeEvents contains(event) not,
			Exception raise("tried finishing event #{event}, but it's not active and hadn't been started.\n" interpolate))
		activeEvents removeAt(activeEvents indexOf(event))
		finishedEvents push(event)
		handlers perform(event) finish ?foreach(?call)
		handlers perform(event) after ?foreach(?call)
		self
	)
	
	addListener := method(eventName, listener,
		//"adding  #{eventName}\n" interpolate println
		handlers perform(eventName) during push(getSlot("listener")) //add the event!
		if(active(eventName), getSlot("listener") ?call)
		self
	)
	
	addStartListener := method(eventName, listener,
		handlers perform(eventName) start push(getSlot("listener")) //add the event!
		self
	)
		
	addFinishListener := method(eventName, listener,
		handlers perform(eventName) finish push(getSlot("listener")) //add the event!
		self
	)
	
	addAfterListener := method(eventName, listener,
		handlers perform(eventName) after push(getSlot("listener")) //add the event!
		if(finished(eventName), getSlot("listener") ?call)
		self
	)
	
	handlers := Object clone do(
		forward := method(
			eventName := call message name
			self setSlot(eventName, Object clone do(
				start  := list()
				during := list()
				finish := list()
				after  := list()
			))
		)
	)
	
	type := "event"
)