((.special_abilities // []) | map(select(.name == "Spellcasting" or .name == "Innate Spellcasting")) | 
    (if length > 0 then 
        if .[].name == "Innate Spellcasting" then
            .[].desc | {
                spellcastingAbility: . | capture("spellcasting ability is (?<ability>\\w+)") | .ability[0:3],
                spells: [. | capture(":\\s(?<spells>(((\\w+)(\\s|,\\s)?))+)"; "g") | .spells | split(",") | map({
                    name: . | gsub("\n"; "") | ltrimstr(" ") | rtrimstr(" ")
                })] | flatten 
        } elif .[].name == "Spellcasting" then
            .[].desc | {
                spellcastingAbility: . | capture("spellcasting ability is (?<ability>\\w+)") | .ability[0:3],
                spellSlots: . | split("\n")[2:] | map(capture("\\((?<slotCount>\\d+) slots?\\)"; "g")) | map({
                    max: (.slotCount // 0 | tonumber),
                    remaining: (.slotCount // 0 | tonumber),
                }),
                spells: . | split("\n")[1:] | map(split(": "; null)) | map(.[0] as $type | .[1] | split(", "; null) | map({
                    name: . | ltrimstr(" ") | rtrimstr(" "),
                    level: (($type | capture("Cantrips|(?<level>\\d+)(st|nd|rd|th)"; "g") | .level // 0) | tonumber),
                })) | flatten
            }
        end
    else 
        null
    end)
)