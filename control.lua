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
            return "worked";
        end
        return "failed";
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
            return "worked";
        end
        return "failed";
    end,

    modify_run_speed = function (name, target_player_name, modifier)
        if target_player_name == "random_player" then
            target_player_name = pick_random_player().name
        end
        
        modifier = tonumber(modifier)

        for i,player in pairs(game.players) do
            if target_player_name == "all_players" or target_player_name == player.name then
                if player.character ~= nil then
                    local base_speed = player.character["character_running_speed_modifier"]
                    local resultant_speed = base_speed + modifier
                    player.character["character_running_speed_modifier"] = resultant_speed
                    if modifier > 0 then
                        player.force.print({"", "[Twitch] ", name, " Buffed ", player.name, "'s run speed"}, {0, 1, 0, 1});
                    else
                        player.force.print({"", "[Twitch] ", name, " Nerfed ", player.name, "'s run speed"}, {1, 0, 0, 1});
                    end
                end
            end
        end
    end
});

