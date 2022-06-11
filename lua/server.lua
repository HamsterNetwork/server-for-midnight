local json = require("lib/json")
local files = require("lib/files")
local language = json.decode(files.load_file(fs.get_dir_product().."language/server/language.json"))
local player_info = json.decode(files.load_file(fs.get_dir_product().."config/server/players.json"))

local teleport_temp = {}
function command_system(ply, text)
    local rid = tostring(player.get_rid(ply))
    current_language = player_info[rid]["language"]
    if string.find(text, "/tpa ") then
        target = string.gsub(text, "/tpa ", "")
        
        players = player.get_hosts_queue()
        for i=1,#players do
            if player.get_name(players[i]) == target then
                local pos = Vector3(0, 0, 0)
                player.get_coordinates(player.get_index(players[i]), pos)
                
                teleport_temp[players[i]] = {
                    target = ply,
                    stats = "wait",
                    pos = pos
                }
                player.send_sms(ply, language[current_language]["teleport"]["sent_succeed"])
                player.send_sms(players[i],string.format(language[current_language]["teleport"]["request"],player.get_name(ply)) )
                
            end
        end
    end
    if text == "/tpaccept" then
        if teleport_temp[ply] ~= nil then
            utils.teleport(teleport_temp[ply].target, teleport_temp[ply].pos)
            teleport_temp[ply] = nil
        else
            player.send_sms(ply, language[current_language]["teleport"]["accept_error"])
        end
    end
    if string.find(text, "/language ") then
        target = string.gsub(text, "/language ", "")
        if language[target] ~= nil then
            player_info[rid] = {
                ["language"] = target
            }
            files.write_file(fs.get_dir_product().."config/server/players.json",json.encode(player_info))
            player.send_sms(ply,string.format(language[current_language]["change_language"],target) )
        end
    end
    if text == "/rules" then
        if teleport_temp[ply] ~= nil then
            utils.teleport(teleport_temp[ply].target, teleport_temp[ply].pos)
            teleport_temp[ply] = nil
        else
            utils.send_chat(language[current_language]["rules"],false)
        end
    end
end
function OnPlayerJoin(ply)
    local rid = tostring(player.get_rid(ply))
    current_language = player_info[rid]["language"]
    if player_info[rid] == nil and rid ~= "0" then
        player_info[rid] = {
            ["language"] = "Chinese"
        }
        files.write_file(fs.get_dir_product().."config/server/players.json",json.encode(player_info))
    end
    utils.send_chat(player.get_name(ply).." "..language[current_language]["welcome"], false)
    player.send_sms(ply, language[current_language]["rules"])
end
function OnScriptEvent(ply, event, args)
    local rid = tostring(player.get_rid(ply))
    if player_info[rid] == nil and rid ~= "0" then
        player_info[rid] = {
            ["language"] = "Chinese"
        }
        files.write_file(fs.get_dir_product().."config/server/players.json",json.encode(player_info))
     
    end
end
function OnChatMsg(ply, text)
    command_system(ply, text)
end