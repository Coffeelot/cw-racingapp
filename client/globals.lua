UseDebug = Config.Debug
UiIsOpen = false

Countdown = 10
FinishedUITimeout = false
IsFirstUser = false
CharacterHasLoaded = false

CurrentName = nil
CurrentAuth = nil
CurrentCrew = nil
CurrentCrypto = nil
CurrentRanking = nil
MyRacerNames = {}

Classes = getVehicleClasses()
Entities = {}
Kicked = false

RaceData = {
    InCreator = false,
    InRace = false,
    ClosestCheckpoint = 0
}

CurrentRaceData = {
    RaceId = nil,
    TrackId = nil,
    RaceName = nil,
    RacerName = nil,
    MaxClass = nil,
    Checkpoints = {},
    Started = false,
    CurrentCheckpoint = nil,
    TotalLaps = 0,
    TotalRacers = 0,
    Lap = 0,
    Position = 0,
    Ghosted = false,
}
