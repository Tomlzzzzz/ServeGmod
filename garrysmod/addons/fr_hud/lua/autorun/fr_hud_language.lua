--[[---------------------------------------------------------------------------
    Pack langue FR complet pour DarkRP — Marseille RP
    Enregistre sous "fr" ET override "en" pour forcer le francais
    chez TOUS les joueurs (meme ceux dont gmod_language n'est pas "fr").
    N'ecrase PAS DarkRP-master.
---------------------------------------------------------------------------]]

local fr = {
    -- Admin
    need_admin = "Tu as besoin des privileges admin pour pouvoir %s",
    need_sadmin = "Tu as besoin des privileges super admin pour pouvoir %s",
    no_privilege = "Tu n'as pas les privileges necessaires pour cette action",
    no_jail_pos = "Aucune position de prison",
    invalid_x = "%s invalide ! %s",

    -- Menu F1
    f1ChatCommandTitle = "Commandes de chat",
    f1Search = "Rechercher...",

    -- Argent
    price = "Prix : %s%d",
    priceTag = "Prix : %s",
    reset_money = "%s a remis a zero l'argent de tous les joueurs !",
    has_given = "%s t'a donne %s",
    you_gave = "Tu as donne %s a %s",
    npc_killpay = "%s pour avoir tue un PNJ !",
    profit = "benefice",
    loss = "perte",
    Donate = "Faire un don",
    you_donated = "Tu as fait un don de %s a %s !",
    has_donated = "%s a fait un don de %s !",

    deducted_x = "Preleve %s%d",
    need_x = "Il faut %s%d",
    deducted_money = "Preleve %s",
    need_money = "Il faut %s",

    payday_message = "Jour de paie ! Tu as recu %s !",
    payday_unemployed = "Tu n'as recu aucun salaire car tu es au chomage !",
    payday_missed = "Jour de paie manque ! (Tu es en prison)",

    property_tax = "Taxe fonciere ! %s",
    property_tax_cant_afford = "Tu n'as pas pu payer les taxes ! Ta propriete t'a ete retiree !",
    taxday = "Jour des impots ! %s%% de tes revenus ont ete preleves !",

    found_cheque = "Tu as trouve un cheque de %s%s a ton nom, de la part de %s.",
    cheque_details = "Ce cheque est etabli a l'ordre de %s.",
    cheque_torn = "Tu as dechire le cheque.",
    cheque_pay = "Payer : %s",
    signed = "Signe : %s",

    found_cash = "Tu as ramasse %s%d !",
    found_money = "Tu as ramasse %s !",

    owner_poor = "Le proprietaire du %s est trop pauvre pour subventionner cette vente !",

    -- Police
    Wanted_text = "Recherche !",
    wanted = "Recherche par la Police !\nMotif : %s",
    youre_arrested = "Tu as ete arrete. Temps restant : %d secondes !",
    youre_arrested_by = "Tu as ete arrete par %s.",
    youre_unarrested_by = "Tu as ete libere par %s.",
    hes_arrested = "%s a ete arrete pour %d secondes !",
    hes_unarrested = "%s a ete libere de prison !",
    warrant_ordered = "%s a ordonne un mandat de perquisition pour %s. Motif : %s",
    warrant_request = "%s demande un mandat de perquisition pour %s\nMotif : %s",
    warrant_request2 = "Demande de mandat envoyee au Maire %s !",
    warrant_approved = "Mandat de perquisition approuve pour %s !\nMotif : %s\nOrdonne par : %s",
    warrant_approved2 = "Tu peux maintenant fouiller sa maison.",
    warrant_denied = "Le Maire %s a refuse ta demande de mandat.",
    warrant_expired = "Le mandat de perquisition pour %s a expire !",
    warrant_required = "Tu as besoin d'un mandat pour pouvoir ouvrir cette porte.",
    warrant_required_unfreeze = "Tu as besoin d'un mandat pour pouvoir defiger ce prop.",
    warrant_required_unweld = "Tu as besoin d'un mandat pour pouvoir dessouder ce prop.",
    wanted_by_police = "%s est recherche par la police !\nMotif : %s\nOrdonne par : %s",
    wanted_by_police_print = "%s a fait rechercher %s, motif : %s",
    wanted_expired = "%s n'est plus recherche par la Police.",
    wanted_revoked = "%s n'est plus recherche par la Police.\nAnnule par : %s",
    cant_arrest_other_cp = "Tu ne peux pas arreter d'autres policiers !",
    must_be_wanted_for_arrest = "Le joueur doit etre recherche pour pouvoir l'arreter.",
    cant_arrest_fadmin_jailed = "Tu ne peux pas arreter un joueur emprisonne par un admin.",
    cant_arrest_no_jail_pos = "Tu ne peux arreter personne car aucune position de prison n'est definie !",
    cant_arrest_spawning_players = "Tu ne peux pas arreter des joueurs en train de spawn.",

    suspect_doesnt_exist = "Le suspect n'existe pas.",
    actor_doesnt_exist = "L'acteur n'existe pas.",
    get_a_warrant = "obtenir un mandat",
    remove_a_warrant = "retirer un mandat",
    make_someone_wanted = "rendre quelqu'un recherche",
    remove_wanted_status = "retirer le statut de recherche",
    already_a_warrant = "Il y a deja un mandat de perquisition pour ce suspect.",
    not_warranted = "Il n'y a aucun mandat de perquisition pour cette personne.",
    already_wanted = "Le suspect est deja recherche.",
    not_wanted = "Le suspect n'est pas recherche.",
    need_to_be_cp = "Tu dois faire partie des forces de police.",
    suspect_must_be_alive_to_do_x = "Le suspect doit etre en vie pour %s.",
    suspect_already_arrested = "Le suspect est deja en prison.",

    -- Joueurs
    health = "Vie : %s",
    job = "Metier : %s",
    salary = "Salaire : %s%s",
    wallet = "Portefeuille : %s%s",
    weapon = "Arme : %s",
    kills = "Kills : %s",
    deaths = "Morts : %s",
    rpname_changed = "%s a change son nom RP en : %s",
    disconnected_player = "Joueur deconnecte",
    player = "joueur",

    -- Equipes / metiers
    need_to_be_before = "Tu dois d'abord etre %s pour pouvoir devenir %s",
    need_to_make_vote = "Tu dois lancer un vote pour devenir %s !",
    team_limit_reached = "Impossible de devenir %s, la limite est atteinte",
    wants_to_be = "%s\nveut devenir\n%s",
    has_not_been_made_team = "%s n'a pas ete nomme %s !",
    job_has_become = "%s a ete nomme %s !",

    -- Catastrophes
    meteor_approaching = "ALERTE : Pluie de meteores en approche !",
    meteor_passing = "La pluie de meteores se calme.",
    meteor_enabled = "Les pluies de meteores sont maintenant activees.",
    meteor_disabled = "Les pluies de meteores sont maintenant desactivees.",
    earthquake_report = "Seisme signale de magnitude %sMw",
    earthtremor_report = "Tremblement de terre signale de magnitude %sMw",

    -- Cles, vehicules et portes
    keys_allowed_to_coown = "Tu es autorise a co-posseder ceci\n(Appuie sur Recharger avec les cles ou F2 pour co-posseder)\n",
    keys_other_allowed = "Autorises a co-posseder :",
    keys_allow_ownership = "(Appuie sur Recharger avec les cles ou F2 pour autoriser la possession)",
    keys_disallow_ownership = "(Appuie sur Recharger avec les cles ou F2 pour interdire la possession)",
    keys_owned_by = "Possede par :",
    keys_unowned = "Sans proprietaire\n(Appuie sur Recharger avec les cles ou F2 pour posseder)",
    keys_everyone = "(Appuie sur Recharger avec les cles ou F2 pour activer pour tout le monde)",
    door_unown_arrested = "Tu ne peux pas posseder ou ceder des choses en etant arrete !",
    door_unownable = "Cette porte ne peut pas etre possedee ou cedee !",
    door_sold = "Tu as vendu ceci pour %s",
    door_already_owned = "Cette porte appartient deja a quelqu'un !",
    door_cannot_afford = "Tu n'as pas les moyens d'acheter cette porte !",
    door_hobo_unable = "Tu ne peux pas acheter de porte en etant clochard !",
    vehicle_cannot_afford = "Tu n'as pas les moyens d'acheter ce vehicule !",
    door_bought = "Tu as achete cette porte pour %s%s",
    vehicle_bought = "Tu as achete ce vehicule pour %s%s",
    door_need_to_own = "Tu dois posseder cette porte pour pouvoir %s",
    door_rem_owners_unownable = "Tu ne peux pas retirer de proprietaires si une porte n'est pas possedable !",
    door_add_owners_unownable = "Tu ne peux pas ajouter de proprietaires si une porte n'est pas possedable !",
    rp_addowner_already_owns_door = "%s possede deja (ou est deja autorise a posseder) cette porte !",
    add_owner = "Ajouter un proprietaire",
    remove_owner = "Retirer un proprietaire",
    coown_x = "Co-posseder %s",
    allow_ownership = "Autoriser la possession",
    disallow_ownership = "Interdire la possession",
    edit_door_group = "Modifier le groupe de portes",
    door_groups = "Groupes de portes",
    door_group_doesnt_exist = "Le groupe de portes n'existe pas !",
    door_group_set = "Groupe de portes defini avec succes.",
    sold_x_doors_for_y = "Tu as vendu %d portes pour %s%d !",
    sold_x_doors = "Tu as vendu %d portes pour %s !",
    no_doors_owned = "Tu ne possedes aucune porte !",

    -- Entites
    drugs = "drogues",
    Drugs = "Drogues",
    drug_lab = "Labo de drogue",
    gun_lab = "Labo d'armes",
    any_lab = "n'importe quel labo",
    gun = "arme",
    microwave = "Micro-ondes",
    food = "nourriture",
    Food = "Nourriture",
    money_printer = "Imprimante a billets",
    tip_jar = "Pot a pourboires",

    sign_this_letter = "Signer cette lettre",
    signed_yours = "Cordialement,",

    money_printer_exploded = "Ton imprimante a billets a explose !",
    money_printer_overheating = "Ton imprimante a billets surchauffe !",

    contents = "Contenu : ",
    amount = "Quantite : ",

    picking_lock = "Crochetage de la serrure",

    cannot_pocket_x = "Tu ne peux pas mettre ca dans ta poche !",
    cannot_pocket_gravgunned = "Tu ne peux pas mettre ca dans ta poche : c'est tenu par un gravgun.",
    object_too_heavy = "Cet objet est trop lourd.",
    pocket_full = "Ta poche est pleine !",
    pocket_no_items = "Ta poche ne contient aucun objet.",
    drop_item = "Lacher l'objet",

    bonus_destroying_entity = "destruction de cette entite illegale.",

    switched_burst = "Passe en mode rafale.",
    switched_fully_auto = "Passe en mode automatique.",
    switched_semi_auto = "Passe en mode semi-automatique.",

    keypad_checker_shoot_keypad = "Tire sur un clavier pour voir ce qu'il controle.",
    keypad_checker_shoot_entity = "Tire sur une entite pour voir quels claviers y sont connectes",
    keypad_checker_click_to_clear = "Clic droit pour effacer.",
    keypad_checker_entering_right_pass = "Saisie du bon mot de passe",
    keypad_checker_entering_wrong_pass = "Saisie du mauvais mot de passe",
    keypad_checker_after_right_pass = "apres avoir saisi le bon mot de passe",
    keypad_checker_after_wrong_pass = "apres avoir saisi le mauvais mot de passe",
    keypad_checker_right_pass_entered = "Bon mot de passe saisi",
    keypad_checker_wrong_pass_entered = "Mauvais mot de passe saisi",
    keypad_checker_controls_x_entities = "Ce clavier controle %d entites",
    keypad_checker_controlled_by_x_keypads = "Cette entite est controlee par %d claviers",
    keypad_on = "ON",
    keypad_off = "OFF",
    seconds = "secondes",

    persons_weapons = "Armes de %s :",
    returned_persons_weapons = "Armes confisquees de %s rendues.",
    no_weapons_confiscated = "%s n'avait aucune arme confisquee !",
    no_illegal_weapons = "%s n'avait aucune arme.",
    confiscated_these_weapons = "Armes confisquees :",
    checking_weapons = "Confiscation des armes",

    shipment_antispam_wait = "Attends avant de faire spawn une autre cargaison.",
    createshipment = "Creer une cargaison",
    splitshipment = "Diviser cette cargaison",
    shipment_cannot_split = "Impossible de diviser cette cargaison.",

    -- Parler
    hear_noone = "Personne ne peut t'entendre %s !",
    hear_everyone = "Tout le monde peut t'entendre !",
    hear_certain_persons = "Joueurs qui peuvent t'entendre %s : ",

    whisper = "chuchoter",
    yell = "crier",
    broadcast = "[Annonce !]",
    radio = "radio",
    request = "(DEMANDE !)",
    group = "(groupe)",
    demote = "(DESTITUTION)",
    ooc = "HRP",
    radio_x = "Radio %d",

    talk = "parler",
    speak = "parler",

    speak_in_ooc = "parler en HRP",
    perform_your_action = "effectuer ton action",
    talk_to_your_group = "parler a ton groupe",

    channel_set_to_x = "Canal regle sur %s !",
    channel = "canal",

    -- Notifications
    disabled = "%s a ete desactive ! %s",
    gm_spawnvehicle = "faire spawn des vehicules",
    gm_spawnsent = "faire spawn des entites scriptees (SENTs)",
    gm_spawnnpc = "faire spawn des personnages non-joueurs (PNJ)",
    see_settings = "Consulte les parametres de DarkRP.",
    limit = "Tu as atteint la limite de %s !",
    have_to_wait = "Tu dois attendre encore %d secondes avant d'utiliser %s !",
    must_be_looking_at = "Tu dois regarder un %s !",
    incorrect_job = "Tu n'as pas le bon metier pour %s",
    unavailable = "Ce %s est indisponible",
    unable = "Tu ne peux pas %s. %s",
    cant_afford = "Tu n'as pas les moyens d'acheter ce %s",
    created_x = "%s a cree un %s",
    cleaned_up = "Tes %s ont ete nettoyes.",
    you_bought_x = "Tu as achete %s pour %s%d.",
    you_bought = "Tu as achete %s pour %s.",
    you_got_yourself = "Tu t'es procure un %s.",
    you_received_x = "Tu as recu %s pour %s.",

    created_first_jailpos = "Tu as cree la premiere position de prison !",
    added_jailpos = "Tu as ajoute une position de prison supplementaire !",
    reset_add_jailpos = "Tu as supprime toutes les positions de prison et en as ajoute une ici.",
    created_spawnpos = "Tu as ajoute une position de spawn pour %s.",
    updated_spawnpos = "Tu as supprime toutes les positions de spawn pour %s et en as ajoute une ici.",
    remove_spawnpos = "Tu as supprime toutes les positions de spawn pour %s.",
    do_not_own_ent = "Tu ne possedes pas cette entite !",
    cannot_drop_weapon = "Impossible de lacher cette arme !",
    job_switch = "Metiers echanges avec succes !",
    job_switch_question = "Echanger de metier avec %s ?",
    job_switch_requested = "Echange de metier demande.",
    switch_jobs = "echanger de metier",

    cooks_only = "Cuisiniers uniquement.",

    -- Divers
    unknown = "Inconnu",
    arguments = "arguments",
    no_one = "personne",
    door = "porte",
    vehicle = "vehicule",
    door_or_vehicle = "porte/vehicule",
    driver = "Conducteur : %s",
    name = "Nom : %s",
    locked = "Verrouille.",
    unlocked = "Deverrouille.",
    player_doesnt_exist = "Le joueur n'existe pas.",
    job_doesnt_exist = "Le metier n'existe pas !",
    must_be_alive_to_do_x = "Tu dois etre en vie pour %s.",
    banned_or_demoted = "Banni/destitue",
    wait_with_that = "Attends avant de faire ca.",
    could_not_find = "Impossible de trouver %s",
    f3tovote = "Appuie sur F3 pour voter",
    listen_up = "Ecoutez bien :",
    nlr = "Regle de Nouvelle Vie : Pas d'arrestation/kill par vengeance.",
    reset_settings = "Tu as reinitialise tous les parametres !",
    must_be_x = "Tu dois etre %s pour pouvoir %s.",
    agenda = "agenda",
    agenda_updated = "L'agenda a ete mis a jour",
    job_set = "%s a defini son metier sur '%s'",
    demote_vote = "destituer",
    demoted = "%s a ete destitue",
    demoted_not = "%s n'a pas ete destitue",
    demote_vote_started = "%s a lance un vote pour la destitution de %s",
    demote_vote_text = "Candidat a la destitution :\n%s",
    cant_demote_self = "Tu ne peux pas te destituer toi-meme.",
    i_want_to_demote_you = "Je veux te destituer. Motif : %s",
    tried_to_avoid_demotion = "Tu as tente d'echapper a la destitution. Tu as echoue et tu as ete destitue.",
    lockdown_started = "Le maire a declenche un couvre-feu, rentrez chez vous !",
    lockdown_ended = "Le couvre-feu est termine",
    gunlicense_requested = "%s a demande a %s un permis de port d'arme",
    gunlicense_granted = "%s a accorde a %s un permis de port d'arme",
    gunlicense_denied = "%s a refuse a %s un permis de port d'arme",
    gunlicense_question_text = "Accorder a %s un permis de port d'arme ?",
    gunlicense_remove_vote_text = "%s a lance un vote pour le retrait du permis d'arme de %s",
    gunlicense_remove_vote_text2 = "Revoquer le permis d'arme :\n%s",
    gunlicense_removed = "Le permis de %s a ete retire !",
    gunlicense_not_removed = "Le permis de %s n'a pas ete retire !",
    vote_specify_reason = "Tu dois preciser un motif !",
    vote_started = "Le vote a ete cree",
    vote_alone = "Tu as gagne le vote car tu es seul sur le serveur.",
    you_cannot_vote = "Tu ne peux pas voter !",
    x_cancelled_vote = "%s a annule le dernier vote.",
    cant_cancel_vote = "Impossible d'annuler le dernier vote car il n'y en avait aucun !",
    jail_punishment = "Punition pour deconnexion ! Emprisonne pour : %d secondes.",
    admin_only = "Admin uniquement !",
    chief_or = "Chef ou ",
    frozen = "Fige.",
    recipient = "destinataire",
    forbidden_name = "Nom interdit.",
    illegal_characters = "Caracteres interdits.",
    too_long = "Trop long.",
    too_short = "Trop court.",

    dead_in_jail = "Tu es maintenant mort jusqu'a la fin de ta peine de prison !",
    died_in_jail = "%s est mort en prison !",

    credits_for = "CREDITS POUR %s\n",
    credits_see_console = "Credits de DarkRP affiches dans la console.",

    rp_getvehicles = "Vehicules disponibles pour les vehicules personnalises :",

    data_not_loaded_one = "Tes donnees n'ont pas encore ete chargees. Patiente.",
    data_not_loaded_two = "Si ca persiste, reconnecte-toi ou contacte un admin.",

    cant_spawn_weapons = "Tu ne peux pas faire spawn d'armes.",
    drive_disabled = "Conduite desactivee pour le moment.",
    property_disabled = "Propriete desactivee pour le moment.",

    not_allowed_to_purchase = "Tu n'es pas autorise a acheter cet objet.",

    rp_teamban_hint = "rp_teamban [nom/ID joueur] [nom/id equipe]. Utilise ceci pour bannir un joueur d'un certain metier.",
    rp_teamunban_hint = "rp_teamunban [nom/ID joueur] [nom/id equipe]. Utilise ceci pour debannir un joueur d'un certain metier.",
    x_teambanned_y_for_z = "%s a banni %s du metier %s pour %s minutes.",
    x_teamunbanned_y = "%s a debanni %s du metier %s.",

    you_set_x_salary_to_y = "Tu as defini le salaire de %s sur %s%d.",
    x_set_your_salary_to_y = "%s a defini ton salaire sur %s%d.",
    you_set_x_money_to_y = "Tu as defini l'argent de %s sur %s%d.",
    x_set_your_money_to_y = "%s a defini ton argent sur %s%d.",

    you_set_x_salary = "Tu as defini le salaire de %s sur %s.",
    x_set_your_salary = "%s a defini ton salaire sur %s.",
    you_set_x_money = "Tu as defini l'argent de %s sur %s.",
    x_set_your_money = "%s a defini ton argent sur %s.",
    you_set_x_name = "Tu as defini le nom de %s sur %s",
    x_set_your_name = "%s a defini ton nom sur %s",

    someone_stole_steam_name = "Quelqu'un utilise deja ton nom Steam comme nom RP, on t'a donc ajoute un '1' apres ton nom.",
    already_taken = "Deja pris.",

    job_doesnt_require_vote_currently = "Ce metier ne necessite pas de vote pour le moment !",

    x_made_you_a_y = "%s t'a nomme %s !",

    cmd_cant_be_run_server_console = "Cette commande ne peut pas etre executee depuis la console serveur.",

    -- Loterie
    lottery_started = "Il y a une loterie ! Participer pour %s%d ?",
    lottery_has_started = "Il y a une loterie ! Participer pour %s ?",
    lottery_entered = "Tu as participe a la loterie pour %s",
    lottery_not_entered = "%s n'a pas participe a la loterie",
    lottery_noone_entered = "Personne n'a participe a la loterie",
    lottery_won = "%s a gagne la loterie ! Il a gagne %s",
    lottery = "loterie",
    lottery_please_specify_an_entry_cost = "Precise un cout de participation (%s-%s)",
    too_few_players_for_lottery = "Trop peu de joueurs pour lancer une loterie. Il faut au moins %d joueurs",
    lottery_ongoing = "Impossible de lancer une loterie, une loterie est deja en cours",

    -- Animations
    custom_animation = "Animation personnalisee !",
    bow = "Saluer",
    sexy_dance = "Danse sexy",
    follow_me = "Suis-moi !",
    laugh = "Rire",
    lion_pose = "Pose du lion",
    nonverbal_no = "Non non-verbal",
    thumbs_up = "Pouce en l'air",
    wave = "Faire signe",
    dance = "Danser",

    -- Faim
    starving = "Affame !",

    -- AFK
    afk_mode = "Mode AFK",
    unable_afk_spam_prevention = "Attends avant de repasser AFK.",
    salary_frozen = "Ton salaire a ete gele.",
    salary_restored = "Bon retour, ton salaire a ete retabli.",
    no_auto_demote = "Tu ne seras pas destitue automatiquement.",
    youre_afk_demoted = "Tu as ete destitue pour etre reste AFK trop longtemps. La prochaine fois utilise /afk.",
    hes_afk_demoted = "%s a ete destitue pour etre reste AFK trop longtemps.",
    afk_cmd_to_exit = "Tape /afk pour sortir du mode AFK.",
    player_now_afk = "%s est maintenant AFK.",
    player_no_longer_afk = "%s n'est plus AFK.",

    -- Menu des contrats (Hitman)
    hit = "contrat",
    hitman = "Tueur a gages",
    current_hit = "Contrat : %s",
    cannot_request_hit = "Impossible de demander un contrat ! %s",
    hitmenu_request = "Demander",
    player_not_hitman = "Ce joueur n'est pas un tueur a gages !",
    distance_too_big = "Distance trop grande.",
    hitman_no_suicide = "Le tueur a gages ne se tuera pas lui-meme.",
    hitman_no_self_order = "Un tueur a gages ne peut pas commander un contrat sur lui-meme.",
    hitman_already_has_hit = "Le tueur a gages a deja un contrat en cours.",
    price_too_low = "Prix trop bas !",
    hit_target_recently_killed_by_hit = "La cible a recemment ete tuee par un contrat,",
    customer_recently_bought_hit = "Le client a recemment demande un contrat.",
    accept_hit_question = "Accepter le contrat de %s\nconcernant %s pour %s%d ?",
    accept_hit_request = "Accepter le contrat de %s\nconcernant %s pour %s ?",
    hit_requested = "Contrat demande !",
    hit_aborted = "Contrat abandonne ! %s",
    hit_accepted = "Contrat accepte !",
    hit_declined = "Le tueur a gages a refuse le contrat !",
    hitman_left_server = "Le tueur a gages a quitte le serveur !",
    customer_left_server = "Le client a quitte le serveur !",
    target_left_server = "La cible a quitte le serveur !",
    hit_price_set_to_x = "Prix du contrat defini sur %s%d.",
    hit_price_set = "Prix du contrat defini sur %s.",
    hit_complete = "Contrat de %s rempli !",
    hitman_died = "Le tueur a gages est mort !",
    target_died = "La cible est morte !",
    hitman_arrested = "Le tueur a gages a ete arrete !",
    hitman_changed_team = "Le tueur a gages a change d'equipe !",
    x_had_hit_ordered_by_y = "%s avait un contrat actif commande par %s",
    place_a_hit = "commander un contrat !",
    hit_cancel = "annulation de contrat !",
    hit_cancelled = "Le contrat a ete annule !",
    no_active_hit = "Tu n'as aucun contrat actif !",

    -- Restrictions de vote
    hobos_no_rights = "Les clochards n'ont aucun droit de vote !",
    gangsters_cant_vote_for_government = "Les gangsters ne peuvent pas voter pour les affaires du gouvernement !",
    government_cant_vote_for_gangsters = "Les officiels du gouvernement ne peuvent pas voter pour les affaires des gangsters !",

    -- VGUI / portes / vehicules
    vote = "Voter",
    time = "Temps : %d",
    yes = "Oui",
    no = "Non",
    ok = "D'accord",
    cancel = "Annuler",
    add = "Ajouter",
    remove = "Retirer",
    none = "Aucun",

    x_options = "Options de %s",
    sell_x = "Vendre %s",
    set_x_title = "Definir le titre du %s",
    set_x_title_long = "Definis le titre du %s que tu regardes.",
    jobs = "Metiers",
    buy_x = "Acheter %s",

    -- Menu F4
    ammo = "munitions",
    weapon_ = "arme",
    no_extra_weapons = "Ce metier n'a pas d'armes supplementaires.",
    become_job = "Devenir ce metier",
    create_vote_for_job = "Lancer un vote",
    shipment = "cargaison",
    Shipments = "Cargaisons",
    shipments = "cargaisons",
    F4guns = "Armes",
    F4entities = "Divers",
    F4ammo = "Munitions",
    F4vehicles = "Vehicules",

    -- Onglet 1
    give_money = "Donner de l'argent au joueur que tu regardes",
    drop_money = "Lacher de l'argent",
    change_name = "Changer ton nom DarkRP",
    go_to_sleep = "Dormir / se reveiller",
    drop_weapon = "Lacher l'arme actuelle",
    buy_health = "Acheter de la vie (%s)",
    request_gunlicense = "Demander un permis de port d'arme",
    demote_player_menu = "Destituer un joueur",

    searchwarrantbutton = "Rendre un joueur recherche",
    unwarrantbutton = "Retirer le statut de recherche d'un joueur",
    noone_available = "Personne de disponible",
    request_warrant = "Demander un mandat de perquisition pour un joueur",
    make_wanted = "Rendre quelqu'un recherche",
    make_unwanted = "Retirer le statut de recherche",
    set_jailpos = "Definir la position de prison",
    add_jailpos = "Ajouter une position de prison",

    set_custom_job = "Definir un metier personnalise (appuie sur Entree pour activer)",

    set_agenda = "Definir l'agenda (appuie sur Entree pour activer)",

    initiate_lockdown = "Declencher un couvre-feu",
    stop_lockdown = "Arreter le couvre-feu",
    start_lottery = "Lancer une loterie",
    give_license_lookingat = "Donner a <lookingat> un permis de port d'arme",

    laws_of_the_land = "LES LOIS DU PAYS",
    law_added = "Loi ajoutee.",
    law_removed = "Loi retiree.",
    law_reset = "Lois reinitialisees.",
    law_too_short = "Loi trop courte.",
    laws_full = "Les lois sont pleines.",
    default_law_change_denied = "Tu n'es pas autorise a modifier les lois par defaut.",

    -- Deuxieme onglet
    job_name = "Nom : ",
    job_description = "Description : ",
    job_weapons = "Armes : ",

    -- Onglet entites
    buy_a = "Acheter %s : %s",

    -- Onglet armes sous licence
    license_tab = [[Armes sous licence

    Coche les armes que les joueurs devraient pouvoir obtenir SANS permis !
    ]],
    license_tab_other_weapons = "Autres armes :",
}

local function addFR()
    if not DarkRP or not DarkRP.addLanguage then return end
    DarkRP.addLanguage("fr", fr)
    DarkRP.addLanguage("en", fr) -- force le FR meme pour les clients non-francais
end

-- DarkRP peut etre charge avant ou apres cet addon : on couvre les deux cas
hook.Add("DarkRPFinishedLoading", "FRHUD_Language", addFR)
addFR()
