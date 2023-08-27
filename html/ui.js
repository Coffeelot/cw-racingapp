let Debug = false
let RacingAppData = {}

let SelectedTrackIdSetup = undefined

let curatedDiv = `<span data-tooltip="This track is curated">⭐</span>`

function roundUpToPrecision(n, d) {
    let round = n.toPrecision(d);

    if(round === n.toString()) {
        return n;
    }

    return +(n + 0.5 * Math.pow(10, Math.floor(Math.log(n) * Math.LOG10E) - 1)).toPrecision(d);
}

function secondsTimeSpanToHMS(milli) {
    let milliseconds = milli % 1000;
    let seconds = Math.floor((milli / 1000) % 60);
    let minutes = Math.floor((milli / (60 * 1000)) % 60);
    minutes = (minutes < 10) ? "0" + minutes : minutes;
    seconds = (seconds < 10) ? "0" + seconds : seconds;

    return minutes + ":" + seconds + "." + String(milliseconds).slice(0,2);
}

function confirmSetupRace() {
    let track = SelectedTrackIdSetup
    let laps = $("#setup-race-laps option:selected").val();
    let buyin = $("#setup-race-buyin option:selected").val();
    let maxClass = $("#setup-race-class option:selected").val();
    let ghostingTime = $("#setup-race-time option:selected").val();

    let data = {
        track: track,
        laps: laps,
        buyIn: buyin,
        maxClass: maxClass,
        ghostingTime: ghostingTime
    }
    $.post('https://cw-racingapp/UiSetupRace', JSON.stringify(data), function(success){
        if (success) {
            if (Debug) console.log('Started a race')
            setTimeout(function(){
                $( "#defaultOpenTab-RacingPage" ).trigger( "click" );
            }, 200)
            
        }
    })
}

function setupRaceGoBack() {
    $(".setup-container").hide()
    $(".tracks-container").fadeIn(600);
    $("#setup-race-track-chosen").html('');    
}

function handleSelectRaceSetup(trackId, trackName) {
    SelectedTrackIdSetup = trackId
    $(".tracks-container").hide();
    $(".setup-container").fadeIn(600);
    $("#setup-race-track-chosen").html(trackName);
}

function selectCurrentActiveRace(trackName) {
    $(".current-races-container").hide();
    $(".current-race-container").fadeIn(600);
    $("#setup-race-track-chosen").html(trackName);
}

function openPage(pageName, elmnt) {
    // Hide all elements with class="tabcontent" by default */
    let i, pagecontent, pagelinks;
    pagecontent = document.getElementsByClassName("pagecontent");
    for (i = 0; i < pagecontent.length; i++) {
      pagecontent[i].style.display = "none";
    }
  
    // Remove the background color of all tablinks/buttons
    pagelinks = document.getElementsByClassName("pagelink");
    for (i = 0; i < pagelinks.length; i++) {
        pagelinks[i].classList.remove("selected-page");
    }
  
    // Show the specific tab content
    document.getElementById(pageName).style.display = "block";
  
    // Add the specific color to the button used to open the tab content
    elmnt.classList.add("selected-page");
    document.getElementById("defaultOpenTab-"+pageName).click();

}

function StartRace(raceId) {
    CloseRacingApp()

    $.post('https://cw-racingapp/UiStartCurrentRace', JSON.stringify(raceId), function(success){
    }, raceId )
    setTimeout(function(){
        $( "#defaultOpenTab-RacingPage" ).trigger( "click" );
    }, 1000)
}
function LeaveRace(raceId) {
    $.post('https://cw-racingapp/UiLeaveCurrentRace',JSON.stringify(raceId), function(success){
        $("#current-race-selection").html('')
        $('#current-race-none').show()
    })
}

function FetchCurrent() {
    $.post('https://cw-racingapp/UiFetchCurrentRace', function(result){
        if (result) {
            if (result.raceId) {
                $("#current-race-selection").css('display', 'flex')
                $("#current-race-selection").html('')
                $('#current-race-none').hide()
                let laps = result.laps
                if (laps == 0) laps = 'Sprint'

                let header = `<h3>${result.trackName}</h3>`
                let body = `<div> Max Class: ${result.class} </br> Total Laps: ${laps} </div>`
                let footer = `<div>Current Racers: ${result.racers}</div>`

                let leaveButton = `<button class="action-button secondary-button" onclick="LeaveRace('${result.raceId}')" id="setup-race-button"><span id="create-tab">Leave Race</span></button>`
                $("#current-race-selection").append(header)
                $("#current-race-selection").append(body)
                $("#current-race-selection").append(footer)
                if(!result.canStart) {
                    let startButton = `<button class="action-button" onclick="StartRace('${result.raceId}')" id="setup-race-button"><span id="create-tab">Start Race</span></button>`
                    $("#current-race-selection").append(startButton)
                }
                $("#current-race-selection").append(leaveButton)
            } else {
                $("#current-race-selection").hide()
                $('#current-race-none').show()
            }
        }
    })
}

