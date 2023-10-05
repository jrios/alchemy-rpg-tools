((.special_abilities // []) | map(select(.name == "Spellcasting" or .name == "Innate Spellcasting")) | 
        (if length > 0 then
            if .[].name == "Innate Spellcasting" then
                .[].desc | {
                    spellcastingAbility: . | capture("spellcasting ability is (?<ability>\\w+)") | .ability[0:3],
                    spells: . | split(":")[1] | split(",") | map({
                        name: . | ltrimstr(" ") | rtrimstr(" ")
                    })
            } elif .[].name == "Spellcasting" then
                .[].desc | {
                    spellcastingAbility: . | capture("spellcasting ability is (?<ability>\\w+)") | .ability[0:3],
                    spellSlots: . | split("\n")[2:] | map(capture("\\((?<slotCount>\\d+) slots?\\)"; "g")) | map({
                        max: (.slotCount // 0 | tonumber),
                        remaining: (.slotCount // 0 | tonumber),
                    }),
                    spells: [. | split(":\n"; "g")[1] |
                        gsub("\n";",") | sub(", (?<lvl>\\d+)"; " \(.lvl)"; "g") |
                        capture("\\((at will|\\d+ slots?)\\): (?<spellList>((?:\\w+\\s?)+,?\\s?)+(?=\\d|$))"; "g") |
                        .spellList | split(",") | 
                        map({ name: . | ltrimstr(" ") | rtrimstr(" ") })
                    ] | flatten
                }
            end
        else
            null
        end)
)