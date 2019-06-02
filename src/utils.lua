local utils = {}
function string:mgsub(_table_)
    for k, v in next, _table_ do
        self = self:gsub(k, v)
    end
    return self
end
function string:emd()
    return self:mgsub({
        ['%_'] = '\\_', ['%['] = '\\[',
        ['%*'] = '\\*', ['%`'] = '\\`'
    })
end
function string:rmd()
    return self:mgsub({
        ['%_'] = '', ['%['] = '',
        ['%*'] = '', ['%`'] = ''
    })
end
function string:ehtml()
    return self:mgsub({
        ['%&'] = '&amp;', ['%<'] = '&lt;', ['%>'] = '&gt;'
    })
end
function string:rhtml()
    return self:mgsub({
        ['%&'] = '', ['%<'] = '', ['%>'] = ''
    })
end
function string:trim()
    return self:gsub('^%s+(.+)%s+$', '%1')
end
function printf(...)
    io.stdout:write(string.format(...))
end
function tprintf(_table_, _string_, ...)
    if not _table_[1] then
        _table_[1] = ''
    end
    _table_[1] = _table_[1] .. string.format(_string_, ...)
end
function vardump(_table_)
    print(require 'serpent'.block(_table_, {comment = false}))
end
function utils.plink(_table_)
    local str = ('[%s](%s)'):format(_table_.text, _table_.link) -- default, markdown
    if _table_.parse_mode == 'markdown' then
        str = ('[%s](%s)'):format(_table_.text, _table_.link)
    elseif _table_.parse_mode == 'html' then
        str = ('<a href="%s">(%s)</a>'):format(_table_.text, _table_.link)
    end
    return str
end
function utils.generate_boundary(limit)
    local _ = {}
    math.randomseed(os.time())
    tprintf(_, 'BOUNDARY--')
    for i=1, limit do
        local random_char = string.char(math.random(98, 122))
        tprintf(_, '%s', random_char)
    end
    tprintf(_, '--END')
    return table.concat(_)
end
function utils.create_readonly_table(_table_)
    return setmetatable({}, {
        __index = _table_,
        __newindex = function()
            print("unable to set readonly table")
        end
    })
end
function utils.download(url, path)
    local protocol, filename = url:match('^(https?).+/(%S+)$')
    local request
    if protocol == 'http' then
        request = require 'socket.http'.request
    elseif protocol == 'https' then
        request = require 'ssl.https'.request
    else
        assert(false, ('unsupported protocol %s'):format(protocol))
    end
    local body, code = request(url)
    assert(body, code)
    local pf = ('./%s'):format(filename)
    if path then
        pf = ('%s/%s'):format(path, filename)
    end
    local file = assert(io.open(pf, 'wb')) -- write, binary
    file:write(body)
    file:close()
    return pf
end
function utils.sleep(seconds)
    require 'cqueues'.sleep(seconds)
end
return utils
