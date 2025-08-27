import { mockRandomCrewResults, mockRandomRaceResults, mockRandomRacersResults } from "./mockHelpers";
import { ActiveRace, Track } from "../store/types";

/* eslint-disable no-loss-of-precision */
export const testState = {
  appIsOpen: true,
  hudIsOpen: false,
  currentPage: "dashboard",
  currentTab: {
    racing : 'current',
    results: 'results'
  },
  showOnlyCurated: true,
  activeRace: {},
  activeHudData: {},
  countdown: -1,
  buttons: {},
  creatorData: {},
  head2headData: {
    inviteRaceId: 'Snickers',
    opponentId: 'PX6944',
  },

  baseData: { 
    data: {
      currentCrewName: "Coffee Sippers",
      allowBuyingCrypto: true,
      allowSellingCrypto: true,
      allowShare: true,
      allowTransferCrypto: true,
      anyoneCanCreate: true,
      showH2H: true,
      dashboardSettings: {
        enabled: true, 
        defaultDaysBack: 200,
        defaultTopRacers: 5,
      },
      allAuthorities: {
        racer: {
          join: true,
          records: true,
          setup: true,
          create: false,
          control: false,
          controlAll: false,
          createCrew: true,
          startRanked: false,
          startElimination: false,
          startReversed: true,
          setupParticipation: false,
          curateTracks: false,
          handleBounties: false,
          handleAutoHost: false,
          handleHosting: false,
          adminMenu: false,
          cancelAll: false,
          startAll: false,
        },
        creator: {
          join: true,
          records: true,
          setup: true,
          create: true,
          control: false,
          controlAll: false,
          createCrew: true,
          startRanked: false,
          startElimination: false,
          startReversed: true,
          setupParticipation: false,
          curateTracks: false,
          handleBounties: false,
          handleAutoHost: false,
          handleHosting: false,
          adminMenu: false,
          cancelAll: false,
          startAll: false,
        },
        master: {
          join: true,
          records: true,
          setup: true,
          create: true,
          control: true,
          controlAll: false,
          createCrew: true,
          startRanked: true,
          startElimination: true,
          startReversed: true,
          setupParticipation: false,
          curateTracks: true,
          handleBounties: true,
          handleAutoHost: true,
          handleHosting: true,
          adminMenu: true,
          cancelAll: true,
          startAll: false,
        },
        god: {
          join: true,
          records: true,
          setup: true,
          create: true,
          control: true,
          controlAll: true,
          createCrew: true,
          startRanked: true,
          startElimination: true,
          startReversed: true,
          setupParticipation: true,
          curateTracks: true,
          handleBounties: true,
          handleAutoHost: true,
          handleHosting: true,
          adminMenu: true,
          cancelAll: true,
          startAll: true,
        },
      },
      auth: {
        join: true,
        records: true,
        setup: true,
        create: true,
        control: true,
        controlAll: true,
        createCrew: true,
        startRanked: true,
        startElimination: true,
        startReversed: true,
        setupParticipation: true,
        curateTracks: true,
        handleBounties: true,
        handleAutoHost: true,
        handleHosting: true,
        adminMenu: true,
        cancelAll: true,
        startAll: true,
      },
      buyIns: [
        {
          text: "Nothing",
          value: 0,
        },
        {
          text: 10,
          value: 10,
        },
        {
          text: 20,
          value: 20,
        },
        {
          text: 50,
          value: 50,
        },
        {
          text: 100,
          value: 100,
        },
        {
          text: 200,
          value: 200,
        },
        {
          text: 500,
          value: 500,
        },
        {
          text: 1000,
          value: 1000,
        },
      ],
      classes: [
        {
          number: 9000,
          text: "No class limit",
          value: "",
        },
        {
          number: 1000,
          text: "X",
          value: "X",
        },
        {
          number: 800,
          text: "S",
          value: "S",
        },
        {
          number: 600,
          text: "A",
          value: "A",
        },
        {
          number: 400,
          text: "B",
          value: "B",
        },
        {
          number: 350,
          text: "C",
          value: "C",
        },
        {
          number: 250,
          text: "D",
          value: "D",
        },
      ],
      cryptoConversionRate: 0.01,
      cryptoType: "RAC",
      currentCrypto: 0,
      currentRacerAuth: "master",
      currentRacerName: "CoffeeGod",
      currentRanking: 0,
      ghostingEnabled: true,
      ghostingTimes: [
        {
          text: "Off",
          value: -1,
        },
        {
          text: "Always",
          value: 0,
        },
        {
          text: "10 s",
          value: 10000,
        },
        {
          text: "30 s",
          value: 30000,
        },
        {
          text: "60 s",
          value: 60000,
        },
        {
          text: "120 s",
          value: 120000,
        },
      ],
      currentVehicle: {
          class: "A",
          model: "Ariant"
      },
      hudSettings: {
        location: "split",
        maxPositions: 5,
      },
      isFirstUser: false,
      isUsingRacingCrypto: true,
      laps: [
        {
          text: "Elimination",
          value: -1,
        },
        {
          text: "Sprint",
          value: 0,
        },
        {
          text: 1,
          value: 1,
        },
        {
          text: 2,
          value: 2,
        },
        {
          text: 3,
          value: 3,
        },
        {
          text: 4,
          value: 4,
        },
        {
          text: 5,
          value: 5,
        },
        {
          text: 6,
          value: 6,
        },
        {
          text: 7,
          value: 7,
        },
        {
          text: 8,
          value: 8,
        },
        {
          text: 9,
          value: 9,
        },
        {
          text: 10,
          value: 10,
        },
      ],
      moneyType: "racingcrypto",
      participationCurrencyOptions: [
        {
          title: "RAC",
          value: "racingcrypto",
        },
        {
          title: "Cash",
          value: "cash",
        },
        {
          title: "Bank",
          value: "bank",
        },
      ],
      payments: {
        automationPayout: "racingcrypto",
        bountyPayout: "racingcrypto",
        createRacingUser: "bank",
        crypto: "cash",
        cryptoType: "RAC",
        participationPayout: "racingcrypto",
        racing: "racingcrypto",
        useRacingCrypto: true,
      },
      primaryColor: "#2ca6b9",
      racerNames: [
        {
          active: 0,
          auth: "god",
          citizenid: "PX6944",
          createdby: "2",
          crew: "asddadas 123",
          crypto: 17,
          id: 44,
          lasttouched: 1735420181000,
          racername: "CoffeeGod",
          races: 15,
          ranking: 1,
          revoked: 0,
          tracks: 0,
          wins: 9,
        },
        {
          active: 0,
          auth: "racer",
          citizenid: "PX6944",
          createdby: "3",
          crypto: 0,
          id: 46,
          lasttouched: 1735419923000,
          racername: "DROP TABLE racer_names-hey",
          races: 0,
          ranking: 0,
          revoked: 0,
          tracks: 0,
          wins: 0,
        },
        {
          active: 1,
          auth: "master",
          citizenid: "PX6944",
          createdby: "PX6944",
          crypto: 0,
          id: 56,
          lasttouched: 1735420181000,
          racername: "CoffeeGod",
          races: 0,
          ranking: 0,
          revoked: 0,
          tracks: 0,
          wins: 0,
        },
      ],
      sellCharge: 0.2,
      translations: {
        NOT_ENOUGH: "Error: Not enough to pay",
        USER_DOES_NOT_EXIST: "Error: User does not exist",
        accept: "Accept",
        access_for: "access for",
        access_list: "Access List",
        access_race: "Race access by citizenId. Separate by commas",
        access_updated: "Access updated",
        active: "Active",
        add_checkpoint: "Add Checkpoint",
        all: "All Classes",
        already_in_race: "You are already in a race.",
        already_making_race: "You are already making a race.",
        any: "Any Type",
        are_you_sure_you_want_to_clear:
          "Clear this tracks leaderboard permanently?",
        are_you_sure_you_want_to_delete_track: "Delete this track permanently?",
        auth: "Auth",
        auth_no: "No auth",
        available: "Available",
        available_races: "Available Races",
        available_races_txt: "See all the currently available races right now.",
        bad_input: "'Input is invalid",
        base_wps: "Use basic waypoints",
        basic_wps_off: "Your Racing GPS will not show basic waypoints",
        basic_wps_on: "Your Racing GPS will show basic waypoints",
        best: "best",
        best_lap: "Best Lap",
        bounties: "Bounties",
        bounties_desc:
          "Bounties will be listed here for you to complete. You can claim the bounty by beating the lap time in any race as long as you fullfill the requirements.",
        bounties_desc_2:
          "After a bounty has been claimed you can not claim it again, but if you beat your own previous time you will get a (possibly reduced) payout.",
        bounties_have_been_generated: " bounties were created.",
        bounty_claimed: "You claimed a bounty worth $",
        buy_in: "Buy in",
        can_be_reverted: "Can be reverted",
        can_not_afford: "You can't afford ",
        cancel_race: "Cancel Race",
        cancel_race_forced: "Force Cancel Race",
        cant_be_reverted: "Can't be reverted",
        cant_decode: "Not possible to decode input",
        changes_are_permanent:
          "Removing records is permanent and can not be reverted",
        checkpoint_2nd: "2nd",
        checkpoint_3rd: "3rd",
        checkpoint_left: "Left Checkpoint",
        checkpoint_next: "Next",
        checkpoint_right: "Right Checkpoint",
        checkpoints: "Checkpoints",
        choose_a_class: "Choose a Class",
        choose_a_track: "Choose a Track",
        circuit: "Circuit",
        circuit_only: "Circuit only",
        citizen_id: "Citizen Id",
        class: "Class",
        class_car: " class car",
        clear_lead: "Clear Leaderboard",
        clear_lead_for: "Clear Leaderboard for",
        clear_leaderboard: "Clear Leaderboard",
        close: "Close",
        close_editor: "Close editor",
        closest_checkpoint: "Closest Checkpoint",
        confirm: "Confirm",
        confirm_record_removal: "Confirm record removal",
        copy_checkpoints: "Copy Checkpoints",
        corrupt_data: "Checkpoint data is corrupt",
        could_not_find_person: "Could not find the person",
        create_crew: "Create a new crew",
        create_racer: "Create Racer",
        create_racing_fob_command: "createracingfob",
        create_racing_fob_description: "Create a Racing GPS (Admin)",
        create_track: "Create Track",
        create_user: "Create a user",
        create_with_editor: "Create With Race Editor",
        create_with_share: "Create With track Share",
        creator: "Creator",
        crew: "Crew",
        crew_invite_accepted: "A racer has accepted to join your crew",
        crew_invite_rejected: "A racer has denied to join your crew",
        crew_rankings: "Crew rankings",
        crew_stats: "Crew Stats",
        crypto_amount: "Crypto amount",
        crypto_hint: "Only whole numbers. Both amounts need to be 1 or above",
        curated: "Curated",
        curation: "Curation Settings",
        currency: "Participation currency",
        currency_text: "$",
        current: "Current",
        current_conversionrate: "Current conversion rate",
        current_race: "Current Race",
        current_race_txt: "Options for your currently entered race.",
        currently_in: "You're currently in a ",
        delete_checkpoint: "Delete Checkpoint",
        delete_track: "Delete track",
        delete_user: "Delete User",
        deny: "Deny",
        description: "Description",
        description_hint: "A short description of the track",
        disband_crew: "Disband current crew",
        disband_crew_first: "Disband your current crew first",
        disbanded_crew: "Your racing crew has been disbanded",
        display_tracks: "Displaying track on your map for 20 seconds",
        distance_check: "Distance check for positions",
        distance_info:
          "Having this on might have an impact on your performance if there are many racers in a race",
        distance_off: "Position checks won't use distance",
        distance_on: "Position checks will use distance",
        draw_text_wps_off: "Your Racing GPS will not show pillar waypoints",
        draw_text_wps_on: "Your Racing GPS will show pillar waypoints",
        edit_access: "Edit access",
        edit_checkpoint_header: "Edit checkpoint",
        edit_settings: "Edit Settings",
        edit_track: "Edit track",
        editing_access_for: "Editing access for",
        editing_access_info: "*Racer Names, separated by commas",
        editor_canceled: "You canceled the editor.",
        editor_confirm: "Press [9] again to confirm.",
        eliminated: "You were eliminated",
        go_to_current_races: "Go to Current Races",
        go_to_bounties: "Go to Bounties",
        go_to_setup_race: "Go to Setup Race",
        elimination: "Elimination",
        error_lacking_user: "You are lacking a racing app user",
        error_lacking_user_desc:
          "You need to have a user selected to access this. If you have one you can select it in settings",
        error_no_user: "No User selected",
        error_no_user_desc: "Select a user in the settings page",
        error_removed: "Your current user has been permanently removed",
        error_removed_desc: "Sucks to suck I guess",
        error_revoked: "Your current user has had it's access revoked",
        error_revoked_desc: "It has not been removed, yet",
        esc: "Press ESC to close",
        expires: "Expires",
        top_3_wins: "Most Wins",
        top_3_wins_losses: "Best Win/Races Ratio",
        extra_payout: "Extra Payout",
        fee: "Selling fee",
        finish: "Finish",
        finished: "Finished",
        first_person: "First Person",
        founder: "Founder",
        founder_can_not_leave: "The Founder can not leave the crew",
        get_in_vehicle: "Get in a vehicle to start!",
        get_ready: "Get Ready!",
        ghosting: "Ghosting",
        ghostingTime: "Time (in seconds) until Ghosting turns off",
        go: "GO!",
        go_back: "Go Back",
        gps_straight_off: "Your Racing GPS will follow roads",
        gps_straight_on: "Your Racing GPS will go straight between checkpoints",
        handle_curation_for: "Handle curation for",
        has_been_removed: " has been removed",
        host_silent: "Host without notification",
        hosted_by: "Hosted by",
        hosting: "Hosting",
        id_not_found: "Citizen by that ID was not found.",
        ignore_roads: "GPS ignores roads",
        incorrect_class: "Your vehicle class is incorrect for this race",
        invalid_fob_type: "Invalid GPS type.",
        invite: "Invite",
        invite_closest: "Invite closest person",
        invite_from_crew: "Invite from crew",
        invites: "Invites",
        is_first_user:
          "You're the first user in the database. Your account will be created as a GOD account",
        join_race: "Join Race",
        kicked_cheese: "You got kicked out of the race for attempting to cheat",
        kicked_idling: "You got kicked out of the race for idling",
        kicked_line: "You got disqualified for trying to start pass the line",
        lap: "LAP",
        laps: "Laps",
        leaderboard_has_been_cleared: "leaderboard has been cleared",
        leave: "Leave",
        leave_current_crew: "Leave current crew",
        leave_race: "Leave Race",
        length: "Length",
        manage: "Manage",
        max_checkpoints:
          "Too many checkpoints might cause issues. Max suggested limit is ",
        max_class: "Max class",
        max_tire_distance: "The max distance allowed is ",
        max_tracks: "You already have the max amount of tracks: ",
        max_uniques: "Max unique names per person:",
        min_tire_distance: "The min distance allowed is ",
        modify_checkpoint: "Modify Checkpoint Menu",
        my_crew: "My crew",
        my_racers: "My Racers",
        my_tracks: "My tracks",
        name_is_used: "Name is used: ",
        name_taken: "Name is taken",
        name_too_long: "The name is too long.",
        name_too_short: "The name is too short.",
        name_track: "Name your track",
        name_track_question: "What do you want your track to be named?",
        need_a_name: "The track need to have a name",
        new_host: "You are the new organizer",
        new_pb: "You got a new personal best!",
        new_rank: "New rank:",
        next_lap: "Next Lap",
        no: "No",
        no_available_tracks:
          "There are no available tracks at the moment to use.",
        no_bounties: "No bounties available",
        no_checkpoints_to_delete:
          "You have not placed any checkpoints to delete.",
        no_checkpoints_to_edit: "No checkpoints to edit",
        no_class_limit: "No class limit",
        no_data: "No data yet",
        no_invites: "No invites pending",
        no_members_in_crew: "No members in this crew yet",
        no_name_track: "This track need to have a name",
        no_pending_races: "There are no pending races at the moment.",
        no_permission: "You do not have permission to do that.",
        no_races: "No race active",
        no_races_exist: "No times have been set on this track",
        no_results: "No Results to browse yet",
        no_tracks_exist: "No Tracks Available",
        not_auth: "Not Authorized",
        not_close_enough_to_join:
          "Not close enough to join. A waypoint was set to the start.",
        not_done_yet: "No racers have passed the finish line yet",
        not_enough_checkpoints:
          "You need a minimum number of checkpoints to save",
        not_enough_money: "Not enough money to join",
        not_in_a_vehicle: "You are not the driver of a vehicle",
        not_in_crew: "You are not in a crew",
        not_in_race: "You are not in a race.",
        number_laps: "Number of Laps",
        off: "Off",
        on: "On",
        open_track_editor_for: "Open track editor for",
        open_tuning_overlay: "Toggle Tuning Overlay",
        participation_amount: "Participation Amount",
        participation_info:
          "This amount will be handed out to all racers who participate",
        participation_trophy: "You got $",
        participation_trophy_crypto: "You got ",
        pending_crew_invite: "You have a pending invite for the racing crew",
        person_no_exist: "This person does not exist",
        pick_track: "Pick a track",
        pillar_columns: "Show floating pillar Waypoints",
        pos: "POS",
        pot: "Pot",
        price: "Price",
        prox_error: "No one close enough",
        purchase: "Purchase",
        purchased_crypto: "Successfully purchased ",
        quick_host: "Quick host",
        race_already_started: "The race has already started!",
        race_canceled: "The race was canceled",
        race_created: "The race was created!",
        race_doesnt_exist: "This race does not exist :(",
        race_go: "GO!",
        race_info: "%s lap(s) | %sm | %s racer(s)",
        race_joined: "You joined the race.",
        race_last_person:
          "You were the last person in that race so it was canceled.",
        race_name_exists: "There is already a race with that name.",
        race_no_exist: "Race doesn't exist anymore",
        race_record: "You now hold the record in %s with a time of: %s!",
        race_records: "Race Records",
        race_records_txt: "See all records for races.",
        race_results: "Recent Races",
        race_results_txt: "See results from previous races",
        race_saved: "The race was saved",
        race_someone_joined: "Someone has joined the race.",
        race_someone_left: "Someone has left the race.",
        race_timed_out: "The race timed out and was canceled.",
        race_type: "Race type",
        race_will_start: "The race will start in 10 seconds.",
        racer_already_in_crew: "This racer is already in the crew",
        racer_finished_place: "finished in place: ",
        racer_id: "Paypal/TempId (leave empty for self)",
        racer_name: "Racer Name",
        racer_rankings: "Racer rankings",
        racer_records: "Racer Records",
        racer_s: "Racer(s)",
        racers: "Racers",
        races: "Races",
        racing: "Racing",
        racing_map: "Map",
        racing_setup: "Racing - Setup",
        rank: "Rank",
        rank_change: "Rank Change",
        rank_update: "Your ranking has been updated with",
        ranked: "Ranked",
        ready_to_race: "Ready to Race, ",
        recipient_racer_name: "Recipient Racer Name",
        refresh: "Refresh",
        remove_crypto: "Exchanged ",
        remove_record: "Remove record",
        removed_user: "Your selected racing user been deleted",
        required_rank: "Rank Req",
        reroll_bounties: "Re-roll bounties",
        results: "Results",
        dashboard_page: "Dashboard",

        return_to_start:
          "Return to the start or you will be kicked from the race: ",
        reversed: "Reversed",
        revoke: "Revoke",
        revoked_access: "Your current racing user has had it's access changed",
        save_track: "Save Track",
        search_dot: "Search...",
        see_records: "Records",
        select_race: "Select Race",
        select_track: "Select Track",
        select_track_to_view: "Select a track to view results",
        selected_track: "Selected Track",
        sell: "Sell",
        set_curated: "Curate",
        set_uncurated: "Un-Curate",
        settings: "Settings",
        setup: "Setup",
        setup_race: "Setup Race",
        shared_with: "Shared with",
        show_gps: "Show GPS Route",
        show_track: "Show Track",
        showing_all: "Showing all tracks",
        curated_only: "Hide non-curated tracks",
        slow_down: "You can't go that fast!",
        sold_crypto: "Successfully sold",
        sprint: "Sprint",
        sprint_only: "Sprint only",
        start_race: "Start Race",
        start_race_forced: "Force start race",
        starting_line: "Start Line",
        starts: "Starts",
        starts_in: "Starts in",
        time: "Time",
        time_added: "Your time has been added to the leaderboard",
        tire_distance: "Tire distance",
        to_many_names: "This person has enough unique Racer Names already...",
        toggled_gps_route_off: "You have toggled GPS Route OFF",
        toggled_gps_route_on: "You have toggled GPS Route ON",
        total: "total",
        total_cost: "Total cost",
        track: "track",
        track_id: "Track ID",
        track_name: "Track Name",
        track_records: "Track Records",
        tracks: "Tracks",
        transfer: "Transfer",
        transfer_succ: "Transfered Crypto to ",
        transfer_succ_rec: "Recieved Crypto from ",
        type: "Type",
        unclaimed: "Unclaimed Record!",
        unknown: "Unknown",
        unowned_dongle: "It doesn't seem to respond do you.",
        useGhosting: "Use Ghosting?",
        user: "User",
        user_list_updated: "Racing user list updated",
        user_no: "No user",
        navigation_title: 'Navigation',
        vehicle: "Vehicle",
        auth_type_master: "Master",
        view_records: "View Records",
        view_records_modal_desc:
          "Here you can view all records on a track and remove them.",
        winner: "Winner",
        wins: "Wins",
        you_get: "You get",
        you_have_to_place_a_new_checkpoint_down_first:
          "You have to place down a new checkpoint first",
      },
    },
    status: 200,
    statusText: "OK",
    headers: {
      "access-control-allow-methods": "POST, GET, OPTIONS",
      "access-control-allow-origin": "*",
      "cache-control": "no-cache, must-revalidate",
      "content-length": "15953",
      "content-type": "application/json",
    },
    config: {
      transitional: {
        silentJSONParsing: true,
        forcedJSONParsing: true,
        clarifyTimeoutError: false,
      },
      adapter: ["xhr", "http", "fetch"],
      transformRequest: [null],
      transformResponse: [null],
      timeout: 0,
      xsrfCookieName: "XSRF-TOKEN",
      xsrfHeaderName: "X-XSRF-TOKEN",
      maxContentLength: -1,
      maxBodyLength: -1,
      env: {},
      headers: {
        Accept: "application/json, text/plain, */*",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      baseURL: "https://cw-racingapp/",
      method: "post",
      url: "GetBaseData",
    },
    request: {},
  },
  isLoadingBaseData: false,
  settings: {},
  tracks: [
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: -2256.849365234375,
            y: 4326.6884765625,
            z: 44.11223220825195,
          },
          offset: {
            left: {
              x: -2264.6513671875,
              y: 4324.92236328125,
              z: 44.19839859008789,
            },
            right: {
              x: -2249.04736328125,
              y: 4328.45458984375,
              z: 44.02606582641601,
            },
          },
        },
        {
          coords: {
            x: -2264.4267578125,
            y: 4377.568359375,
            z: 40.85072708129883,
          },
          offset: {
            left: {
              x: -2268.205078125,
              y: 4378.87646484375,
              z: 40.73799133300781,
            },
            right: {
              x: -2260.6484375,
              y: 4376.26025390625,
              z: 40.96346282958984,
            },
          },
        },
        {
          coords: {
            x: -2242.9189453125,
            y: 4431.54248046875,
            z: 38.74330139160156,
          },
          offset: {
            left: {
              x: -2245.475830078125,
              y: 4434.61767578125,
              z: 38.80965805053711,
            },
            right: {
              x: -2240.362060546875,
              y: 4428.46728515625,
              z: 38.67694473266601,
            },
          },
        },
        {
          coords: {
            x: -2199.084228515625,
            y: 4485.59130859375,
            z: 34.05620193481445,
          },
          offset: {
            left: {
              x: -2202.66455078125,
              y: 4487.3623046875,
              z: 33.84563827514648,
            },
            right: {
              x: -2195.50390625,
              y: 4483.8203125,
              z: 34.26676559448242,
            },
          },
        },
        {
          coords: {
            x: -2164.881591796875,
            y: 4518.5078125,
            z: 33.96925354003906,
          },
          offset: {
            left: {
              x: -2165.021240234375,
              y: 4522.50537109375,
              z: 33.96320343017578,
            },
            right: {
              x: -2164.741943359375,
              y: 4514.51025390625,
              z: 33.97530364990234,
            },
          },
        },
        {
          coords: {
            x: -2090.8564453125,
            y: 4511.24658203125,
            z: 28.82595252990722,
          },
          offset: {
            left: {
              x: -2091.1552734375,
              y: 4515.2353515625,
              z: 28.81850051879882,
            },
            right: {
              x: -2090.5576171875,
              y: 4507.2578125,
              z: 28.83340454101562,
            },
          },
        },
        {
          coords: {
            x: -2035.1630859375,
            y: 4523.50830078125,
            z: 27.6301155090332,
          },
          offset: {
            left: {
              x: -2033.6153564453127,
              y: 4527.1953125,
              z: 27.73784255981445,
            },
            right: {
              x: -2036.7108154296875,
              y: 4519.8212890625,
              z: 27.52238845825195,
            },
          },
        },
        {
          coords: {
            x: -1972.865966796875,
            y: 4489.171875,
            z: 32.30507278442383,
          },
          offset: {
            left: {
              x: -1969.9371337890625,
              y: 4491.89599609375,
              z: 32.32128524780273,
            },
            right: {
              x: -1975.7947998046875,
              y: 4486.44775390625,
              z: 32.28886032104492,
            },
          },
        },
        {
          coords: {
            x: -1958.9832763671875,
            y: 4471.875,
            z: 33.38861846923828,
          },
          offset: {
            left: {
              x: -1955.70263671875,
              y: 4474.1494140625,
              z: 33.13693237304687,
            },
            right: {
              x: -1962.263916015625,
              y: 4469.6005859375,
              z: 33.64030456542969,
            },
          },
        },
        {
          coords: {
            x: -1946.1064453125,
            y: 4460.71728515625,
            z: 34.17923355102539,
          },
          offset: {
            left: {
              x: -1945.668701171875,
              y: 4466.64794921875,
              z: 33.38080215454101,
            },
            right: {
              x: -1946.544189453125,
              y: 4454.78662109375,
              z: 34.97766494750976,
            },
          },
        },
        {
          coords: {
            x: -1920.5986328125,
            y: 4477.65869140625,
            z: 29.56040573120117,
          },
          offset: {
            left: {
              x: -1923.9195556640625,
              y: 4481.376953125,
              z: 29.17958450317382,
            },
            right: {
              x: -1917.2777099609375,
              y: 4473.9404296875,
              z: 29.94122695922851,
            },
          },
        },
        {
          coords: {
            x: -1883.20458984375,
            y: 4480.52587890625,
            z: 26.16768646240234,
          },
          offset: {
            left: {
              x: -1884.395263671875,
              y: 4485.375,
              z: 25.90925025939941,
            },
            right: {
              x: -1882.013916015625,
              y: 4475.6767578125,
              z: 26.42612266540527,
            },
          },
        },
        {
          coords: {
            x: -1844.819091796875,
            y: 4499.92626953125,
            z: 21.62620162963867,
          },
          offset: {
            left: {
              x: -1843.781494140625,
              y: 4504.7978515625,
              z: 21.19057464599609,
            },
            right: {
              x: -1845.856689453125,
              y: 4495.0546875,
              z: 22.06182861328125,
            },
          },
        },
        {
          coords: {
            x: -1811.54150390625,
            y: 4479.18408203125,
            z: 16.81292915344238,
          },
          offset: {
            left: {
              x: -1810.4273681640625,
              y: 4484.05126953125,
              z: 16.54586410522461,
            },
            right: {
              x: -1812.6556396484375,
              y: 4474.31689453125,
              z: 17.07999420166015,
            },
          },
        },
        {
          coords: {
            x: -1757.879638671875,
            y: 4463.9736328125,
            z: 5.41567516326904,
          },
          offset: {
            left: {
              x: -1755.2833251953125,
              y: 4468.23486328125,
              z: 5.73346138000488,
            },
            right: {
              x: -1760.4759521484375,
              y: 4459.71240234375,
              z: 5.0978889465332,
            },
          },
        },
        {
          coords: {
            x: -1665.1468505859375,
            y: 4449.53759765625,
            z: 1.87412655353546,
          },
          offset: {
            left: {
              x: -1662.7906494140625,
              y: 4453.923828125,
              z: 1.41591942310333,
            },
            right: {
              x: -1667.5030517578125,
              y: 4445.1513671875,
              z: 2.3323335647583,
            },
          },
        },
        {
          coords: {
            x: -1614.2169189453125,
            y: 4380.48046875,
            z: 1.8424162864685,
          },
          offset: {
            left: {
              x: -1609.75732421875,
              y: 4382.7412109375,
              z: 1.88582789897918,
            },
            right: {
              x: -1618.676513671875,
              y: 4378.2197265625,
              z: 1.79900467395782,
            },
          },
        },
        {
          coords: {
            x: -1553.65234375,
            y: 4327.0869140625,
            z: 3.76294469833374,
          },
          offset: {
            left: {
              x: -1551.467529296875,
              y: 4331.58056640625,
              z: 3.58115029335021,
            },
            right: {
              x: -1555.837158203125,
              y: 4322.59326171875,
              z: 3.94473910331726,
            },
          },
        },
        {
          coords: {
            x: -1466.15966796875,
            y: 4304.28515625,
            z: 2.42341828346252,
          },
          offset: {
            left: {
              x: -1465.7359619140625,
              y: 4310.27001953125,
              z: 2.45702457427978,
            },
            right: {
              x: -1466.5833740234375,
              y: 4298.30029296875,
              z: 2.38981199264526,
            },
          },
        },
        {
          coords: {
            x: -1402.850830078125,
            y: 4303.64990234375,
            z: 4.15459728240966,
          },
          offset: {
            left: {
              x: -1402.2645263671875,
              y: 4307.5556640625,
              z: 3.52234697341918,
            },
            right: {
              x: -1403.4371337890625,
              y: 4299.744140625,
              z: 4.78684759140014,
            },
          },
        },
        {
          coords: {
            x: -1342.9195556640625,
            y: 4318.92431640625,
            z: 5.65349292755126,
          },
          offset: {
            left: {
              x: -1345.2916259765625,
              y: 4322.1416015625,
              z: 5.80060863494873,
            },
            right: {
              x: -1340.5474853515625,
              y: 4315.70703125,
              z: 5.5063772201538,
            },
          },
        },
        {
          coords: {
            x: -1237.251953125,
            y: 4362.29150390625,
            z: 7.41466426849365,
          },
          offset: {
            left: {
              x: -1237.9112548828125,
              y: 4366.23681640625,
              z: 7.43791055679321,
            },
            right: {
              x: -1236.5926513671875,
              y: 4358.34619140625,
              z: 7.39141798019409,
            },
          },
        },
        {
          coords: {
            x: -1165.62060546875,
            y: 4365.07763671875,
            z: 7.41084861755371,
          },
          offset: {
            left: {
              x: -1166.43701171875,
              y: 4368.99365234375,
              z: 7.41402626037597,
            },
            right: {
              x: -1164.80419921875,
              y: 4361.16162109375,
              z: 7.40767097473144,
            },
          },
        },
        {
          coords: {
            x: -1071.8681640625,
            y: 4371.7412109375,
            z: 13.34563732147216,
          },
          offset: {
            left: {
              x: -1070.1124267578125,
              y: 4382.466796875,
              z: 15.04289054870605,
            },
            right: {
              x: -1073.6239013671875,
              y: 4361.015625,
              z: 11.64838409423828,
            },
          },
        },
        {
          coords: {
            x: -962.3970336914064,
            y: 4350.21484375,
            z: 11.22719764709472,
          },
          offset: {
            left: {
              x: -962.6928100585938,
              y: 4355.20263671875,
              z: 11.03585147857666,
            },
            right: {
              x: -962.1012573242188,
              y: 4345.22705078125,
              z: 11.41854381561279,
            },
          },
        },
        {
          coords: {
            x: -876.5358276367188,
            y: 4391.9765625,
            z: 19.5855770111084,
          },
          offset: {
            left: {
              x: -879.4190673828125,
              y: 4396.060546875,
              z: 19.68398475646972,
            },
            right: {
              x: -873.652587890625,
              y: 4387.892578125,
              z: 19.48716926574707,
            },
          },
        },
        {
          coords: {
            x: -809.7577514648438,
            y: 4410.39013671875,
            z: 18.91035842895507,
          },
          offset: {
            left: {
              x: -808.6151123046875,
              y: 4415.25390625,
              z: 19.11100387573242,
            },
            right: {
              x: -810.900390625,
              y: 4405.5263671875,
              z: 18.70971298217773,
            },
          },
        },
        {
          coords: {
            x: -745.44873046875,
            y: 4412.794921875,
            z: 19.67461204528808,
          },
          offset: {
            left: {
              x: -746.3036499023438,
              y: 4417.72119140625,
              z: 19.71253585815429,
            },
            right: {
              x: -744.5938110351562,
              y: 4407.86865234375,
              z: 19.63668823242187,
            },
          },
        },
        {
          coords: {
            x: -687.7816772460938,
            y: 4388.78857421875,
            z: 25.32780265808105,
          },
          offset: {
            left: {
              x: -685.8093872070312,
              y: 4393.3818359375,
              z: 25.22755622863769,
            },
            right: {
              x: -689.7539672851562,
              y: 4384.1953125,
              z: 25.42804908752441,
            },
          },
        },
        {
          coords: {
            x: -589.7083740234375,
            y: 4363.71240234375,
            z: 50.91108322143555,
          },
          offset: {
            left: {
              x: -588.5853271484375,
              y: 4367.55029296875,
              z: 51.00346755981445,
            },
            right: {
              x: -590.8314208984375,
              y: 4359.87451171875,
              z: 50.81869888305664,
            },
          },
        },
        {
          coords: {
            x: -495.2115783691406,
            y: 4353.5146484375,
            z: 65.78436279296875,
          },
          offset: {
            left: {
              x: -492.7489013671875,
              y: 4356.66650390625,
              z: 65.775634765625,
            },
            right: {
              x: -497.67425537109375,
              y: 4350.36279296875,
              z: 65.7930908203125,
            },
          },
        },
        {
          coords: {
            x: -416.52154541015625,
            y: 4289.4990234375,
            z: 56.82502365112305,
          },
          offset: {
            left: {
              x: -414.2548522949219,
              y: 4292.7939453125,
              z: 56.74670791625976,
            },
            right: {
              x: -418.7882385253906,
              y: 4286.2041015625,
              z: 56.90333938598633,
            },
          },
        },
        {
          coords: {
            x: -338.3056335449219,
            y: 4252.20166015625,
            z: 42.81773376464844,
          },
          offset: {
            left: {
              x: -335.0643005371094,
              y: 4254.54541015625,
              z: 42.83132934570312,
            },
            right: {
              x: -341.5469665527344,
              y: 4249.85791015625,
              z: 42.80413818359375,
            },
          },
        },
        {
          coords: {
            x: -241.4145965576172,
            y: 4228.1298828125,
            z: 44.20049667358398,
          },
          offset: {
            left: {
              x: -241.0870361328125,
              y: 4232.1162109375,
              z: 44.20173645019531,
            },
            right: {
              x: -241.74215698242188,
              y: 4224.1435546875,
              z: 44.19925689697265,
            },
          },
        },
        {
          coords: {
            x: -202.7253875732422,
            y: 4220.5595703125,
            z: 44.13401412963867,
          },
          offset: {
            left: {
              x: -203.25828552246097,
              y: 4226.53564453125,
              z: 44.09271240234375,
            },
            right: {
              x: -202.19248962402344,
              y: 4214.58349609375,
              z: 44.17531585693359,
            },
          },
        },
        {
          coords: {
            x: -167.77093505859375,
            y: 4245.66748046875,
            z: 44.35789108276367,
          },
          offset: {
            left: {
              x: -171.08551025390625,
              y: 4249.4111328125,
              z: 44.35652542114258,
            },
            right: {
              x: -164.45635986328125,
              y: 4241.923828125,
              z: 44.35925674438476,
            },
          },
        },
        {
          coords: {
            x: -100.05821990966795,
            y: 4293.8525390625,
            z: 45.26468658447265,
          },
          offset: {
            left: {
              x: -102.30169677734376,
              y: 4297.1640625,
              z: 45.26012802124023,
            },
            right: {
              x: -97.8147430419922,
              y: 4290.541015625,
              z: 45.26924514770508,
            },
          },
        },
        {
          coords: {
            x: -49.6675796508789,
            y: 4408.77734375,
            z: 56.46329498291015,
          },
          offset: {
            left: {
              x: -52.76509094238281,
              y: 4411.29541015625,
              z: 56.71890640258789,
            },
            right: {
              x: -46.570068359375,
              y: 4406.25927734375,
              z: 56.20768356323242,
            },
          },
        },
        {
          coords: {
            x: 13.43776893615722,
            y: 4452.548828125,
            z: 59.12195587158203,
          },
          offset: {
            left: {
              x: 12.60110664367675,
              y: 4456.45947265625,
              z: 59.19240570068359,
            },
            right: {
              x: 14.27443122863769,
              y: 4448.63818359375,
              z: 59.05150604248047,
            },
          },
        },
        {
          coords: {
            x: 127.75250244140624,
            y: 4425.84130859375,
            z: 72.6594467163086,
          },
          offset: {
            left: {
              x: 129.2264862060547,
              y: 4429.5595703125,
              z: 72.69580078125,
            },
            right: {
              x: 126.27851104736328,
              y: 4422.123046875,
              z: 72.62309265136719,
            },
          },
        },
        {
          coords: {
            x: 299.3467712402344,
            y: 4516.10693359375,
            z: 61.98148727416992,
          },
          offset: {
            left: {
              x: 299.27532958984375,
              y: 4522.103515625,
              z: 61.78820419311523,
            },
            right: {
              x: 299.418212890625,
              y: 4510.1103515625,
              z: 62.17477035522461,
            },
          },
        },
        {
          coords: {
            x: 368.2682495117188,
            y: 4460.0400390625,
            z: 62.27444076538086,
          },
          offset: {
            left: {
              x: 373.38275146484375,
              y: 4463.173828125,
              z: 62.13192749023437,
            },
            right: {
              x: 363.15374755859375,
              y: 4456.90625,
              z: 62.41695404052734,
            },
          },
        },
        {
          coords: {
            x: 444.2218017578125,
            y: 4361.22021484375,
            z: 62.74337387084961,
          },
          offset: {
            left: {
              x: 445.04388427734375,
              y: 4367.1591796875,
              z: 62.9765739440918,
            },
            right: {
              x: 443.3997192382813,
              y: 4355.28125,
              z: 62.51017379760742,
            },
          },
        },
        {
          coords: {
            x: 495.34326171875,
            y: 4311.740234375,
            z: 55.14636993408203,
          },
          offset: {
            left: {
              x: 501.2787170410156,
              y: 4312.61328125,
              z: 55.05460357666015,
            },
            right: {
              x: 489.4078063964844,
              y: 4310.8671875,
              z: 55.2381362915039,
            },
          },
        },
        {
          coords: {
            x: 863.4036254882812,
            y: 4255.78125,
            z: 50.04796600341797,
          },
          offset: {
            left: {
              x: 857.4392700195312,
              y: 4256.31787109375,
              z: 49.67533874511719,
            },
            right: {
              x: 869.3679809570312,
              y: 4255.24462890625,
              z: 50.42059326171875,
            },
          },
        },
        {
          coords: {
            x: 1071.971923828125,
            y: 4445.73779296875,
            z: 57.36433029174805,
          },
          offset: {
            left: {
              x: 1074.3017578125,
              y: 4451.26708984375,
              z: 57.37883758544922,
            },
            right: {
              x: 1069.64208984375,
              y: 4440.20849609375,
              z: 57.34982299804687,
            },
          },
        },
        {
          coords: {
            x: 1214.8389892578125,
            y: 4456.384765625,
            z: 54.7417984008789,
          },
          offset: {
            left: {
              x: 1211.279052734375,
              y: 4461.21435546875,
              z: 54.80121612548828,
            },
            right: {
              x: 1218.39892578125,
              y: 4451.55517578125,
              z: 54.68238067626953,
            },
          },
        },
        {
          coords: {
            x: 1346.6715087890625,
            y: 4489.55712890625,
            z: 58.28782272338867,
          },
          offset: {
            left: {
              x: 1343.8048095703125,
              y: 4494.82763671875,
              z: 58.22243499755859,
            },
            right: {
              x: 1349.5382080078125,
              y: 4484.28662109375,
              z: 58.35321044921875,
            },
          },
        },
        {
          coords: {
            x: 1543.9686279296875,
            y: 4561.90185546875,
            z: 50.41799163818359,
          },
          offset: {
            left: {
              x: 1542.01416015625,
              y: 4567.57373046875,
              z: 50.50675201416015,
            },
            right: {
              x: 1545.923095703125,
              y: 4556.22998046875,
              z: 50.32923126220703,
            },
          },
        },
        {
          coords: {
            x: 1739.835693359375,
            y: 4574.23974609375,
            z: 38.97458267211914,
          },
          offset: {
            left: {
              x: 1739.3658447265625,
              y: 4584.2255859375,
              z: 39.2162857055664,
            },
            right: {
              x: 1740.3055419921875,
              y: 4564.25390625,
              z: 38.73287963867187,
            },
          },
        },
      ],
      Creator: "CITIZENID",
      CreatorName: "ilmicioletale",
      Curated: 0,
      Distance: 4896,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 0,
      RaceId: "CW-4267",
      RaceName: "Zancudo Sprint",
      Racers: [],
      Records: [],
      Started: false,
      Waiting: false,
    },
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: -2582.39453125,
            y: 2286.38818359375,
            z: 29.5360164642334,
          },
          offset: {
            left: {
              x: -2582.210693359375,
              y: 2277.39013671875,
              z: 29.5351619720459,
            },
            right: {
              x: -2582.578369140625,
              y: 2295.38623046875,
              z: 29.5368709564209,
            },
          },
        },
        {
          coords: {
            x: -2731.85595703125,
            y: 2266.02197265625,
            z: 19.92663764953613,
          },
          offset: {
            left: {
              x: -2724.1943359375,
              y: 2258.129638671875,
              z: 20.02683639526367,
            },
            right: {
              x: -2739.517578125,
              y: 2273.914306640625,
              z: 19.82643890380859,
            },
          },
        },
        {
          coords: {
            x: -2918.5322265625,
            y: 2143.631591796875,
            z: 39.21545791625976,
          },
          offset: {
            left: {
              x: -2911.9111328125,
              y: 2134.847412109375,
              z: 39.22481918334961,
            },
            right: {
              x: -2925.1533203125,
              y: 2152.415771484375,
              z: 39.20609664916992,
            },
          },
        },
        {
          coords: {
            x: -2995.92333984375,
            y: 1974.99658203125,
            z: 30.07115745544433,
          },
          offset: {
            left: {
              x: -2985.595458984375,
              y: 1971.2105712890625,
              z: 30.07850837707519,
            },
            right: {
              x: -3006.251220703125,
              y: 1978.7825927734375,
              z: 30.06380653381347,
            },
          },
        },
        {
          coords: {
            x: -3038.636474609375,
            y: 1726.0665283203125,
            z: 36.27307891845703,
          },
          offset: {
            left: {
              x: -3027.77978515625,
              y: 1727.83642578125,
              z: 36.26284408569336,
            },
            right: {
              x: -3049.4931640625,
              y: 1724.296630859375,
              z: 36.2833137512207,
            },
          },
        },
        {
          coords: {
            x: -3031.9716796875,
            y: 1427.916748046875,
            z: 24.20453071594238,
          },
          offset: {
            left: {
              x: -3023.8115234375,
              y: 1420.5404052734375,
              z: 24.17464256286621,
            },
            right: {
              x: -3040.1318359375,
              y: 1435.2930908203125,
              z: 24.23441886901855,
            },
          },
        },
        {
          coords: {
            x: -3097.6484375,
            y: 1276.93994140625,
            z: 19.72138023376465,
          },
          offset: {
            left: {
              x: -3086.727783203125,
              y: 1275.6212158203125,
              z: 19.72920799255371,
            },
            right: {
              x: -3108.569091796875,
              y: 1278.2586669921875,
              z: 19.71355247497558,
            },
          },
        },
        {
          coords: {
            x: -3096.392578125,
            y: 1191.3839111328125,
            z: 19.85276222229004,
          },
          offset: {
            left: {
              x: -3091.90234375,
              y: 1196.7540283203125,
              z: 19.83323860168457,
            },
            right: {
              x: -3100.8828125,
              y: 1186.0137939453125,
              z: 19.8722858428955,
            },
          },
        },
        {
          coords: {
            x: -3069.420166015625,
            y: 1189.047119140625,
            z: 21.13960456848144,
          },
          offset: {
            left: {
              x: -3071.197021484375,
              y: 1194.7779541015625,
              z: 21.14068031311035,
            },
            right: {
              x: -3067.643310546875,
              y: 1183.3162841796875,
              z: 21.13852882385254,
            },
          },
        },
        {
          coords: {
            x: -3019.80908203125,
            y: 1270.015869140625,
            z: 29.23141288757324,
          },
          offset: {
            left: {
              x: -3025.477783203125,
              y: 1271.9813232421875,
              z: 29.1927547454834,
            },
            right: {
              x: -3014.140380859375,
              y: 1268.0504150390625,
              z: 29.27007102966308,
            },
          },
        },
        {
          coords: {
            x: -2911.379638671875,
            y: 1322.180419921875,
            z: 47.55038833618164,
          },
          offset: {
            left: {
              x: -2905.894287109375,
              y: 1324.611083984375,
              z: 47.60969543457031,
            },
            right: {
              x: -2916.864990234375,
              y: 1319.749755859375,
              z: 47.49108123779297,
            },
          },
        },
        {
          coords: {
            x: -2801.451171875,
            y: 1309.326416015625,
            z: 72.23029327392578,
          },
          offset: {
            left: {
              x: -2805.9833984375,
              y: 1313.258056640625,
              z: 72.21415710449219,
            },
            right: {
              x: -2796.9189453125,
              y: 1305.394775390625,
              z: 72.24642944335938,
            },
          },
        },
        {
          coords: {
            x: -2711.396240234375,
            y: 1488.5211181640625,
            z: 103.85919952392578,
          },
          offset: {
            left: {
              x: -2716.428955078125,
              y: 1491.787841796875,
              z: 103.89177703857422,
            },
            right: {
              x: -2706.363525390625,
              y: 1485.25439453125,
              z: 103.82662200927736,
            },
          },
        },
        {
          coords: {
            x: -2662.52392578125,
            y: 1505.8619384765625,
            z: 115.51280212402344,
          },
          offset: {
            left: {
              x: -2664.11962890625,
              y: 1511.578857421875,
              z: 114.6344985961914,
            },
            right: {
              x: -2660.92822265625,
              y: 1500.14501953125,
              z: 116.39110565185548,
            },
          },
        },
        {
          coords: {
            x: -2641.859619140625,
            y: 1534.9373779296875,
            z: 118.86908721923828,
          },
          offset: {
            left: {
              x: -2647.476806640625,
              y: 1536.9517822265625,
              z: 118.24498748779295,
            },
            right: {
              x: -2636.242431640625,
              y: 1532.9229736328125,
              z: 119.4931869506836,
            },
          },
        },
        {
          coords: {
            x: -2639.4921875,
            y: 1601.122802734375,
            z: 124.88906860351564,
          },
          offset: {
            left: {
              x: -2645.180419921875,
              y: 1603.0318603515625,
              z: 124.90965270996094,
            },
            right: {
              x: -2633.803955078125,
              y: 1599.2137451171875,
              z: 124.86848449707033,
            },
          },
        },
        {
          coords: {
            x: -2589.830078125,
            y: 1662.490966796875,
            z: 140.61363220214844,
          },
          offset: {
            left: {
              x: -2591.955322265625,
              y: 1668.1019287109375,
              z: 140.6162567138672,
            },
            right: {
              x: -2587.704833984375,
              y: 1656.8800048828125,
              z: 140.6110076904297,
            },
          },
        },
        {
          coords: {
            x: -2503.76904296875,
            y: 1699.36572265625,
            z: 153.52525329589844,
          },
          offset: {
            left: {
              x: -2509.73779296875,
              y: 1699.975830078125,
              z: 153.50425720214844,
            },
            right: {
              x: -2497.80029296875,
              y: 1698.755615234375,
              z: 153.54624938964844,
            },
          },
        },
        {
          coords: {
            x: -2483.81591796875,
            y: 1809.9937744140625,
            z: 160.7616729736328,
          },
          offset: {
            left: {
              x: -2488.38818359375,
              y: 1806.1092529296875,
              z: 160.6946258544922,
            },
            right: {
              x: -2479.24365234375,
              y: 1813.8782958984375,
              z: 160.82872009277344,
            },
          },
        },
        {
          coords: {
            x: -2531.585693359375,
            y: 1926.21240234375,
            z: 170.69207763671875,
          },
          offset: {
            left: {
              x: -2535.96923828125,
              y: 1930.309326171875,
              z: 170.71263122558597,
            },
            right: {
              x: -2527.2021484375,
              y: 1922.115478515625,
              z: 170.67152404785156,
            },
          },
        },
        {
          coords: {
            x: -2398.279296875,
            y: 1942.7227783203127,
            z: 179.57598876953125,
          },
          offset: {
            left: {
              x: -2395.927001953125,
              y: 1948.2420654296875,
              z: 179.63668823242188,
            },
            right: {
              x: -2400.631591796875,
              y: 1937.2034912109375,
              z: 179.51528930664065,
            },
          },
        },
        {
          coords: {
            x: -2299.155517578125,
            y: 1865.3734130859375,
            z: 181.78074645996097,
          },
          offset: {
            left: {
              x: -2298.935546875,
              y: 1871.369384765625,
              z: 181.7847442626953,
            },
            right: {
              x: -2299.37548828125,
              y: 1859.37744140625,
              z: 181.77674865722656,
            },
          },
        },
        {
          coords: {
            x: -2189.466796875,
            y: 1932.533935546875,
            z: 188.656478881836,
          },
          offset: {
            left: {
              x: -2192.556640625,
              y: 1937.67724609375,
              z: 188.6527099609375,
            },
            right: {
              x: -2186.376953125,
              y: 1927.390625,
              z: 188.6602478027344,
            },
          },
        },
        {
          coords: {
            x: -2117.3173828125,
            y: 1997.404052734375,
            z: 190.11883544921875,
          },
          offset: {
            left: {
              x: -2118.091064453125,
              y: 2003.3538818359375,
              z: 190.1389923095703,
            },
            right: {
              x: -2116.543701171875,
              y: 1991.4542236328127,
              z: 190.0986785888672,
            },
          },
        },
        {
          coords: {
            x: -2036.95654296875,
            y: 1990.4749755859375,
            z: 189.40304565429688,
          },
          offset: {
            left: {
              x: -2030.9923095703127,
              y: 1989.82080078125,
              z: 189.3933258056641,
            },
            right: {
              x: -2042.9207763671875,
              y: 1991.129150390625,
              z: 189.4127655029297,
            },
          },
        },
        {
          coords: {
            x: -2013.9644775390625,
            y: 1915.6834716796875,
            z: 186.04066467285156,
          },
          offset: {
            left: {
              x: -2012.748779296875,
              y: 1921.5589599609375,
              z: 186.02920532226568,
            },
            right: {
              x: -2015.18017578125,
              y: 1909.8079833984375,
              z: 186.0521240234375,
            },
          },
        },
        {
          coords: {
            x: -1970.64306640625,
            y: 1847.133056640625,
            z: 182.6196441650391,
          },
          offset: {
            left: {
              x: -1965.3319091796875,
              y: 1844.341796875,
              z: 182.6171417236328,
            },
            right: {
              x: -1975.9542236328127,
              y: 1849.92431640625,
              z: 182.6221466064453,
            },
          },
        },
        {
          coords: {
            x: -1950.3385009765625,
            y: 1759.655029296875,
            z: 175.14193725585938,
          },
          offset: {
            left: {
              x: -1950.762451171875,
              y: 1765.6400146484375,
              z: 175.12245178222656,
            },
            right: {
              x: -1949.91455078125,
              y: 1753.6700439453125,
              z: 175.1614227294922,
            },
          },
        },
        {
          coords: {
            x: -1879.3135986328127,
            y: 1811.4168701171875,
            z: 165.08514404296875,
          },
          offset: {
            left: {
              x: -1885.1456298828127,
              y: 1812.8262939453127,
              z: 165.0498046875,
            },
            right: {
              x: -1873.4815673828127,
              y: 1810.0074462890625,
              z: 165.1204833984375,
            },
          },
        },
        {
          coords: {
            x: -1794.967041015625,
            y: 1881.0499267578127,
            z: 148.72862243652344,
          },
          offset: {
            left: {
              x: -1800.2928466796875,
              y: 1878.28662109375,
              z: 148.7463531494141,
            },
            right: {
              x: -1789.6412353515625,
              y: 1883.813232421875,
              z: 148.7108917236328,
            },
          },
        },
        {
          coords: {
            x: -1878.8614501953127,
            y: 1996.4200439453127,
            z: 141.937255859375,
          },
          offset: {
            left: {
              x: -1884.8609619140625,
              y: 1996.4947509765625,
              z: 141.9596405029297,
            },
            right: {
              x: -1872.8619384765625,
              y: 1996.3453369140625,
              z: 141.9148712158203,
            },
          },
        },
        {
          coords: {
            x: -1774.36767578125,
            y: 2058.122802734375,
            z: 122.85993957519533,
          },
          offset: {
            left: {
              x: -1778.431396484375,
              y: 2062.537109375,
              z: 122.8251724243164,
            },
            right: {
              x: -1770.303955078125,
              y: 2053.70849609375,
              z: 122.89470672607422,
            },
          },
        },
        {
          coords: {
            x: -1656.9517822265625,
            y: 2151.24951171875,
            z: 99.21678924560548,
          },
          offset: {
            left: {
              x: -1660.666748046875,
              y: 2155.960205078125,
              z: 99.12759399414064,
            },
            right: {
              x: -1653.23681640625,
              y: 2146.538818359375,
              z: 99.30598449707033,
            },
          },
        },
        {
          coords: {
            x: -1705.3250732421875,
            y: 2240.99365234375,
            z: 82.38408660888672,
          },
          offset: {
            left: {
              x: -1708.8868408203125,
              y: 2236.165283203125,
              z: 82.39203643798828,
            },
            right: {
              x: -1701.7633056640625,
              y: 2245.822021484375,
              z: 82.37613677978516,
            },
          },
        },
        {
          coords: {
            x: -1856.7689208984375,
            y: 2304.875732421875,
            z: 65.41776275634766,
          },
          offset: {
            left: {
              x: -1857.2529296875,
              y: 2298.895263671875,
              z: 65.41143035888672,
            },
            right: {
              x: -1856.284912109375,
              y: 2310.856201171875,
              z: 65.4240951538086,
            },
          },
        },
        {
          coords: {
            x: -2015.054443359375,
            y: 2278.445068359375,
            z: 46.92208099365234,
          },
          offset: {
            left: {
              x: -2015.37646484375,
              y: 2272.453857421875,
              z: 46.89783096313476,
            },
            right: {
              x: -2014.732421875,
              y: 2284.436279296875,
              z: 46.94633102416992,
            },
          },
        },
        {
          coords: {
            x: -2112.849853515625,
            y: 2308.68115234375,
            z: 37.09455490112305,
          },
          offset: {
            left: {
              x: -2112.3056640625,
              y: 2302.705810546875,
              z: 37.08944702148437,
            },
            right: {
              x: -2113.39404296875,
              y: 2314.656494140625,
              z: 37.09966278076172,
            },
          },
        },
        {
          coords: {
            x: -2257.154541015625,
            y: 2273.703369140625,
            z: 32.19904708862305,
          },
          offset: {
            left: {
              x: -2254.104248046875,
              y: 2268.53662109375,
              z: 32.20043182373047,
            },
            right: {
              x: -2260.204833984375,
              y: 2278.8701171875,
              z: 32.19766235351562,
            },
          },
        },
        {
          coords: {
            x: -2438.587646484375,
            y: 2291.46875,
            z: 31.5549030303955,
          },
          offset: {
            left: {
              x: -2440.424072265625,
              y: 2285.7568359375,
              z: 31.53557586669922,
            },
            right: {
              x: -2436.751220703125,
              y: 2297.1806640625,
              z: 31.57423019409179,
            },
          },
        },
        {
          coords: {
            x: -2582.52685546875,
            y: 2286.3828125,
            z: 29.52339363098144,
          },
          offset: {
            left: {
              x: -2582.296142578125,
              y: 2277.3857421875,
              z: 29.52884483337402,
            },
            right: {
              x: -2582.757568359375,
              y: 2295.3798828125,
              z: 29.51794242858886,
            },
          },
        },
      ],
      Creator: "CITIZENID",
      CreatorName: "ilmicioletale",
      Curated: 1,
      Distance: 4933,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 0,
      RaceId: "CW-8087",
      RaceName: "Zancudo Petrol Station",
      Racers: [],
      Records: [],
      Started: false,
      Waiting: false,
    },
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: 100.68633270263672,
            y: 6404.29248046875,
            z: 30.83957290649414,
          },
          offset: {
            left: {
              x: 93.90451049804688,
              y: 6396.9443359375,
              z: 30.73969268798828,
            },
            right: {
              x: 107.46815490722656,
              y: 6411.640625,
              z: 30.939453125,
            },
          },
        },
        {
          coords: {
            x: -111.04287719726564,
            y: 6267.3720703125,
            z: 30.72929191589355,
          },
          offset: {
            left: {
              x: -104.46923065185548,
              y: 6259.83642578125,
              z: 30.77276992797851,
            },
            right: {
              x: -117.61652374267578,
              y: 6274.90771484375,
              z: 30.68581390380859,
            },
          },
        },
        {
          coords: {
            x: -192.9027862548828,
            y: 6186.1962890625,
            z: 30.71134185791015,
          },
          offset: {
            left: {
              x: -186.3596954345703,
              y: 6178.6337890625,
              z: 30.69762420654297,
            },
            right: {
              x: -199.4458770751953,
              y: 6193.7587890625,
              z: 30.72505950927734,
            },
          },
        },
        {
          coords: {
            x: -198.4038238525391,
            y: 6181.37841796875,
            z: 30.70988845825195,
          },
          offset: {
            left: {
              x: -191.81655883789065,
              y: 6173.85498046875,
              z: 30.7741413116455,
            },
            right: {
              x: -204.9910888671875,
              y: 6188.90185546875,
              z: 30.6456356048584,
            },
          },
        },
        {
          coords: {
            x: -203.151611328125,
            y: 6177.11376953125,
            z: 30.70864486694336,
          },
          offset: {
            left: {
              x: -196.32000732421875,
              y: 6169.8125,
              z: 30.85074424743652,
            },
            right: {
              x: -209.98321533203128,
              y: 6184.4150390625,
              z: 30.56654548645019,
            },
          },
        },
        {
          coords: {
            x: -207.87860107421875,
            y: 6172.708984375,
            z: 30.70704841613769,
          },
          offset: {
            left: {
              x: -200.9112091064453,
              y: 6165.53759765625,
              z: 30.86673736572265,
            },
            right: {
              x: -214.8459930419922,
              y: 6179.88037109375,
              z: 30.54735946655273,
            },
          },
        },
        {
          coords: {
            x: -213.14971923828128,
            y: 6167.65087890625,
            z: 30.7036018371582,
          },
          offset: {
            left: {
              x: -206.1779022216797,
              y: 6160.48193359375,
              z: 30.73056030273437,
            },
            right: {
              x: -220.1215362548828,
              y: 6174.81982421875,
              z: 30.67664337158203,
            },
          },
        },
        {
          coords: {
            x: -217.6303253173828,
            y: 6163.30615234375,
            z: 30.70631408691406,
          },
          offset: {
            left: {
              x: -210.66354370117188,
              y: 6156.1328125,
              z: 30.80494117736816,
            },
            right: {
              x: -224.59710693359375,
              y: 6170.4794921875,
              z: 30.60768699645996,
            },
          },
        },
        {
          coords: {
            x: -222.79627990722656,
            y: 6158.294921875,
            z: 30.70975685119629,
          },
          offset: {
            left: {
              x: -215.8324432373047,
              y: 6151.11865234375,
              z: 30.77610778808593,
            },
            right: {
              x: -229.76011657714844,
              y: 6165.47119140625,
              z: 30.64340591430664,
            },
          },
        },
        {
          coords: {
            x: -228.4624481201172,
            y: 6152.794921875,
            z: 30.71010971069336,
          },
          offset: {
            left: {
              x: -221.49815368652344,
              y: 6145.61865234375,
              z: 30.72949409484863,
            },
            right: {
              x: -235.42674255371097,
              y: 6159.97119140625,
              z: 30.69072532653808,
            },
          },
        },
        {
          coords: {
            x: -233.534912109375,
            y: 6147.86572265625,
            z: 30.71163368225097,
          },
          offset: {
            left: {
              x: -226.5711669921875,
              y: 6140.68896484375,
              z: 30.6915340423584,
            },
            right: {
              x: -240.4986572265625,
              y: 6155.04248046875,
              z: 30.73173332214355,
            },
          },
        },
        {
          coords: {
            x: -239.8647003173828,
            y: 6141.72265625,
            z: 30.71056747436523,
          },
          offset: {
            left: {
              x: -232.90164184570312,
              y: 6134.54541015625,
              z: 30.64941024780273,
            },
            right: {
              x: -246.8277587890625,
              y: 6148.89990234375,
              z: 30.77172470092773,
            },
          },
        },
      ],
      Creator: "PX6944",
      CreatorName: "CoffeeGod",
      Curated: 0,
      Distance: 432,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 0,
      RaceId: "LR-7629",
      RaceName: "Test Bug Distance",
      Racers: [],
      Records: [],
      Started: false,
      Waiting: false,
    },
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: -113.32921600341795,
            y: -1760.225830078125,
            z: 29.36194038391113,
          },
          offset: {
            left: {
              x: -108.30362701416016,
              y: -1754.0030517578125,
              z: 29.50430297851562,
            },
            right: {
              x: -118.35480499267578,
              y: -1766.4486083984375,
              z: 29.21957778930664,
            },
          },
        },
        {
          coords: {
            x: 68.70814514160156,
            y: -1894.669921875,
            z: 21.21682167053222,
          },
          offset: {
            left: {
              x: 63.43711853027344,
              y: -1890.0645751953127,
              z: 21.30220603942871,
            },
            right: {
              x: 73.97917175292969,
              y: -1899.2752685546875,
              z: 21.13143730163574,
            },
          },
        },
        {
          coords: {
            x: 114.32415771484376,
            y: -1868.48388671875,
            z: 23.82795143127441,
          },
          offset: {
            left: {
              x: 117.5067138671875,
              y: -1862.2586669921875,
              z: 24.17135238647461,
            },
            right: {
              x: 111.1416015625,
              y: -1874.7091064453127,
              z: 23.48455047607422,
            },
          },
        },
        {
          coords: {
            x: 203.72703552246097,
            y: -1914.4783935546875,
            z: 22.8807258605957,
          },
          offset: {
            left: {
              x: 207.4356689453125,
              y: -1908.5782470703127,
              z: 23.53949737548828,
            },
            right: {
              x: 200.01840209960935,
              y: -1920.3785400390625,
              z: 22.22195434570312,
            },
          },
        },
        {
          coords: {
            x: 166.9515838623047,
            y: -1968.9581298828127,
            z: 18.42771530151367,
          },
          offset: {
            left: {
              x: 172.21600341796875,
              y: -1973.57177734375,
              z: 18.44822120666504,
            },
            right: {
              x: 161.68716430664065,
              y: -1964.344482421875,
              z: 18.4072093963623,
            },
          },
        },
        {
          coords: {
            x: 137.2245330810547,
            y: -2028.5673828125,
            z: 17.87018585205078,
          },
          offset: {
            left: {
              x: 144.2139434814453,
              y: -2028.901123046875,
              z: 18.062105178833,
            },
            right: {
              x: 130.2351226806641,
              y: -2028.233642578125,
              z: 17.67826652526855,
            },
          },
        },
        {
          coords: {
            x: 198.43118286132812,
            y: -2049.568603515625,
            z: 17.91439437866211,
          },
          offset: {
            left: {
              x: 204.1633453369141,
              y: -2037.901123046875,
              z: 17.80331039428711,
            },
            right: {
              x: 192.6990203857422,
              y: -2061.236083984375,
              z: 18.02547836303711,
            },
          },
        },
        {
          coords: {
            x: 311.0249938964844,
            y: -2152.796875,
            z: 14.19787788391113,
          },
          offset: {
            left: {
              x: 317.2146301269531,
              y: -2144.9697265625,
              z: 14.85045719146728,
            },
            right: {
              x: 304.8353576660156,
              y: -2160.6240234375,
              z: 13.54529857635498,
            },
          },
        },
        {
          coords: {
            x: 412.7559509277344,
            y: -2144.107421875,
            z: 17.64271736145019,
          },
          offset: {
            left: {
              x: 404.5970764160156,
              y: -2138.32568359375,
              z: 17.58690452575683,
            },
            right: {
              x: 420.9148254394531,
              y: -2149.88916015625,
              z: 17.69853019714355,
            },
          },
        },
        {
          coords: {
            x: 468.5089111328125,
            y: -2077.64453125,
            z: 23.15605545043945,
          },
          offset: {
            left: {
              x: 461.2742614746094,
              y: -2070.7421875,
              z: 23.02085876464844,
            },
            right: {
              x: 475.7435607910156,
              y: -2084.546875,
              z: 23.29125213623047,
            },
          },
        },
        {
          coords: {
            x: 449.6446228027344,
            y: -2019.6002197265625,
            z: 23.17243385314941,
          },
          offset: {
            left: {
              x: 439.728759765625,
              y: -2029.4830322265625,
              z: 23.09724235534668,
            },
            right: {
              x: 459.56048583984375,
              y: -2009.7174072265625,
              z: 23.24762535095215,
            },
          },
        },
        {
          coords: {
            x: 330.5835266113281,
            y: -1891.3895263671875,
            z: 25.48711204528809,
          },
          offset: {
            left: {
              x: 325.3032836914063,
              y: -1897.3897705078127,
              z: 25.82780075073242,
            },
            right: {
              x: 335.86376953125,
              y: -1885.3892822265625,
              z: 25.14642333984375,
            },
          },
        },
        {
          coords: {
            x: 177.21697998046875,
            y: -1763.9510498046875,
            z: 28.72109031677246,
          },
          offset: {
            left: {
              x: 171.9209136962891,
              y: -1769.9462890625,
              z: 28.81774711608886,
            },
            right: {
              x: 182.51304626464844,
              y: -1757.955810546875,
              z: 28.62443351745605,
            },
          },
        },
        {
          coords: {
            x: -4.60164546966552,
            y: -1611.87548828125,
            z: 28.85005187988281,
          },
          offset: {
            left: {
              x: -10.336838722229,
              y: -1617.4522705078125,
              z: 28.93069076538086,
            },
            right: {
              x: 1.13354778289794,
              y: -1606.2987060546875,
              z: 28.76941299438477,
            },
          },
        },
        {
          coords: {
            x: -101.75933837890624,
            y: -1530.240234375,
            z: 33.3100357055664,
          },
          offset: {
            left: {
              x: -107.20349884033205,
              y: -1536.09912109375,
              z: 33.4958610534668,
            },
            right: {
              x: -96.31517791748048,
              y: -1524.38134765625,
              z: 33.12421035766601,
            },
          },
        },
        {
          coords: {
            x: -214.89122009277344,
            y: -1439.5008544921875,
            z: 30.93794631958008,
          },
          offset: {
            left: {
              x: -219.72439575195312,
              y: -1445.8758544921875,
              z: 30.93214607238769,
            },
            right: {
              x: -210.05804443359375,
              y: -1433.1258544921875,
              z: 30.94374656677246,
            },
          },
        },
        {
          coords: {
            x: -256.2709045410156,
            y: -1422.414306640625,
            z: 30.86265563964844,
          },
          offset: {
            left: {
              x: -255.54269409179688,
              y: -1429.3753662109375,
              z: 30.97805404663086,
            },
            right: {
              x: -256.9991149902344,
              y: -1415.4532470703125,
              z: 30.74725723266601,
            },
          },
        },
        {
          coords: {
            x: -282.7162780761719,
            y: -1460.218994140625,
            z: 30.85860633850097,
          },
          offset: {
            left: {
              x: -275.8057250976563,
              y: -1461.333740234375,
              z: 30.81753730773925,
            },
            right: {
              x: -289.6268310546875,
              y: -1459.104248046875,
              z: 30.89967536926269,
            },
          },
        },
        {
          coords: {
            x: -357.8591613769531,
            y: -1638.488525390625,
            z: 18.65974426269531,
          },
          offset: {
            left: {
              x: -352.2396240234375,
              y: -1642.662109375,
              z: 18.71074295043945,
            },
            right: {
              x: -363.4786987304687,
              y: -1634.31494140625,
              z: 18.60874557495117,
            },
          },
        },
        {
          coords: {
            x: -402.2857360839844,
            y: -1816.564208984375,
            z: 20.89498138427734,
          },
          offset: {
            left: {
              x: -395.5667114257813,
              y: -1814.6068115234375,
              z: 21.04831314086914,
            },
            right: {
              x: -409.0047607421875,
              y: -1818.5216064453127,
              z: 20.74164962768554,
            },
          },
        },
        {
          coords: {
            x: -330.70989990234375,
            y: -1834.2818603515625,
            z: 23.41063499450683,
          },
          offset: {
            left: {
              x: -329.3654479980469,
              y: -1827.4146728515625,
              z: 23.59495544433593,
            },
            right: {
              x: -332.0543518066406,
              y: -1841.1490478515625,
              z: 23.22631454467773,
            },
          },
        },
        {
          coords: {
            x: -231.40773010253903,
            y: -1821.98974609375,
            z: 29.49941825866699,
          },
          offset: {
            left: {
              x: -234.91183471679688,
              y: -1815.9306640625,
              z: 29.40822410583496,
            },
            right: {
              x: -227.90362548828128,
              y: -1828.048828125,
              z: 29.59061241149902,
            },
          },
        },
        {
          coords: {
            x: -165.7869415283203,
            y: -1782.8223876953125,
            z: 29.40845489501953,
          },
          offset: {
            left: {
              x: -169.90586853027344,
              y: -1777.1634521484375,
              z: 29.50992584228515,
            },
            right: {
              x: -161.6680145263672,
              y: -1788.4813232421875,
              z: 29.3069839477539,
            },
          },
        },
      ],
      Creator: "CITIZENID",
      CreatorName: "ciphertv",
      Curated: 1,
      Distance: 2582,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 0,
      RaceId: "CW-3610",
      RaceName: "Southside Sprint",
      Racers: [],
      Records: [],
      Started: false,
      Waiting: false,
    },
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: 1916.5615234375,
            y: -959.0528564453124,
            z: 78.88324737548828,
          },
          offset: {
            left: {
              x: 1921.7457275390625,
              y: -965.1456909179688,
              z: 78.92194366455078,
            },
            right: {
              x: 1911.3773193359375,
              y: -952.9600219726564,
              z: 78.84455108642578,
            },
          },
        },
        {
          coords: {
            x: 1850.300048828125,
            y: -1031.4061279296875,
            z: 78.8812255859375,
          },
          offset: {
            left: {
              x: 1857.3009033203127,
              y: -1035.27685546875,
              z: 78.9571762084961,
            },
            right: {
              x: 1843.2991943359375,
              y: -1027.535400390625,
              z: 78.8052749633789,
            },
          },
        },
        {
          coords: {
            x: 1719.4814453125,
            y: -1295.4481201171875,
            z: 85.38350677490234,
          },
          offset: {
            left: {
              x: 1723.8350830078125,
              y: -1302.1593017578125,
              z: 85.46202087402344,
            },
            right: {
              x: 1715.1278076171875,
              y: -1288.7369384765625,
              z: 85.30499267578125,
            },
          },
        },
        {
          coords: {
            x: 1575.621337890625,
            y: -1409.8304443359375,
            z: 79.46774291992188,
          },
          offset: {
            left: {
              x: 1581.508544921875,
              y: -1415.2469482421875,
              z: 79.5208511352539,
            },
            right: {
              x: 1569.734130859375,
              y: -1404.4139404296875,
              z: 79.41463470458984,
            },
          },
        },
        {
          coords: {
            x: 1403.387939453125,
            y: -1555.674072265625,
            z: 56.7538833618164,
          },
          offset: {
            left: {
              x: 1408.17529296875,
              y: -1562.08349609375,
              z: 56.74676132202148,
            },
            right: {
              x: 1398.6005859375,
              y: -1549.2646484375,
              z: 56.76100540161133,
            },
          },
        },
        {
          coords: {
            x: 1382.8994140625,
            y: -1686.1331787109375,
            z: 60.87969207763672,
          },
          offset: {
            left: {
              x: 1397.223388671875,
              y: -1679.0247802734375,
              z: 61.42361068725586,
            },
            right: {
              x: 1368.575439453125,
              y: -1693.2415771484375,
              z: 60.33577346801758,
            },
          },
        },
        {
          coords: {
            x: 1426.0341796875,
            y: -1870.2037353515625,
            z: 71.18351745605469,
          },
          offset: {
            left: {
              x: 1441.968994140625,
              y: -1871.516357421875,
              z: 71.7821273803711,
            },
            right: {
              x: 1410.099365234375,
              y: -1868.89111328125,
              z: 70.58490753173828,
            },
          },
        },
        {
          coords: {
            x: 1315.80859375,
            y: -2022.802734375,
            z: 46.5206184387207,
          },
          offset: {
            left: {
              x: 1321.0855712890625,
              y: -2035.7681884765625,
              z: 46.29645538330078,
            },
            right: {
              x: 1310.5316162109375,
              y: -2009.8372802734375,
              z: 46.74478149414062,
            },
          },
        },
        {
          coords: {
            x: 1280.145751953125,
            y: -2165.7978515625,
            z: 48.33737182617187,
          },
          offset: {
            left: {
              x: 1298.4227294921875,
              y: -2160.6064453125,
              z: 48.3809585571289,
            },
            right: {
              x: 1261.8687744140625,
              y: -2170.9892578125,
              z: 48.29378509521484,
            },
          },
        },
        {
          coords: {
            x: 1289.300048828125,
            y: -2480.194580078125,
            z: 46.62458038330078,
          },
          offset: {
            left: {
              x: 1300.618408203125,
              y: -2490.0302734375,
              z: 46.23427581787109,
            },
            right: {
              x: 1277.981689453125,
              y: -2470.35888671875,
              z: 47.01488494873047,
            },
          },
        },
        {
          coords: {
            x: 1212.7442626953125,
            y: -2539.742919921875,
            z: 38.26563262939453,
          },
          offset: {
            left: {
              x: 1219.9039306640625,
              y: -2554.048095703125,
              z: 37.95227432250976,
            },
            right: {
              x: 1205.5845947265625,
              y: -2525.437744140625,
              z: 38.5789909362793,
            },
          },
        },
        {
          coords: {
            x: 1198.1680908203125,
            y: -2593.813720703125,
            z: 38.63562774658203,
          },
          offset: {
            left: {
              x: 1204.7398681640625,
              y: -2587.668212890625,
              z: 38.84534072875976,
            },
            right: {
              x: 1191.5963134765625,
              y: -2599.959228515625,
              z: 38.4259147644043,
            },
          },
        },
        {
          coords: {
            x: 1290.49365234375,
            y: -2598.568115234375,
            z: 45.94710922241211,
          },
          offset: {
            left: {
              x: 1287.6092529296875,
              y: -2590.04345703125,
              z: 46.05852127075195,
            },
            right: {
              x: 1293.3780517578125,
              y: -2607.0927734375,
              z: 45.83569717407226,
            },
          },
        },
        {
          coords: {
            x: 1474.137939453125,
            y: -2586.865966796875,
            z: 48.6036148071289,
          },
          offset: {
            left: {
              x: 1474.85888671875,
              y: -2577.89501953125,
              z: 48.62173461914062,
            },
            right: {
              x: 1473.4169921875,
              y: -2595.8369140625,
              z: 48.58549499511719,
            },
          },
        },
        {
          coords: {
            x: 1615.0037841796875,
            y: -2536.770751953125,
            z: 70.2624282836914,
          },
          offset: {
            left: {
              x: 1614.07373046875,
              y: -2527.820068359375,
              z: 70.39791870117188,
            },
            right: {
              x: 1615.933837890625,
              y: -2545.721435546875,
              z: 70.12693786621094,
            },
          },
        },
        {
          coords: {
            x: 1646.987060546875,
            y: -2461.842041015625,
            z: 84.93600463867188,
          },
          offset: {
            left: {
              x: 1637.870849609375,
              y: -2465.951171875,
              z: 85.03759002685547,
            },
            right: {
              x: 1656.103271484375,
              y: -2457.73291015625,
              z: 84.83441925048828,
            },
          },
        },
        {
          coords: {
            x: 1655.629638671875,
            y: -2383.828125,
            z: 95.31616973876952,
          },
          offset: {
            left: {
              x: 1651.661865234375,
              y: -2374.65087890625,
              z: 95.50850677490236,
            },
            right: {
              x: 1659.597412109375,
              y: -2393.00537109375,
              z: 95.12383270263672,
            },
          },
        },
        {
          coords: {
            x: 1668.614990234375,
            y: -2236.899658203125,
            z: 110.4331512451172,
          },
          offset: {
            left: {
              x: 1660.17236328125,
              y: -2242.2587890625,
              z: 110.48942565917967,
            },
            right: {
              x: 1677.0576171875,
              y: -2231.54052734375,
              z: 110.37687683105467,
            },
          },
        },
        {
          coords: {
            x: 1653.0816650390625,
            y: -2183.664794921875,
            z: 108.11876678466795,
          },
          offset: {
            left: {
              x: 1643.15673828125,
              y: -2182.4423828125,
              z: 108.1628646850586,
            },
            right: {
              x: 1663.006591796875,
              y: -2184.88720703125,
              z: 108.07466888427736,
            },
          },
        },
        {
          coords: {
            x: 1677.3280029296875,
            y: -2130.80126953125,
            z: 107.215087890625,
          },
          offset: {
            left: {
              x: 1668.9849853515625,
              y: -2125.289306640625,
              z: 107.3171157836914,
            },
            right: {
              x: 1685.6710205078125,
              y: -2136.313232421875,
              z: 107.1130599975586,
            },
          },
        },
        {
          coords: {
            x: 1714.7930908203125,
            y: -2034.080078125,
            z: 109.56355285644533,
          },
          offset: {
            left: {
              x: 1704.851806640625,
              y: -2035.1514892578127,
              z: 109.71421813964844,
            },
            right: {
              x: 1724.734375,
              y: -2033.0086669921875,
              z: 109.4128875732422,
            },
          },
        },
        {
          coords: {
            x: 1731.5438232421875,
            y: -1941.47412109375,
            z: 116.50113677978516,
          },
          offset: {
            left: {
              x: 1724.115966796875,
              y: -1934.779052734375,
              z: 116.5668487548828,
            },
            right: {
              x: 1738.9716796875,
              y: -1948.169189453125,
              z: 116.4354248046875,
            },
          },
        },
        {
          coords: {
            x: 1733.4173583984375,
            y: -1850.3685302734375,
            z: 114.50086975097656,
          },
          offset: {
            left: {
              x: 1727.021484375,
              y: -1856.69970703125,
              z: 114.59398651123048,
            },
            right: {
              x: 1739.813232421875,
              y: -1844.037353515625,
              z: 114.40775299072266,
            },
          },
        },
        {
          coords: {
            x: 1753.206787109375,
            y: -1731.829345703125,
            z: 116.66439819335938,
          },
          offset: {
            left: {
              x: 1749.5191650390625,
              y: -1724.7320556640625,
              z: 116.83601379394533,
            },
            right: {
              x: 1756.8944091796875,
              y: -1738.9266357421875,
              z: 116.49278259277344,
            },
          },
        },
        {
          coords: {
            x: 1790.828369140625,
            y: -1574.436767578125,
            z: 114.73091888427736,
          },
          offset: {
            left: {
              x: 1783.052734375,
              y: -1576.3099365234375,
              z: 114.90847778320312,
            },
            right: {
              x: 1798.60400390625,
              y: -1572.5635986328125,
              z: 114.55335998535156,
            },
          },
        },
        {
          coords: {
            x: 1822.39111328125,
            y: -1446.9962158203125,
            z: 121.817626953125,
          },
          offset: {
            left: {
              x: 1816.4461669921875,
              y: -1441.6431884765625,
              z: 121.87100219726564,
            },
            right: {
              x: 1828.3360595703127,
              y: -1452.3492431640625,
              z: 121.76425170898438,
            },
          },
        },
        {
          coords: {
            x: 1912.8480224609375,
            y: -1310.6458740234375,
            z: 133.03871154785156,
          },
          offset: {
            left: {
              x: 1902.969970703125,
              y: -1309.09912109375,
              z: 132.86131286621097,
            },
            right: {
              x: 1922.72607421875,
              y: -1312.192626953125,
              z: 133.2161102294922,
            },
          },
        },
        {
          coords: {
            x: 1902.3056640625,
            y: -1225.8594970703125,
            z: 120.05872344970705,
          },
          offset: {
            left: {
              x: 1893.434814453125,
              y: -1224.3486328125,
              z: 120.21672058105467,
            },
            right: {
              x: 1911.176513671875,
              y: -1227.370361328125,
              z: 119.90072631835938,
            },
          },
        },
        {
          coords: {
            x: 1940.2215576171875,
            y: -1096.0767822265625,
            z: 96.57366943359376,
          },
          offset: {
            left: {
              x: 1931.357421875,
              y: -1094.519775390625,
              z: 96.63494873046876,
            },
            right: {
              x: 1949.085693359375,
              y: -1097.6337890625,
              z: 96.51239013671876,
            },
          },
        },
        {
          coords: {
            x: 1997.4241943359375,
            y: -1000.0828857421876,
            z: 84.40451049804688,
          },
          offset: {
            left: {
              x: 1989.5108642578127,
              y: -995.7977905273438,
              z: 84.53192901611328,
            },
            right: {
              x: 2005.3375244140625,
              y: -1004.3679809570312,
              z: 84.27709197998047,
            },
          },
        },
        {
          coords: {
            x: 2001.494384765625,
            y: -963.0249633789064,
            z: 79.63314819335938,
          },
          offset: {
            left: {
              x: 1992.694091796875,
              y: -964.9097290039064,
              z: 79.57564544677734,
            },
            right: {
              x: 2010.294677734375,
              y: -961.1401977539064,
              z: 79.6906509399414,
            },
          },
        },
      ],
      Creator: "CITIZENID",
      CreatorName: "Coffee",
      Curated: 1,
      Distance: 4030,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 0,
      RaceId: "CW-4925",
      RaceName: "Oil Fields",
      Racers: [],
      Records: [],
      Started: false,
      Waiting: false,
    },
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: -2058.68896484375,
            y: -174.2387847900391,
            z: 24.18918800354004,
          },
          offset: {
            left: {
              x: -2055.868408203125,
              y: -181.7250518798828,
              z: 24.21828079223632,
            },
            right: {
              x: -2061.509521484375,
              y: -166.7525177001953,
              z: 24.16009521484375,
            },
          },
        },
        {
          coords: {
            x: -2134.77197265625,
            y: -233.72691345214844,
            z: 16.39933967590332,
          },
          offset: {
            left: {
              x: -2127.85546875,
              y: -237.74609375,
              z: 16.48214530944824,
            },
            right: {
              x: -2141.6884765625,
              y: -229.70773315429688,
              z: 16.3165340423584,
            },
          },
        },
        {
          coords: {
            x: -2184.907958984375,
            y: -332.6751403808594,
            z: 12.6775951385498,
          },
          offset: {
            left: {
              x: -2181.79638671875,
              y: -341.1178283691406,
              z: 12.87374210357666,
            },
            right: {
              x: -2188.01953125,
              y: -324.2324523925781,
              z: 12.48144817352295,
            },
          },
        },
        {
          coords: {
            x: -2464.942138671875,
            y: -212.4425811767578,
            z: 16.91022109985351,
          },
          offset: {
            left: {
              x: -2467.74365234375,
              y: -218.8575439453125,
              z: 16.9064826965332,
            },
            right: {
              x: -2462.140625,
              y: -206.02761840820312,
              z: 16.91395950317382,
            },
          },
        },
        {
          coords: {
            x: -2826.685791015625,
            y: 57.62279891967773,
            z: 14.1447696685791,
          },
          offset: {
            left: {
              x: -2829.598388671875,
              y: 51.25756454467773,
              z: 14.14350032806396,
            },
            right: {
              x: -2823.773193359375,
              y: 63.98803329467773,
              z: 14.14603900909423,
            },
          },
        },
        {
          coords: {
            x: -3068.1494140625,
            y: 232.63751220703128,
            z: 14.85400962829589,
          },
          offset: {
            left: {
              x: -3071.65478515625,
              y: 226.58119201660156,
              z: 15.0361623764038,
            },
            right: {
              x: -3064.64404296875,
              y: 238.69383239746097,
              z: 14.67185688018798,
            },
          },
        },
        {
          coords: {
            x: -3084.89013671875,
            y: 745.8052978515625,
            z: 20.42885398864746,
          },
          offset: {
            left: {
              x: -3090.589599609375,
              y: 749.8613891601562,
              z: 20.17327499389648,
            },
            right: {
              x: -3079.190673828125,
              y: 741.7492065429688,
              z: 20.68443298339844,
            },
          },
        },
        {
          coords: {
            x: -3123.770263671875,
            y: 836.9495849609375,
            z: 16.05182647705078,
          },
          offset: {
            left: {
              x: -3130.315185546875,
              y: 834.4703369140625,
              z: 15.9230031967163,
            },
            right: {
              x: -3117.225341796875,
              y: 839.4288330078125,
              z: 16.18065071105957,
            },
          },
        },
        {
          coords: {
            x: -3229.374755859375,
            y: 982.0936279296876,
            z: 12.07406234741211,
          },
          offset: {
            left: {
              x: -3238.326171875,
              y: 981.1641845703124,
              z: 12.17106819152832,
            },
            right: {
              x: -3220.42333984375,
              y: 983.0230712890624,
              z: 11.97705650329589,
            },
          },
        },
        {
          coords: {
            x: -3180.9599609375,
            y: 1199.06494140625,
            z: 8.89853382110595,
          },
          offset: {
            left: {
              x: -3189.95849609375,
              y: 1199.2152099609375,
              z: 8.96695232391357,
            },
            right: {
              x: -3171.96142578125,
              y: 1198.9146728515625,
              z: 8.83011531829834,
            },
          },
        },
        {
          coords: {
            x: -3109.22021484375,
            y: 1253.911865234375,
            z: 19.77123260498047,
          },
          offset: {
            left: {
              x: -3101.289306640625,
              y: 1252.8624267578125,
              z: 19.75432777404785,
            },
            right: {
              x: -3117.151123046875,
              y: 1254.9613037109375,
              z: 19.78813743591309,
            },
          },
        },
        {
          coords: {
            x: -3066.968994140625,
            y: 1189.839111328125,
            z: 21.32436370849609,
          },
          offset: {
            left: {
              x: -3069.736328125,
              y: 1195.16259765625,
              z: 21.2685604095459,
            },
            right: {
              x: -3064.20166015625,
              y: 1184.515625,
              z: 21.38016700744629,
            },
          },
        },
        {
          coords: {
            x: -3004.870849609375,
            y: 1298.2100830078125,
            z: 32.69803619384765,
          },
          offset: {
            left: {
              x: -3009.91162109375,
              y: 1301.46435546875,
              z: 32.67031478881836,
            },
            right: {
              x: -2999.830078125,
              y: 1294.955810546875,
              z: 32.72575759887695,
            },
          },
        },
        {
          coords: {
            x: -2777.5234375,
            y: 1335.9649658203125,
            z: 77.6662368774414,
          },
          offset: {
            left: {
              x: -2782.165771484375,
              y: 1339.7662353515625,
              z: 77.65728759765625,
            },
            right: {
              x: -2772.881103515625,
              y: 1332.1636962890625,
              z: 77.67518615722656,
            },
          },
        },
        {
          coords: {
            x: -2633.997314453125,
            y: 1473.685302734375,
            z: 124.50038146972656,
          },
          offset: {
            left: {
              x: -2628.346923828125,
              y: 1475.7025146484375,
              z: 124.55901336669922,
            },
            right: {
              x: -2639.647705078125,
              y: 1471.6680908203125,
              z: 124.4417495727539,
            },
          },
        },
        {
          coords: {
            x: -2623.475830078125,
            y: 1118.884765625,
            z: 162.81524658203125,
          },
          offset: {
            left: {
              x: -2617.66796875,
              y: 1120.389892578125,
              z: 162.8806610107422,
            },
            right: {
              x: -2629.28369140625,
              y: 1117.379638671875,
              z: 162.7498321533203,
            },
          },
        },
        {
          coords: {
            x: -2422.194091796875,
            y: 1034.8189697265625,
            z: 194.8414764404297,
          },
          offset: {
            left: {
              x: -2421.16259765625,
              y: 1040.7296142578125,
              z: 194.8628387451172,
            },
            right: {
              x: -2423.2255859375,
              y: 1028.9083251953125,
              z: 194.8201141357422,
            },
          },
        },
        {
          coords: {
            x: -2157.74951171875,
            y: 995.6871948242188,
            z: 186.9688720703125,
          },
          offset: {
            left: {
              x: -2153.170166015625,
              y: 999.5621337890624,
              z: 187.08534240722656,
            },
            right: {
              x: -2162.328857421875,
              y: 991.812255859375,
              z: 186.85240173339844,
            },
          },
        },
        {
          coords: {
            x: -2019.4385986328127,
            y: 822.8612670898438,
            z: 162.05120849609375,
          },
          offset: {
            left: {
              x: -2013.4820556640625,
              y: 822.1405029296875,
              z: 162.06826782226565,
            },
            right: {
              x: -2025.3951416015625,
              y: 823.58203125,
              z: 162.03414916992188,
            },
          },
        },
        {
          coords: {
            x: -1903.937255859375,
            y: 751.1669311523438,
            z: 140.5968780517578,
          },
          offset: {
            left: {
              x: -1907.6085205078127,
              y: 755.91259765625,
              z: 140.6139373779297,
            },
            right: {
              x: -1900.2659912109375,
              y: 746.4212646484375,
              z: 140.57981872558597,
            },
          },
        },
        {
          coords: {
            x: -1765.43505859375,
            y: 797.2158203125,
            z: 139.4486541748047,
          },
          offset: {
            left: {
              x: -1760.0601806640625,
              y: 792.7322387695312,
              z: 139.5384979248047,
            },
            right: {
              x: -1770.8099365234375,
              y: 801.6994018554688,
              z: 139.3588104248047,
            },
          },
        },
        {
          coords: {
            x: -1922.4866943359375,
            y: 671.649658203125,
            z: 125.13976287841795,
          },
          offset: {
            left: {
              x: -1917.0284423828127,
              y: 667.267578125,
              z: 125.07227325439452,
            },
            right: {
              x: -1927.9449462890625,
              y: 676.03173828125,
              z: 125.2072525024414,
            },
          },
        },
        {
          coords: {
            x: -1968.0806884765625,
            y: 383.4694213867187,
            z: 93.8378677368164,
          },
          offset: {
            left: {
              x: -1961.128173828125,
              y: 384.2811584472656,
              z: 93.89115142822266,
            },
            right: {
              x: -1975.033203125,
              y: 382.6576843261719,
              z: 93.78458404541016,
            },
          },
        },
        {
          coords: {
            x: -1746.31396484375,
            y: 41.03237152099609,
            z: 66.98880767822266,
          },
          offset: {
            left: {
              x: -1733.5889892578125,
              y: 55.1412239074707,
              z: 67.11170959472656,
            },
            right: {
              x: -1759.0389404296875,
              y: 26.92351913452148,
              z: 66.86590576171875,
            },
          },
        },
        {
          coords: {
            x: -1587.6162109375,
            y: -194.32379150390625,
            z: 54.96126174926758,
          },
          offset: {
            left: {
              x: -1581.068359375,
              y: -196.7978973388672,
              z: 55.02985763549805,
            },
            right: {
              x: -1594.1640625,
              y: -191.8496856689453,
              z: 54.89266586303711,
            },
          },
        },
        {
          coords: {
            x: -1760.25146484375,
            y: -339.1641540527344,
            z: 45.21129989624023,
          },
          offset: {
            left: {
              x: -1763.7296142578125,
              y: -345.2388000488281,
              z: 45.23727798461914,
            },
            right: {
              x: -1756.7733154296875,
              y: -333.0895080566406,
              z: 45.18532180786133,
            },
          },
        },
        {
          coords: {
            x: -1888.3553466796875,
            y: -197.1964569091797,
            z: 36.81180191040039,
          },
          offset: {
            left: {
              x: -1892.918212890625,
              y: -202.4972991943359,
              z: 36.52742767333984,
            },
            right: {
              x: -1883.79248046875,
              y: -191.89561462402344,
              z: 37.09617614746094,
            },
          },
        },
      ],
      Creator: "CITIZENID",
      CreatorName: "xdDevion",
      Curated: 1,
      Distance: 6049,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 0,
      RaceId: "CW-9628",
      RaceName: "High-Hill Hijinks",
      Racers: [],
      Records: [],
      Started: false,
      Waiting: false,
    },
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: -387.7688598632813,
            y: 1179.626220703125,
            z: 325.15087890625,
          },
          offset: {
            left: {
              x: -386.2536315917969,
              y: 1184.2259521484375,
              z: 323.9072570800781,
            },
            right: {
              x: -389.2840881347656,
              y: 1175.0264892578125,
              z: 326.3945007324219,
            },
          },
        },
        {
          coords: {
            x: -259.7069396972656,
            y: 1264.41943359375,
            z: 310.418701171875,
          },
          offset: {
            left: {
              x: -266.7976684570313,
              y: 1268.1236572265625,
              z: 310.4309692382813,
            },
            right: {
              x: -252.61619567871097,
              y: 1260.7152099609375,
              z: 310.40643310546875,
            },
          },
        },
        {
          coords: {
            x: -179.09573364257812,
            y: 1378.920654296875,
            z: 294.2252197265625,
          },
          offset: {
            left: {
              x: -186.6234130859375,
              y: 1376.2127685546875,
              z: 294.2637634277344,
            },
            right: {
              x: -171.56805419921875,
              y: 1381.6285400390625,
              z: 294.1866760253906,
            },
          },
        },
        {
          coords: {
            x: -517.8108520507812,
            y: 1326.0838623046875,
            z: 300.8497619628906,
          },
          offset: {
            left: {
              x: -516.2027587890625,
              y: 1318.247314453125,
              z: 300.7950439453125,
            },
            right: {
              x: -519.4189453125,
              y: 1333.92041015625,
              z: 300.90447998046875,
            },
          },
        },
        {
          coords: {
            x: -698.6935424804688,
            y: 1188.0963134765625,
            z: 265.19891357421875,
          },
          offset: {
            left: {
              x: -694.852294921875,
              y: 1183.6920166015625,
              z: 263.8399963378906,
            },
            right: {
              x: -702.5347900390625,
              y: 1192.5006103515625,
              z: 266.5578308105469,
            },
          },
        },
        {
          coords: {
            x: -768.1461181640625,
            y: 1191.78466796875,
            z: 261.7866821289063,
          },
          offset: {
            left: {
              x: -773.5426635742188,
              y: 1189.344482421875,
              z: 260.826171875,
            },
            right: {
              x: -762.7495727539062,
              y: 1194.224853515625,
              z: 262.7471923828125,
            },
          },
        },
        {
          coords: {
            x: -763.452392578125,
            y: 1683.3760986328125,
            z: 200.73719787597656,
          },
          offset: {
            left: {
              x: -768.3964233398438,
              y: 1686.62890625,
              z: 199.7495269775391,
            },
            right: {
              x: -758.5083618164062,
              y: 1680.123291015625,
              z: 201.7248687744141,
            },
          },
        },
        {
          coords: {
            x: -534.3758544921875,
            y: 1965.3997802734375,
            z: 205.365951538086,
          },
          offset: {
            left: {
              x: -539.9415893554688,
              y: 1967.2659912109375,
              z: 204.1248779296875,
            },
            right: {
              x: -528.8101196289062,
              y: 1963.5335693359375,
              z: 206.6070251464844,
            },
          },
        },
        {
          coords: {
            x: -253.92404174804688,
            y: 1832.31884765625,
            z: 197.89540100097656,
          },
          offset: {
            left: {
              x: -256.4438171386719,
              y: 1837.6673583984375,
              z: 196.87339782714844,
            },
            right: {
              x: -251.40428161621097,
              y: 1826.9703369140625,
              z: 198.9174041748047,
            },
          },
        },
        {
          coords: {
            x: -124.20548248291016,
            y: 1859.6407470703127,
            z: 197.92236328125,
          },
          offset: {
            left: {
              x: -122.8287353515625,
              y: 1865.3179931640625,
              z: 196.553451538086,
            },
            right: {
              x: -125.5822296142578,
              y: 1853.9635009765625,
              z: 199.2912750244141,
            },
          },
        },
        {
          coords: {
            x: 83.5237808227539,
            y: 1695.611083984375,
            z: 226.381591796875,
          },
          offset: {
            left: {
              x: 86.13288116455078,
              y: 1701.01416015625,
              z: 226.3815155029297,
            },
            right: {
              x: 80.91468048095703,
              y: 1690.2080078125,
              z: 226.3816680908203,
            },
          },
        },
        {
          coords: {
            x: 155.65158081054688,
            y: 1485.46728515625,
            z: 238.85606384277344,
          },
          offset: {
            left: {
              x: 160.73800659179688,
              y: 1488.4293212890625,
              z: 237.69227600097656,
            },
            right: {
              x: 150.56515502929688,
              y: 1482.5052490234375,
              z: 240.0198516845703,
            },
          },
        },
        {
          coords: {
            x: 239.0494842529297,
            y: 1350.8895263671875,
            z: 238.3094024658203,
          },
          offset: {
            left: {
              x: 244.7320251464844,
              y: 1352.100341796875,
              z: 236.8118896484375,
            },
            right: {
              x: 233.366943359375,
              y: 1349.6787109375,
              z: 239.80691528320312,
            },
          },
        },
        {
          coords: {
            x: 134.11788940429688,
            y: 1392.736572265625,
            z: 254.4127197265625,
          },
          offset: {
            left: {
              x: 133.60386657714844,
              y: 1386.938720703125,
              z: 252.95652770996097,
            },
            right: {
              x: 134.6319122314453,
              y: 1398.534423828125,
              z: 255.8689117431641,
            },
          },
        },
        {
          coords: {
            x: -79.83805084228516,
            y: 1504.904541015625,
            z: 282.0643615722656,
          },
          offset: {
            left: {
              x: -81.96759796142578,
              y: 1499.295166015625,
              z: 282.0642395019531,
            },
            right: {
              x: -77.70850372314453,
              y: 1510.513916015625,
              z: 282.0644836425781,
            },
          },
        },
        {
          coords: {
            x: -140.47406005859375,
            y: 1512.3170166015625,
            z: 287.6602172851563,
          },
          offset: {
            left: {
              x: -139.9065704345703,
              y: 1504.337646484375,
              z: 287.7491760253906,
            },
            right: {
              x: -141.0415496826172,
              y: 1520.29638671875,
              z: 287.5712585449219,
            },
          },
        },
        {
          coords: {
            x: -460.981689453125,
            y: 1331.3038330078125,
            z: 306.1158142089844,
          },
          offset: {
            left: {
              x: -453.0932312011719,
              y: 1332.634521484375,
              z: 306.1566162109375,
            },
            right: {
              x: -468.8701477050781,
              y: 1329.97314453125,
              z: 306.0750122070313,
            },
          },
        },
        {
          coords: {
            x: -430.4809875488281,
            y: 1190.9625244140625,
            z: 325.16595458984375,
          },
          offset: {
            left: {
              x: -429.1232604980469,
              y: 1196.7103271484375,
              z: 324.1077270507813,
            },
            right: {
              x: -431.8387145996094,
              y: 1185.2147216796875,
              z: 326.2241821289063,
            },
          },
        },
      ],
      Creator: "CITIZENID",
      CreatorName: "NoSwear",
      Curated: 1,
      Distance: 3959,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 0,
      RaceId: "CW-9030",
      RaceName: "HSPU",
      Racers: [],
      Records: [],
      Started: false,
      Waiting: false,
    },
    {
      Access: [],
      Automated: true,
      BuyIn: 1,
      Checkpoints: [
        {
          coords: {
            x: 192.1571044921875,
            y: -3009.646240234375,
            z: 5.43363714218139,
          },
          offset: {
            left: {
              x: 203.15435791015625,
              y: -3009.89111328125,
              z: 5.45968914031982,
            },
            right: {
              x: 181.15985107421875,
              y: -3009.4013671875,
              z: 5.40758514404296,
            },
          },
        },
        {
          coords: {
            x: 177.57647705078125,
            y: -3113.79150390625,
            z: 5.27964162826538,
          },
          offset: {
            left: {
              x: 191.57095336914065,
              y: -3113.3984375,
              z: 5.27972698211669,
            },
            right: {
              x: 163.58200073242188,
              y: -3114.1845703125,
              z: 5.27955627441406,
            },
          },
        },
        {
          coords: {
            x: 176.9245147705078,
            y: -3242.927734375,
            z: 5.28103351593017,
          },
          offset: {
            left: {
              x: 190.92404174804688,
              y: -3242.8125,
              z: 5.28138065338134,
            },
            right: {
              x: 162.92498779296875,
              y: -3243.04296875,
              z: 5.280686378479,
            },
          },
        },
        {
          coords: {
            x: 222.51715087890625,
            y: -3328.126220703125,
            z: 5.4850206375122,
          },
          offset: {
            left: {
              x: 222.85586547851568,
              y: -3320.13525390625,
              z: 5.65613365173339,
            },
            right: {
              x: 222.17843627929688,
              y: -3336.1171875,
              z: 5.31390762329101,
            },
          },
        },
        {
          coords: {
            x: 283.7339782714844,
            y: -3265.1943359375,
            z: 5.36109447479248,
          },
          offset: {
            left: {
              x: 263.8367309570313,
              y: -3263.633544921875,
              z: 6.65055227279663,
            },
            right: {
              x: 303.6312255859375,
              y: -3266.755126953125,
              z: 4.07163667678833,
            },
          },
        },
        {
          coords: {
            x: 298.6358642578125,
            y: -3053.411865234375,
            z: 5.56501054763793,
          },
          offset: {
            left: {
              x: 285.6551208496094,
              y: -3054.118408203125,
              z: 5.59668350219726,
            },
            right: {
              x: 311.6166076660156,
              y: -3052.705322265625,
              z: 5.53333759307861,
            },
          },
        },
        {
          coords: {
            x: 298.32684326171875,
            y: -2857.054931640625,
            z: 5.70135927200317,
          },
          offset: {
            left: {
              x: 285.0413513183594,
              y: -2861.47021484375,
              z: 5.69374752044677,
            },
            right: {
              x: 311.6123352050781,
              y: -2852.6396484375,
              z: 5.70897102355957,
            },
          },
        },
        {
          coords: {
            x: 249.983139038086,
            y: -2807.890625,
            z: 5.69134283065795,
          },
          offset: {
            left: {
              x: 260.7420349121094,
              y: -2815.187744140625,
              z: 5.702157497406,
            },
            right: {
              x: 239.22425842285156,
              y: -2800.593505859375,
              z: 5.68052816390991,
            },
          },
        },
        {
          coords: {
            x: 228.74984741210935,
            y: -2883.035888671875,
            z: 5.64216566085815,
          },
          offset: {
            left: {
              x: 243.13877868652344,
              y: -2887.273193359375,
              z: 5.57682657241821,
            },
            right: {
              x: 214.3609161376953,
              y: -2878.798583984375,
              z: 5.70750474929809,
            },
          },
        },
        {
          coords: {
            x: 198.01296997070312,
            y: -2977.896484375,
            z: 5.61833953857421,
          },
          offset: {
            left: {
              x: 212.44078063964844,
              y: -2981.990966796875,
              z: 5.88906192779541,
            },
            right: {
              x: 183.5851593017578,
              y: -2973.802001953125,
              z: 5.34761714935302,
            },
          },
        },
      ],
      Creator: "CITIZENID",
      CreatorName: "Coffee",
      Curated: 1,
      Distance: 1045,
      FirstPerson: false,
      Ghosting: false,
      GhostingTime: 0,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 1,
      ParticipationAmount: 100,
      ParticipationCurrency: "racingcrypto",
      RaceId: "CW-7666",
      RaceName: "Elysian",
      Racers: [],
      Ranked: true,
      Records: [
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 31787,
          Vehicle: "ARGENTO",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 32387,
          Vehicle: "ARIANT",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 34320,
          Vehicle: "SULTAN3",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 35218,
          Vehicle: "ARGENTO",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 38500,
          Vehicle: "ARGENTO",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 38909,
          Vehicle: "ARGENTO",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 38979,
          Vehicle: "ARGENTO",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 39449,
          Vehicle: "ARGENTO",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 39559,
          Vehicle: "ARGENTO",
        },
        {
          Class: "S",
          Holder: "DROP TABLE racer_names-hey",
          RaceType: "Circuit",
          Reversed: false,
          Time: 39949,
          Vehicle: "ELEGYX",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 40559,
          Vehicle: "ARGENTO",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 40959,
          Vehicle: "ARGENTO",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 41120,
          Vehicle: "ARGENTO",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 47671,
          Vehicle: "ARGENTO",
        },
        {
          Class: "D",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 49351,
          Vehicle: "GRNWDC",
        },
        {
          Class: "S",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 94162,
          Vehicle: "ELEGYX",
        },
      ],
      Reversed: false,
      SetupRacerName: "AutoMate",
      Started: false,
      Waiting: true,
    },
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: -510.4322814941406,
            y: -371.5877990722656,
            z: 34.87500762939453,
          },
          offset: {
            left: {
              x: -509.40765380859375,
              y: -354.6226806640625,
              z: 35.24238586425781,
            },
            right: {
              x: -511.4569091796875,
              y: -388.5529174804687,
              z: 34.50762939453125,
            },
          },
        },
        {
          coords: {
            x: -200.75738525390625,
            y: -397.3887939453125,
            z: 31.70195007324218,
          },
          offset: {
            left: {
              x: -208.572021484375,
              y: -382.2976989746094,
              z: 31.26623916625977,
            },
            right: {
              x: -192.9427490234375,
              y: -412.4798889160156,
              z: 32.13766098022461,
            },
          },
        },
        {
          coords: {
            x: -87.43092346191406,
            y: -138.5001983642578,
            z: 56.68759536743164,
          },
          offset: {
            left: {
              x: -103.9622573852539,
              y: -134.5375213623047,
              z: 56.79850769042969,
            },
            right: {
              x: -70.89958953857422,
              y: -142.46287536621097,
              z: 56.57668304443359,
            },
          },
        },
        {
          coords: {
            x: -31.23219490051269,
            y: 78.6716537475586,
            z: 73.76529693603516,
          },
          offset: {
            left: {
              x: -45.31785583496094,
              y: 83.82820892333984,
              z: 73.82945251464844,
            },
            right: {
              x: -17.14653396606445,
              y: 73.51509857177734,
              z: 73.70114135742188,
            },
          },
        },
        {
          coords: {
            x: 103.458251953125,
            y: 386.9282531738281,
            z: 114.53620147705078,
          },
          offset: {
            left: {
              x: 98.1424789428711,
              y: 392.8990783691406,
              z: 114.83930206298828,
            },
            right: {
              x: 108.7740249633789,
              y: 380.9574279785156,
              z: 114.23310089111328,
            },
          },
        },
        {
          coords: {
            x: 318.6685485839844,
            y: 399.8387451171875,
            z: 116.81597900390624,
          },
          offset: {
            left: {
              x: 321.0819091796875,
              y: 406.4095458984375,
              z: 116.8360595703125,
            },
            right: {
              x: 316.2551879882813,
              y: 393.2679443359375,
              z: 116.7958984375,
            },
          },
        },
        {
          coords: {
            x: 466.24957275390625,
            y: 280.1034240722656,
            z: 102.39488983154295,
          },
          offset: {
            left: {
              x: 469.9212951660156,
              y: 290.471923828125,
              z: 102.28286743164064,
            },
            right: {
              x: 462.5778503417969,
              y: 269.7349243164063,
              z: 102.50691223144533,
            },
          },
        },
        {
          coords: {
            x: 609.338623046875,
            y: 309.3448486328125,
            z: 105.74745178222656,
          },
          offset: {
            left: {
              x: 604.279296875,
              y: 316.7863464355469,
              z: 105.91270446777344,
            },
            right: {
              x: 614.39794921875,
              y: 301.9033508300781,
              z: 105.58219909667967,
            },
          },
        },
        {
          coords: {
            x: 909.9212646484376,
            y: 455.2260437011719,
            z: 119.83137512207033,
          },
          offset: {
            left: {
              x: 898.1940307617188,
              y: 457.7234802246094,
              z: 119.34600830078124,
            },
            right: {
              x: 921.6484985351564,
              y: 452.7286071777344,
              z: 120.31674194335938,
            },
          },
        },
        {
          coords: {
            x: 981.0866088867188,
            y: 514.4160766601562,
            z: 104.01200103759766,
          },
          offset: {
            left: {
              x: 984.0901489257812,
              y: 523.9503173828125,
              z: 104.28964233398438,
            },
            right: {
              x: 978.0830688476564,
              y: 504.8818359375,
              z: 103.73435974121094,
            },
          },
        },
        {
          coords: {
            x: 1056.5831298828125,
            y: 519.5407104492188,
            z: 94.54176330566406,
          },
          offset: {
            left: {
              x: 1051.203125,
              y: 525.4609375,
              z: 94.62295532226564,
            },
            right: {
              x: 1061.963134765625,
              y: 513.6204833984375,
              z: 94.4605712890625,
            },
          },
        },
        {
          coords: {
            x: 1148.07080078125,
            y: 675.14404296875,
            z: 126.11238098144533,
          },
          offset: {
            left: {
              x: 1138.76318359375,
              y: 678.7913208007812,
              z: 125.85559844970705,
            },
            right: {
              x: 1157.37841796875,
              y: 671.4967651367188,
              z: 126.3691635131836,
            },
          },
        },
        {
          coords: {
            x: 1114.8406982421875,
            y: 755.5865478515625,
            z: 149.5244903564453,
          },
          offset: {
            left: {
              x: 1114.623779296875,
              y: 745.58984375,
              z: 149.3871612548828,
            },
            right: {
              x: 1115.0576171875,
              y: 765.583251953125,
              z: 149.6618194580078,
            },
          },
        },
        {
          coords: {
            x: 1078.20068359375,
            y: 768.6824951171875,
            z: 153.84754943847656,
          },
          offset: {
            left: {
              x: 1068.21875,
              y: 769.1892700195312,
              z: 154.1719207763672,
            },
            right: {
              x: 1088.1826171875,
              y: 768.1757202148438,
              z: 153.52317810058597,
            },
          },
        },
        {
          coords: {
            x: 1151.953125,
            y: 1146.1414794921875,
            z: 171.30776977539065,
          },
          offset: {
            left: {
              x: 1144.2449951171875,
              y: 1148.2823486328125,
              z: 171.2705078125,
            },
            right: {
              x: 1159.6612548828125,
              y: 1144.0006103515625,
              z: 171.34503173828125,
            },
          },
        },
        {
          coords: {
            x: 1051.6641845703125,
            y: 1641.3765869140625,
            z: 164.5110626220703,
          },
          offset: {
            left: {
              x: 1043.986083984375,
              y: 1643.619384765625,
              z: 164.63705444335938,
            },
            right: {
              x: 1059.34228515625,
              y: 1639.1337890625,
              z: 164.38507080078125,
            },
          },
        },
        {
          coords: {
            x: 423.2825927734375,
            y: 1769.32666015625,
            z: 234.1060028076172,
          },
          offset: {
            left: {
              x: 429.0067138671875,
              y: 1762.382080078125,
              z: 234.193359375,
            },
            right: {
              x: 417.5584716796875,
              y: 1776.271240234375,
              z: 234.0186462402344,
            },
          },
        },
        {
          coords: {
            x: 203.83706665039065,
            y: 1674.20703125,
            z: 230.83560180664065,
          },
          offset: {
            left: {
              x: 207.4219207763672,
              y: 1664.8720703125,
              z: 230.92237854003903,
            },
            right: {
              x: 200.2522125244141,
              y: 1683.5419921875,
              z: 230.7488250732422,
            },
          },
        },
        {
          coords: {
            x: 128.28050231933597,
            y: 1665.563720703125,
            z: 227.9800720214844,
          },
          offset: {
            left: {
              x: 121.4077377319336,
              y: 1658.2999267578125,
              z: 227.9341735839844,
            },
            right: {
              x: 135.15325927734375,
              y: 1672.8275146484375,
              z: 228.0259704589844,
            },
          },
        },
        {
          coords: {
            x: -128.5625457763672,
            y: 1860.669677734375,
            z: 197.6771697998047,
          },
          offset: {
            left: {
              x: -131.78775024414065,
              y: 1850.153076171875,
              z: 197.67221069335935,
            },
            right: {
              x: -125.33734130859376,
              y: 1871.186279296875,
              z: 197.68212890625,
            },
          },
        },
        {
          coords: {
            x: -228.1758728027344,
            y: 1846.239013671875,
            z: 197.26138305664065,
          },
          offset: {
            left: {
              x: -223.67076110839844,
              y: 1839.628173828125,
              z: 197.25733947753903,
            },
            right: {
              x: -232.6809844970703,
              y: 1852.849853515625,
              z: 197.2654266357422,
            },
          },
        },
        {
          coords: {
            x: -526.2551879882812,
            y: 1978.2227783203127,
            z: 205.1627655029297,
          },
          offset: {
            left: {
              x: -519.2728271484375,
              y: 1972.544189453125,
              z: 205.1580047607422,
            },
            right: {
              x: -533.237548828125,
              y: 1983.9013671875,
              z: 205.1675262451172,
            },
          },
        },
        {
          coords: {
            x: -753.3041381835938,
            y: 1716.922607421875,
            z: 200.6162567138672,
          },
          offset: {
            left: {
              x: -744.338623046875,
              y: 1716.1358642578125,
              z: 200.6228179931641,
            },
            right: {
              x: -762.2696533203125,
              y: 1717.7093505859375,
              z: 200.6096954345703,
            },
          },
        },
        {
          coords: {
            x: -768.2259521484375,
            y: 1554.6968994140625,
            z: 218.03689575195312,
          },
          offset: {
            left: {
              x: -759.0867309570312,
              y: 1550.6424560546875,
              z: 218.2286071777344,
            },
            right: {
              x: -777.3651733398438,
              y: 1558.7513427734375,
              z: 217.84518432617188,
            },
          },
        },
        {
          coords: {
            x: -717.5108032226562,
            y: 1133.0103759765625,
            z: 261.1079711914063,
          },
          offset: {
            left: {
              x: -709.5823364257812,
              y: 1139.09423828125,
              z: 261.4632263183594,
            },
            right: {
              x: -725.4392700195312,
              y: 1126.926513671875,
              z: 260.7527160644531,
            },
          },
        },
        {
          coords: {
            x: -704.7056884765625,
            y: 923.4232177734376,
            z: 232.71731567382812,
          },
          offset: {
            left: {
              x: -694.7734375,
              y: 924.5711669921876,
              z: 232.53627014160156,
            },
            right: {
              x: -714.637939453125,
              y: 922.2752685546876,
              z: 232.8983612060547,
            },
          },
        },
        {
          coords: {
            x: -1052.3134765625,
            y: 786.7579345703125,
            z: 166.2924041748047,
          },
          offset: {
            left: {
              x: -1051.56884765625,
              y: 779.7991943359375,
              z: 166.14610290527344,
            },
            right: {
              x: -1053.05810546875,
              y: 793.7166748046875,
              z: 166.43870544433597,
            },
          },
        },
        {
          coords: {
            x: -1412.881591796875,
            y: 476.10845947265625,
            z: 107.97335815429688,
          },
          offset: {
            left: {
              x: -1409.5936279296875,
              y: 481.12701416015625,
              z: 107.91121673583984,
            },
            right: {
              x: -1416.1695556640625,
              y: 471.08990478515625,
              z: 108.0354995727539,
            },
          },
        },
        {
          coords: {
            x: -1074.10302734375,
            y: 406.6505432128906,
            z: 68.27764892578125,
          },
          offset: {
            left: {
              x: -1066.1273193359375,
              y: 406.0277404785156,
              z: 68.27922058105469,
            },
            right: {
              x: -1082.0787353515625,
              y: 407.2733459472656,
              z: 68.27607727050781,
            },
          },
        },
        {
          coords: {
            x: -1107.6795654296875,
            y: 267.3129577636719,
            z: 63.79012298583984,
          },
          offset: {
            left: {
              x: -1105.943603515625,
              y: 250.40223693847656,
              z: 63.67247009277344,
            },
            right: {
              x: -1109.41552734375,
              y: 284.2236938476563,
              z: 63.90777587890625,
            },
          },
        },
        {
          coords: {
            x: -1435.579833984375,
            y: 82.6058578491211,
            z: 51.82279586791992,
          },
          offset: {
            left: {
              x: -1419.61376953125,
              y: 83.61650085449219,
              z: 51.56775665283203,
            },
            right: {
              x: -1451.5458984375,
              y: 81.59521484375,
              z: 52.07783508300781,
            },
          },
        },
        {
          coords: {
            x: -1359.63037109375,
            y: -56.9217643737793,
            z: 51.01789093017578,
          },
          offset: {
            left: {
              x: -1360.30126953125,
              y: -40.93655776977539,
              z: 51.17018890380859,
            },
            right: {
              x: -1358.95947265625,
              y: -72.90697479248047,
              z: 50.86559295654297,
            },
          },
        },
        {
          coords: {
            x: -1138.7503662109375,
            y: -142.99905395507812,
            z: 38.72564315795898,
          },
          offset: {
            left: {
              x: -1130.6689453125,
              y: -129.1951904296875,
              z: 38.3453140258789,
            },
            right: {
              x: -1146.831787109375,
              y: -156.80291748046875,
              z: 39.10597229003906,
            },
          },
        },
        {
          coords: {
            x: -958.6815185546876,
            y: -152.71517944335938,
            z: 37.17106246948242,
          },
          offset: {
            left: {
              x: -965.2702026367188,
              y: -140.3677520751953,
              z: 36.81026077270508,
            },
            right: {
              x: -952.0928344726564,
              y: -165.06260681152344,
              z: 37.53186416625976,
            },
          },
        },
        {
          coords: {
            x: -814.7227783203125,
            y: -79.55953979492188,
            z: 37.20301818847656,
          },
          offset: {
            left: {
              x: -820.908447265625,
              y: -67.00016784667969,
              z: 37.20304489135742,
            },
            right: {
              x: -808.537109375,
              y: -92.11891174316406,
              z: 37.2029914855957,
            },
          },
        },
        {
          coords: {
            x: -747.9846801757812,
            y: -144.57159423828125,
            z: 36.83731842041016,
          },
          offset: {
            left: {
              x: -729.8728637695312,
              y: -136.0885467529297,
              z: 36.82323455810547,
            },
            right: {
              x: -766.0964965820312,
              y: -153.0546417236328,
              z: 36.85140228271485,
            },
          },
        },
        {
          coords: {
            x: -643.2421264648438,
            y: -324.3406066894531,
            z: 34.1538200378418,
          },
          offset: {
            left: {
              x: -626.1567993164062,
              y: -313.9438781738281,
              z: 34.13769912719726,
            },
            right: {
              x: -660.3274536132812,
              y: -334.7373352050781,
              z: 34.16994094848633,
            },
          },
        },
        {
          coords: {
            x: -549.92041015625,
            y: -369.6502990722656,
            z: 34.49242782592773,
          },
          offset: {
            left: {
              x: -550.5958862304688,
              y: -349.6652526855469,
              z: 34.86914443969726,
            },
            right: {
              x: -549.2449340820312,
              y: -389.6353454589844,
              z: 34.1157112121582,
            },
          },
        },
      ],
      Creator: "CITIZENID",
      CreatorName: "Tailshake",
      Curated: 0,
      Distance: 9148,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 0,
      RaceId: "CW-7664",
      RaceName: "Devils Touge",
      Racers: [],
      Records: [
        {
          Class: "A",
          Holder: "Mist",
          RaceType: "Sprint",
          Reversed: false,
          Time: 294847,
          Vehicle: "REMUSTWO",
        },
        {
          Class: "X",
          Holder: "Spectre",
          RaceType: "Sprint",
          Reversed: false,
          Time: 307151,
          Vehicle: "JESTER3",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 331276,
          Vehicle: "ZR380S",
        },
      ],
      Started: false,
      Waiting: false,
    },
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: -52.340576171875,
            y: -254.4996795654297,
            z: 45.27838516235351,
          },
          offset: {
            left: {
              x: -45.10497665405273,
              y: -236.93161010742188,
              z: 45.37432098388672,
            },
            right: {
              x: -59.57617568969726,
              y: -272.0677490234375,
              z: 45.18244934082031,
            },
          },
        },
        {
          coords: {
            x: 92.44344329833984,
            y: -308.3395690917969,
            z: 45.82535934448242,
          },
          offset: {
            left: {
              x: 97.17047119140624,
              y: -294.10394287109375,
              z: 45.86815643310547,
            },
            right: {
              x: 87.71641540527344,
              y: -322.5751953125,
              z: 45.78256225585937,
            },
          },
        },
        {
          coords: {
            x: 220.2377471923828,
            y: -353.2974548339844,
            z: 43.72373962402344,
          },
          offset: {
            left: {
              x: 225.21533203125,
              y: -339.1474914550781,
              z: 43.77010345458984,
            },
            right: {
              x: 215.26016235351568,
              y: -367.4474182128906,
              z: 43.67737579345703,
            },
          },
        },
        {
          coords: {
            x: 434.8890075683594,
            y: -369.8930969238281,
            z: 46.63096618652344,
          },
          offset: {
            left: {
              x: 424.3216857910156,
              y: -357.8793640136719,
              z: 46.67497634887695,
            },
            right: {
              x: 445.4563293457031,
              y: -381.9068298339844,
              z: 46.58695602416992,
            },
          },
        },
        {
          coords: {
            x: 674.4837036132812,
            y: -388.93560791015625,
            z: 41.22829818725586,
          },
          offset: {
            left: {
              x: 667.317626953125,
              y: -380.5914001464844,
              z: 41.08168029785156,
            },
            right: {
              x: 681.6497802734375,
              y: -397.2798156738281,
              z: 41.37491607666015,
            },
          },
        },
        {
          coords: {
            x: 709.2294921875,
            y: -373.5025939941406,
            z: 41.29356384277344,
          },
          offset: {
            left: {
              x: 704.8684692382812,
              y: -361.260009765625,
              z: 41.61063003540039,
            },
            right: {
              x: 713.5905151367188,
              y: -385.74517822265625,
              z: 40.97649765014648,
            },
          },
        },
        {
          coords: {
            x: 774.9202880859375,
            y: -348.205078125,
            z: 48.19004440307617,
          },
          offset: {
            left: {
              x: 770.478271484375,
              y: -334.9306335449219,
              z: 48.43080139160156,
            },
            right: {
              x: 779.3623046875,
              y: -361.4795227050781,
              z: 47.94928741455078,
            },
          },
        },
        {
          coords: {
            x: 947.6083984375,
            y: -312.1497192382813,
            z: 66.55909729003906,
          },
          offset: {
            left: {
              x: 936.3272094726564,
              y: -303.8621520996094,
              z: 66.78507232666016,
            },
            right: {
              x: 958.8895874023438,
              y: -320.4372863769531,
              z: 66.33312225341797,
            },
          },
        },
        {
          coords: {
            x: 1010.8661499023438,
            y: -189.2675323486328,
            z: 70.17040252685547,
          },
          offset: {
            left: {
              x: 995.4771728515624,
              y: -203.55238342285156,
              z: 70.51866912841797,
            },
            right: {
              x: 1026.255126953125,
              y: -174.9826812744141,
              z: 69.82213592529297,
            },
          },
        },
        {
          coords: {
            x: 936.9588623046876,
            y: -144.921142578125,
            z: 74.34542846679688,
          },
          offset: {
            left: {
              x: 928.8676147460938,
              y: -159.8720855712891,
              z: 74.30453491210938,
            },
            right: {
              x: 945.0501098632812,
              y: -129.97019958496097,
              z: 74.38632202148438,
            },
          },
        },
        {
          coords: {
            x: 835.392333984375,
            y: -80.7162094116211,
            z: 80.15900421142578,
          },
          offset: {
            left: {
              x: 825.69970703125,
              y: -94.6823501586914,
              z: 80.1463394165039,
            },
            right: {
              x: 845.0849609375,
              y: -66.75006866455078,
              z: 80.17166900634766,
            },
          },
        },
        {
          coords: {
            x: 714.3644409179688,
            y: -2.98843121528625,
            z: 83.4005355834961,
          },
          offset: {
            left: {
              x: 702.1898193359375,
              y: -17.57469749450683,
              z: 83.53929138183594,
            },
            right: {
              x: 726.5390625,
              y: 11.59783458709716,
              z: 83.26177978515625,
            },
          },
        },
        {
          coords: {
            x: 475.57135009765625,
            y: 6.85476112365722,
            z: 86.1971435546875,
          },
          offset: {
            left: {
              x: 491.9124755859375,
              y: -6.28397274017334,
              z: 85.03915405273438,
            },
            right: {
              x: 459.230224609375,
              y: 19.99349594116211,
              z: 87.35513305664062,
            },
          },
        },
        {
          coords: {
            x: 340.6079711914063,
            y: -103.55077362060548,
            z: 67.06570434570312,
          },
          offset: {
            left: {
              x: 336.7756652832031,
              y: -121.1378936767578,
              z: 66.98306274414062,
            },
            right: {
              x: 344.4402770996094,
              y: -85.96365356445312,
              z: 67.14834594726562,
            },
          },
        },
        {
          coords: {
            x: 241.789291381836,
            y: -67.8154296875,
            z: 69.22379302978516,
          },
          offset: {
            left: {
              x: 237.21115112304688,
              y: -81.03971862792969,
              z: 69.62232208251953,
            },
            right: {
              x: 246.367431640625,
              y: -54.59113693237305,
              z: 68.82526397705078,
            },
          },
        },
        {
          coords: {
            x: 139.30531311035156,
            y: -30.49337768554687,
            z: 67.125732421875,
          },
          offset: {
            left: {
              x: 135.05670166015625,
              y: -43.83120727539062,
              z: 67.35309600830078,
            },
            right: {
              x: 143.55392456054688,
              y: -17.15555000305175,
              z: 66.89836883544922,
            },
          },
        },
        {
          coords: {
            x: 27.08864593505859,
            y: 8.11531543731689,
            z: 69.66206359863281,
          },
          offset: {
            left: {
              x: 22.22893714904785,
              y: -5.01181125640869,
              z: 69.9107666015625,
            },
            right: {
              x: 31.94835472106933,
              y: 21.24244308471679,
              z: 69.41336059570312,
            },
          },
        },
        {
          coords: {
            x: -50.02418518066406,
            y: 16.54994201660156,
            z: 71.70174407958984,
          },
          offset: {
            left: {
              x: -37.83869552612305,
              y: 6.1815013885498,
              z: 71.6053466796875,
            },
            right: {
              x: -62.20967483520508,
              y: 26.91838264465332,
              z: 71.79814147949219,
            },
          },
        },
        {
          coords: {
            x: -74.2797622680664,
            y: -88.04427337646484,
            z: 57.37857437133789,
          },
          offset: {
            left: {
              x: -61.39990997314453,
              y: -93.53143310546876,
              z: 57.40367126464844,
            },
            right: {
              x: -87.15961456298828,
              y: -82.55711364746094,
              z: 57.35347747802734,
            },
          },
        },
        {
          coords: {
            x: -99.25440216064452,
            y: -209.050048828125,
            z: 44.6744155883789,
          },
          offset: {
            left: {
              x: -82.53565979003906,
              y: -215.71580505371097,
              z: 44.44753646850586,
            },
            right: {
              x: -115.97314453125,
              y: -202.3842926025391,
              z: 44.90129470825195,
            },
          },
        },
      ],
      Creator: "CITIZENID",
      CreatorName: "Coffee",
      Curated: 1,
      Distance: 2578,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 0,
      RaceId: "CW-3232",
      RaceName: "Cop Blocked",
      Racers: [],
      Records: [
        {
          Class: "S",
          Holder: "Spectre",
          RaceType: "Circuit",
          Reversed: false,
          Time: 71079,
          Vehicle: "TAILGATER2",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 78618,
          Vehicle: "ARGENTO",
        },
        {
          Class: "A",
          Holder: "Mist",
          RaceType: "Circuit",
          Reversed: false,
          Time: 79338,
          Vehicle: "rhinehart",
        },
        {
          Class: "B",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 82759,
          Vehicle: "FUTO2",
        },
        {
          Class: "B",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 90361,
          Vehicle: "ALTIOR",
        },
        {
          Class: "B",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 91220,
          Vehicle: "SG32",
        },
        {
          Class: "C",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 107115,
          Vehicle: "TULIP",
        },
      ],
      Started: false,
      Waiting: false,
    },
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: -951.294677734375,
            y: -3142.659912109375,
            z: 13.47097206115722,
          },
          offset: {
            left: {
              x: -957.2703247070312,
              y: -3142.1220703125,
              z: 13.41959381103515,
            },
            right: {
              x: -945.3190307617188,
              y: -3143.19775390625,
              z: 13.52235031127929,
            },
          },
        },
        {
          coords: {
            x: -948.0409545898438,
            y: -3129.415283203125,
            z: 13.45976543426513,
          },
          offset: {
            left: {
              x: -954.02880859375,
              y: -3129.040283203125,
              z: 13.52758884429931,
            },
            right: {
              x: -942.0531005859376,
              y: -3129.790283203125,
              z: 13.39194202423095,
            },
          },
        },
        {
          coords: {
            x: -951.2445068359376,
            y: -3116.597900390625,
            z: 13.46012878417968,
          },
          offset: {
            left: {
              x: -956.2779541015624,
              y: -3119.86083984375,
              z: 13.59123706817627,
            },
            right: {
              x: -946.2110595703124,
              y: -3113.3349609375,
              z: 13.3290205001831,
            },
          },
        },
        {
          coords: {
            x: -960.56787109375,
            y: -3110.69140625,
            z: 13.45966625213623,
          },
          offset: {
            left: {
              x: -961.089599609375,
              y: -3116.665771484375,
              z: 13.64642715454101,
            },
            right: {
              x: -960.046142578125,
              y: -3104.717041015625,
              z: 13.27290534973144,
            },
          },
        },
        {
          coords: {
            x: -970.6781005859376,
            y: -3113.638671875,
            z: 13.45991611480712,
          },
          offset: {
            left: {
              x: -967.0567016601564,
              y: -3118.419921875,
              z: 13.62271213531494,
            },
            right: {
              x: -974.2994995117188,
              y: -3108.857421875,
              z: 13.29712009429931,
            },
          },
        },
        {
          coords: {
            x: -977.2415771484376,
            y: -3121.7421875,
            z: 13.45987510681152,
          },
          offset: {
            left: {
              x: -971.831298828125,
              y: -3124.33251953125,
              z: 13.59945106506347,
            },
            right: {
              x: -982.65185546875,
              y: -3119.15185546875,
              z: 13.32029914855957,
            },
          },
        },
        {
          coords: {
            x: -979.8442993164064,
            y: -3131.27001953125,
            z: 13.46070194244384,
          },
          offset: {
            left: {
              x: -973.9588012695312,
              y: -3132.4365234375,
              z: 13.47455024719238,
            },
            right: {
              x: -985.7297973632812,
              y: -3130.103515625,
              z: 13.44685363769531,
            },
          },
        },
        {
          coords: {
            x: -977.562255859375,
            y: -3141.7724609375,
            z: 13.4671573638916,
          },
          offset: {
            left: {
              x: -973.3984985351564,
              y: -3137.453369140625,
              z: 13.56455421447753,
            },
            right: {
              x: -981.7260131835938,
              y: -3146.091552734375,
              z: 13.36976051330566,
            },
          },
        },
        {
          coords: {
            x: -967.9418334960938,
            y: -3147.066650390625,
            z: 13.46479320526123,
          },
          offset: {
            left: {
              x: -965.8265991210938,
              y: -3141.451904296875,
              z: 13.43802738189697,
            },
            right: {
              x: -970.0570678710938,
              y: -3152.681396484375,
              z: 13.49155902862548,
            },
          },
        },
        {
          coords: {
            x: -962.5408325195312,
            y: -3149.759033203125,
            z: 13.46294212341308,
          },
          offset: {
            left: {
              x: -959.727294921875,
              y: -3144.459716796875,
              z: 13.4582290649414,
            },
            right: {
              x: -965.3543701171876,
              y: -3155.058349609375,
              z: 13.46765518188476,
            },
          },
        },
      ],
      Creator: "PX6944",
      CreatorName: "CoffeeGod",
      Curated: 0,
      Distance: 96,
      LastLeaderboard: [],
      Metadata: [],
      NumStarted: 0,
      RaceId: "LR-9238",
      RaceName: "Airport Tiny loop",
      Racers: [],
      Records: [
        {
          Class: "S",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 5361,
          Vehicle: "ELEGYX",
        },
        {
          Class: "S",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 5422,
          Vehicle: "ELEGYRH6",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 5801,
          Vehicle: "ARIANT",
        },
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 6181,
          Vehicle: "ELEGY",
        },
        {
          Class: "B",
          Holder: "Air_Lady_1337",
          RaceType: "Circuit",
          Reversed: false,
          Time: 7312,
          Vehicle: "FUTO",
        },
        {
          Class: "S",
          Holder: "CoffeeGod",
          RaceType: "Sprint",
          Reversed: false,
          Time: 7711,
          Vehicle: "JESTER5",
        },
        {
          Class: "S",
          Holder: "Air_Lady_1337",
          RaceType: "Sprint",
          Reversed: false,
          Time: 12433,
          Vehicle: "ELEGYX",
        },
      ],
      Started: false,
      Waiting: false,
    },
    {
      Access: [],
      Checkpoints: [
        {
          coords: {
            x: -966.4417724609376,
            y: -3162.1279296875,
            z: 13.39627170562744,
          },
          offset: {
            left: {
              x: -973.0220336914064,
              y: -3174.485107421875,
              z: 13.39398384094238,
            },
            right: {
              x: -959.8615112304688,
              y: -3149.770751953125,
              z: 13.3985595703125,
            },
          },
        },
        {
          coords: {
            x: -1237.8831787109375,
            y: -3005.679443359375,
            z: 13.39489364624023,
          },
          offset: {
            left: {
              x: -1244.860595703125,
              y: -3017.81689453125,
              z: 13.39362049102783,
            },
            right: {
              x: -1230.90576171875,
              y: -2993.5419921875,
              z: 13.39616680145263,
            },
          },
        },
        {
          coords: {
            x: -1449.152587890625,
            y: -2884.2236328125,
            z: 13.40870189666748,
          },
          offset: {
            left: {
              x: -1456.629638671875,
              y: -2897.227294921875,
              z: 13.41144943237304,
            },
            right: {
              x: -1441.675537109375,
              y: -2871.219970703125,
              z: 13.40595436096191,
            },
          },
        },
        {
          coords: {
            x: -1590.509521484375,
            y: -2802.975341796875,
            z: 13.38827228546142,
          },
          offset: {
            left: {
              x: -1597.938720703125,
              y: -2816.006103515625,
              z: 13.33716678619384,
            },
            right: {
              x: -1583.080322265625,
              y: -2789.944580078125,
              z: 13.439377784729,
            },
          },
        },
        {
          coords: {
            x: -1660.6480712890625,
            y: -2807.0126953125,
            z: 13.39604568481445,
          },
          offset: {
            left: {
              x: -1646.7435302734375,
              y: -2814.9287109375,
              z: 13.39320278167724,
            },
            right: {
              x: -1674.5526123046875,
              y: -2799.0966796875,
              z: 13.39888858795166,
            },
          },
        },
        {
          coords: {
            x: -1681.987548828125,
            y: -2879.745849609375,
            z: 13.39528179168701,
          },
          offset: {
            left: {
              x: -1672.018310546875,
              y: -2880.529052734375,
              z: 13.4061803817749,
            },
            right: {
              x: -1691.956787109375,
              y: -2878.962646484375,
              z: 13.38438320159912,
            },
          },
        },
        {
          coords: {
            x: -1628.3316650390625,
            y: -2969.6005859375,
            z: 13.39890480041503,
          },
          offset: {
            left: {
              x: -1622.5457763671875,
              y: -2961.4443359375,
              z: 13.42977333068847,
            },
            right: {
              x: -1634.1175537109375,
              y: -2977.7568359375,
              z: 13.3680362701416,
            },
          },
        },
        {
          coords: {
            x: -1597.54833984375,
            y: -2977.004638671875,
            z: 13.39643669128418,
          },
          offset: {
            left: {
              x: -1601.8206787109375,
              y: -2967.963134765625,
              z: 13.39857482910156,
            },
            right: {
              x: -1593.2760009765625,
              y: -2986.046142578125,
              z: 13.39429855346679,
            },
          },
        },
        {
          coords: {
            x: -1590.971435546875,
            y: -2967.19873046875,
            z: 13.39704132080078,
          },
          offset: {
            left: {
              x: -1600.9150390625,
              y: -2966.138671875,
              z: 13.38818645477295,
            },
            right: {
              x: -1581.02783203125,
              y: -2968.2587890625,
              z: 13.40589618682861,
            },
          },
        },
        {
          coords: {
            x: -1597.8265380859375,
            y: -2914.1865234375,
            z: 13.3944444656372,
          },
          offset: {
            left: {
              x: -1606.863525390625,
              y: -2909.90478515625,
              z: 13.38701438903808,
            },
            right: {
              x: -1588.78955078125,
              y: -2918.46826171875,
              z: 13.40187454223632,
            },
          },
        },
        {
          coords: {
            x: -1563.28759765625,
            y: -2913.97119140625,
            z: 13.41120815277099,
          },
          offset: {
            left: {
              x: -1557.8892822265625,
              y: -2905.553466796875,
              z: 13.42385387420654,
            },
            right: {
              x: -1568.6859130859375,
              y: -2922.388916015625,
              z: 13.39856243133545,
            },
          },
        },
        {
          coords: {
            x: -1483.9874267578125,
            y: -2959.671630859375,
            z: 13.37813758850097,
          },
          offset: {
            left: {
              x: -1478.766357421875,
              y: -2951.142822265625,
              z: 13.36561965942382,
            },
            right: {
              x: -1489.20849609375,
              y: -2968.200439453125,
              z: 13.39065551757812,
            },
          },
        },
        {
          coords: {
            x: -1396.6602783203125,
            y: -3009.81201171875,
            z: 13.39811897277832,
          },
          offset: {
            left: {
              x: -1391.7242431640625,
              y: -3001.115234375,
              z: 13.41542243957519,
            },
            right: {
              x: -1401.5963134765625,
              y: -3018.5087890625,
              z: 13.38081550598144,
            },
          },
        },
        {
          coords: {
            x: -1325.4005126953125,
            y: -3071.636474609375,
            z: 13.37961769104003,
          },
          offset: {
            left: {
              x: -1316.497314453125,
              y: -3067.084228515625,
              z: 13.28734588623046,
            },
            right: {
              x: -1334.3037109375,
              y: -3076.188720703125,
              z: 13.47188949584961,
            },
          },
        },
        {
          coords: {
            x: -1285.207763671875,
            y: -3140.709228515625,
            z: 13.38634967803955,
          },
          offset: {
            left: {
              x: -1276.2763671875,
              y: -3134.2880859375,
              z: 13.37827014923095,
            },
            right: {
              x: -1294.13916015625,
              y: -3147.13037109375,
              z: 13.39442920684814,
            },
          },
        },
        {
          coords: {
            x: -1205.4365234375,
            y: -3218.686279296875,
            z: 13.3785696029663,
          },
          offset: {
            left: {
              x: -1200.150146484375,
              y: -3209.039794921875,
              z: 13.38315391540527,
            },
            right: {
              x: -1210.722900390625,
              y: -3228.332763671875,
              z: 13.37398529052734,
            },
          },
        },
        {
          coords: {
            x: -1103.9425048828125,
            y: -3231.681884765625,
            z: 13.38118934631347,
          },
          offset: {
            left: {
              x: -1105.548583984375,
              y: -3220.800048828125,
              z: 13.47441387176513,
            },
            right: {
              x: -1102.33642578125,
              y: -3242.563720703125,
              z: 13.28796482086181,
            },
          },
        },
        {
          coords: {
            x: -1069.8671875,
            y: -3223.16943359375,
            z: 13.38103294372558,
          },
          offset: {
            left: {
              x: -1074.0067138671875,
              y: -3212.978515625,
              z: 13.47477531433105,
            },
            right: {
              x: -1065.7276611328125,
              y: -3233.3603515625,
              z: 13.28729057312011,
            },
          },
        },
        {
          coords: {
            x: -1006.5269165039064,
            y: -3234.296875,
            z: 13.38113117218017,
          },
          offset: {
            left: {
              x: -1001.1937866210938,
              y: -3224.676513671875,
              z: 13.47604370117187,
            },
            right: {
              x: -1011.8600463867188,
              y: -3243.917236328125,
              z: 13.28621864318847,
            },
          },
        },
        {
          coords: {
            x: -945.2286987304688,
            y: -3269.811279296875,
            z: 13.37784004211425,
          },
          offset: {
            left: {
              x: -939.8189086914064,
              y: -3260.233642578125,
              z: 13.4094762802124,
            },
            right: {
              x: -950.6384887695312,
              y: -3279.388916015625,
              z: 13.34620380401611,
            },
          },
        },
        {
          coords: {
            x: -881.6238403320312,
            y: -3262.424072265625,
            z: 13.37996864318847,
          },
          offset: {
            left: {
              x: -891.4531860351562,
              y: -3257.4873046875,
              z: 13.49530982971191,
            },
            right: {
              x: -871.7944946289062,
              y: -3267.36083984375,
              z: 13.26462745666503,
            },
          },
        },
        {
          coords: {
            x: -895.0726318359375,
            y: -3207.05078125,
            z: 13.3817663192749,
          },
          offset: {
            left: {
              x: -900.539306640625,
              y: -3216.59619140625,
              z: 13.38187980651855,
            },
            right: {
              x: -889.60595703125,
              y: -3197.50537109375,
              z: 13.38165283203125,
            },
          },
        },
      ],
      Creator: "2",
      CreatorName: "CoffeeGod",
      Curated: 1,
      Distance: 1974,
      LastLeaderboard: [],
      Metadata: {
        raceType: "circuit_only",
      },
      NumStarted: 0,
      RaceId: "LR-4907",
      RaceName: "Airport Test Track",
      Racers: [],
      Records: [
        {
          Class: "A",
          Holder: "CoffeeGod",
          RaceType: "Circuit",
          Reversed: false,
          Time: 63015,
          Vehicle: "ASTEROPERS",
        },
      ],
      Started: false,
      Waiting: false,
    },
  ],
  results: {},
  myCrew: {},
  notification: {
    type: "success",
    title: "4 bounties were created.",
    text: 'WAAHOO',
  },
  bounties: [
    {
      claimed: [
        {
          trackId: "CW-3232",
          racerName: "Paulie",
          carClass: "B",
          vehicleModel: "FUTO",
          raceType: "Circuit",
          time: 78618,
          reversed: false,
        },
        {
          trackId: "CW-3232",
          racerName: "Tony Soprano",
          carClass: "B",
          vehicleModel: "FUTO2",
          raceType: "Circuit",
          time: 58618,
          reversed: false,
        },
      ],
      id: "bty_1",
      maxClass: "B",
      price: 300,
      rankRequired: 0,
      reversed: false,
      sprint: false,
      timeToBeat: 94310,
      trackId: "CW-3232",
      trackName: "Cop Blocked",
    },
    {
      claimed: [],
      id: "bty_2",
      maxClass: "B",
      price: 500,
      rankRequired: 2,
      reversed: false,
      sprint: true,
      timeToBeat: 134908,
      trackId: "CW-4267",
      trackName: "Zancudo Sprint",
    },
    {
      claimed: [],
      id: "bty_3",
      maxClass: "A",
      price: 200,
      rankRequired: 0,
      reversed: false,
      sprint: false,
      timeToBeat: 35921,
      trackId: "CW-7666",
      trackName: "Elysian",
    },
    {
      claimed: [],
      id: "bty_4",
      maxClass: "D",
      price: 100,
      rankRequired: 0,
      reversed: true,
      sprint: false,
      timeToBeat: 53982,
      trackId: "CW-7666",
      trackName: "Elysian",
    },
  ],
  showCryptoModal: false,
};

