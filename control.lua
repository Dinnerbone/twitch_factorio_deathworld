local function pick_random_player ()
    return game.players[math.random(#game.players)]
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

        local targetPlayer = game.get_player(targetName);

        if targetName == "*" or targetName == "" then
            local playerCount = #game.players;
            targetPlayer = game.players[math.random(1, playerCount)];
        else 
            if targetPlayer == nil then
                for _, player in pairs(game.players) do
                    if string.find(string.lower(player.name), string.lower(targetName)) then
                        targetPlayer = player; 
                    end
                end
            end
        end

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

    modify_run_speed = function (name, target_player_name, modifier)
        if target_player_name == "random_player" then
            target_player_name = pick_random_player().name
        end
        
        modifier = tonumber(modifier)
        target_player_name = target_player_name.lower
        for _,player in pairs(game.players) do
            if target_player_name == "all_players" or target_player_name == player.name.lower then
                if player.character ~= nil then
                    local base_speed = player.character["character_running_speed_modifier"]
                    local resultant_speed = base_speed + modifier
                    player.character["character_running_speed_modifier"] = resultant_speed
                    if modifier > 0 then
                        player.force.print({"", "[Twitch] ", name, " Buffed ", player.name, "'s run speed"}, {0, 1, 0, 1});
                    else
                        player.force.print({"", "[Twitch] ", name, " Nerfed ", player.name, "'s run speed"}, {1, 0, 0, 1});
                    end
                else
                    rcon.print({"failed|Unable to find player character for ", player.name});
                    return;
                end
            else
                rcon.print("failed|Unable to find player by that name");
                return;
            end
        end
        rcon.print("worked");
        return;
    end,
});

