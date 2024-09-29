export type Racer = {
    RacerName: string
}

export type Notification = {
    title: string,
    text?: string,
    type: string,
}

export type Auth = {
    join: boolean,
    records: boolean,
    setup: boolean,
    create: boolean,
    control: boolean,
    controlAll: boolean,
    createCrew: boolean,
    startRanked: boolean,
    startElimination: boolean,
    startReversed: boolean,
    setupParticipation: boolean,
    curateTracks: boolean,
}

export type Settings = {
    IgnoreRoadsForGps: boolean,
    ShowGpsRoute: boolean,
    UseUglyWaypoint: boolean,
    CheckDistance: boolean
}

export type CreatorData = {
    Checkpoints: [],
    ConfirmDelete: boolean,
    ClosestCheckpoint: number,
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

export type CrewMember = {
    citizenID: string,
    racername: string,
    rank: number
}

export type Crew = {
    id: number,
    crewName: string,
    founderName: string,
    founderCitizenid: string,
    members: CrewMember[],
    wins: number,
    races: number,
    rank: number
}

export type CrewList = Record<string, Crew>

export type MyRacer = {
    auth: string,
    citizenid: string,
    id: number,
    lasttouched: number,
    racername: string,
    races: number,
    ranking: number,
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
    ghosting: boolean,
    ranked: boolean,
    reversed: boolean,
}

export type CheckpointTimes = {
    lap: number,
    checkpoint: number,
    time: number,
}

export type ActiveRacer = {
    Checkpoint: number,
    RacerSource: number,
    RacerName: string,
    PlayerVehicleEntity: number,
    Lap: number,
    Placement: number,
    Finished: boolean,
    CheckpointTimes: CheckpointTimes[]
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
        currentCrewName: string,
        currentRanking: number,
        auth: Auth
        hudSettings: { location: string, maxPositions: number },
        translations: Record<string,string>,
        anyoneCanCreate: boolean,
        isFirstUser: boolean,
    }
}

export type Access = {
    race: string
}

export type TrackRecord = {
    Class: string,
    Holder: string,
    Time: number,
    Vehicle: string,
    RaceType: string,
    Reversed: boolean
}

export type Result = {
    RacerName: string,
    TotalTime: number,
    BestLap: number,
    Ranking: number,
    RacingCrew?: string,
    TotalChange: number,
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
    Records: TrackRecord[],
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
        Ranked: boolean,
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
        Records: TrackRecord[],
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