function openTabs(tabName, elmnt) {
    if (Debug) console.log('================== Opened Tab:', tabName, '================== ')
    // Hide all elements with class="tabcontent" by default */
    let i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "none";
    }
  
    // Remove the background color of all tablinks/buttons
    tablinks = document.getElementsByClassName("tablink");
    for (i = 0; i < tablinks.length; i++) {
       tablinks[i].classList.remove("selected-tab");
    }
  
    // Show the specific tab content
    document.getElementById(tabName).style.display = "block";
  
    // Add the specific color to the button used to open the tab content
    elmnt.classList.add("selected-tab");
    if(tabName == "Current") FetchCurrent()
    if(tabName == "Available") GetListedRaces()
    if(tabName == "Results") GetResults()
    if(tabName == "Records") GetRecords()
    if(tabName == "MyTracks") GetMyTracks()

}

function ToggleLoaderOff(className) {
    $(`#${className}-loader`).hide()
    $(`.${className}`).show()
}
function ToggleLoaderOn(className) {
    $(`.${className}`).hide()
    $(`#${className}-loader`).css('display', 'flex')
}

function ToggleEmptyOff(className) {
    $(`#${className}-none`).hide()
    $(`.${className}`).show()
}
function ToggleEmptyOn(className) {
    $(`.${className}`).hide()
    $(`#${className}-none`).show()
}

let ConfirmIsOpen = false

function CloseConfirmation() {
    $('.confirmation-box').animate({
        bottom: '-=150px',
    });
    setTimeout(function(){
        $(".confirmation-header").html('')
        $(".confirmation-body").html('')
        $(".confirmation-footer").html('')
        ConfirmIsOpen = false
    }, 500)
}


function OpenConfirmation(header, body, footer) {
    if (ConfirmIsOpen) {
        $(".confirmation-header").html(header)
        $(".confirmation-body").html(body)
        $(".confirmation-footer").html(footer)  
    } else {
        ConfirmIsOpen = true
        $(".confirmation-header").html(header)
        $(".confirmation-body").html(body)
        $(".confirmation-footer").html(footer)
        $('.confirmation-box').animate({
            bottom: '+=150px',
        });
    }
}

function createCard(id, header, body, footer) {
    let element = `
        <div id="${id}" class="card">
            <div class="card-content">
                ${header}
                ${body}
                ${footer}
            </div>
        </div>
    `
    return element
}

// Get the element with id="defaultOpenPage" and click on it
document.getElementById("defaultOpenPage").click();

let Results
let Tracks

function HandleUpdateResults() {
    $('#results-items-table').html('')
    let selectedTrack = $("#results-track-selector option:selected").val();
    if (Debug) console.log('Selected track:', selectedTrack)
    if (Debug) console.log('Selected results:', JSON.stringify(Results[selectedTrack]))

    let type = "Sprint"
    if (Results[selectedTrack].Data.Laps > 0) type = "Circuit"
    $('#result-race-type').html(type)
    $('#result-race-host').html(Results[selectedTrack].Data.SetupRacerName)
    $('#result-race-creator').html(Results[selectedTrack].Data.RaceData.CreatorName)

    let amount = 0
    $.each(Results[selectedTrack].Result, function(i, val) {
        amount = amount+1
        let element = `
            <tr id="${i}" value="${i}" >
                <td class="result-row">
                    <span class="result-holder">
                        <span class="result-header"></span>
                        <span class="result-value first"> ${i+1}: ${val.RacerName} </span>
                    </span>
                </td>
                <td class="result-row">
                    <span class="result-holder">
                        <span class="result-header"> Time </span>
                        <span class="result-value"> ${ secondsTimeSpanToHMS(val.TotalTime)} </span>
                    </span>
                </td>
                <td class="result-row">
                    <span class="result-holder">
                            <span class="result-header"> Best Lap </span>
                            <span class="result-value"> ${val.BestLap > 0 ? secondsTimeSpanToHMS(val.BestLap) : 'N/A'} </span>
                    </span>
                </td>
                <td class="result-row">
                    <span class="result-holder">
                        <span class="result-header"> Vehicle </span>
                        <span class="result-value"> ${val.VehicleModel} </span>
                    </span>
                </td>
                <td class="result-row">
                    <span class="result-holder">
                        <span class="result-header"> Class </span>
                        <span class="result-value"> ${val.CarClass} </span>
                    </span>
                </td>
            </tr>
        `;
        $('#results-items-table').append(element)
    })
    if (amount == 0) {
        ToggleEmptyOn('results-items-table')
    } else {
        ToggleEmptyOff('results-items-table')
    }
}

