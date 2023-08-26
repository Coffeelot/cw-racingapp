var CreatorActive = false;
var RaceActive = false;

function roundUpToPrecision(n, d) {
    var round = n.toPrecision(d);

    if(round === n.toString()) {
        return n;
    }

    return +(n + 0.5 * Math.pow(10, Math.floor(Math.log(n) * Math.LOG10E) - 1)).toPrecision(d);
}

function secondsTimeSpanToHMS(milli) {
    var milliseconds = milli % 1000;
    var seconds = Math.floor((milli / 1000) % 60);
    var minutes = Math.floor((milli / (60 * 1000)) % 60);
    minutes = (minutes < 10) ? "0" + minutes : minutes;
    seconds = (seconds < 10) ? "0" + seconds : seconds;

    return minutes + ":" + seconds + "." + String(milliseconds).slice(0,2);
}


function UpdateCountdown(data) {
    console.log('HOHO')
    if(typeof data.data.value == 'number') {
        $(".number-holder").show();
        $("#countdown-number").show();
        $("#countdown-number").html(data.data.value);
        $("#countdown-number").fadeOut(900);
        $(".number-holder").fadeOut(900);
    } else {
        $("#countdown-text").show();
        $("#countdown-text").html(data.data.value);
        $("#countdown-text").fadeOut(4000);
    }
}

function updatePositions(positions) {
    $(".racer-positions").html('');

    $.each(positions, function(i, driver) {
        let element = `<span class="racer-position"><span class="racer-position-number"> ${i+1}: </span><span id="${i}" class="racer-position-name"> ${driver.RacerName}  </span></span>`;
        $(".racer-positions").append(element);
    });
}

function UpdateUI(type, data) {
    if (type == "creator") {
        if (data.active) {
            if (!CreatorActive) {
                CreatorActive = true;
                $(".editor").fadeIn(300);
                $("#editor-racename").html('Race: ' + data.data.RaceName);
                if (data.racedata.Checkpoints) {
                    $("#editor-checkpoints").html('Checkpoints: ' + data.racedata.Checkpoints.length + ' / ?');
                }
                $("#editor-keys-add-button").html(data.buttons.AddCheckpoint);
                $("#editor-keys-delete-button").html(data.buttons.DeleteCheckpoint);
                $("#editor-keys-edit-button").html(data.buttons.MoveCheckpoint);
                $("#editor-keys-tiredistance").html('<span style="color: rgb(0, 201, 0);">'+ data.buttons.IncreaseDistance +' </span> / <span style="color: rgb(255, 43, 43);">'+ data.buttons.DecreaseDistance+'</span> - Tire Distance ['+data.data.TireDistance+'.0]');
                if (data.racedata.ClosestCheckpoint !== undefined && data.racedata.ClosestCheckpoint !== 0) {
                    $("#editor-keys-delete").html('<span style="color: rgb(255, 43, 43);">'+data.buttons.DeleteCheckpoint+'</span> - Delete Checkpoint [' + data.racedata.ClosestCheckpoint + ']');
                } else {
                    $("#editor-keys-delete").html("");
                }
                $("#editor-keys-cancel-button").html(data.buttons.Exit);
                $("#editor-keys-save-button").html(data.buttons.SaveRace);

            } else {
                $("#editor-racename").html('Race: ' + data.data.RaceName);
                if (data.racedata.Checkpoints) {
                    $("#editor-checkpoints").html('Checkpoints: ' + data.racedata.Checkpoints.length + ' / ?');
                }
                $("#editor-keys-tiredistance").html('<span style="color: rgb(0, 201, 0);">'+ data.buttons.IncreaseDistance +' </span> / <span style="color: rgb(255, 43, 43);">'+ data.buttons.DecreaseDistance+'</span> - Tire Distance ['+data.data.TireDistance+'.0]');
                if (data.racedata.ClosestCheckpoint !== undefined && data.racedata.ClosestCheckpoint !== 0) {
                    $("#editor-keys-delete").html('<span style="color: rgb(255, 43, 43);">'+data.buttons.DeleteCheckpoint+'</span> - Delete Checkpoint [' + data.racedata.ClosestCheckpoint + ']');
                } else {
                    $("#editor-keys-delete").html("");
                }
                $("#editor-keys-cancel-button").html(data.buttons.Exit);
                $("#editor-keys-save-button").html(data.buttons.SaveRace);
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
                updatePositions(data.data.Positions)
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
                updatePositions(data.data.Positions)
            }
        } else {
            RaceActive = false;
            $(".editor").hide();
            $(".race").fadeOut(300);
        }
    }
}


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