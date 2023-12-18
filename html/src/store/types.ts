export type Racer = {
    RacerName: string
}

export type Auth = {
    join: boolean,
    records: boolean,
    setup: boolean,
    create: boolean,
    control: boolean,
    controlAll: boolean,
}

export type Settings = {
    IgnoreRoadsForGps: boolean,
    ShowGpsRoute: boolean,
    UseUglyWaypoint: boolean,
}

export type CreatorData = {
    Checkpoints: [],
    ConfirmDelete: boolean,
    IsEdit: boolean,
    RaceDistance: number,
    RaceId: string,
    RaceName: string,
    RacerName: string,
    TireDistance: number,
}

export type Buttons = {
    IncreaseDistance: string,
    SaveRace: string,
    DecreaseDistance: string,
    Exit: string,
    DeleteCheckpoint: string,
    MoveCheckpoint: string,
    AddCheckpoint: string,
}

export type MyRacer = {
    auth: string,
    citizenid: string,
    id: number,
    lasttouched: number,
    racername: string,
    races: number,
    revoked: number,
    tracks: number,
    wins: number,
    createdby?: string,
}

export type ActiveHudData = {
    ClosestCheckpoint: number,
    InRace: boolean,
    InCreator: boolean
}

export type CurrentRace = {
    trackName: string,
    racers: number,
    laps: number,
    class: string,
    cantStart: boolean,
    ghosted: boolean,
    raceId: string,
    ghosting: boolean
}

export type ActiveRacer = {
    Checkpoint: number,
    RacerSource: number,
    RacerName: string,
    PlayerVehicleEntity: number,
    Lap: number,
    Placement: number,
    Finished: boolean
}

export type ActiveRace = {
    currentCheckpoint: number,
    totalCheckpoints: number,
    totalLaps: number,
    currentLap: number,
    raceStarted: boolean,
    raceName: string,
    time: number,
    totalTime: number,
    bestLap: number,
    position: number,
    positions: ActiveRacer[],
    totalRacers: number,
    ghosted: boolean,
}

export type Race = {
    raceId: string,
    raceName: string,
    checkpoints: [],
    totalRacers: number,
    currentCheckpoint: number,
    totalLaps: number,
    currentLap: number,
    time: number,
    bestLap: number,
    totalTime: number,
    position: number,
    positions: [],
    ghosted: boolean,
    racers: []
}

export type RacerName = {
    revoked: boolean,
    racername: string
}

export type InputField = {
    value: number,
    text: string | number,
}

export type VehicleClass = {
    value: string,
    text: string,
    number: number
}

export type BaseData = {
    data: {
        classes: VehicleClass[],
        laps: InputField[],
        buyIns: InputField[],
        moneyType: string,
        cryptoType: string,
        ghostingEnabled: boolean,
        ghostingTimes: InputField[],
        allowShare: boolean,
        racerNames: RacerName[],
        currentRacerName: string,
        currentRacerAuth: string,
        auth: Auth
    }
}

export type Access = {
    race: string
}

export type Record = {
    Class: string,
    Holder: string,
    Time: number,
    Vehicle: string,
    RaceType: string
}

export type Result = {
    RacerName: string,
    TotalTime: number,
    BestLap: number,
    VehicleModel: string
    CarClass: string
}

export type Track = {
    Access: Access,
    Checkpoints: [],
    Creator: string,
    CreatorName: string,
    Curated: number,
    Distance: number,
    LastLeaderboard: [],
    NumStarted: number,
    RaceId: string,
    RaceName: string,
    Racers: [],
    Records: Record[],
    Started: boolean,
    Waiting: boolean,
}


export type ResultData = {
    Data: {
      BuyIn: number,
      ExpirationTime: string,
      Ghosting: false,
      GhostingTime: number,
      Laps: number,
      MaxClass: string,
      RaceData: {
        Access: Access,
        Automated: boolean,
        Checkpoints: [],
        Creator: string,
        CreatorName: string,
        Curated: number,
        Distance: number,
        LastLeaderboard: [],
        NumStarted: number,
        RaceId: string,
        RaceName: string,
        Racers: [],
        Records: Record[],
        Started: boolean,
        Waiting: boolean
      },
      RaceId: string,
      SetupCitizenId: number,
      SetupRacerName: string
    },
    Result: Result[]
}

// export type RecordData = {
//     Access: [],
//     Checkpoints: [],
//     Creator: string,
//     CreatorName: string,
//     Curated: number,
//     Distance: number,
//     LastLeaderboard: [],
//     NumStarted: 0,
//     RaceId: string,
//     RaceName: string,
//     Racers: [],
//     Records: Record[],
//     Started: boolean,
//     Waiting: boolean
  
// }