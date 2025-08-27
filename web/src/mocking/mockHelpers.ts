import { TopRacerStats, TrackRaceStats } from "@/store/types";

// --- Random helpers ---
const words = [
  "Coffee", "God", "Lady", "Tea", "Summer", "Pizza", "Nasty", "Hamburger", "Bread", "Turbo", "Drift", "King", "Queen", "Cool", "Crew", "Squad", "Maker", "Demon", "Rider", "Drop", "Table", "Soprano", "Walnuts", "Paradym", "Chicken", "Rice", "Ice", "Cream", "Flower", "Plant", "Agent 47", "Tony"
];

function randomWord() {
  return words[Math.floor(Math.random() * words.length)];
}

function randomName() {
  return `${randomWord()}${randomWord()}`;
}

function randomCrewName() {
  return `${randomWord()} ${randomWord()}`;
}

function randomCitizenId() {
  // 2 uppercase + 4 digits
  const letters = () => String.fromCharCode(65 + Math.floor(Math.random() * 26));
  const digits = () => Math.floor(Math.random() * 10);
  return `${letters()}${letters()}${digits()}${digits()}${digits()}${digits()}`;
}

function randomCarClass() {
  return ["A", "B", "C", "S", "D", "X"][Math.floor(Math.random() * 6)];
}

function randomVehicle() {
  return ["Ariant", "Argento", "Futo", "ELEGYX", "Atlas", "Sultan3", "Jester3", "Tailgater2", "RemusTwo", "Altior", "Tulip", "Rhinehart"][Math.floor(Math.random() * 12)];
}

// --- Race Result Row ---
export function randomRaceResult(): any {
  return {
    RacingCrew: randomCrewName(),
    RacerSource: 1,
    RacerName: randomName(),
    TotalTime: Math.floor(Math.random() * 30000) + 10000,
    CarClass: randomCarClass(),
    BestLap: Math.floor(Math.random() * 30000) + 10000,
    Ranking: Math.floor(Math.random() * 500) + 1,
    VehicleModel: randomVehicle(),
  };
}
export const mockRandomRaceResults = Array.from({ length: 100 }, randomRaceResult);

// --- Crew Row ---
export function randomCrewResult(): any {
  const founderName = randomName();
  const founderCitizenID = randomCitizenId();
  return {
    id: Math.floor(Math.random() * 10000),
    founderName,
    members: [
      {
        citizenID: founderCitizenID,
        rank: 0,
        racername: founderName,
      },
    ],
    crewName: randomCrewName(),
    founderCitizenid: founderCitizenID,
    rank: Math.floor(Math.random() * 20) + 1,
    races: Math.floor(Math.random() * 50),
    wins: Math.floor(Math.random() * 20),
  };
}
export const mockRandomCrewResults = Array.from({ length: 40 }, randomCrewResult);
export const mockCrewResults = mockRandomCrewResults;

// --- Racer Row ---
export function randomRacerResult(): any {
  const name = randomName();
  const citizenid = randomCitizenId();
  const createdby = randomCitizenId();
  const crew = Math.random() > 0.5 ? randomCrewName() : undefined;
  const auths = ["racer", "creator", "god", "master"];
  const auth = auths[Math.floor(Math.random() * auths.length)];
  const ranking = Math.floor(Math.random() * 200000);
  const wins = Math.floor(Math.random() * 20);
  const races = wins + Math.floor(Math.random() * 20);
  const crypto = Math.floor(Math.random() * 5000);
  const active = Math.random() > 0.2 ? 1 : 0;
  const revoked = 0;
  const tracks = Math.floor(Math.random() * 5);
  const lasttouched = Date.now() - Math.floor(Math.random() * 1000000000);

  return {
    auth,
    ranking,
    lasttouched,
    racername: name,
    createdby,
    id: Math.floor(Math.random() * 10000),
    revoked,
    tracks,
    citizenid,
    active,
    wins,
    races,
    crypto,
    crew,
  };
}
export const mockRandomRacersResults = Array.from({ length: 90 }, randomRacerResult);