export const fakeRaces = [
  {
    Started: false,
    Waiting: true,
    RaceId: "race-id",
    TrackId: "track-id",
    Automated: true,
    Ghosting: true,
    SetupRacerName: "Made Up Name Lol",
    GhostingTime: 0,
    BuyIn: 0,
    Hidden: false,
    Ranked: true,
    Reversed: true,
    FirstPerson: true,
    ParticipationAmount: 0,
    ParticipationCurrency: 0,
    MaxClass: "A",
    RaceData: {
      Started: false,
    },
    TrackData: {
      Distance: 1000,
      RaceName: "Test Track",
    },
    Racers: [{}, {}],
    racers: 2,
  },
  {
    Started: false,
    Waiting: true,
    RaceId: "race-id2",
    TrackId: "track-id1",
    Automated: true,
    Ghosting: true,
    SetupRacerName: "Tom",
    GhostingTime: 0,
    BuyIn: 200,
    Hidden: false,
    Ranked: true,
    Reversed: false,
    FirstPerson: false,
    ParticipationAmount: 20,
    ParticipationCurrency: "crypto",
    MaxClass: "A",
    RaceData: {
      Started: false,
    },
    TrackData: {
      Distance: 1000,
      RaceName: "Test Track",
    },
    Racers: [{}, {}],
    racers: 20,
  },
];

