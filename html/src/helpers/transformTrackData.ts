export const transformTrackData = (racename: string, trackData: any, buttons: any) => {
    return {
        raceName: racename,
        checkpoints: trackData.Checkpoints,
        closestCheckpoint: trackData.ClosestCheckpoint,
        tireDistance: trackData.TireDistance,
        buttons: {
          add: buttons.AddCheckpoint,
          delete: buttons.DeleteCheckpoint,
          move: buttons.MoveCheckpoint,
          increaseDist: buttons.IncreaseDistance,
          decreaseDist: buttons.DecreaseDistance,
          exit: buttons.Exit,
          save: buttons.SaveRace
        }
    }
}