function FilterResultsByClass(Records, selectedClass) {
    if (selectedClass) {
        let filteredRecords = []
        Records.forEach(Record => {
            if (Record.Class == selectedClass) filteredRecords.push(Record)
        });
        return filteredRecords
    } else {
        return Records
    }
}

function HandleUpdateRecords() {
    $('#records-items-table').html('')
    let selectedTrack = $("#records-track-selector option:selected").val();
    let selectedClass = $("#records-class-selector option:selected").val();
    if (Debug) console.log('Selected track:', selectedTrack)
    if (Debug) console.log('Selected class:', selectedClass)
    if (selectedTrack) {
        if (Debug) console.log('Selected records:', JSON.stringify(Tracks[selectedTrack]))
    
        $('#record-race-creator').html(Tracks[selectedTrack].CreatorName)
    
        let amount = 0
        $.each(FilterResultsByClass(Tracks[selectedTrack].Records, selectedClass), function(i, val) {
            amount = amount + 1
            let element = `
                <tr id="${i}" value="${i}" >
                    <td class="result-row">
                        <span class="result-holder">
                            <span class="result-header"></span>
                            <span class="result-value first"> ${i+1}: ${val.Holder} </span>
                        </span>
                    </td>
                    <td class="result-row">
                        <span class="result-holder">
                            <span class="result-header"> Time </span>
                            <span class="result-value"> ${ secondsTimeSpanToHMS(val.Time)} </span>
                        </span>
                    </td>
                    <td class="result-row">
                        <span class="result-holder">
                            <span class="result-header"> Vehicle </span>
                            <span class="result-value"> ${val.Vehicle} </span>
                        </span>
                    </td>
                    <td class="result-row">
                        <span class="result-holder">
                            <span class="result-header"> Class </span>
                            <span class="result-value"> ${val.Class} </span>
                        </span>
                    </td>
                    <td class="result-row">
                        <span class="result-holder">
                            <span class="result-header"> Type </span>
                            <span class="result-value"> ${val.RaceType ? val.RaceType : 'Unknown'} </span>
                        </span>
                    </td>
                </tr>
            `;
            $('#records-items-table').append(element)
        })
        if (amount == 0) {
            ToggleEmptyOn('records-items-table')
        } else {
            ToggleEmptyOff('records-items-table')
        }
    } else {
            ToggleEmptyOff('records-items-table')
    }
}

function GetRecords() {
    ToggleLoaderOn('records-items')
    $.post('https://cw-racingapp/UiGetTracks', function(result){
        if (result) {
            Tracks = result
            $('.records-container').show()
            $('#records-track-selector').html('')
            let amountResults = 0
            $.each(result, function(i, val) {
                if (Debug) console.log('Adding ' + val.RaceName + ' to record track list')
                amountResults = amountResults+1
                let element = `
                    <option id="${i}" value="${val.RaceId}">${val.RaceName}</option>
                `;
                $('#records-track-selector').append(element)
            })
            if(amountResults == 0) {
                $('.records-container').hide()
            }

            ToggleLoaderOff('records-items')
            HandleUpdateRecords()
        }
    })
}

function GetResults() {
    ToggleLoaderOn('results-items')
    $.post('https://cw-racingapp/UiGetRacingResults', function(result){
        if (result) {
            Results = result
            $('.results-container').show()
            $('#results-track-selector').html('')
            let amountResults = 0
            $.each(result, function(i, val) {
                amountResults = amountResults+1
                let element = `
                    <option id="${i}" value="${i}">${val.Data.RaceData.RaceName} | Race ID: ${val.Data.RaceId}</option>
                `;
                $('#results-track-selector').append(element)
            })
            if(amountResults == 0) {
                $('.results-container').hide()
                ToggleEmptyOn('results-container')
            } else {
                ToggleEmptyOff('results-container')
                ToggleLoaderOff('results-items')
                ToggleLoaderOff('records-items')
                HandleUpdateResults()
                HandleUpdateRecords()
            }
        }
    })
}

