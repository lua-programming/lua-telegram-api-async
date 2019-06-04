local Telegram = require 'telegram'
local Api = Telegram.api.Init("213210238:AAEP1XgZOXjIiAqDJvUEDBzBHmLqAzO3Rug")
local Utils = Telegram.utils
local update_id = 0
local function script()
    local updates = function(tab, err)
        for i, updates in pairs(tab.result) do
            local msg = updates.message
            if msg.text then
                local callback = function(result, description, var)
                    printf("----------\t%s\t----------\n", "Sleep testing")
                    Utils.sleep(5)
                    Api : sendMessage {
                        chat_id = var.chat.id,
                        text = "I'm awake!"
                    }
                    if description == '200' then
                        printf("----------\t%s\t----------\n", "Message sent")
                    else
                        printf("----------\t%s\t----------\n", "Error sending messsage")
                    end
                end
                if msg.text == "/wait" then
                    Api : sendMessage({
                        chat_id = msg.chat.id,
                        text = "I'll sleep for 5 seconds...",
                        define = {
                            chat = { id = msg.chat.id },
                            text = msg.text,
                            update_id = updates.update_id
                        }
                    }, assert(callback))
                elseif msg.text == "/testup" then
                    Api : sendMessage {
                        chat_id = msg.chat.id,
                        text = "It's up!"
                    }
                end
            end
            update_id = updates.update_id
        end
    end
    Api : getUpdates({offset = update_id+1}, assert(updates))
end
Api : Running(script)
