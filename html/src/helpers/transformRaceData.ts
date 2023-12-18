export const transformRaceData = (raceData: any) => {
    return {
        raceName: raceData.RaceName,
        checkpoints: raceData.Checkpoints,
        totalRacers: raceData.TotalRacers,
        currentCheckpoint: raceData.CurrentCheckpoint,
        totalLaps: raceData.TotalLaps,
        currentLap: raceData.CurrentLap,
        time: raceData.Time,
        bestLap: raceData.BestLap,
        totalTime: raceData.TotalTime,
        position: raceData.Position,
        positions: raceData.Positions,
        ghosted: raceData.Ghosted,
        racers: raceData.Racers
    }
}