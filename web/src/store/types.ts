export type Racer = {
  RacerName: string;
};

export type BountyClaim = {
  racerName: string;
  vehicleModel: string;
  time: number;
};

export type Bounty = {
  id: string;
  trackId: string;
  maxClass: string;
  reversed: boolean;
  timeToBeat: number;
  extraTime: number;
  price: string;
  rankRequired: number;
  sprint: boolean;
  trackName: string;
  claimed: Record<string, BountyClaim>;
};

export type TrackMetadata = {
  description?: string;
  raceType?: string;
};

export type Notification = {
  title: string;
  text?: string;
  type: string;
};

export type DashboardSettings = {
    enabled: boolean, 
    defaultDaysBack: number,
    defaultTopRacers: number,
}

export type Auth = {
  join: boolean;
  records: boolean;
  setup: boolean;
  create: boolean;
  control: boolean;
  controlAll: boolean;
  createCrew: boolean;
  startRanked: boolean;
  startElimination: boolean;
  startReversed: boolean;
  setupParticipation: boolean;
  curateTracks: boolean;
  handleBounties: boolean;
  handleAutoHost: boolean,
  handleHosting: boolean,
  adminMenu: boolean,
  cancelAll: boolean;
  startAll: boolean;
};

export type Settings = {
  IgnoreRoadsForGps: boolean;
  ShowGpsRoute: boolean;
  UseUglyWaypoint: boolean;
  CheckDistance: boolean;
  UseDrawTextWaypoint: boolean;
};

export type CreatorData = {
  Checkpoints: [];
  ConfirmDelete: boolean;
  ClosestCheckpoint: number;
  IsEdit: boolean;
  RaceDistance: number;
  RaceId: string;
  RaceName: string;
  RacerName: string;
  TireDistance: number;
};

export type Buttons = {
  IncreaseDistance: string;
  SaveRace: string;
  DecreaseDistance: string;
  Exit: string;
  DeleteCheckpoint: string;
  MoveCheckpoint: string;
  AddCheckpoint: string;
};

export type CrewMember = {
  citizenID: string;
  racername: string;
  rank: number;
};

export type Crew = {
  id: number;
  crewName: string;
  founderName: string;
  founderCitizenid: string;
  members: CrewMember[];
  wins: number;
  races: number;
  rank: number;
};

export type CrewList = Record<string, Crew>;

export type MyRacer = {
  auth: string;
  citizenid: string;
  id: number;
  lasttouched: number;
  racername: string;
  races: number;
  ranking: number;
  revoked: number;
  tracks: number;
  wins: number;
  createdby?: string;
  crew?: string;
};

export type ActiveHudData = {
  ClosestCheckpoint: number;
  InRace: boolean;
  InCreator: boolean;
};

export type CurrentRace = {
  trackName: string;
  racers: number;
  laps: number;
  class: string;
  canStart: boolean;
  ghosted: boolean;
  raceId: string;
  ghosting: boolean;
  ranked: boolean;
  reversed: boolean;
  hostName: string;
};

export type CheckpointTimes = {
  lap: number;
  checkpoint: number;
  time: number;
};

export type ActiveRacer = {
  Checkpoint: number;
  RacerSource: number;
  RacerName: string;
  PlayerVehicleEntity: number;
  Lap: number;
  Placement: number;
  Finished: boolean;
  CheckpointTimes: CheckpointTimes[];
};

export type ActiveRace = {
  currentCheckpoint: number;
  totalCheckpoints: number;
  totalLaps: number;
  currentLap: number;
  raceStarted: boolean;
  raceName: string;
  time: number;
  totalTime: number;
  bestLap: number;
  position: number;
  positions: ActiveRacer[];
  totalRacers: number;
  ghosted: boolean;
};

export type RacerName = {
  revoked: boolean;
  racername: string;
};

export type InputField = {
  value: number;
  text: string | number;
};

export type VehicleClass = {
  value: string;
  text: string;
  number: number;
};

export type Payments = {
  useRacingCrypto: string;
  cryptoType: string;
  racing: string;
  automationPayout: string;
  participationPayout: string;
  bountyPayout: string;
  createRacingUser: string;
  crypto: string;
};

export type Vehicle = {
  model: string;
  class: string;
}