let joinableTracks 

function JoinRace(RaceId) {
    $.post('https://cw-racingapp/UiJoinRace', JSON.stringify(RaceId), function(success){
    })
}

// FOR AVAILABLE RACES TAB
function PopulateAvailableRaces(data) {
    $(".available-races").html('');
    joinableTracks = data
    $.each(data, function(i, track) {
        let ghostingText = ''
        if (track.Ghosting) {
            ghostingText = ' | 👻'
            if (track.GhostingTime) {
                ghostingText = ghostingText + ' ('+race.GhostingTime+'s)'
            }
        }

        let lapsText = 'Sprint |'
        if (track.laps>0) {
            lapsText = track.Laps + ' lap(s) |'
        }
        let stringifiedTrack = JSON.stringify(track)

        let joinButton = `<button class="action-button" onclick="JoinRace('${track.RaceData.RaceId}')" id="setup-race-button"><span id="create-tab">Join Race</span></button>`

        let element = `
        <div id="${track.RaceData.RaceId}-${i}" class="big-card", '${track.RaceData.name}')">
            <div class="card-content">
                <div class="card-header">${track.RaceData.RaceName}</div>
                <div class="card-body">${lapsText + track.RaceData.Distance+ 'm | ' +track.racers+ ' racer(s) | Class: ' + track.maxClass + ghostingText}</div>
                <div class="card-footer">${!track.disabled ? joinButton : ''}</div>
        </div>
        `;
        $(".available-races").append(element);
    })
}

function GetListedRaces() {
    ToggleLoaderOn('available-races')
    $.post('https://cw-racingapp/UiGetListedRaces', function(result){
        if (result) {
            PopulateAvailableRaces(result)
            ToggleLoaderOff('available-races')
        }
    })
}

let AvailableTracks
// FOR SETUP TAB

function handleShowTrack(RaceId) {
    $.post('https://cw-racingapp/UiShowTrack', JSON.stringify(RaceId), function(success){
        CloseRacingApp()
    })
}

function PopulateAvailableTracks() {
    $(".tracks-items").html('');
    let curatedOnly = $("#race-setup-curated-checkbox").is(':checked');
    $.each(AvailableTracks, function(i, track) {
        if (!curatedOnly || (curatedOnly && track.Curated)) {
            let setupTrackButton = `<button class="action-button small" onclick="handleSelectRaceSetup('${track.RaceId}', '${track.RaceName}')" id="setup-start-button"><span id="create-tab">Setup</span></button>`
            let showTrack = `<button class="action-button secondary-button small" onclick="handleShowTrack('${track.RaceId}')" id="setup-start-button"><span id="create-tab">Show Track</span></button>`


            let header = `<div class="card-header">${track.RaceName} ${track.Curated? curatedDiv:''}</div>`
            let body = `<div class="card-body">Creator: ${track.CreatorName} </br> Length: ${track.Distance} m</div>`
            let footer = `<div class="card-footer inline standardGap">${showTrack} ${setupTrackButton}</div>`
            let element = createCard(track.value, header, body, footer)
            $(".tracks-items").append(element);
        }
    })
}

function GetAvailableTracks() {
    $('#track-items-loader').css('display', 'flex')
    $('.tracks-items').hide()
    $.post('https://cw-racingapp/UiGetAvailableTracks', function(result){
        if (result) {
            AvailableTracks = result
            PopulateAvailableTracks()
            $('#track-items-loader').hide()
            $('.tracks-items').show()
        }
    })
}

function CloseRacingApp() {
    $('.ui-container').animate({
        height: '-=10px',
    });;
    $('.ui-container').fadeOut(500);
    $.post('https://cw-racingapp/UiCloseUi');
}


// My track functions
function HandleCreateTrack() {
    let name = $("#create-track-input").val();
    $.post('https://cw-racingapp/UiCreateTrack', JSON.stringify({name: name}), function(success){
        if (success) {
            if (Debug) console.log('Started a race')
            setTimeout(function(){
                $( "#defaultOpenTab-RacingPage" ).trigger( "click" );
            }, 200)
            
        }
    })
}

