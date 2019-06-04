local Telegram = require 'telegram'
local Api = Telegram.api.Init("213210238:AAEP1XgZOXjIiAqDJvUEDBzBHmLqAzO3Rug")
local Utils = Telegram.utils
local update_id = 0
local function script()
    local function updates(tab, err)
        for i, updates in pairs(tab.result) do
            local msg = updates.message
            if msg.text then
                if msg.text == "/getfileserver" then
                    local callback = function(result, description, var)
                        Api : sendMessage {
                            chat_id = var.chat.id,
                            text = "Document sent from server!"
                        }
                    end
                    local file = Utils.download("https://telegram.org/img/t_logo.png", "/tmp")
                    Api : sendDocument({
                        chat_id = msg.chat.id,
                        document = ('file://%s') : format(file),
                        define = msg
                    }, callback)
                elseif msg.text == "/getfileweb" then
                    local callback = function(result, description, var)
                        Api : sendMessage {
                            chat_id = var.chat.id,
                            text = "Document sent from web server!"
                        }
                    end
                    Api : sendDocument({
                        chat_id = msg.chat.id,
                        document = "https://telegram.org/img/t_logo.png",
                        define = msg
                    }, callback)
                end
            end
            update_id = updates.update_id
        end
    end
    Api : getUpdates({offset = update_id+1}, updates)
end

Api : Running (script, true)