export const mockRecords = [
  {
    vehicleModel: "ELEGYX",
    reversed: false,
    id: 3,
    time: 6981,
    carClass: "S",
    trackId: "LR-9238",
    racerName: "CoffeeGod",
    timestamp: 1750087440000.0,
    raceType: "Circuit",
  },
  {
    vehicleModel: "Argento RS",
    reversed: false,
    id: 8,
    time: 7664,
    carClass: "S",
    trackId: "LR-9238",
    racerName: "CoffeeGod",
    timestamp: 1750334447000.0,
    raceType: "Sprint",
  },
  {
    vehicleModel: "ARIANT",
    reversed: false,
    id: 4,
    time: 8742,
    carClass: "A",
    trackId: "LR-9238",
    racerName: "Air_Lady_1337",
    timestamp: 1750087651000.0,
    raceType: "Circuit",
  },
  {
    vehicleModel: "Atlas",
    reversed: true,
    id: 5,
    time: 8931,
    carClass: "D",
    trackId: "LR-9238",
    racerName: "CoffeeGod",
    timestamp: 1750271139000.0,
    raceType: "Sprint",
  },
  {
    vehicleModel: "Futo",
    reversed: false,
    id: 12,
    time: 9463,
    carClass: "B",
    trackId: "LR-9238",
    racerName: "CoffeeGod",
    timestamp: 1750609789000.0,
    raceType: "Circuit",
  },
  {
    vehicleModel: "Ariant",
    reversed: false,
    id: 11,
    time: 9683,
    carClass: "A",
    trackId: "LR-9238",
    racerName: "CoffeeGod",
    timestamp: 1750364461000.0,
    raceType: "Circuit",
  },
];

