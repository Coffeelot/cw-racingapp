local Translations = {
    error = {
        name_too_short = 'Имя слишком короткое.',
        name_too_long = 'Имя слишком длинное.',
        unowned_dongle = "Ничего не происходит",
        id_not_found = "ID не найден.",
        invalid_fob_type = "Invalid fob type.",
        not_in_race = "Вы не учавствуете в генке.",
        race_already_started = "Гонка уже началась!",
        race_doesnt_exist = "Эта гонка не существует",
        race_timed_out = "Гонка отменена",
        race_name_exists = "Гонка с таким именем уже существует",
        no_permission = "У Вас нет разрешения на это",
        already_making_race = "Вы уже создаете гонку",
        already_in_race = "Вы уже в гонке",
        return_to_start = "Вернитесь на старт или вы будете дисквалифицированы из: ",
        slow_down = "Притормозите!",
        no_checkpoints_to_delete = "Нет чекпоинтов, нечего удалять",
        not_enough_checkpoints = "Чтобы сохранить, нужно минимум 10 чекпоинтов",
        max_tire_distance = "Максимальная разрешенная дистанция ",
        min_tire_distance = "Минимальная разрешенная дистанция ",
        editor_confirm = "Нажните [9] еще раз, чтобы подтвердить.",
        editor_canceled = "Вы отменили редактирование.",
        can_not_afford = "Вы не можете себе этого позволить",
        could_not_find_person = "Персона не найдена"
    },
    primary = {
        race_last_person = "Гонка отменена т.к Вы были последним участником",
        race_someone_joined = "Кто-то вступил в гонку.",
        race_someone_left = "Кто-то покинул гонку.",
        race_joined = "Вы вступили в гонку.",
        race_will_start = "Гонка начнется через 10 сек.",
        racer_finished_place = " finished in place: ",
        no_pending_races = "В данный момент нет активных гонок.",
        no_races_exist = "На этом круге никто не поставил лучшее время",
        no_available_tracks = "В данный момент нет свободных треков.",
        has_been_removed = " был убран",
        leaderboard_has_been_cleared = "таблицы очищены"
    },
    success = {
        race_created = "Гонка создана!",
        race_saved = "Гонка сохранена",
        race_record = "Вы установили рекорд на %s с результатом: %s!",
        race_go = "GO!",
        race_finished = "Вы винишировали ",
        race_best_lap = "Лучший круг ",
        new_pb = "Лучше персональное время круга!",
        time_added = "Ваш результат занесен в таблицу"
    },
    commands = {
        create_racing_fob_command = 'createracingfob',
        create_racing_fob_description = 'Create a Racing Fob (Admin)',
    },
    text = {
        checkpoint_left = "Left Checkpoint",
        checkpoint_right = "Right Checkpoint",
        get_in_vehicle = "Get in a vehicle to start!",
    },
    menu = {
        ready_to_race = "Ready to Race, ",
        current_race = "Текущая гонка",
        current_race_txt = "Опции для текущей гонки",
        available_races = "Доступные гонки",
        available_races_txt = "See all the currently available races right now.",
        race_records = "Рекорды",
        race_records_txt = "Таблица гоночных рекордов",
        setup_race = "Устроить гонку",
        create_race = "Создать трэк",
        close = "Закрыть",
        racers = " Гонщик (и)",
        start_race = "Старт",
        leave_race =  "Покинуть гонку",
        go_back = "назад",
        race_info = "%s lap(s) | %sm | %s racer(s)",
        unclaimed = "Unclaimed Record!",
        choose_a_track = "Выберите трэк",
        choose_a_class = "Выберите класс",
        racing_setup = "Racing - Setup",
        select_track = "Выберите трэк",
        number_laps = "Кол-во кругов (0 - Спринт)",
        name_track_question = "Как назовете трэк?",
        name_track = "Назовите трэк",
        all = 'Открытый класс',
        my_tracks = "Мои трэки",
        delete_track = "Удалить трэк",
        clear_leaderboard = "Очистить таблицу рекордов",
        are_you_sure_you_want_to_delete_track = 'Удалить трэк полностью?',
        are_you_sure_you_want_to_clear = 'Удалить таблицу рекордов полностью?',
        yes = "Да",
        no = "Нет",
        useGhosting = "Use Ghosting?",
        ghostingTime = "Time (in seconds) until Ghosting turns off",
        no_tracks_exist = "Нет созданных трэков"
    }
}
Lang = Locale:new({phrases = Translations, warnOnMissing = true})

-- bk#6540