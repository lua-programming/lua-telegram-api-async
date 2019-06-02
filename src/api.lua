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
-- METATABLE --
local API = { __data = {}}

local json      = require 'dkjson'
local https     = require 'ssl.https'
local ltn12     = require 'ltn12'
local cqueues   = require 'cqueues'
-- THREADS
local thread    = cqueues.new()
local cop2      = cqueues.new()
-- FUNCTIONS
function API:Request(method, parameters, callback)
    assert(parameters, 'error: parameters not found.\n\tExecute: method:Parameters({list})')
    assert(self.URL , 'error: token not found.\n\tExecute: method:Init(\'BotToken\')')
    local utils = require 'telegram.utils'
    local boundary = utils.generate_boundary(10)
    local source = {}
    if parameters.define then
        vars = utils.create_readonly_table(parameters.define)
        parameters.define = nil
    end
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
    local response = {}
    local dat, code
    dat, code = https.request {
        ['url'] = self.URL..method,
        ['method'] = 'POST',
        ['headers'] = {
            ['Content-Type'] = ('%s; boundary=%s'):format('multipart/form-data', boundary),
            ['Content-Length'] = #source[1]
        },
        ['source'] = ltn12.source.string(source[1]),
        ['sink'] = ltn12.sink.table(response)
    }
    dat = table.concat(response)
    if #dat == 0 then
        pcall(callback, nil, tostring(code), vars)
    else
        local tab = json.decode(dat)
        if not tab then
            pcall(callback, nil, 'json error', vars)
        elseif not tab.ok then
            pcall(callback, false, tab.description, vars)
        else
            pcall(callback, tab, '200', vars)
        end
    end
    self.__data = {} -- I set this table to empty, it prevent to use it again
end
function API:Loop()
    thread:loop()
end
function API:Running(_function_)
    while true do
        cop2:wrap(function()
            assert(thread:loop())
        end)
        cop2:wrap(_function_)
        assert(cop2:step())
    end
end
local function load_methods(Telegram_API_Methods)
    for index, method in next, Telegram_API_Methods do
        API[method] = function(self, parameters, callback)
            thread:wrap(function()
                self:Request(method, parameters, callback)
            end)
        end
    end
end
return {
    _VERSION = 'Telegram Bot API 4.2 https://github.com/otgo',
    Init = function(token)
        API.URL = 'https://api.telegram.org/bot'..token..'/'
        -- READ_METHODS
        load_methods(Telegram_API_Methods)
        local self = setmetatable({}, {__index = API})
        return self
    end
}
