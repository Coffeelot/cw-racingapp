local Translations = {
    error = {
        name_too_short = 'Nome troppo corto.',
        name_too_long = 'Nome troppo lungo.',
        unowned_dongle = "Non sembra corrispondere.",
        id_not_found = "Citizen ID non trovato.",
        invalid_fob_type = "fob invalida.",
        not_in_race = "Non sei in gara.",
        race_already_started = "La gara e partita!",
        race_doesnt_exist = "Questa gara non esiste:(",
        race_timed_out = "Timed out gara cancellata.",
        race_name_exists = "Esiste gia una gara con quel nome.",
        no_permission = "Non hai il permesso per farlo.",
        already_making_race = "Stai gia creando una gara.",
        already_in_race = "Gia sei in gara.",
        return_to_start = "Torna all inizio o verrai espulso dalla gara: ",
        slow_down = "Non puoi andare cosi veloce!",
        no_checkpoints_to_delete = "Non hai posizionato alcun checkpoint da eliminare.",
        not_enough_checkpoints = "Servono altri checkpoint per salvare",
        max_tire_distance = "Distanza massima consentita  ",
        min_tire_distance = "Distanza minima consentita  ",
        editor_confirm = "Premi di nuovo [9] per confermare.",
        editor_canceled = "Hai cancellato l editor.",
        can_not_afford = "Non puoi farlo",
        could_not_find_person = "Impossibile trovare la persona",
        not_enough_money = "Non hai soldi per partecipare"
    },
    primary = {
        race_last_person = "Eri l ultima persona in ara, quindi e stata annullata.",
        race_someone_joined = "Qualcuno si e unito alla gara.",
        race_someone_left = "Qualcuno ha abbandonato la gara.",
        race_joined = "Ti sei unito alla gara.",
        race_will_start = "La gara inizia tra 10 secondi.",
        racer_finished_place = " gara finita in posizione: ",
        no_pending_races = "Al momento non ci sono gare in sospeso.",
        no_races_exist = "Nessun tempo impostato su questa pista",
        no_available_tracks = "Al momento non ci sono tracciati disponibili da utilizzare.",
        has_been_removed = " rimosso",
        leaderboard_has_been_cleared = "classifica cancellata"
    },
    success = {
        race_created = "gara create!",
        race_saved = "gara salvata",
        race_record = "Hai fatto il record su %s con il tempo di: %s!",
        race_go = "GO!",
        race_finished = "Hai finito la gara in ",
        race_best_lap = "Hai ottenuto il miglior giro su ",
        new_pb = "Hai un nuovo record personale!",
        time_added = "Tempo aggiunto alla classifica"
    },
    commands = {
        create_racing_fob_command = 'createracingfob',
        create_racing_fob_description = 'Crea un portachiavi da corsa (Admin)',
    },
    text = {
        checkpoint_left = "Checkpoint SX",
        checkpoint_right = "Checkpoint DX",
        get_in_vehicle = "Sali su un veicolo per iniziare!",
    },
    menu = {
        ready_to_race = "Pronto a gareggiare, ",
        current_race = "Gara attuale",
        current_race_txt = "Opzioni per la gara inserita.",
        available_races = "Gare disponibili",
        available_races_txt = "Visualizza tutte le gare disponibili.",
        race_records = "Record",
        race_records_txt = "Vedi tutti i record per la gara.",
        setup_race = "Setup a Race",
        create_race = "Crea un Tracciato",
        close = "Chiudi il Menu",
        racers = " pilota(i)",
        start_race = "Start Race",
        leave_race =  "Esci dalla gara",
        go_back = "Indietro",
        race_info = "%s giro(i) | %sm | %s pilota(i)",
        unclaimed = "Record non reclamato!",
        choose_a_track = "Scegli il tracciato",
        choose_a_class = "Scegli la classe",
        racing_setup = "Racing - Setup",
        select_track = "Selezione la tua traccia",
        number_laps = "Numeri di giri (0 x Sprint)",
        name_track_question = "Come vuoi che si chiami la traccia?",
        name_track = "Nome tracciato",
        all = 'Tutte le Classi',
        my_tracks = "I miei tracciati",
        delete_track = "Elimina traccia",
        clear_leaderboard = "Cancella Leaderboard",
        are_you_sure_you_want_to_delete_track = 'Elimina questa traccia definitimanente?',
        are_you_sure_you_want_to_clear = 'Resetto la classifiva definitivamente?',
        yes = "Si",
        no = "No",
        useGhosting = "Usi Ghosting?",
        ghostingTime = "Tempo (in secondi) ghost attivo",
        no_class_limit = "Nessun limite di classi",
        max_class = "Classe massima consentita",
        buyIn = "Buy in",
    }
}
Lang = Locale:new({phrases = Translations, warnOnMissing = true})
-- Maintained by Coffeelot and Brains74