function ClearLeaderboardConfirm(RaceId, RaceName) {
    if (Debug) console.log('Confirmed clear leaderboard for', RaceId)
    $.post('https://cw-racingapp/UiClearLeaderboard', JSON.stringify({RaceName: RaceName, RaceId: RaceId}), function(success){
        if (success) {
            if (Debug) console.log('Leaderboard was cleared:', success)
            CloseConfirmation()
            ToggleLoaderOn('mytracks-items')
            setTimeout(function(){
                $( "#defaultOpenTab-MyTracksPage" ).trigger( "click" );
            }, 1000)
        }
    })
}

function ClearLeaderboard(RaceId, RaceName) {
    let header = `Clear Leaderboards For '${RaceName}'?`
    let body = "This can not be undone!"
    let footer = `<button class="action-button small" onclick="ClearLeaderboardConfirm('${RaceId}', '${RaceName}')" id="mytracks-delete-button"><span id="create-tab">Confirm</span></button>`
    OpenConfirmation(header, body, footer)
}

function OpenTrackEditor(RaceId, RaceName) {
    $.post('https://cw-racingapp/UiEditTrack', JSON.stringify({RaceName: RaceName, RaceId: RaceId}), function(success){
        if (success) {
            CloseConfirmation()
            CloseRacingApp()
        }
    })
}

function EditTrack(RaceId, RaceName) {
    let header = `Open track editor For '${RaceName}'?`
    let body = ""
    let footer = `<button class="action-button small" onclick="OpenTrackEditor('${RaceId}', '${RaceName}')" id="mytracks-edit-button"><span id="create-tab">Confirm</span></button>`
    OpenConfirmation(header, body, footer)
}

function EditAccessConfirm(RaceId, RaceName) {
    if (Debug) console.log('Confirmed edit access for', RaceName)
    let access = { race: $("#edit-track-access-input").val() };
    if (Debug) console.log('New Access:', access)
    $.post('https://cw-racingapp/UiEditAccess', JSON.stringify({RaceName: RaceName, RaceId: RaceId, NewAccess: access}), function(success){
        if (success) {
            if (Debug) console.log('Leaderboard was cleared:', success)
            CloseConfirmation()
            ToggleLoaderOn('mytracks-items')
            setTimeout(function(){
                $( "#defaultOpenTab-MyTracksPage" ).trigger( "click" );
            }, 1000)
        }
    })
}

function EditAccessTrack(RaceId, RaceName, Access) {
    if (Debug) console.log('Edit Access', RaceName)
    $.post('https://cw-racingapp/UiGetAccess', JSON.stringify({RaceName: RaceName, RaceId: RaceId}), function(result){
        if (result) {
            
            let header = `Delete track: '${RaceName}'?`
            let body = `<div class="option"> <span class="option-title">Start Race</span><input type="text" placeholder="Racenames, separate by commas" id="edit-track-access-input" value="${result.race}"></div>`
            let footer = `<button class="action-button small" onclick="EditAccessConfirm('${RaceId}', '${RaceName}')" id="mytracks-delete-button"><span id="create-tab">Confirm</span></button>`
            OpenConfirmation(header, body, footer)
        }
    })
}

function DeleteTrackConfirm(RaceId, RaceName) {
    if (Debug) console.log('Confirmed deletion of ', RaceId)
    $.post('https://cw-racingapp/UiDeleteTrack', JSON.stringify({RaceName: RaceName, RaceId: RaceId}), function(success){
        if (success) {
            if (Debug) console.log('Track was deleted:', success)
            CloseConfirmation()
            ToggleLoaderOn('mytracks-items')
            setTimeout(function(){
                $( "#defaultOpenTab-MyTracksPage" ).trigger( "click" );
            }, 1000)
        }
    })
}

function DeleteTrack(RaceId, RaceName) {
    if (Debug) console.log('Deleting track', RaceName)
    let header = `Delete track: '${RaceName}'?`
    let body = "This can not be undone!"
    let footer = `<button class="action-button small" onclick="DeleteTrackConfirm('${RaceId}', '${RaceName}')" id="mytracks-delete-button"><span id="create-tab">Confirm</span></button>`
    OpenConfirmation(header, body, footer)
}

