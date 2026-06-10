--[[---------------------------------------------------------------------------
    Concession Marseille RP - CONFIG VEHICULES (genere automatiquement)
    Genere le 2026-06-09 15:49:52
    
    Edite les champs name / price / vip / category selon tes envies.
    L'ordre des entrees = ordre d'affichage dans le menu concess.
---------------------------------------------------------------------------]]

FRConcess = FRConcess or {}

FRConcess.VehiclesList = {


    -- ============ Azok30 ============
    { class = "azok30_citroen_berlingo_2017", name = "Citroen Berlingo 2017", price = 30200, vip = false, category = "Azok30" },
    { class = "azok30_ktm_690_smc_r", name = "KTM 690 SMC R", price = 102000, vip = false, category = "Azok30" },
    { class = "azok30_lamborghini_urus", name = "Lamborghini Urus 2019 TopCar Design", price = 852500, vip = true, category = "Azok30" },
    { class = "azok30_peugeot_307", name = "Peugeot 307", price = 50000, vip = false, category = "Azok30" },
    { class = "azok30_renault_clio_3_rs", name = "Renault Clio 3 RS", price = 95000, vip = false, category = "Azok30" },
    { class = "azok30_renault_clio_4", name = "Renault Clio 4", price = 70000, vip = false, category = "Azok30" },
    { class = "azok30_renault_scenic_2", name = "Renault Scenic 2", price = 45050, vip = false, category = "Azok30" },
    { class = "azok30_tmax_530", name = "Yamaha Tmax 530 2018", price = 350500, vip = true, category = "Azok30" },

    -- ============ CrSk Autos ============
    { class = "crsk_bugatti_visiongt", name = "Bugatti Vision Gran Turismo 2015", price = 4000000, vip = true, category = "CrSk Autos" },
    { class = "crsk_honda_accord_2008", name = "Honda Accord 2008", price = 50000, vip = false, category = "CrSk Autos" },
    { class = "crsk_mercedes_g500_2008", name = "Mercedes-Benz G 500 2008", price = 200000, vip = false, category = "CrSk Autos" },
    { class = "crsk_peugeot_206rc_2003", name = "Peugeot 206 RC '03", price = 90000, vip = false, category = "CrSk Autos" },

    -- ============ Go Kart ============
    { class = "electric_gokart", name = "Go-Kart VIP", price = 800000, vip = true, category = "Go Kart" },
    { class = "electric_gokart_weenie", name = "Go-Kart", price = 600000, vip = false, category = "Go Kart" },

    -- ============ LW Cars ============
    { class = "chev_impala_09", name = "Chevrolet Impala LS", price = 110000, vip = false, category = "LW Cars" },
    { class = "merc_sprinter_boxtruck_lw", name = "Mercedes Sprinter Boxtruck", price = 150000, vip = false, category = "LW Cars" },
    { class = "merc_sprinter_lwb_lw", name = "Mercedes Sprinter LWB", price = 120500, vip = false, category = "LW Cars" },
    { class = "merc_sprinter_swb_lw", name = "Mercedes Sprinter SWB", price = 100000, vip = false, category = "LW Cars" },
    { class = "ren_5turbo_lw", name = "Renault 5 Turbo", price = 250000, vip = false, category = "LW Cars" },
    { class = "renault_alpine_lw", name = "Renault Alpine A110 1600S", price = 1200000, vip = false, category = "LW Cars" },
    { class = "renault_alpine_zar_lw", name = "Renault Alpine A110-50 ZAR", price = 2500000, vip = true, category = "LW Cars" },
    { class = "yare_buggy", name = "Y.A.R.E Buggy", price = 325000, vip = true, category = "LW Cars" },

    -- ============ Marcus' Cars ============
    { class = "rs3", name = "2011 Audi RS3", price = 550250, vip = false, category = "Marcus' Cars" },

    -- ============ Realistic_Bike ============
    { class = "realistic_bike_ktm_690", name = "KTM Duke 690", price = 230000, vip = false, category = "Realistic_Bike" },
    { class = "realistic_bike_kawasaki_ninja_h2", name = "Kawasaki Ninja H2", price = 350000, vip = false, category = "Realistic_Bike" },
    { class = "realistic_bike_yamaha_yz_250", name = "Yamaha YZ 250", price = 525000, vip = false, category = "Realistic_Bike" },

    -- ============ RebS's Cars ============
    { class = "rebs_hl2_renault_traffic", name = "2013 Renault Traffic", price = 70000, vip = false, category = "RebS's Cars" },

    -- ============ Rytrak Cars ============
    { class = "rmeganers", name = "Renault Megane 4 RS", price = 161250, vip = false, category = "Rytrak Cars" },

    -- ============ SFC - Cars ============
    { class = "dannio_custom_2018_yamahar1", name = "Yamaha R1 2018", price = 850000, vip = true, category = "SFC - Cars" },

    -- ============ SGM Cars ============
    { class = "rv", name = "1980s RV", price = 350000, vip = true, category = "SGM Cars" },
    { class = "aventador", name = "2012 Lamborghini Aventador", price = 1750000, vip = false, category = "SGM Cars" },
    { class = "lambosine", name = "2012 Lamborghini Aventador Lambosine", price = 2000000, vip = true, category = "SGM Cars" },
    { class = "cybertruck_sgm", name = "2021 Tesla Cybertruck", price = 2500000, vip = true, category = "SGM Cars" },

    -- ============ Skylar Automotive ============
    { class = "sky_r8_ico", name = "2017 Audi R8 V10", price = 950000, vip = false, category = "Skylar Automotive" },

    -- ============ Super's Cars ============
    { class = "sm2020rs6", name = "2020 Audi RS6 Avant", price = 3000000, vip = true, category = "Super's Cars" },

    -- ============ TDM Cars ============
    { class = "audir8plustdm", name = "Audi R8 Plus", price = 750000, vip = false, category = "TDM Cars" },
    { class = "rs4avanttdm", name = "Audi RS4 Avant", price = 320000, vip = false, category = "TDM Cars" },
    { class = "auds5tdm", name = "Audi S5", price = 200000, vip = false, category = "TDM Cars" },
    { class = "auditttdm", name = "Audi TT 07", price = 140000, vip = false, category = "TDM Cars" },
    { class = "bowlexrstdm", name = "Bowler EXR-S", price = 250000, vip = false, category = "TDM Cars" },
    { class = "eb110tdm", name = "Bugatti EB110", price = 3500000, vip = true, category = "TDM Cars" },
    { class = "veyronsstdm", name = "Bugatti Veyron SS", price = 3250000, vip = true, category = "TDM Cars" },
    { class = "cad_escaladetdm", name = "Cadillac Escalade 2012", price = 210000, vip = false, category = "TDM Cars" },
    { class = "cad_lmptdm", name = "Cadillac LMP", price = 1100000, vip = false, category = "TDM Cars" },
    { class = "che_69camarotdm", name = "Chevrolet Camaro SS 69", price = 280000, vip = false, category = "TDM Cars" },
    { class = "che_camarozl1tdm", name = "Chevrolet Camaro ZL1", price = 300000, vip = false, category = "TDM Cars" },
    { class = "che_chevellesstdm", name = "Chevrolet Chevelle SS", price = 220000, vip = false, category = "TDM Cars" },
    { class = "che_corv_gsctdm", name = "Chevrolet Corvette GSC", price = 285000, vip = false, category = "TDM Cars" },
    { class = "che_stingray427tdm", name = "Chevrolet Corvette Stingray 427", price = 350000, vip = true, category = "TDM Cars" },
    { class = "che_sparktdm", name = "Chevrolet Spark", price = 20000, vip = false, category = "TDM Cars" },
    { class = "deloreantdm", name = "Delorean DMC-12", price = 500000, vip = true, category = "TDM Cars" },
    { class = "fer_250gtotdm", name = "Ferrari 250 GTO", price = 10025000, vip = false, category = "TDM Cars" },
    { class = "fer_458spidtdm", name = "Ferrari 458 Spider", price = 1800000, vip = false, category = "TDM Cars" },
    { class = "fer_enzotdm", name = "Ferrari Enzo", price = 2350000, vip = false, category = "TDM Cars" },
    { class = "ferf12tdm", name = "Ferrari F12 Berlinetta", price = 2200000, vip = false, category = "TDM Cars" },
    { class = "ferf430tdm", name = "Ferrari F430", price = 1500000, vip = false, category = "TDM Cars" },
    { class = "fer_lafertdm", name = "Ferrari LaFerrari", price = 1135000, vip = false, category = "TDM Cars" },
    { class = "f350tdm", name = "Ford F350 SuperDuty", price = 150000, vip = false, category = "TDM Cars" },
    { class = "for_focus_rs16tdm", name = "Ford Focus RS '16", price = 130000, vip = false, category = "TDM Cars" },
    { class = "focussvttdm", name = "Ford Focus SVT", price = 24500, vip = false, category = "TDM Cars" },
    { class = "gt05tdm", name = "Ford GT 05", price = 850000, vip = false, category = "TDM Cars" },
    { class = "mustanggttdm", name = "Ford Mustang GT", price = 215000, vip = false, category = "TDM Cars" },
    { class = "raptorsvttdm", name = "Ford Raptor SVT", price = 185000, vip = false, category = "TDM Cars" },
    { class = "for_she_gt500tdm", name = "Ford Shelby GT500", price = 380000, vip = false, category = "TDM Cars" },
    { class = "transittdm", name = "Ford Transit", price = 70000, vip = false, category = "TDM Cars" },
    { class = "sierratdm", name = "GMC Sierra Monster", price = 400000, vip = false, category = "TDM Cars" },
    { class = "gmcvantdm", name = "GMC Vandura", price = 70000, vip = false, category = "TDM Cars" },
    { class = "hon_crxsirtdm", name = "Honda CR-X SiR", price = 75000, vip = false, category = "TDM Cars" },
    { class = "civic97tdm", name = "Honda Civic Type R 97", price = 130000, vip = false, category = "TDM Cars" },
    { class = "s2000tdm", name = "Honda S2000", price = 150000, vip = false, category = "TDM Cars" },
    { class = "grandchetdm", name = "Jeep Grand Cherokee 2012", price = 225000, vip = false, category = "TDM Cars" },
    { class = "wrangler_fnftdm", name = "Jeep Wrangler F&F", price = 450000, vip = true, category = "TDM Cars" },
    { class = "xbowtdm", name = "KTM X-BOW", price = 650000, vip = true, category = "TDM Cars" },
    { class = "lex_is300tdm", name = "Lexus IS 300", price = 150000, vip = false, category = "TDM Cars" },
    { class = "lex_isftdm", name = "Lexus IS F", price = 250000, vip = false, category = "TDM Cars" },
    { class = "mas_ghiblitdm", name = "Maserati Ghibli S", price = 340000, vip = false, category = "TDM Cars" },
    { class = "mas_quattrotdm", name = "Maserati Quattroporte Sport GT S", price = 280000, vip = false, category = "TDM Cars" },
    { class = "furaitdm", name = "Mazda Furai", price = 9000000, vip = true, category = "TDM Cars" },
    { class = "mx5tdm", name = "Mazda MX-5 2007", price = 85000, vip = false, category = "TDM Cars" },
    { class = "rx7tdm", name = "Mazda RX-7", price = 200000, vip = false, category = "TDM Cars" },
    { class = "rx8tdm", name = "Mazda RX-8", price = 140000, vip = false, category = "TDM Cars" },
    { class = "mclarenf1tdm", name = "McLaren F1", price = 935000, vip = false, category = "TDM Cars" },
    { class = "mp412cgt3tdm", name = "McLaren GT MP4-12C GT3", price = 1400000, vip = true, category = "TDM Cars" },
    { class = "p1tdm", name = "McLaren P1", price = 2350000, vip = false, category = "TDM Cars" },
    { class = "mer_slrtdm", name = "Mercedes McLaren SLR", price = 1200000, vip = false, category = "TDM Cars" },
    { class = "mer300slgulltdm", name = "Mercedes-Benz 300SL Gullwing Coupe", price = 450000, vip = false, category = "TDM Cars" },
    { class = "c32amgtdm", name = "Mercedes-Benz C32 AMG", price = 220000, vip = false, category = "TDM Cars" },
    { class = "mere63tdm", name = "Mercedes-Benz E63 AMG", price = 400000, vip = false, category = "TDM Cars" },
    { class = "merml63tdm", name = "Mercedes-Benz ML63 AMG", price = 350000, vip = false, category = "TDM Cars" },
    { class = "sl65amgtdm", name = "Mercedes-Benz SL65 AMG", price = 600000, vip = false, category = "TDM Cars" },
    { class = "slsamgtdm", name = "Mercedes-Benz SLS AMG", price = 1345000, vip = true, category = "TDM Cars" },
    { class = "morgaerosstdm", name = "Morgan Aero SS", price = 1675000, vip = true, category = "TDM Cars" },
    { class = "350ztdm", name = "Nissan 350z", price = 150000, vip = false, category = "TDM Cars" },
    { class = "370ztdm", name = "Nissan 370z", price = 150000, vip = false, category = "TDM Cars" },
    { class = "gtrtdm", name = "Nissan GT-R Black Edition", price = 650000, vip = false, category = "TDM Cars" },
    { class = "nis_leaftdm", name = "Nissan Leaf", price = 70000, vip = false, category = "TDM Cars" },
    { class = "r34tdm", name = "Nissan Skyline R34", price = 500000, vip = false, category = "TDM Cars" },
    { class = "noblem600tdm", name = "Noble M600", price = 450000, vip = false, category = "TDM Cars" },
    { class = "zondagrtdm", name = "Pagani Carsport America Zonda GR", price = 3500000, vip = true, category = "TDM Cars" },
    { class = "c12tdm", name = "Pagani Zonda C12", price = 3000000, vip = false, category = "TDM Cars" },
    { class = "pon_fierogttdm", name = "Pontiac Fiero GT", price = 80000, vip = false, category = "TDM Cars" },
    { class = "pon_firebirdtransamtdm", name = "Pontiac Firebird Trans Am", price = 150000, vip = true, category = "TDM Cars" },
    { class = "porgt3rsrtdm", name = "Porsche 911 GT3-RSR", price = 1785000, vip = true, category = "TDM Cars" },
    { class = "918spydtdm", name = "Porsche 918 Spyder", price = 450000, vip = false, category = "TDM Cars" },
    { class = "997gt3tdm", name = "Porsche 997 GT3", price = 650000, vip = false, category = "TDM Cars" },
    { class = "carreragttdm", name = "Porsche Carrera GT", price = 785000, vip = false, category = "TDM Cars" },
    { class = "cayennetdm", name = "Porsche Cayenne Turbo S", price = 350000, vip = false, category = "TDM Cars" },
    { class = "porcycletdm", name = "Porsche Tricycle", price = 300000, vip = true, category = "TDM Cars" },
    { class = "tesmodelstdm", name = "Tesla Model S", price = 250000, vip = false, category = "TDM Cars" },
    { class = "priustdm", name = "Toyota Prius", price = 65000, vip = false, category = "TDM Cars" },
    { class = "supratdm", name = "Toyota Supra", price = 250000, vip = false, category = "TDM Cars" },
    { class = "vwcampertdm", name = "Volkswagen Camper 1965", price = 800000, vip = true, category = "TDM Cars" },
    { class = "vwgolfgti14tdm", name = "Volkswagen Golf GTI 2014", price = 110000, vip = false, category = "TDM Cars" },
    { class = "vw_golfr32tdm", name = "Volkswagen Golf R32", price = 150000, vip = false, category = "TDM Cars" },
    { class = "golfvr6tdm", name = "Volkswagen Golf VR6 GTi", price = 85000, vip = false, category = "TDM Cars" },
    { class = "vwsciroccortdm", name = "Volkswagen Scirocco R", price = 130000, vip = false, category = "TDM Cars" },
    { class = "242turbotdm", name = "Volvo 242 Turbo", price = 150000, vip = false, category = "TDM Cars" },
    { class = "vol850rtdm", name = "Volvo 850 R", price = 150000, vip = false, category = "TDM Cars" },
    { class = "st1tdm", name = "Zenvo ST1", price = 750000, vip = false, category = "TDM Cars" },


}

-- Groupes ULX/ULib consideres comme VIP
FRConcess.VipGroups = {
    ["vip"]         = true,
    ["superadmin"]  = true,
    ["admin"]       = true,
}