export const mockRacersResult = [
  {
    races: 31,
    tracks: 0,
    crypto: 3453,
    revoked: 0,
    auth: "god",
    createdby: "2",
    crew: "Coffee Sippers",
    lasttouched: 1750364574000.0,
    citizenid: "PX6944",
    wins: 16,
    racername: "CoffeeGod",
    ranking: 210,
    id: 44,
    active: 1,
  },
  {
    tracks: 0,
    crypto: 0,
    revoked: 0,
    auth: "racer",
    createdby: "3",
    races: 0,
    lasttouched: 1749232090000.0,
    citizenid: "PX6944",
    wins: 0,
    racername: "DROP TABLE racer_names-hey",
    ranking: 0,
    id: 46,
    active: 0,
  },
  {
    races: 25,
    tracks: 0,
    crypto: 19,
    revoked: 0,
    auth: "creator",
    createdby: "4",
    crew: "Lady Crew",
    lasttouched: 1750334456000.0,
    citizenid: "MT0699",
    wins: 12,
    racername: "Air_Lady_1337",
    ranking: 10,
    id: 47,
    active: 1,
  },
  {
    tracks: 0,
    crypto: 0,
    revoked: 0,
    auth: "racer",
    createdby: "QC4792",
    races: 4,
    lasttouched: 1741117554000.0,
    citizenid: "QC4792",
    wins: 3,
    racername: "Spectre",
    ranking: 399,
    id: 48,
    active: 1,
  },
  {
    tracks: 0,
    crypto: 0,
    revoked: 0,
    auth: "racer",
    createdby: "DD2940",
    races: 3,
    lasttouched: 1741200851000.0,
    citizenid: "DD2940",
    wins: 1,
    racername: "Mist",
    ranking: 191919,
    id: 49,
    active: 1,
  },
  {
    tracks: 0,
    crypto: 0,
    revoked: 0,
    auth: "racer",
    createdby: "FT5570",
    races: 0,
    lasttouched: 1734692884000.0,
    citizenid: "FT5570",
    wins: 0,
    racername: "ADad",
    ranking: 0,
    id: 55,
    active: 0,
  },
  {
    tracks: 0,
    crypto: 0,
    revoked: 0,
    auth: "master",
    createdby: "PX6944",
    races: 0,
    lasttouched: 1749232134000.0,
    citizenid: "PX6944",
    wins: 0,
    racername: "maST COF",
    ranking: 0,
    id: 56,
    active: 0,
  },
];