export type BaseData = {
  data: {
    classes: VehicleClass[];
    currentVehicle?: Vehicle;
    laps: InputField[];
    buyIns: InputField[];
    participationCurrencyOptions: InputField[];
    moneyType: string;
    cryptoType: string;
    ghostingEnabled: boolean;
    ghostingTimes: InputField[];
    allowShare: boolean;
    racerNames: RacerName[];
    currentRacerName: string;
    currentRacerAuth: string;
    currentCrewName: string;
    currentCrypto: number;
    currentRanking: number;
    cryptoConversionRate: number;
    allowBuyingCrypto: boolean;
    allowSellingCrypto: boolean;
    allowTransferCrypto: boolean;
    showH2H: boolean;
    sellCharge: number;
    auth: Auth;
    hudSettings: { location: string; maxPositions: number };
    translations: Record<string, string>;
    anyoneCanCreate: boolean;
    isFirstUser: boolean;
    isUsingRacingCrypto: boolean;
    payments: Payments;
    hideMap: boolean;
    hideH2h: boolean;
    allAuthorities:Record<string, Auth>;
    dashboardSettings: DashboardSettings,
  };
};

export type Access = {
  race?: string;
};

export type TrackRecord = {
  Class: string;
  Holder: string;
  Time: number;
  Vehicle: string;
  RaceType: string;
  Reversed: boolean;
};

export type Result = {
  RacerName: string;
  TotalTime: number;
  BestLap: number;
  Ranking: number;
  RacingCrew?: string;
  TotalChange: number;
  VehicleModel: string;
  CarClass: string;
};

export type Coordinate = { x: number; y: number; z: number };

export type Checkpoint = {
  coords: Coordinate;
  offset: {
    left: Coordinate;
    right: Coordinate;
  };
};

export type Race = {
  Started: boolean
  Waiting: boolean
  RaceId: string
  TrackId: string
  Automated: boolean
  Ghosting: boolean
  SetupRacerName: string
  GhostingTime: number
  BuyIn: number
  Hidden: boolean
  Ranked: boolean
  Reversed: boolean
  FirstPerson: boolean
  ParticipationAmount: number
  ParticipationCurrency: number
  Racers: Racer[]
};

export type RaceRecord = {
  trackId: string,
  racerName: string,
  crew?: string,
  carClass: string,
  vehicleModel: string,
  raceType: string,
  time: number,
  reversed: number,
  pbHistory: string,
}

export type Track = {
  Access: Access;
  Checkpoints: Checkpoint[];
  Creator: string;
  CreatorName: string;
  Curated: number;
  Distance: number;
  LastLeaderboard: [];
  NumStarted: number;
  TrackId: string;
  RaceName: string;
  Racers: [];
  Started: boolean;
  Waiting: boolean;
  Metadata: TrackMetadata;
};

export type TrackResult = {
  id: number;
  raceId: string;
  raceName: string;
  trackId: string;
  results: string;
  amountOfRacers: number;
  laps: number;
  hostName: string;
  maxClass: string | null;
  ghosting: boolean;
  ranked: boolean;
  reversed: boolean;
  firstPerson: boolean;
  automated: boolean;
  hidden: boolean;
  silent: boolean;
  buyIn: number;
  data: string;
  timestamp: string;
};

export type Head2HeadRacer = {
  citizenId: string;
  racerName: string;
  source: number;
};

export type Head2HeadCurrent = {
  finishCoords: Coordinate[];
  finished: boolean;
  raceId: string;
  racers: Head2HeadRacer[];
  started: boolean;
};

export type Head2headData = {
  opponentId: string | undefined;
  inviteRaceId: string | undefined;
  invitee: string | undefined;
  current: Head2HeadCurrent;
};

export type TrackRaceStats = {
  trackId: string;
  trackName: string;
  avgParticipants: number;
  totalRaces: number;
  avgTime: number;
  bestTime: number;
  ghostingCount: number;
  rankedCount: number;
  firstPersonCount: number;
  automatedCount: number;
  silentCount: number;
  mostUsedMaxClass: string;
}

export type TopRacerStats = {
  topRacerWins: {
    racerName: string;
    wins: number;
  }[];
  topRacerWinLoss : {
    racerName: string;
    wins: number
    losses: number;
    winLoss: number;
  }[];
}