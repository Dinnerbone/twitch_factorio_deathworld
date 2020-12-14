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

    plant_tree = function (targetName)
        local planted = false;

        local targetPlayer = game.get_player(targetName);

        if targetName == "*" then
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
            for x = -3,3 do
                for y = -3,3 do
                    local targetX = targetPlayer.position.x + x + math.random(0, 6);
                    local targetY = targetPlayer.position.y + y + math.random(0, 6);
                    local createdEntity = game.surfaces.nauvis.create_entity({name="tree-01", amount=1, position={targetX, targetY}});
                    if createdEntity then
                        planted = true;
                        rcon.print("worked");
                        return;
                    end
                end
            end
            
            if planted then
                rcon.print("worked");
            else
                rcon.print("failed|Unable to plant tree here");
                return;
            end
        end
        rcon.print("failed|Unable to find player by that name");
        return;
    end
});