export const availableUsersMock = [
  {
    fobType: "creator",
    label: "creator user ($5000)",
    purchaseType: {
      location: {
        x: 938.5599975585938,
        y: -1549.800048828125,
        z: 34.36999893188476,
        w: 163.58999633789063,
      },
      jobRequirement: {
        creator: false,
        god: false,
        master: false,
        racer: false,
      },
      active: true,
      racingUserCosts: {
        creator: 5000,
        god: 1000000,
        master: 10000,
        racer: 0,
      },
      moneyType: "bank",
      requireToken: false,
    },
  },
  {
    fobType: "god",
    label: "god user ($1000000)",
    purchaseType: {
      location: {
        x: 938.5599975585938,
        y: -1549.800048828125,
        z: 34.36999893188476,
        w: 163.58999633789063,
      },
      jobRequirement: {
        creator: false,
        god: false,
        master: false,
        racer: false,
      },
      active: true,
      racingUserCosts: {
        creator: 5000,
        god: 1000000,
        master: 10000,
        racer: 0,
      },
      moneyType: "bank",
      requireToken: false,
    },
  },
  {
    fobType: "master",
    label: "master user ($10000)",
    purchaseType: {
      location: {
        x: 938.5599975585938,
        y: -1549.800048828125,
        z: 34.36999893188476,
        w: 163.58999633789063,
      },
      jobRequirement: {
        creator: false,
        god: false,
        master: false,
        racer: false,
      },
      active: true,
      racingUserCosts: {
        creator: 5000,
        god: 1000000,
        master: 10000,
        racer: 0,
      },
      moneyType: "bank",
      requireToken: false,
    },
  },
  {
    fobType: "racer",
    label: "racer user ($0)",
    purchaseType: {
      location: {
        x: 938.5599975585938,
        y: -1549.800048828125,
        z: 34.36999893188476,
        w: 163.58999633789063,
      },
      jobRequirement: {
        creator: false,
        god: false,
        master: false,
        racer: false,
      },
      active: true,
      racingUserCosts: {
        creator: 5000,
        god: 1000000,
        master: 10000,
        racer: 0,
      },
      moneyType: "bank",
      requireToken: false,
    },
  },
];

