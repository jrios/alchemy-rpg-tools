{
    abilityScores: [
        { name: "str", value: .strength }, 
        { name: "dex", value: .dexterity }, 
        { name: "con", value: .constitution },
        { name: "int", value: .intelligence },
        { name: "wis", value: .wisdom }, 
        { name: "cha", value: .charisma }
    ], 
    actions: .actions  | map({
        name: .name,
        description: .desc,
        isRanged: .desc | test("Ranged"; "g"),
        hasTwoHanded: (.desc | test("two(\\s|-)hand")),
        range: ("(?<near>\\d+)\/(?<far>\\d+)" as $range |
            if (.desc | test($range))
            then
                (.desc | capture($range))
            else
                null
            end
        ),
        dice: ("\\((?<dmgRoll>\\d+d\\d+)(\\+|\\s\\+\\s)?(?<bonusDmg>\\d)?\\)\\s(?<dmgType>\\w+)" as $dice |
            if (.desc | test($dice))
            then
                [(.desc | capture($dice; "g"))]
            else
                null
            end
        ),
        save: ("\\DC\\s?(?<dc>\\d+)\\s+(?<ability>\\w+)" as $save |
            if (.desc | test($save))
            then
                (.desc | capture($save) | if length > 1 then . end)
            else
                null
            end
        ) }) | map((
            if ((.dice | length > 1) and .hasTwoHanded)
            # There are multiple dice and two handed, so split into two different actions
            then 
                . + {
                    name: (.name + " (One Handed)"),
                    dice: [.dice[0]]
                },
                . + {
                    name: (.name + "(Two Handed)"),
                    dice: [.dice[1]]
                } 
            else
        . 
    end
)) | map((
    if ((.dice | length > 1) and .hasTwoHanded)
    # There are multiple dice and two handed, so split into two different actions
    then 
        . + {
            name: (.name + " (One Handed)"),
            dice: [.dice[0]]
        },
        . + {
            name: (.name + "(Two Handed)"),
            dice: [.dice[1]]
        } 
    else
        . 
    end
)) | to_entries | map({
    name: .value.name,
    description: .value.description,
    sortOrder: .key,
    steps: (
        if .value.dice == null then 
            []
        else 
            [{
                attack: {
                    actionType: "Action",
                    damageRolls: .value.dice | map({
                        dice: .dmgRoll,
                        type: .dmgType,
                        bonus: .bonusDmg? | 0 | tonumber
                    }),
                    crit: 20,
                    isRanged: .value.isRanged,
                    name: .value.name,
                    rollsAttack: true,
                    savingThrow: (
                        if .value.save == null 
                        then 
                            {} 
                        else 
                            {
                            abilityName: .value.save.ability | .[0:3],
                            difficultyClass: .value.save.dc | tonumber
                            }
                        end
                    )
                },
                type: "custom-attack"
            }]
        end)
    }),
    alignment,
    armorClass: .armor_class,
    conditionImmunities: .condition_immunities | split(", "),
    challengeRating: .challenge_rating, 
    hitDice: .hit_dice,
    movementModes: [
        (if .speed.walk? != null then { mode: "Walk", distance: .speed.walk } else empty end),
        (if .speed.fly? != null then { mode: (if .speed.hover then "Fly (Hover)" else "Fly" end), distance: .speed.fly } else empty end),
        (if .speed.swim? != null then { mode: "Swim", distance: .speed.swim } else empty end),
        (if .speed.climb? != null then { mode: "Climb", distance: .speed.climb } else empty end),
        (if .speed.burrow? != null then { mode: "Burrow", distance: .speed.burrow } else empty end)
    ],
    name,
    proficiencies: .languages | split(",") | map({ name: ., type: "language" }),
    senses: ("(?<type>\\w+)\\s(?<distance>\\d+)\\s?(ft\\.?)" as $senses | (
        if (.senses | test($senses))
        then
            [.senses | capture($senses; "g") | {distance: .distance | tonumber, name: .type}]
        else
            null
        end
    )),
    size,
    skills: .skills | to_entries | map({
        abilityName: $skills[0][.key] | .[0:3],
        name: .key,
        bonus: .value,
        proficient: true,
    }),
    speed: .speed.walk,
    textBlocks: [{
        title: "Abilities",
        textBlocks: [.special_abilities, .legendary_actions, .reactions] | flatten | map(select(type == "object")) | map({ title: .name, body: .desc })
    }],
    trackers: [{ 
        color: "Green", 
        "max": .hit_points, 
        value: .hit_points, 
        type: "Bar" 
    }],
    type,
    typeTags: (
        if (.subtype == "") then 
            [.type]
        else 
            [.type, .subtype] 
        end
    )
}