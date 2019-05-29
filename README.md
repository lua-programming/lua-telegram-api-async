# lua-telegram-api-async
This is a lua script in test.

You can send messages, files, etc. and it will work as async mode (it is not working by a server)

You can install it by luarocks:
```bash
luarocks install telegram
```

Example:
```lua
local Api = require 'telegram.api'
Api = Api.Init("213210238:AAEP1XgZOXjIiAqDJvUEDBzBHmLqAzO3Rug") -- init with your token
local offset
Api:
Start(function()
    local update_id = offset or 0
    local function updates(tab, err)
        for i, updates in pairs(tab.result) do
            local msg = updates.message
            if msg.text then
                local callback = function(a, b, var)
                    printf("Message\t%s\nChat_id\t%s", msg.text, msg.chat.id)
                end
                Api:
                sendMessage({
                    chat_id = msg.chat.id,
                    text = msg.text
                }, callback) -- this function will be executed in the background
            end
            offset = updates.update_id
        end
    end
    Api:
    getUpdates({offset=update_id+1}, updates) -- this too
end)
```

Its uses are like this:
Api : method (see methods [telegram bots api](https://core.telegram.org/bots/api#available-methods))

Useful functions:
-------------------------------------
`: addthread(function)` X function will be added into actual coroutines.

`: printf(string, values)`

`: sleep(seconds)` it executes a pause with X seconds