export const mockCrewData = {
  crew: {
    races: 2,
    members: [
      { citizenID: "PX6944", rank: 0, racername: "CoffeeGod" },
      { citizenID: "WAHO", rank: 0, racername: "Not Coffee" },
      { citizenID: "WAHO2", rank: 0, racername: "Not Coffee2" },
      { citizenID: "WAHO3", rank: 0, racername: "Not Coffee3" },
      { citizenID: "WAHO4", rank: 0, racername: "Not Coffee4" },
      { citizenID: "WAHO5", rank: 0, racername: "Not Coffee5" },
      { citizenID: "WAHO6", rank: 0, racername: "Not Coffee6" },
      { citizenID: "WAHO7", rank: 0, racername: "Not Coffee7" },
      { citizenID: "WAHO8", rank: 0, racername: "Not Coffee8" },
    ],
    crewName: "Coffee Sippers",
    founderCitizenid: "PX6944",
    wins: 1,
    rank: 12,
    founderName: "CoffeeGod",
    id: 24,
  },
  invites: {
    crewName: "Coffee Sippers",
    crewId: 24,
  },
};

export const mockRacingResults = [
  {
    firstPerson: false,
    hostName: "CoffeeGod",
    hidden: false,
    automated: false,
    ranked: false,
    ghosting: true,
    data: "[]",
    reversed: false,
    amountOfRacers: 2,
    raceId: "RI-492761",
    laps: 1,
    trackId: "LR-9238",
    id: 4,
    raceName: "Airport Tiny loop",
    timestamp: 1750364574000.0,
    buyIn: 0,
    results: JSON.stringify(mockRandomRaceResults),
    silent: false,
  },
  {
    firstPerson: false,
    hostName: "CoffeeGod",
    hidden: false,
    automated: false,
    ranked: false,
    ghosting: true,
    data: "[]",
    reversed: false,
    amountOfRacers: 2,
    raceId: "RI-715333",
    laps: 1,
    trackId: "LR-9238",
    id: 3,
    raceName: "Airport Tiny loop",
    timestamp: 1750363416000.0,
    buyIn: 0,
    results:
      '[{"RacingCrew":"Coffee Sippers","BestLap":11592,"RacerSource":1,"RacerName":"CoffeeGod","VehicleModel":"Ariant","TotalTime":11592,"Ranking":210,"CarClass":"A"}]',
    silent: false,
  },
  {
    firstPerson: false,
    hostName: "CoffeeGod",
    hidden: false,
    automated: false,
    ranked: true,
    ghosting: false,
    data: "[]",
    reversed: false,
    amountOfRacers: 2,
    raceId: "RI-972082",
    laps: 0,
    trackId: "LR-9238",
    id: 2,
    raceName: "Airport Tiny loop",
    silent: false,
    timestamp: 1750334457000.0,
    buyIn: 0,
    results:
      '[{"TotalTime":7664,"BestLap":7664,"RacerSource":1,"TotalChange":12,"VehicleModel":"Argento RS","RacerName":"CoffeeGod","CarClass":"S","Ranking":198,"RacingCrew":"Coffee Sippers"},{"TotalTime":16924,"BestLap":16924,"RacerSource":2,"TotalChange":5,"VehicleModel":"Futo","RacerName":"Air_Lady_1337","CarClass":"B","Ranking":5,"RacingCrew":"Lady Crew"}]',
    maxClass: "",
  },
  {
    firstPerson: false,
    hostName: "CoffeeGod",
    hidden: false,
    automated: false,
    ranked: false,
    ghosting: true,
    data: "[]",
    reversed: false,
    amountOfRacers: 2,
    raceId: "RI-828549",
    laps: 1,
    trackId: "LR-9238",
    id: 1,
    raceName: "Airport Tiny loop",
    timestamp: 1750087792000.0,
    buyIn: 0,
    results:
      '[{"TotalTime":26306,"RacerSource":2,"RacerName":"Air_Lady_1337","BestLap":26306,"Ranking":5,"VehicleModel":"ARIANT","RacingCrew":"Lady Crew","CarClass":"A"},{"TotalTime":31377,"RacerSource":1,"RacerName":"CoffeeGod","BestLap":31377,"Ranking":198,"VehicleModel":"ELEGYX","RacingCrew":"Coffee Sippers","CarClass":"S"}]',
    silent: false,
  },
];

