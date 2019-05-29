local Telegram_API_Methods = {
    'answerInlineQuery',
    'answerCallbackQuery',
    'deleteMessage',
    'deleteChatPhoto',
    'deleteChatStickerSet',
    'editMessageText',
    'editMessageMedia',
    'editMessageCaption',
    'exportChatInviteLink',
    'editMessageReplyMarkup',
    'editMessageLiveLocation',
    'forwardMessage',
    'getMe',
    'getChat',
    'getFile',
    'getUpdates',
    'getChatMember',
    'getChatMembersCount',
    'getUserProfilePhotos',
    'getChatAdministrators',
    'kickChatMember',
    'leaveChat',
    'pinChatMessage',
    'promoteChatMember',
    'restrictChatMember',
    'sendPoll',
    'stopPoll',
    'sendVenue',
    'sendPhoto',
    'sendVoice',
    'sendVideo',
    'sendAudio',
    'sendSticker',
    'sendContact',
    'sendMessage',
    'setChatTitle',
    'sendDocument',
    'sendLocation',
    'sendVideoNote',
    'sendAnimation',
    'sendChatAction',
    'setChatStickerSet',
    'setChatDescription',
    'stopMessageLiveLocation',
    'unpinChatMessage'
}
local media_table_for_curl = {
    'audio',
    'document',
    'video',
    'animation',
    'voice',
    'videonote',
    'photo'
}
local API = {}
API.__data = {}
API.__modules = {}
local json = require 'dkjson'
local https = require 'ssl.https'
local ltn12 = require 'ltn12'
local function tprintf(_table, _str, ...)
    if not _table[1] then
        _table[1] = ''
    end
    _table[1] = _table[1] .. string.format(_str, ...)
end
local function generate_boundary()
    local _ = {'TELEGRAM--'}
    math.randomseed(os.time())
    for i=1,10 do
        table.insert(_, string.char(math.random(98, 122)))
    end
    table.insert(_, '--BOT')
    return table.concat(_)
end
function printf(...)
    print(string.format(...))
end
function API:sleep(seconds)
  self.__modules.copas.sleep(seconds)
end
function API:Request(method, parameters, callback)
    assert(parameters, 'error: parameters not found.\n\tExecute: method:Parameters({list})')
    assert(self.URL , 'error: token not found.\n\tExecute: method:Init(\'BotToken\')')
    local boundary = generate_boundary()
    local source = {}
    for var, val in next, parameters do
        local type_val = type(val)
        if type_val == 'table' then
            tprintf(source, '--%s\r\n', boundary)
            tprintf(source, 'Content-Disposition: form-data; name="%s"\r\n', var)
            tprintf(source, 'Content-Type: application/json\r\n\r\n')
            tprintf(source, '%s\r\n', json.encode(val))
        elseif type_val == 'string' or type_val == 'number' then
            local file_from_server = tostring(val):match('^file://(.+)')
            if file_from_server then
                local file = assert(io.open(file_from_server, 'r'), 'unable to open file')
                local file_data = file:read('*all')
                local filename = file_from_server:gsub('^(.+/)', '')
                tprintf(source, '--%s\r\n', boundary)
                tprintf(source, 'Content-Disposition: form-data; name="%s"; filename="%s"\r\n', var, filename)
                tprintf(source, 'Content-Type: multipart/form-data\r\n\r\n')
                tprintf(source, '%s\r\n', file_data)
                file:close()
            else
                tprintf(source, '--%s\r\n', boundary)
                tprintf(source, 'Content-Disposition: form-data; name="%s"\r\n\r\n', var)
                tprintf(source, '%s\r\n', val)
            end
        end
    end
    tprintf(source, '--%s--\r\n', boundary)
    self.__data = {} -- se vacía la tabla para evitar que se vuelva a usar la misma por error
    local response = {}
    local dat, code
    dat, code = https.request {
        ['url'] = self.URL..method,
        ['method'] = 'POST',
        ['headers'] = {
            ['Content-Type'] = string.format('%s; boundary=%s', 'multipart/form-data', boundary),
            ['Content-Length'] = #source[1]
        },
        ['source'] = ltn12.source.string(source[1]),
        ['sink'] = ltn12.sink.table(response)
    }
    dat = table.concat(response)
    if #dat == 0 then
        pcall(callback, nil, code)
    else
        local tab = json.decode(dat)
        if not tab then
            pcall(callback, nil, 'json error')
        elseif not tab.ok then
            pcall(callback, false, tab.description)
        else
            pcall(callback, tab, 200)
        end
    end
end
function API:Start(_)
    local co = coroutine.create(function()
        while true do
            _()
            self.__modules.copas.loop()
        end
    end)
    coroutine.resume(co)
end
function API:addthread(_)
    self.__modules.copas.addthread(function() self.__modules.copas.sleep(0) _() end)
end
local function load_methods(Telegram_API_Methods)
    for index, method in pairs(Telegram_API_Methods) do
        API[method] = function(self, parameters, callback)
            self.__modules.copas.addthread(function()
                self.__modules.copas.sleep(0)
                self:Request(method, parameters, callback)
            end)
        end
    end
end
return {
    _VERSION = 'Telegram Bot API 4.2',
    Init = function(token)
        API.URL = 'https://api.telegram.org/bot'..token..'/'
        -- Lee las metodos de la API, la lista está al inicio de este script
        load_methods(Telegram_API_Methods)
        API.__modules.copas = require 'copas'
        local self = setmetatable({}, {__index = API})
        return self
    end
}