export function randomTrackRecord(): any {
  return {
    racerName: randomName(),
    timestamp: Date.now() - Math.floor(Math.random() * 1000000000),
    trackId: `TR-${Math.floor(Math.random() * 9000 + 1000)}`,
    time: Math.floor(Math.random() * 30000) + 5000,
    vehicleModel: randomVehicle(),
    reversed: Math.random() > 0.5,
    carClass: randomCarClass(),
    id: Math.floor(Math.random() * 10000),
    raceType: ["Circuit", "Sprint", "Elimination"][Math.floor(Math.random() * 3)],
  };
}
export const mockRandomTrackResults = () => Array.from({ length: 40 }, randomTrackRecord)

// Generates a single mock track race stats object
function randomTrackRaceStats(): TrackRaceStats {
  const trackId = `TR-${Math.floor(Math.random() * 9000 + 1000)}`;
  const trackName = randomName();
  const totalRaces = Math.floor(Math.random() * 40) + 1;
  const avgParticipants = Math.round(Math.random() * 10 + 2);
  const avgTime = Math.floor(Math.random() * 30000) + 12000;
  const bestTime = avgTime - Math.floor(Math.random() * 5000);
  const ghostingCount = Math.floor(Math.random() * 20);
  const rankedCount = Math.floor(Math.random() * 20);
  const firstPersonCount = Math.floor(Math.random() * 10);
  const automatedCount = Math.floor(Math.random() * 5);
  const silentCount = Math.floor(Math.random() * 5);
  const mostUsedMaxClass = randomCarClass();

  return {
    trackId,
    trackName,
    totalRaces,
    avgParticipants,
    avgTime,
    bestTime,
    ghostingCount,
    rankedCount,
    firstPersonCount,
    automatedCount,
    silentCount,
    mostUsedMaxClass,
  };
}

// Generates a mock list of track race stats for a week
export function mockTrackRaceStatsForWeek(count = 10): TrackRaceStats[] {
  // return []
  return Array.from({ length: count }, randomTrackRaceStats);
}

function randomTrackRaceStatsForTrack(trackId: string, trackName: string): TrackRaceStats {
  const totalRaces = Math.floor(Math.random() * 40) + 1;
  const avgParticipants = Math.round(Math.random() * 10 + 2);
  const avgTime = Math.floor(Math.random() * 30000) + 12000;
  const bestTime = avgTime - Math.floor(Math.random() * 5000);
  const ghostingCount = Math.floor(Math.random() * 20);
  const rankedCount = Math.floor(Math.random() * 20);
  const firstPersonCount = Math.floor(Math.random() * 10);
  const automatedCount = Math.floor(Math.random() * 5);
  const silentCount = Math.floor(Math.random() * 5);
  const mostUsedMaxClass = randomCarClass();

  return {
    trackId,
    trackName,
    totalRaces,
    avgParticipants,
    avgTime,
    bestTime,
    ghostingCount,
    rankedCount,
    firstPersonCount,
    automatedCount,
    silentCount,
    mostUsedMaxClass,
  };
}

// Generates a mock list of track race stats for all tracks in testState
export function mockTopRacerStats(): TopRacerStats {
  // return { topRacerWins: [], topRacerWinLoss: [] };
  // Generate 3 unique racer names
  const racers = Array.from({ length: 5 }, () => randomName());

  // Generate consistent wins/losses for each racer
  const stats = racers.map((racerName, i) => {
    // Higher index = fewer wins, more losses
    const wins = Math.floor(Math.random() * 10) + (3 - i) * 2 + 1;
    const losses = Math.floor(Math.random() * 10) + i + 1;
    const winLoss = (wins + losses) > 0 ? wins / (wins + losses) : wins > 0 ? 999 : 0;
    return { racerName, wins, losses, winLoss };
  });

  // Sort for each table as needed
  const topRacerWins = [...stats].sort((a, b) => b.wins - a.wins).map(({ racerName, wins }) => ({ racerName, wins }));
  const topRacerWinLoss = [...stats].sort((a, b) => b.winLoss - a.winLoss);

  return { topRacerWins, topRacerWinLoss };
}