export const mockCrewResults = mockRandomCrewResults;

export const mockRacersResults = mockRandomRacersResults

export const mockTrimmedTracks: Track[] = [
    {
        "Racers": [],
        "Metadata": {},
        "CreatorName": "Coffee",
        "RaceName": "Oil Fields",
        "NumStarted": 1,
        "Started": false,
        "TrackId": "CW-4925",
        "Distance": 4030,
        "Access": {},
        "Curated": 1,
        "Creator": "CITIZENID",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    },
    {
        "Racers": [],
        "Metadata": {},
        "CreatorName": "ciphertv",
        "RaceName": "Southside Sprint",
        "NumStarted": 0,
        "Started": false,
        "TrackId": "CW-3610",
        "Distance": 2582,
        "Access": {},
        "Curated": 1,
        "Creator": "CITIZENID",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    },
    {
        "Racers": [],
        "Metadata": {},
        "CreatorName": "Coffee",
        "RaceName": "Cop Blocked",
        "NumStarted": 0,
        "Started": false,
        "TrackId": "CW-3232",
        "Distance": 2578,
        "Access": {},
        "Curated": 1,
        "Creator": "CITIZENID",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    },
    {
        "Racers": [],
        "Metadata": {},
        "CreatorName": "Tailshake",
        "RaceName": "Devils Touge",
        "NumStarted": 0,
        "Started": false,
        "TrackId": "CW-7664",
        "Distance": 9148,
        "Access": {},
        "Curated": 1,
        "Creator": "CITIZENID",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    },
    {
        "Racers": [],
        "Metadata": {},
        "CreatorName": "ilmicioletale",
        "RaceName": "Zancudo Sprint",
        "NumStarted": 0,
        "Started": false,
        "TrackId": "CW-4267",
        "Distance": 4896,
        "Access": {},
        "Curated": 1,
        "Creator": "CITIZENID",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    },
    {
        "Racers": [],
        "Metadata": {},
        "CreatorName": "xdDevion",
        "RaceName": "High-Hill Hijinks",
        "NumStarted": 0,
        "Started": false,
        "TrackId": "CW-9628",
        "Distance": 6049,
        "Access": {},
        "Curated": 1,
        "Creator": "CITIZENID",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    },
    {
        "Racers": [],
        "Metadata": {},
        "CreatorName": "CoffeeGod",
        "RaceName": "Airport Tiny loop",
        "NumStarted": 0,
        "Started": false,
        "TrackId": "LR-9238",
        "Distance": 96,
        "Access": {},
        "Curated": 0,
        "Creator": "PX6944",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    },
    {
        "Racers": [],
        "Metadata": {
            "raceType": "circuit_only"
        },
        "CreatorName": "CoffeeGod",
        "RaceName": "Airport Test Track",
        "NumStarted": 0,
        "Started": false,
        "TrackId": "LR-4907",
        "Distance": 1974,
        "Access": {},
        "Curated": 1,
        "Creator": "2",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    },
    {
        "Racers": [],
        "Metadata": {},
        "CreatorName": "NoSwear",
        "RaceName": "HSPU",
        "NumStarted": 0,
        "Started": false,
        "TrackId": "CW-9030",
        "Distance": 3959,
        "Access": {},
        "Curated": 1,
        "Creator": "CITIZENID",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    },
    {
        "Racers": [],
        "Metadata": {},
        "CreatorName": "ilmicioletale",
        "RaceName": "Zancudo Petrol Station",
        "NumStarted": 0,
        "Started": false,
        "TrackId": "CW-8087",
        "Distance": 4933,
        "Access": {},
        "Curated": 1,
        "Creator": "CITIZENID",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    },
    {
        "Racers": [],
        "Metadata": {},
        "CreatorName": "Coffee",
        "RaceName": "Elysian",
        "NumStarted": 0,
        "Started": false,
        "TrackId": "CW-7666",
        "Distance": 1045,
        "Access": {},
        "Curated": 1,
        "Creator": "CITIZENID",
        "Waiting": false,
        "LastLeaderboard": [],
        "Checkpoints": []
    }
]

