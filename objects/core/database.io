database := MySQL clone do(
	type := "database"
	init := method(
		webylene db := self
		
		W event addAfterListener("loadConfig", block(
			self settings := cf("database")
			e := try(
				connect(settings at("host"), settings at("username"), settings at("password"), settings at("db"), if(settings at("port"), settings at("port"), 3306), settings at("ssh"))
			) 
			e catch(Exception, e pass)
		) setScope(self))
	)
)  