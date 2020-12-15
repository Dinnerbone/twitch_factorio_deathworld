local function get_target_player_from_name (target_name)
    if target_name == "*" or target_name == "" then
        return game.players[math.random(#game.players)]
    end

    local target_player = game.get_player(target_name);
    if target_player == nil then
        for _, player in pairs(game.players) do
            if string.find(string.lower(player.name), string.lower(target_name)) then
                target_player = player; 
            end
        end
    end

    return target_player
end

remote.add_interface("twitch_deathworld",{
    help_research = function (name, amount)
        local player = game.players[1];
        local force = player.force;
        local research = force.current_research;

        if research then
            local new_amount = force.research_progress + amount;
            if new_amount >= 1 then
                force.research_progress = 1;
                force.print({"", "[Twitch] ", name, " completed ", research.localised_name}, {0, 1, 0, 1});
            else
                force.research_progress = new_amount;
                force.print({"", "[Twitch] ", name, " contributed to ", research.localised_name}, {0, 1, 0, 1});
            end
            rcon.print("worked");
            return;
        end
        rcon.print("failed");
        return;
    end,

    hurt_research = function (name, amount)
        local player = game.players[1];
        local force = player.force;
        local research = force.current_research;

        if research then
            local new_amount = force.research_progress - amount;
            if new_amount <= 0 then
                force.research_progress = 0;
                force.print({"", "[Twitch] ", name, " completely reset ", research.localised_name}, {1, 0, 0, 1});
            else
                force.research_progress = new_amount;
                force.print({"", "[Twitch] ", name, " set back ", research.localised_name}, {1, 0, 0, 1});
            end
            rcon.print("worked");
            return;
        end
        rcon.print("failed");
        return;
    end,
      
    plant_tree = function (targetName, amount)
        local planted = false;
        local targetPlayer = get_target_player_from_name(targetName)

        if targetPlayer then
            for i = 1, tonumber(amount) do
                local targetX = targetPlayer.position.x + math.random(-6, 6);
                local targetY = targetPlayer.position.y + math.random(-6, 6);
                local createdEntity = game.surfaces.nauvis.create_entity({name="tree-01", amount=1, position={targetX, targetY}});
                if createdEntity then
                    planted = true;
                end
            end

            if planted then
                rcon.print("worked");
                return;
            else
                rcon.print("failed|Unable to plant tree here");
                return;
            end
        end
        rcon.print("failed|Unable to find player by that name");
        return;
    end,

    modify_run_speed = function (name, target_player_name, modifier_change, lower_limit, upper_limit)
        local target_player = get_target_player_from_name(target_player_name)       
        lower_limit = lower_limit or 0.5
        upper_limit = upper_limit or 3
        modifier_change = tonumber(modifier_change)

        if target_player and target_player.character ~= nil then
            local current_speed_modifier = target_player.character["character_running_speed_modifier"]
            local resultant_speed_modifier = current_speed_modifier + modifier_change
            
            local limits_reached = false
            if resultant_speed_modifier < lower_limit then
                resultant_speed_modifier = lower_limit
                if current_speed_modifier == lower_limit then
                    limits_reached = true
                end
            elseif resultant_speed_modifier > 3 then
                resultant_speed_modifier = 3
                if current_speed_modifier == upper_limit then
                    limits_reached = true
                end
            end

            if limits_reached then
                rcon.print("failed|Player at speed threshold already");
                return;
            else
                target_player.character["character_running_speed_modifier"] = resultant_speed_modifier

                if modifier_change > 0 then
                    target_player.force.print({"", "[Twitch] ", name, " Buffed ", target_player.name, "'s run speed"}, {0, 1, 0, 1});
                else
                    target_player.force.print({"", "[Twitch] ", name, " Nerfed ", target_player.name, "'s run speed"}, {1, 0, 0, 1});
                end
            end
        else
            rcon.print("failed|Unable to find player by that name");
            return;
        end
        rcon.print("worked");
        return;
    end,
});