export const activeRaceMock: ActiveRace = {
      currentCheckpoint: 29,
      totalCheckpoints: 100,
      totalLaps: 5,
      currentLap: 1,
      raceStarted: true,
      raceName: 'Mock Race',
      time: 12400,
      totalTime: 0,
      bestLap: 0,
      position: 1,
      totalRacers: 0,
      ghosted: true,
      positions: [
        {
          Checkpoint: 2,
          RacerSource: 1,
          RacerName: "Mock Racer",
          PlayerVehicleEntity: 0,
          Lap: 1,
          Placement: 1,
          Finished: true,
          CheckpointTimes: [
            {
              lap: 1,
              checkpoint: 1,
              time: 10400,
            },
            {
              lap: 1,
              checkpoint: 2,
              time: 12400,
            },
          ],
        },
        {
          Checkpoint: 1,
          RacerSource: 1,
          RacerName: "Someone else",
          PlayerVehicleEntity: 0,
          Lap: 1,
          Placement: 2,
          Finished: true,
          CheckpointTimes: [
            {
                lap: 1,
                checkpoint: 1,
                time: 19400,
            }
          ]
        },
        {
          Checkpoint: 1,
          RacerSource: 1,
          RacerName: "Someone else 2",
          PlayerVehicleEntity: 0,
          Lap: 1,
          Placement: 4,
          Finished: false,
          CheckpointTimes: [
            {
                lap: 1,
                checkpoint: 1,
                time: 39400,
            }
          ]
        },
        {
          Checkpoint: 2,
          RacerSource: 1,
          RacerName: "Someone else 3",
          PlayerVehicleEntity: 0,
          Lap: 1,
          Placement: 3,
          Finished: false,
          CheckpointTimes: [
            {
                lap: 1,
                checkpoint: 1,
                time: 19400,
            },
            {
                lap: 1,
                checkpoint: 2,
                time: 29400,
            }
          ]
        },
      ],
  }