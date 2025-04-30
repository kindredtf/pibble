// Zone data for pib_mesa

printl("[pib_mesa] Map-specific data loaded")

::GetZoneText <- function(zoneId)
{
    local zoneText = {
        [1] = "Off the Glass! (2X)",
        [2] = "Freakbob! (3X)",
        [3] = "Oh my pib! (4X)",
        [4] = "CLIP DAT!!!! (5X)",
        [5] = "WHAT THE FLUB?!?! (6X)",
        [6] = "PIBBY LORE CREATED!!! (10X)",
        [7] = "Low Taper Fade! Sheeesh! (2X)",
        [8] = "Low Taper Fade! Sheeesh! (2X)",
        [9] = "Hotdog! (2X)",
        [10] = "Hotdog! (2X)",
        [11] = "Wall extender! (1.25X)",
        [12] = "Wall extender! (1.25X)",
        [13] = "Pibble! (1.5X)",
        [14] = "Pibble! (1.5X)",
    }
    return zoneText[zoneId]
}