function GetMyTracks() {
    ToggleLoaderOn('mytracks-items')
    $.post('https://cw-racingapp/UiGetMyTracks', function(result){
        if (result) {
            Tracks = result
            $('.mytracks-items').show()
            $('.mytracks-items').html('')
            let amountResults = 0
            $.each(result, function(i, track) {
                ToggleEmptyOff('mytracks-items')
                amountResults = amountResults+1
                let clearLeaderboardButton = `<button class="action-button secondary-button small" onclick="ClearLeaderboard('${track.RaceId}', '${track.RaceName}')" id="mytracks-clear-button"><span id="create-tab">Clear LB</span></button>`
                let editTrackButton = `<button class="action-button secondary-button small" onclick="EditTrack('${track.RaceId}', '${track.RaceName}')" id="mytracks-edit-button"><span id="create-tab">Edit</span></button>`
                let editAccessButton = `<button class="action-button secondary-button small" onclick="EditAccessTrack('${track.RaceId}', '${track.RaceName}')" id="mytracks-edit-access-button"><span id="create-tab">Access</span></button>`
                let deleteTrackButton = `<button class="action-button secondary-button small" onclick="DeleteTrack('${track.RaceId}', '${track.RaceName}')" id="mytracks-delete-button"><span id="create-tab">Delete</span></button>`
                let element = `
                    <div id="${track.RaceId}-${i}" class="big-card">
                        <div class="card-content">
                            <div class="card-header">${track.RaceName} | ${track.RaceId} ${track.Curated ? ' | ' + curatedDiv :'' }</div>
                            <div class="card-body">${track.Distance+ 'm'} | ${track.Checkpoints.length + ' checkpoints'}</div>
                            <div class="card-footer standardGap inline">${clearLeaderboardButton}${!track.Curated ? editTrackButton:''}${editAccessButton}${deleteTrackButton}</div>
                    </div>
                `;
                $('.mytracks-items').append(element)
            })
            if(amountResults == 0) {
                ToggleEmptyOn('mytracks-items')
            }

            ToggleLoaderOff('mytracks-items')
            HandleUpdateRecords()
        }
    })
}

function OpenRacingApp() {
    GetAvailableTracks();
    $('.ui-container').fadeIn(100);
    $('.ui-container').animate({
        height: '+=10px',
    });;

}

$(document).on('keydown', function(event) {
    switch(event.keyCode) {
        case 27:
            CloseRacingApp();
            break;
    }
});

// // for debug. 
// $(document).on('keydown', function(event) {
//     switch(event.keyCode) {
//         case 20:
//             $('.slider').toggleClass('close-confirmation');
//             break;
//     }
// });

function DoSetup() {
    // SETUP

    //laps
    $('#setup-race-laps').html()
    $.each(RacingAppData.laps, function(i, val) {
        let element = `
        <option id="${val.value}" value="${val.value}" >${val.text}</option>
        `;
        $('#setup-race-laps').append(element)
    })

    //buyin
    $('#setup-race-buyin').html()
    $.each(RacingAppData.buyIns, function(i, val) {
        let element = `
        <option id="${val.value}" value="${val.value}">${val.text}</option>
        `;
        $('#setup-race-buyin').append(element)
    })

    //ghosting
    if (RacingAppData.ghostingEnabled) {
        $('#setup-race-time').html()
        $.each(RacingAppData.ghostingTimes, function(i, val) {
            let element = `
            <option id="${val.value}" value="${val.value}">${val.text}</option>
            `;
            $('#setup-race-time').append(element)
        })
    } else {
        $('#ghosting-option-setup').hide()
    }
    //class
    $('#setup-race-class').html()
    $.each(RacingAppData.classes, function(i, val) {
        let element = `
        <option id="${val.value}" value="${val.value}">${val.text}</option>
        `;
        $('#setup-race-class').append(element)
    })
    $('#records-class-selector').html()
    $.each(RacingAppData.classes, function(i, val) {
        let element = `
        <option id="${val.value}" value="${val.value}">${val.text}</option>
        `;
        $('#records-class-selector').append(element)
    })
}

$(document).ready(function(){
    $('.ui-container').hide();
    $('.ui-container').animate({
        height: '-=10px',
    });

    $.post('https://cw-racingapp/GetBaseData', function(setup){
        if (Debug) console.log(JSON.stringify(setup))
        RacingAppData = setup
        DoSetup()
    })
    window.addEventListener('message', function(event){
        let data = event.data;
        if (data.open == true) {
            if (Debug) console.log(JSON.stringify(RacingAppData))
            OpenRacingApp()
        }
    });
});
