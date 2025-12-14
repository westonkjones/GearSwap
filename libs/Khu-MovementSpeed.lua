-------------------------------------------------------------------------------------------------------------------
-- Movement Speed Detection Module for GearSwap
--
-- This module adds automatic movement speed gear swapping when you move.
--
-- To use this in your character files:
-- 1. Add this line to your character's Globals file or job file AFTER including Mote-Include:
--    include('MovementSpeed-Include')
--
-- 2. Define a sets.Moving gear set in your job file with your movement speed items:
--    sets.Moving = {feet="Horos Shoes +4"}
--
-- 3. (Optional) Toggle auto-movement speed on/off with:
--    //gs c toggle AutoMovementSpeed
-------------------------------------------------------------------------------------------------------------------

-- Only initialize once
if movement_speed_initialized then
    return
end
movement_speed_initialized = true

-- Add AutoMovementSpeed state if using Mote-Include
if state then
    state.AutoMovementSpeed = M(true, 'Auto Movement Speed')
else
    -- Fallback for non-Mote setups
    AutoMovementSpeed = true
end

-- Movement tracking variables
local last_pos = {x=0, y=0, z=0}
local last_check_time = 0
local is_moving = false
local movement_check_delay = 0.1 -- Check every 100ms

-- Register the prerender event for movement detection
windower.register_event('prerender', function()
    -- Skip if GearSwap is disabled or AutoMovementSpeed is off
    if gearswap_disabled then return end

    local auto_enabled = (state and state.AutoMovementSpeed and state.AutoMovementSpeed.value) or AutoMovementSpeed
    if not auto_enabled then return end

    local current_time = os.clock()
    if current_time - last_check_time < movement_check_delay then
        return
    end
    last_check_time = current_time

    local pos = windower.ffxi.get_mob_by_target('me')
    if not pos then return end

    local was_moving = is_moving

    -- Check if position has changed (player is moving)
    if pos.x ~= last_pos.x or pos.y ~= last_pos.y then
        is_moving = true
        last_pos.x = pos.x
        last_pos.y = pos.y
        last_pos.z = pos.z
    else
        is_moving = false
    end

    -- Only trigger gear swap when movement state changes
    if was_moving ~= is_moving then
        -- Only swap gear when idle (not engaged in combat or casting)
        if player and player.status == 'Idle' then
            handle_equipping_gear(player.status)
        end
    end
end)

-- Override customize_idle_set to add movement speed gear
-- This gets called by get_idle_set() in Mote-Include
local original_customize_idle_set = user_customize_idle_set

function user_customize_idle_set(idleSet)
    -- Call original function if it exists
    if original_customize_idle_set then
        idleSet = original_customize_idle_set(idleSet)
    end

    -- Add movement speed gear if moving
    local auto_enabled = (state and state.AutoMovementSpeed and state.AutoMovementSpeed.value) or AutoMovementSpeed
    if auto_enabled and is_moving and sets.Moving then
        idleSet = set_combine(idleSet, sets.Moving)
    end

    return idleSet
end

-- Add toggle command for AutoMovementSpeed
if self_command then
    local original_self_command = self_command

    function self_command(command)
        if command == 'toggle AutoMovementSpeed' or command == 'toggle automovementspeed' then
            if state and state.AutoMovementSpeed then
                state.AutoMovementSpeed:toggle()
                add_to_chat(122, 'Auto Movement Speed: '..tostring(state.AutoMovementSpeed.value))
            else
                AutoMovementSpeed = not AutoMovementSpeed
                add_to_chat(122, 'Auto Movement Speed: '..tostring(AutoMovementSpeed))
            end
            -- Refresh gear
            if player and player.status == 'Idle' then
                handle_equipping_gear(player.status)
            end
        else
            original_self_command(command)
        end
    end
end

-- Notification
add_to_chat(122, 'Movement Speed module loaded. Define sets.Moving in your gear file.')
