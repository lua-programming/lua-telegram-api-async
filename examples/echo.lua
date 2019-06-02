local Api = require 'telegram.api'
Api = Api.Init("213210238:AAEP1XgZOXjIiAqDJvUEDBzBHmLqAzO3Rug")
local update_id = 0
local function script()
    local update_id = offset or 0
    local function updates(tab, err)
        for i, updates in pairs(tab.result) do
            local msg = updates.message
            if msg.text then
                local callback = function(a, b, vars)
                    printf("Message\t%s\nChat_id\t%s", vars.text, vars.chat_id)
                end
                Api : sendMessage({
                    chat_id = msg.chat.id,
                    text = msg.text,
                    define = {
                        chat_id = msg.chat.id,
                        text = msg.text
                    }
                }, callback)
            end
            update_id = updates.update_id
        end
    end
    Api : getUpdates({offset = update_id+1}, updates)
end

Api : Running (script)
