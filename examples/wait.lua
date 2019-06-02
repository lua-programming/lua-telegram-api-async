local Telegram = require 'telegram'
local Api = Telegram.api.Init("213210238:AAEP1XgZOXjIiAqDJvUEDBzBHmLqAzO3Rug")
local Utils = Telegram.utils
local update_id = 0
local function script()
    local updates = function(tab, err)
        for i, updates in pairs(tab.result) do
            local msg = updates.message
            if msg.text then
                local callback = function(result, description, vars)
                    local msg_text = "Message\t%s\nChat_id\t%s\nUpdate_id\t%i\n"
                    msg_text = msg_text:format(vars.msg.text, vars.msg.chat.id, updates.update_id)
                    printf("----------\t%s\t----------\n", "Sleep testing")
                    Utils.sleep(5)
                    Api : sendMessage {
                        chat_id = vars.msg.chat.id,
                        text = msg_text
                    }
                    if description == '200' then
                        printf("----------\t%s\t----------\n", "Message sent")
                    else
                        printf("----------\t%s\t----------\n", "Error sending messsage")
                    end
                end
                if msg.text == "/test" then
                    Api : sendMessage({
                        chat_id = msg.chat.id,
                        text = "Wait for 5 seconds...",
                        define = {
                            msg = msg
                        }
                    }, callback)
                end
            end
            update_id = updates.update_id
        end
    end
    Api : getUpdates({offset = update_id+1}, updates)
end
Api : Running(script)
