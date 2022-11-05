var CreatorActive = false;
var RaceActive = false;

$(document).ready(function(){
    window.addEventListener('message', function(event){
        var data = event.data;

        if (data.action == "Update") {
            UpdateUI(data.type, data);
        }
    });
});

function secondsTimeSpanToHMS(s) {
    var h = Math.floor(s/3600); //Get whole hours
    s -= h*3600;
    var m = Math.floor(s/60); //Get remaining minutes
    s -= m*60;
    return h+":"+(m < 10 ? '0'+m : m)+":"+(s < 10 ? '0'+s : s); //zero padding on minutes and seconds
}

function UpdateUI(type, data) {
    if (type == "creator") {
        if (data.active) {
            if (!CreatorActive) {
                CreatorActive = true;
                $(".editor").fadeIn(300);
                $("#editor-racename").html('Race: ' + data.data.RaceName);
                $("#editor-checkpoints").html('Checkpoints: ' + data.data.Checkpoints.length + ' / ?');
                $("#editor-keys-tiredistance").html('<span style="color: rgb(0, 201, 0);">+ ] </span> / <span style="color: rgb(255, 43, 43);">- [</span> - Tire Distance ['+data.data.TireDistance+'.0]');
                if (data.racedata.ClosestCheckpoint !== undefined && data.racedata.ClosestCheckpoint !== 0) {
                    $("#editor-keys-delete").html('<span style="color: rgb(255, 43, 43);">8</span> - Delete Checkpoint [' + data.racedata.ClosestCheckpoint + ']');
                } else {
                    $("#editor-keys-delete").html("");
                }
            } else {
                $("#editor-racename").html('Race: ' + data.data.RaceName);
                $("#editor-checkpoints").html('Checkpoints: ' + data.data.Checkpoints.length + ' / ?');
                $("#editor-keys-tiredistance").html('<span style="color: rgb(0, 201, 0);">+ ] </span> / <span style="color: rgb(255, 43, 43);">- [</span> - Tire Distance ['+data.data.TireDistance+'.0]');
                if (data.racedata.ClosestCheckpoint !== undefined && data.racedata.ClosestCheckpoint !== 0) {
                    $("#editor-keys-delete").html('<span style="color: rgb(255, 43, 43);">8</span> - Delete Checkpoint [' + data.racedata.ClosestCheckpoint + ']');
                } else {
                    $("#editor-keys-delete").html("");
                }
            }
        } else {
            CreatorActive = false;
            $(".editor").fadeOut(300);
        }
    } else if (type == "race") {
        if (data.active) {
            if (!RaceActive) {
                RaceActive = true;
                $(".editor").hide();
                $(".race").fadeIn(300);
                $("#race-racename").html('Race: ' + data.data.RaceName);
                $("#race-checkpoints").html('Checkpoint: ' + data.data.CurrentCheckpoint + ' / ' + data.data.TotalCheckpoints);
                if (data.data.TotalLaps == 0) {
                    $("#race-lap").html('Round: Sprint');
                } else {
                    $("#race-lap").html('Round: ' + data.data.CurrentLap + ' / ' + data.data.TotalLaps);
                }
                $("#race-time").html('Round Time: ' + secondsTimeSpanToHMS(data.data.Time));
                if (data.data.BestLap !== 0) {
                    $("#race-besttime").html('Best Round: ' + secondsTimeSpanToHMS(data.data.BestLap));
                } else {
                    $("#race-besttime").html('Best Round: N/A');
                }
                $("#race-totaltime").html('Total Time: ' + secondsTimeSpanToHMS(data.data.TotalTime));
            } else {
                $("#race-racename").html('Race: ' + data.data.RaceName);
                $("#race-checkpoints").html('Checkpoint: ' + data.data.CurrentCheckpoint + ' / ' + data.data.TotalCheckpoints);
                if (data.data.TotalLaps == 0) {
                    $("#race-lap").html('Round: Sprint');
                } else {
                    $("#race-lap").html('Round: ' + data.data.CurrentLap + ' / ' + data.data.TotalLaps);
                }
                $("#race-time").html('Round Time: ' + secondsTimeSpanToHMS(data.data.Time));
                if (data.data.BestLap !== 0) {
                    $("#race-besttime").html('Best Round: ' + secondsTimeSpanToHMS(data.data.BestLap));
                } else {
                    $("#race-besttime").html('Best Round: N/A');
                }
                $("#race-totaltime").html('Total Time: ' + secondsTimeSpanToHMS(data.data.TotalTime));
            }
        } else {
            RaceActive = false;
            $(".editor").hide();
            $(".race").fadeOut(300);
        }
    }
}