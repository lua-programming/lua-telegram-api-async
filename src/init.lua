local libs = {'api', 'utils'} local _ = {} for i,x in next,libs do _[x] = require( ('telegram.%s') : format (x) ) end return _
