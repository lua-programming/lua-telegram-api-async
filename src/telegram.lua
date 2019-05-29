local libs = {
	'api'
}
local _ = {}
for i,x in next, libs do _[x] = require(string.format("telegram.%s", x)) end
return _
