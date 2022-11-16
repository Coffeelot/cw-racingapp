var CreatorActive = false;
var RaceActive = false;

$(document).ready(function(){
    window.addEventListener('message', function(event){
        var data = event.data;

        if (data.action == "Update") {
            UpdateUI(data.type, data);
        } else if (data.action == "Countdown") {
            UpdateCountdown(data)
        }
    });
});

function secondsTimeSpanToHMS(s) {
    var m = Math.floor(s/60); //Get remaining minutes
    s -= m*60;
    return (m < 10 ? '0'+m : m)+":"+(s < 10 ? '0'+s : s); //zero padding on minutes and seconds
}

function UpdateCountdown(data) {
    if(typeof data.data.value == 'number') {
        $("#countdown-number").show();
        $("#countdown-number").html(data.data.value);
        $("#countdown-number").fadeOut(900);
    } else {
        $("#countdown-text").show();
        $("#countdown-text").html(data.data.value);
        $("#countdown-text").fadeOut(4000);
    }
}

function UpdateUI(type, data) {
    if (type == "creator") {
        if (data.active) {
            if (!CreatorActive) {
                CreatorActive = true;
                $(".editor").fadeIn(300);
                $("#editor-racename").html('Race: ' + data.data.RaceName);
                $("#editor-checkpoints").html('Checkpoints: ' + data.racedata.Checkpoints.length + ' / ?');
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
                $("#race-racename").html(data.data.RaceName);
                let totalRacers = data.data.TotalRacers
                if (!totalRacers) {
                    totalRacers = 0
                }
                $("#race-position").html(data.data.Position + ' / ' + totalRacers);
                $("#race-checkpoints").html(data.data.CurrentCheckpoint + ' / ' + data.data.TotalCheckpoints);
                if (data.data.TotalLaps == 0) {
                    $("#race-lap").html('Sprint');
                } else {
                    $("#race-lap").html(data.data.CurrentLap + ' / ' + data.data.TotalLaps);
                }
                $("#race-time").html(secondsTimeSpanToHMS(data.data.Time));
                if (data.data.BestLap !== 0) {
                    $("#race-besttime").html(secondsTimeSpanToHMS(data.data.BestLap));
                } else {
                    $("#race-besttime").html('N/A');
                }
                $("#race-totaltime").html(secondsTimeSpanToHMS(data.data.TotalTime));
            } else {
                $("#race-racename").html(data.data.RaceName);
                let totalRacers = data.data.TotalRacers
                if (!totalRacers) {
                    totalRacers = 0
                }
                $("#race-position").html(data.data.Position + ' / ' + totalRacers);
                $("#race-checkpoints").html(data.data.CurrentCheckpoint + ' / ' + data.data.TotalCheckpoints);
                if (data.data.TotalLaps == 0) {
                    $("#race-lap").html('Sprint');
                } else {
                    $("#race-lap").html(data.data.CurrentLap + ' / ' + data.data.TotalLaps);
                }
                $("#race-time").html(secondsTimeSpanToHMS(data.data.Time));
                if (data.data.BestLap !== 0) {
                    $("#race-besttime").html(secondsTimeSpanToHMS(data.data.BestLap));
                } else {
                    $("#race-besttime").html('N/A');
                }
                $("#race-totaltime").html(secondsTimeSpanToHMS(data.data.TotalTime));
                if (data.data.Ghosted) {
                    $("#race-ghosted-value").html('👻');
                    $("#race-ghosted-span").show();

                } else {
                    $("#race-ghosted-value").html('');
                    $("#race-ghosted-span").hide();
                }
            }
        } else {
            RaceActive = false;
            $(".editor").hide();
            $(".race").fadeOut(300);
        }
    }
}