--Place for settings and custom functions to work across one character, all jobs.

state.DisplayMode = M(true, 'Display Mode') --Set this to false if you don't want to display modes at the bottom of your screen.
--Uncomment the settings below and change the values to edit the display's look.
--displayx = 3
--displayy = 1062
--displayfont = 'Arial'
--displaysize = 12
--displaybold = true
--displaybg = 0
--displaystroke = 2
--displaytransparancy = 192
--state.DisplayColors = {
    -- h='\\cs(255, 0, 0)', -- Red for active booleans and non-default modals
    -- w='\\cs(255,255,255)', -- White for labels and default modals
    -- n='\\cs(192,192,192)', -- White for labels and default modals
    -- s='\\cs(96,96,96)' -- Gray for inactive booleans
--}

bayld_items = {'Tlalpoloani','Macoquetza','Camatlatia','Icoyoca','Tlamini','Suijingiri Kanemitsu',
'Zoquittihuitz','Quauhpilli Helm','Chocaliztli Mask','Xux Hat','Quauhpilli Gloves','Xux Trousers',
'Chocaliztli Boots','Maochinoli','Xiutleato','Hatxiik','Kuakuakait','Azukinagamitsu','Atetepeyorg',
'Kaquljaan','Ajjub Bow','Baqil Staff','Ixtab','Tamaxchi','Otomi Helm','Otomi Gloves','Kaabnax Hat',
'Kaabnax Trousers','Ejekamal Mask','Ejekamal Boots','Quiahuiz Helm','Quiahuiz Trousers','Uk\'uxkaj Cap'}

--[[ List of all Bayld Items.
bayld_items = {'Tlalpoloani','Macoquetza','Camatlatia','Icoyoca','Tlamini','Suijingiri Kanemitsu','Zoquittihuitz',
'Quauhpilli Helm','Chocaliztli Mask','Xux Hat','Quauhpilli Gloves','Xux Trousers','Chocaliztli Boots','Maochinoli',
'Hatxiik','Kuakuakait','Azukinagamitsu','Atetepeyorg','Kaquljaan','Ajjub Bow','Baqil Staff','Ixtab','Otomi Helm',
'Otomi Gloves','Kaabnax Hat','Kaabnax Trousers','Ejekamal Mask','Ejekamal Boots','Quiahuiz Helm','Quiahuiz Trousers',
'Uk\'uxkaj Cap'}
]]

include('../../libs/Khu-MovementSpeed.lua')

-------------------------------------------------------------------------------------------------------------------
-- Custom self commands for warp rings and dimensional rings
-------------------------------------------------------------------------------------------------------------------

-- Function to use enchanted items (warp rings, dimensional rings, etc)
function use_enchantment(item_name)
    local slot_list = {"main","sub","range","ammo","head","body","hands",
                      "legs","feet","neck","waist","left_ear","right_ear",
                      "left_ring","right_ring","back"}

    local item_table = res.items:with('enl',item_name) or res.items:with('en',item_name)
    local slot = ''

    if item_table == nil then
        add_to_chat(123, 'Invalid item: '..item_name)
        return
    end

    -- Check if item targets self
    if not item_table.targets or not item_table.targets:contains('Self') then
        add_to_chat(123, 'Item cannot be used on self: '..item_name)
        return
    end

    -- Find which slot this item goes in
    if item_table.slots:contains(0) then
        slot = 'main'
    else
        for k,v in pairs(item_table.slots) do
            if v == true then
                slot = slot_list[k+1]
                break
            end
        end
    end

    if slot == '' then
        add_to_chat(123, 'Could not determine slot for: '..item_name)
        return
    end

    -- Enable the slot, equip the item, then disable to lock it in place
    enable(slot)
    equip({[slot]=item_table.en})
    disable(slot)

    add_to_chat(158, 'Equipping '..item_table.en..' and preparing to use...')

    -- Use the item after a delay to allow equip to complete
    local use_delay = 9
    coroutine.schedule(function()
        send_command('input /item "'..item_table.en..'" <me>')
        add_to_chat(158, 'Using '..item_table.en)
    end, use_delay)
end

-- User self command handler for custom commands
function user_self_command(commandArgs, eventArgs)
    if commandArgs[1] then
        local command = commandArgs[1]:lower()

        if command == 'warp' then
            use_enchantment("Warp Ring")
            eventArgs.handled = true
        elseif command == 'holla' then
            use_enchantment("Dim. Ring (Holla)")
            eventArgs.handled = true
        elseif command == 'dem' then
            use_enchantment("Dim. Ring (Dem)")
            eventArgs.handled = true
        elseif command == 'mea' then
            use_enchantment("Dim. Ring (Mea)")
            eventArgs.handled = true
        end
    end
end