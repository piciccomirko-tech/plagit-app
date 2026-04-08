//
//  HospitalityCatalog.swift
//  Plagit
//
//  3-level hospitality business taxonomy:
//  Main Category → Subcategory → Role
//
//  Scalable: add new entries to the `all` array — no UI rewrite needed.
//

import Foundation

// MARK: - Data Models

struct HospitalityCategory: Identifiable, Hashable {
    let id: String          // stable key, e.g. "restaurants"
    let name: String        // display name
    let icon: String        // SF Symbol
    let subcategories: [HospitalitySubcategory]
}

struct HospitalitySubcategory: Identifiable, Hashable {
    let id: String
    let name: String
    let roles: [HospitalityRole]
}

struct HospitalityRole: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String        // SF Symbol
}

// MARK: - Catalog

enum HospitalityCatalog {

    // MARK: - Full Catalog (alphabetically sorted)

    static let all: [HospitalityCategory] = [

        // ── Back Office ──
        HospitalityCategory(id: "back_office", name: "Back Office", icon: "desktopcomputer", subcategories: [
            HospitalitySubcategory(id: "bo_accounting", name: "Accounting & Finance", roles: [
                HospitalityRole(id: "bo_accountant", name: "Accountant", icon: "dollarsign.circle"),
                HospitalityRole(id: "bo_bookkeeper", name: "Bookkeeper", icon: "book.closed"),
                HospitalityRole(id: "bo_controller", name: "Financial Controller", icon: "chart.bar"),
                HospitalityRole(id: "bo_payroll", name: "Payroll Specialist", icon: "banknote"),
            ]),
            HospitalitySubcategory(id: "bo_admin", name: "Administration", roles: [
                HospitalityRole(id: "bo_admin_asst", name: "Administrative Assistant", icon: "doc.text"),
                HospitalityRole(id: "bo_data_entry", name: "Data Entry Clerk", icon: "keyboard"),
                HospitalityRole(id: "bo_office_mgr", name: "Office Manager", icon: "person.badge.key"),
                HospitalityRole(id: "bo_receptionist", name: "Receptionist", icon: "phone"),
            ]),
            HospitalitySubcategory(id: "bo_hr", name: "Human Resources", roles: [
                HospitalityRole(id: "bo_hr_coordinator", name: "HR Coordinator", icon: "person.2"),
                HospitalityRole(id: "bo_hr_manager", name: "HR Manager", icon: "person.badge.key"),
                HospitalityRole(id: "bo_recruiter", name: "Recruiter", icon: "person.badge.plus"),
                HospitalityRole(id: "bo_trainer", name: "Training Coordinator", icon: "book"),
            ]),
            HospitalitySubcategory(id: "bo_it", name: "IT & Systems", roles: [
                HospitalityRole(id: "bo_it_manager", name: "IT Manager", icon: "server.rack"),
                HospitalityRole(id: "bo_it_support", name: "IT Support Specialist", icon: "wrench.and.screwdriver"),
                HospitalityRole(id: "bo_systems_admin", name: "Systems Administrator", icon: "desktopcomputer"),
            ]),
            HospitalitySubcategory(id: "bo_marketing", name: "Marketing & Sales", roles: [
                HospitalityRole(id: "bo_digital_mktg", name: "Digital Marketing Specialist", icon: "globe"),
                HospitalityRole(id: "bo_marketing_mgr", name: "Marketing Manager", icon: "megaphone"),
                HospitalityRole(id: "bo_revenue_mgr", name: "Revenue Manager", icon: "chart.line.uptrend.xyaxis"),
                HospitalityRole(id: "bo_sales_mgr", name: "Sales Manager", icon: "briefcase"),
            ]),
        ]),

        // ── Bakeries & Pastry ──
        HospitalityCategory(id: "bakeries", name: "Bakeries & Pastry", icon: "birthday.cake", subcategories: [
            HospitalitySubcategory(id: "bk_artisan", name: "Artisan Bakery", roles: [
                HospitalityRole(id: "bk_artisan_baker", name: "Artisan Baker", icon: "oven"),
                HospitalityRole(id: "bk_bread_baker", name: "Bread Baker", icon: "oven"),
                HospitalityRole(id: "bk_sourdough", name: "Sourdough Specialist", icon: "leaf"),
            ]),
            HospitalitySubcategory(id: "bk_chocolate", name: "Chocolaterie", roles: [
                HospitalityRole(id: "bk_chocolatier", name: "Chocolatier", icon: "drop.fill"),
                HospitalityRole(id: "bk_confectioner", name: "Confectioner", icon: "sparkles"),
            ]),
            HospitalitySubcategory(id: "bk_pastry", name: "Pastry Shop", roles: [
                HospitalityRole(id: "bk_cake_decorator", name: "Cake Decorator", icon: "paintbrush"),
                HospitalityRole(id: "bk_pastry_chef", name: "Pastry Chef", icon: "birthday.cake"),
                HospitalityRole(id: "bk_viennoiserie", name: "Viennoiserie Baker", icon: "oven"),
            ]),
            HospitalitySubcategory(id: "bk_production", name: "Production Bakery", roles: [
                HospitalityRole(id: "bk_baker", name: "Production Baker", icon: "oven"),
                HospitalityRole(id: "bk_line_lead", name: "Production Line Lead", icon: "person.badge.key"),
                HospitalityRole(id: "bk_quality", name: "Quality Controller", icon: "checkmark.shield"),
            ]),
        ]),

        // ── Bars ──
        HospitalityCategory(id: "bars", name: "Bars", icon: "wineglass", subcategories: [
            HospitalitySubcategory(id: "bar_cocktail", name: "Cocktail Bar", roles: [
                HospitalityRole(id: "bar_barback", name: "Barback", icon: "tray"),
                HospitalityRole(id: "bar_head_bartender", name: "Head Bartender", icon: "wineglass.fill"),
                HospitalityRole(id: "bar_mixologist", name: "Mixologist", icon: "wineglass"),
            ]),
            HospitalitySubcategory(id: "bar_hotel", name: "Hotel Bar", roles: [
                HospitalityRole(id: "bar_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "bar_lounge_mgr", name: "Lounge Manager", icon: "person.badge.key"),
                HospitalityRole(id: "bar_sommelier", name: "Sommelier", icon: "wineglass.fill"),
            ]),
            HospitalitySubcategory(id: "bar_lounge", name: "Lounge Bar", roles: [
                HospitalityRole(id: "bar_lg_barback", name: "Barback", icon: "tray"),
                HospitalityRole(id: "bar_lg_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "bar_lg_host", name: "Hostess", icon: "person.wave.2"),
                HospitalityRole(id: "bar_lg_mgr", name: "Floor Manager", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "bar_pub", name: "Pub & Gastropub", roles: [
                HospitalityRole(id: "bar_cellar", name: "Cellar Manager", icon: "shippingbox"),
                HospitalityRole(id: "bar_pub_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "bar_pub_mgr", name: "Pub Manager", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "bar_rooftop", name: "Rooftop Bar", roles: [
                HospitalityRole(id: "bar_rt_barback", name: "Barback", icon: "tray"),
                HospitalityRole(id: "bar_rt_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "bar_rt_host", name: "Hostess", icon: "person.wave.2"),
                HospitalityRole(id: "bar_rt_mgr", name: "Floor Manager", icon: "person.badge.key"),
                HospitalityRole(id: "bar_rt_waiter", name: "Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "bar_wine", name: "Wine Bar", roles: [
                HospitalityRole(id: "bar_wine_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "bar_wine_sommelier", name: "Sommelier", icon: "wineglass.fill"),
                HospitalityRole(id: "bar_wine_steward", name: "Wine Steward", icon: "list.bullet"),
            ]),
        ]),

        // ── Cafés ──
        HospitalityCategory(id: "cafes", name: "Cafés", icon: "cup.and.saucer", subcategories: [
            HospitalitySubcategory(id: "cafe_bakery", name: "Bakery Café", roles: [
                HospitalityRole(id: "cafe_bk_baker", name: "Baker", icon: "oven"),
                HospitalityRole(id: "cafe_bk_barista", name: "Barista", icon: "cup.and.saucer"),
                HospitalityRole(id: "cafe_bk_cashier", name: "Cashier", icon: "creditcard"),
                HospitalityRole(id: "cafe_bk_pastry", name: "Pastry Chef", icon: "birthday.cake"),
            ]),
            HospitalitySubcategory(id: "cafe_brunch", name: "Brunch & Breakfast Cafe", roles: [
                HospitalityRole(id: "cafe_brunch_cook", name: "Brunch Cook", icon: "frying.pan"),
                HospitalityRole(id: "cafe_brunch_mgr", name: "Cafe Manager", icon: "person.badge.key"),
                HospitalityRole(id: "cafe_brunch_server", name: "Server", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "cafe_coffee", name: "Coffee Shop", roles: [
                HospitalityRole(id: "cafe_barista", name: "Barista", icon: "cup.and.saucer"),
                HospitalityRole(id: "cafe_head_barista", name: "Head Barista", icon: "cup.and.saucer.fill"),
                HospitalityRole(id: "cafe_roaster", name: "Coffee Roaster", icon: "flame"),
                HospitalityRole(id: "cafe_shift_lead", name: "Shift Lead", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "cafe_tea", name: "Tea Room", roles: [
                HospitalityRole(id: "cafe_tea_server", name: "Server", icon: "tray"),
                HospitalityRole(id: "cafe_tea_specialist", name: "Tea Specialist", icon: "leaf"),
            ]),
        ]),

        // ── Catering ──
        HospitalityCategory(id: "catering", name: "Catering", icon: "takeoutbag.and.cup.and.straw", subcategories: [
            HospitalitySubcategory(id: "cat_corporate", name: "Corporate Catering", roles: [
                HospitalityRole(id: "cat_corp_chef", name: "Catering Chef", icon: "flame"),
                HospitalityRole(id: "cat_corp_coord", name: "Catering Coordinator", icon: "calendar"),
                HospitalityRole(id: "cat_corp_server", name: "Catering Server", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "cat_event", name: "Event Catering", roles: [
                HospitalityRole(id: "cat_evt_chef", name: "Event Chef", icon: "flame"),
                HospitalityRole(id: "cat_evt_mgr", name: "Catering Manager", icon: "person.badge.key"),
                HospitalityRole(id: "cat_evt_server", name: "Catering Server", icon: "tray"),
                HospitalityRole(id: "cat_evt_setup", name: "Setup Crew", icon: "hammer"),
            ]),
            HospitalitySubcategory(id: "cat_luxury", name: "Luxury Catering", roles: [
                HospitalityRole(id: "cat_lux_butler", name: "Butler", icon: "person"),
                HospitalityRole(id: "cat_lux_chef", name: "Head Chef", icon: "flame"),
                HospitalityRole(id: "cat_lux_mgr", name: "Catering Manager", icon: "person.badge.key"),
                HospitalityRole(id: "cat_lux_server", name: "Waiter", icon: "tray"),
                HospitalityRole(id: "cat_lux_somm", name: "Sommelier", icon: "wineglass.fill"),
            ]),
            HospitalitySubcategory(id: "cat_mobile", name: "Mobile Catering", roles: [
                HospitalityRole(id: "cat_food_truck", name: "Food Truck Operator", icon: "car"),
                HospitalityRole(id: "cat_mobile_cook", name: "Mobile Cook", icon: "flame"),
            ]),
            HospitalitySubcategory(id: "cat_private", name: "Private Catering", roles: [
                HospitalityRole(id: "cat_priv_butler", name: "Butler", icon: "person"),
                HospitalityRole(id: "cat_priv_chef", name: "Private Chef", icon: "flame"),
                HospitalityRole(id: "cat_priv_server", name: "Private Server", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "cat_wedding", name: "Wedding Catering", roles: [
                HospitalityRole(id: "cat_wed_chef", name: "Head Chef", icon: "flame"),
                HospitalityRole(id: "cat_wed_coord", name: "Catering Coordinator", icon: "calendar"),
                HospitalityRole(id: "cat_wed_mgr", name: "Catering Manager", icon: "person.badge.key"),
                HospitalityRole(id: "cat_wed_server", name: "Event Waiter", icon: "tray"),
                HospitalityRole(id: "cat_wed_setup", name: "Setup Crew", icon: "hammer"),
            ]),
        ]),

        // ── Clubs & Nightlife ──
        HospitalityCategory(id: "clubs", name: "Clubs & Nightlife", icon: "music.note", subcategories: [
            HospitalitySubcategory(id: "club_beach", name: "Beach Club", roles: [
                HospitalityRole(id: "club_beach_bar", name: "Beach Bartender", icon: "wineglass"),
                HospitalityRole(id: "club_beach_host", name: "Host", icon: "person.wave.2"),
                HospitalityRole(id: "club_beach_mgr", name: "Beach Club Manager", icon: "person.badge.key"),
                HospitalityRole(id: "club_beach_server", name: "Server", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "club_lounge", name: "Lounge", roles: [
                HospitalityRole(id: "club_lounge_bar", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "club_lounge_host", name: "Hostess", icon: "person.wave.2"),
                HospitalityRole(id: "club_lounge_vip", name: "VIP Host", icon: "star"),
            ]),
            HospitalitySubcategory(id: "club_members", name: "Members Club", roles: [
                HospitalityRole(id: "club_mem_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "club_mem_concierge", name: "Concierge", icon: "person.wave.2"),
                HospitalityRole(id: "club_mem_host", name: "Hostess", icon: "person.wave.2"),
                HospitalityRole(id: "club_mem_mgr", name: "General Manager", icon: "person.badge.key"),
                HospitalityRole(id: "club_mem_waiter", name: "Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "club_night", name: "Nightclub", roles: [
                HospitalityRole(id: "club_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "club_door", name: "Door Host", icon: "shield"),
                HospitalityRole(id: "club_dj", name: "DJ", icon: "music.note"),
                HospitalityRole(id: "club_mgr", name: "Club Manager", icon: "person.badge.key"),
                HospitalityRole(id: "club_promoter", name: "Promoter", icon: "megaphone"),
                HospitalityRole(id: "club_security", name: "Security", icon: "shield.fill"),
            ]),
        ]),

        // ── Corporate Hospitality ──
        HospitalityCategory(id: "corporate", name: "Corporate Hospitality", icon: "building.2", subcategories: [
            HospitalitySubcategory(id: "corp_canteen", name: "Corporate Canteen", roles: [
                HospitalityRole(id: "corp_canteen_chef", name: "Canteen Chef", icon: "flame"),
                HospitalityRole(id: "corp_canteen_mgr", name: "Canteen Manager", icon: "person.badge.key"),
                HospitalityRole(id: "corp_canteen_server", name: "Server", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "corp_exec", name: "Executive Dining", roles: [
                HospitalityRole(id: "corp_exec_butler", name: "Butler", icon: "person"),
                HospitalityRole(id: "corp_exec_chef", name: "Executive Chef", icon: "flame"),
                HospitalityRole(id: "corp_exec_server", name: "Server", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "corp_lounge", name: "VIP Lounge", roles: [
                HospitalityRole(id: "corp_lounge_attendant", name: "Lounge Attendant", icon: "person.wave.2"),
                HospitalityRole(id: "corp_lounge_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "corp_lounge_mgr", name: "Lounge Manager", icon: "person.badge.key"),
            ]),
        ]),

        // ── Cruises & Yachts ──
        HospitalityCategory(id: "cruises", name: "Cruises & Yachts", icon: "ferry", subcategories: [
            HospitalitySubcategory(id: "cr_cruise", name: "Cruise Ship", roles: [
                HospitalityRole(id: "cr_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "cr_cabin_stew", name: "Cabin Steward", icon: "bed.double"),
                HospitalityRole(id: "cr_cruise_chef", name: "Cruise Chef", icon: "flame"),
                HospitalityRole(id: "cr_entertainment", name: "Entertainment Host", icon: "music.note"),
                HospitalityRole(id: "cr_maitre_d", name: "Maitre D'", icon: "person.badge.key"),
                HospitalityRole(id: "cr_waiter", name: "Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "cr_river", name: "River Cruise", roles: [
                HospitalityRole(id: "cr_river_chef", name: "Chef", icon: "flame"),
                HospitalityRole(id: "cr_river_server", name: "Server", icon: "tray"),
                HospitalityRole(id: "cr_river_steward", name: "Steward", icon: "bed.double"),
            ]),
            HospitalitySubcategory(id: "cr_yacht", name: "Yacht", roles: [
                HospitalityRole(id: "cr_deckhand", name: "Deckhand", icon: "wrench"),
                HospitalityRole(id: "cr_stew", name: "Stewardess", icon: "person.wave.2"),
                HospitalityRole(id: "cr_yacht_chef", name: "Yacht Chef", icon: "flame"),
            ]),
        ]),

        // ── Delivery ──
        HospitalityCategory(id: "delivery", name: "Delivery", icon: "bicycle", subcategories: [
            HospitalitySubcategory(id: "del_catering", name: "Catering Delivery", roles: [
                HospitalityRole(id: "del_cat_driver", name: "Delivery Driver", icon: "car"),
                HospitalityRole(id: "del_cat_evt_asst", name: "Event Delivery Assistant", icon: "shippingbox"),
                HospitalityRole(id: "del_cat_logistics", name: "Logistics Coordinator", icon: "map"),
                HospitalityRole(id: "del_cat_setup", name: "Setup Crew", icon: "hammer"),
            ]),
            HospitalitySubcategory(id: "del_dark", name: "Dark Kitchen Delivery", roles: [
                HospitalityRole(id: "del_dark_dispatch", name: "Dispatch Coordinator", icon: "arrow.triangle.branch"),
                HospitalityRole(id: "del_dark_kitchen", name: "Kitchen Dispatcher", icon: "flame"),
                HospitalityRole(id: "del_dark_order", name: "Order Coordinator", icon: "list.clipboard"),
                HospitalityRole(id: "del_dark_packer", name: "Order Packer", icon: "shippingbox"),
                HospitalityRole(id: "del_dark_shift", name: "Shift Supervisor", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "del_premium", name: "Premium / VIP Delivery", roles: [
                HospitalityRole(id: "del_prem_chauffeur", name: "Chauffeur Delivery", icon: "car.fill"),
                HospitalityRole(id: "del_prem_concierge", name: "Client Delivery Concierge", icon: "person.wave.2"),
                HospitalityRole(id: "del_prem_luxury", name: "Luxury Delivery Assistant", icon: "star"),
            ]),
            HospitalitySubcategory(id: "del_restaurant", name: "Restaurant Delivery", roles: [
                HospitalityRole(id: "del_rest_dispatch", name: "Dispatch Coordinator", icon: "arrow.triangle.branch"),
                HospitalityRole(id: "del_rest_driver", name: "Delivery Driver", icon: "car"),
                HospitalityRole(id: "del_rest_packer", name: "Order Packer", icon: "shippingbox"),
                HospitalityRole(id: "del_rest_rider", name: "Delivery Rider", icon: "bicycle"),
                HospitalityRole(id: "del_rest_supervisor", name: "Delivery Supervisor", icon: "person.badge.key"),
            ]),
        ]),

        // ── Entertainment Hospitality ──
        HospitalityCategory(id: "entertainment", name: "Entertainment Hospitality", icon: "theatermasks", subcategories: [
            HospitalitySubcategory(id: "ent_club_stage", name: "Club Shows / Stage Performance", roles: [
                HospitalityRole(id: "ent_cs_acrobat", name: "Acrobat", icon: "figure.gymnastics"),
                HospitalityRole(id: "ent_cs_aerial", name: "Aerial Performer", icon: "wind"),
                HospitalityRole(id: "ent_cs_choreo", name: "Choreographer", icon: "music.note.list"),
                HospitalityRole(id: "ent_cs_dancer", name: "Dancer", icon: "figure.dance"),
                HospitalityRole(id: "ent_cs_fire", name: "Fire Performer", icon: "flame"),
                HospitalityRole(id: "ent_cs_led", name: "LED Performer", icon: "light.max"),
                HospitalityRole(id: "ent_cs_showgirl", name: "Showgirl", icon: "sparkles"),
                HospitalityRole(id: "ent_cs_stage", name: "Stage Performer", icon: "theatermasks"),
            ]),
            HospitalitySubcategory(id: "ent_family", name: "Family Entertainment", roles: [
                HospitalityRole(id: "ent_fam_activity", name: "Activity Host", icon: "figure.run"),
                HospitalityRole(id: "ent_fam_character", name: "Character Performer", icon: "theatermasks"),
                HospitalityRole(id: "ent_fam_event", name: "Event Host", icon: "person.wave.2"),
                HospitalityRole(id: "ent_fam_kids", name: "Kids Entertainer", icon: "figure.child"),
                HospitalityRole(id: "ent_fam_performer", name: "Performer", icon: "music.note"),
            ]),
            HospitalitySubcategory(id: "ent_hotel", name: "Hotel Entertainment", roles: [
                HospitalityRole(id: "ent_htl_activities", name: "Activities Host", icon: "figure.run"),
                HospitalityRole(id: "ent_htl_dj", name: "DJ", icon: "music.note"),
                HospitalityRole(id: "ent_htl_host", name: "Entertainment Host", icon: "person.wave.2"),
                HospitalityRole(id: "ent_htl_event", name: "Event Host", icon: "calendar"),
                HospitalityRole(id: "ent_htl_kids", name: "Kids Entertainer", icon: "figure.child"),
                HospitalityRole(id: "ent_htl_singer", name: "Live Singer", icon: "mic"),
                HospitalityRole(id: "ent_htl_pianist", name: "Pianist", icon: "pianokeys"),
                HospitalityRole(id: "ent_htl_sax", name: "Saxophonist", icon: "music.note"),
                HospitalityRole(id: "ent_htl_violin", name: "Violinist", icon: "music.note"),
            ]),
            HospitalitySubcategory(id: "ent_live_music", name: "Live Music Venue", roles: [
                HospitalityRole(id: "ent_lm_band", name: "Band Performer", icon: "music.mic"),
                HospitalityRole(id: "ent_lm_dj", name: "DJ", icon: "music.note"),
                HospitalityRole(id: "ent_lm_mgr", name: "Entertainment Manager", icon: "person.badge.key"),
                HospitalityRole(id: "ent_lm_singer", name: "Live Singer", icon: "mic"),
                HospitalityRole(id: "ent_lm_mc", name: "MC / Host", icon: "person.wave.2"),
                HospitalityRole(id: "ent_lm_musician", name: "Musician", icon: "guitars"),
                HospitalityRole(id: "ent_lm_pianist", name: "Pianist", icon: "pianokeys"),
                HospitalityRole(id: "ent_lm_sax", name: "Saxophonist", icon: "music.note"),
                HospitalityRole(id: "ent_lm_stage", name: "Stage Assistant", icon: "hammer"),
                HospitalityRole(id: "ent_lm_violin", name: "Violinist", icon: "music.note"),
            ]),
            HospitalitySubcategory(id: "ent_lounge", name: "Lounge Entertainment", roles: [
                HospitalityRole(id: "ent_lg_dj", name: "DJ", icon: "music.note"),
                HospitalityRole(id: "ent_lg_singer", name: "Live Singer", icon: "mic"),
                HospitalityRole(id: "ent_lg_performer", name: "Lounge Performer", icon: "theatermasks"),
                HospitalityRole(id: "ent_lg_pianist", name: "Pianist", icon: "pianokeys"),
                HospitalityRole(id: "ent_lg_sax", name: "Saxophonist", icon: "music.note"),
                HospitalityRole(id: "ent_lg_violin", name: "Violinist", icon: "music.note"),
            ]),
            HospitalitySubcategory(id: "ent_night", name: "Night Entertainment", roles: [
                HospitalityRole(id: "ent_nt_dancer", name: "Dancer", icon: "figure.dance"),
                HospitalityRole(id: "ent_nt_dj", name: "DJ", icon: "music.note"),
                HospitalityRole(id: "ent_nt_coord", name: "Entertainment Coordinator", icon: "calendar"),
                HospitalityRole(id: "ent_nt_floor", name: "Floor Entertainer", icon: "sparkles"),
                HospitalityRole(id: "ent_nt_mc", name: "MC / Host", icon: "person.wave.2"),
                HospitalityRole(id: "ent_nt_performer", name: "Performer", icon: "music.note"),
                HospitalityRole(id: "ent_nt_show", name: "Show Host", icon: "theatermasks"),
                HospitalityRole(id: "ent_nt_vip", name: "VIP Hostess", icon: "star"),
            ]),
            HospitalitySubcategory(id: "ent_resort", name: "Resort Entertainment", roles: [
                HospitalityRole(id: "ent_res_activities", name: "Activities Host", icon: "figure.run"),
                HospitalityRole(id: "ent_res_dancer", name: "Dancer", icon: "figure.dance"),
                HospitalityRole(id: "ent_res_dj", name: "DJ", icon: "music.note"),
                HospitalityRole(id: "ent_res_entertainer", name: "Entertainer", icon: "theatermasks"),
                HospitalityRole(id: "ent_res_mgr", name: "Entertainment Manager", icon: "person.badge.key"),
                HospitalityRole(id: "ent_res_kids", name: "Kids Club Entertainer", icon: "figure.child"),
                HospitalityRole(id: "ent_res_mc", name: "MC / Host", icon: "person.wave.2"),
                HospitalityRole(id: "ent_res_show", name: "Show Performer", icon: "sparkles"),
                HospitalityRole(id: "ent_res_sports", name: "Sports Entertainer", icon: "figure.run"),
            ]),
            HospitalitySubcategory(id: "ent_wedding", name: "Wedding & Event Entertainment", roles: [
                HospitalityRole(id: "ent_wed_band", name: "Band Performer", icon: "music.mic"),
                HospitalityRole(id: "ent_wed_dancer", name: "Dancer", icon: "figure.dance"),
                HospitalityRole(id: "ent_wed_dj", name: "DJ", icon: "music.note"),
                HospitalityRole(id: "ent_wed_singer", name: "Live Singer", icon: "mic"),
                HospitalityRole(id: "ent_wed_mc", name: "MC / Host", icon: "person.wave.2"),
                HospitalityRole(id: "ent_wed_musician", name: "Musician", icon: "guitars"),
                HospitalityRole(id: "ent_wed_sax", name: "Saxophonist", icon: "music.note"),
                HospitalityRole(id: "ent_wed_violin", name: "Violinist", icon: "music.note"),
                HospitalityRole(id: "ent_wed_entertainer", name: "Wedding Entertainer", icon: "heart"),
            ]),
        ]),

        // ── Events & Banqueting ──
        HospitalityCategory(id: "events", name: "Events & Banqueting", icon: "party.popper", subcategories: [
            HospitalitySubcategory(id: "evt_banquet", name: "Banqueting", roles: [
                HospitalityRole(id: "evt_banquet_captain", name: "Banquet Captain", icon: "person.badge.key"),
                HospitalityRole(id: "evt_banquet_chef", name: "Banquet Chef", icon: "flame"),
                HospitalityRole(id: "evt_banquet_mgr", name: "Banquet Manager", icon: "person.badge.key"),
                HospitalityRole(id: "evt_banquet_server", name: "Banquet Server", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "evt_conference", name: "Conference & Exhibition", roles: [
                HospitalityRole(id: "evt_av_tech", name: "AV Technician", icon: "speaker.wave.2"),
                HospitalityRole(id: "evt_conf_coord", name: "Conference Coordinator", icon: "calendar"),
                HospitalityRole(id: "evt_registration", name: "Registration Staff", icon: "person.text.rectangle"),
            ]),
            HospitalitySubcategory(id: "evt_exhibition", name: "Exhibitions", roles: [
                HospitalityRole(id: "evt_exh_bartender", name: "Event Bartender", icon: "wineglass"),
                HospitalityRole(id: "evt_exh_coord", name: "Event Coordinator", icon: "calendar"),
                HospitalityRole(id: "evt_exh_host", name: "Hostess", icon: "person.wave.2"),
                HospitalityRole(id: "evt_exh_server", name: "Event Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "evt_floral", name: "Floral & Decoration", roles: [
                HospitalityRole(id: "evt_fl_balloon", name: "Balloon Decorator", icon: "circle.circle"),
                HospitalityRole(id: "evt_fl_decorator", name: "Event Decorator", icon: "paintpalette"),
                HospitalityRole(id: "evt_fl_styling", name: "Event Styling Coordinator", icon: "wand.and.stars"),
                HospitalityRole(id: "evt_fl_designer", name: "Floral Designer", icon: "leaf"),
                HospitalityRole(id: "evt_fl_florist", name: "Florist", icon: "leaf.fill"),
                HospitalityRole(id: "evt_fl_setup", name: "Set-Up Decor Assistant", icon: "hammer"),
                HospitalityRole(id: "evt_fl_table", name: "Table Decor Specialist", icon: "tablecells"),
                HospitalityRole(id: "evt_fl_venue", name: "Venue Stylist", icon: "sparkles"),
                HospitalityRole(id: "evt_fl_visual", name: "Visual Merchandising Decorator", icon: "eye"),
                HospitalityRole(id: "evt_fl_wedding", name: "Wedding Decorator", icon: "heart"),
            ]),
            HospitalitySubcategory(id: "evt_gala", name: "Gala Dinners", roles: [
                HospitalityRole(id: "evt_gala_bartender", name: "Event Bartender", icon: "wineglass"),
                HospitalityRole(id: "evt_gala_chef", name: "Head Chef", icon: "flame"),
                HospitalityRole(id: "evt_gala_mgr", name: "Banquet Manager", icon: "person.badge.key"),
                HospitalityRole(id: "evt_gala_sommelier", name: "Sommelier", icon: "wineglass.fill"),
                HospitalityRole(id: "evt_gala_waiter", name: "Event Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "evt_wedding", name: "Weddings", roles: [
                HospitalityRole(id: "evt_florist", name: "Florist", icon: "leaf"),
                HospitalityRole(id: "evt_wed_coord", name: "Wedding Coordinator", icon: "heart"),
                HospitalityRole(id: "evt_wed_server", name: "Wedding Server", icon: "tray"),
            ]),
        ]),

        // ── Fitness & Wellness ──
        HospitalityCategory(id: "fitness", name: "Fitness & Wellness", icon: "dumbbell", subcategories: [
            HospitalitySubcategory(id: "fit_gym", name: "Gym", roles: [
                HospitalityRole(id: "fit_gym_club_mgr", name: "Club Manager", icon: "person.badge.key"),
                HospitalityRole(id: "fit_gym_fitness_mgr", name: "Fitness Manager", icon: "figure.run"),
                HospitalityRole(id: "fit_gym_instructor", name: "Gym Instructor", icon: "dumbbell"),
                HospitalityRole(id: "fit_gym_membership", name: "Membership Advisor", icon: "person.badge.plus"),
                HospitalityRole(id: "fit_gym_pt", name: "Personal Trainer", icon: "figure.strengthtraining.traditional"),
                HospitalityRole(id: "fit_gym_reception", name: "Receptionist", icon: "phone"),
            ]),
            HospitalitySubcategory(id: "fit_nutrition", name: "Nutrition Studio", roles: [
                HospitalityRole(id: "fit_nut_dietitian", name: "Dietitian", icon: "leaf"),
                HospitalityRole(id: "fit_nut_nutritionist", name: "Nutritionist", icon: "carrot"),
                HospitalityRole(id: "fit_nut_reception", name: "Receptionist", icon: "phone"),
                HospitalityRole(id: "fit_nut_wellness", name: "Wellness Coach", icon: "heart"),
            ]),
            HospitalitySubcategory(id: "fit_recovery", name: "Recovery Center", roles: [
                HospitalityRole(id: "fit_rec_pt", name: "Personal Trainer", icon: "figure.strengthtraining.traditional"),
                HospitalityRole(id: "fit_rec_reception", name: "Receptionist", icon: "phone"),
                HospitalityRole(id: "fit_rec_wellness", name: "Wellness Coach", icon: "heart"),
            ]),
            HospitalitySubcategory(id: "fit_spa", name: "Spa", roles: [
                HospitalityRole(id: "fit_spa_club_mgr", name: "Club Manager", icon: "person.badge.key"),
                HospitalityRole(id: "fit_spa_membership", name: "Membership Advisor", icon: "person.badge.plus"),
                HospitalityRole(id: "fit_spa_reception", name: "Receptionist", icon: "phone"),
                HospitalityRole(id: "fit_spa_wellness", name: "Wellness Coach", icon: "heart"),
            ]),
            HospitalitySubcategory(id: "fit_wellness", name: "Wellness Center", roles: [
                HospitalityRole(id: "fit_well_club_mgr", name: "Club Manager", icon: "person.badge.key"),
                HospitalityRole(id: "fit_well_dietitian", name: "Dietitian", icon: "leaf"),
                HospitalityRole(id: "fit_well_fitness_mgr", name: "Fitness Manager", icon: "figure.run"),
                HospitalityRole(id: "fit_well_nutritionist", name: "Nutritionist", icon: "carrot"),
                HospitalityRole(id: "fit_well_reception", name: "Receptionist", icon: "phone"),
                HospitalityRole(id: "fit_well_wellness", name: "Wellness Coach", icon: "heart"),
            ]),
        ]),

        // ── Healthcare Hospitality ──
        HospitalityCategory(id: "healthcare", name: "Healthcare Hospitality", icon: "cross.case", subcategories: [
            HospitalitySubcategory(id: "hc_clinic", name: "Clinic", roles: [
                HospitalityRole(id: "hc_clinic_cleaner", name: "Cleaner", icon: "sparkles"),
                HospitalityRole(id: "hc_clinic_front", name: "Front Desk Agent", icon: "person.text.rectangle"),
                HospitalityRole(id: "hc_clinic_hosp_asst", name: "Hospitality Assistant", icon: "person"),
                HospitalityRole(id: "hc_clinic_reception", name: "Receptionist", icon: "phone"),
            ]),
            HospitalitySubcategory(id: "hc_hospital", name: "Hospital", roles: [
                HospitalityRole(id: "hc_hosp_catering", name: "Catering Assistant", icon: "takeoutbag.and.cup.and.straw"),
                HospitalityRole(id: "hc_hosp_cleaner", name: "Cleaner", icon: "sparkles"),
                HospitalityRole(id: "hc_hosp_guest", name: "Guest Services", icon: "person.wave.2"),
                HospitalityRole(id: "hc_hosp_housekeeper", name: "Housekeeper", icon: "bed.double"),
                HospitalityRole(id: "hc_hosp_patient", name: "Patient Services Coordinator", icon: "heart.text.square"),
                HospitalityRole(id: "hc_hosp_porter", name: "Porter", icon: "suitcase"),
                HospitalityRole(id: "hc_hosp_reception", name: "Receptionist", icon: "phone"),
            ]),
            HospitalitySubcategory(id: "hc_med_wellness", name: "Medical Wellness Center", roles: [
                HospitalityRole(id: "hc_mw_front", name: "Front Desk Agent", icon: "person.text.rectangle"),
                HospitalityRole(id: "hc_mw_guest", name: "Guest Services", icon: "person.wave.2"),
                HospitalityRole(id: "hc_mw_hosp_asst", name: "Hospitality Assistant", icon: "person"),
                HospitalityRole(id: "hc_mw_patient", name: "Patient Services Coordinator", icon: "heart.text.square"),
                HospitalityRole(id: "hc_mw_reception", name: "Receptionist", icon: "phone"),
            ]),
            HospitalitySubcategory(id: "hc_recovery", name: "Recovery Center", roles: [
                HospitalityRole(id: "hc_rec_catering", name: "Catering Assistant", icon: "takeoutbag.and.cup.and.straw"),
                HospitalityRole(id: "hc_rec_cleaner", name: "Cleaner", icon: "sparkles"),
                HospitalityRole(id: "hc_rec_guest", name: "Guest Services", icon: "person.wave.2"),
                HospitalityRole(id: "hc_rec_housekeeper", name: "Housekeeper", icon: "bed.double"),
                HospitalityRole(id: "hc_rec_patient", name: "Patient Services Coordinator", icon: "heart.text.square"),
                HospitalityRole(id: "hc_rec_reception", name: "Receptionist", icon: "phone"),
            ]),
        ]),

        // ── Hotels ──
        HospitalityCategory(id: "hotels", name: "Hotels", icon: "building", subcategories: [
            HospitalitySubcategory(id: "htl_boutique", name: "Boutique Hotel", roles: [
                HospitalityRole(id: "htl_bout_concierge", name: "Concierge", icon: "person.wave.2"),
                HospitalityRole(id: "htl_bout_gm", name: "General Manager", icon: "person.badge.key"),
                HospitalityRole(id: "htl_bout_reception", name: "Receptionist", icon: "phone"),
            ]),
            HospitalitySubcategory(id: "htl_business", name: "Business Hotel", roles: [
                HospitalityRole(id: "htl_biz_concierge", name: "Concierge", icon: "person.wave.2"),
                HospitalityRole(id: "htl_biz_front_desk", name: "Front Desk Agent", icon: "person.text.rectangle"),
                HospitalityRole(id: "htl_biz_gm", name: "General Manager", icon: "person.badge.key"),
                HospitalityRole(id: "htl_biz_housekeeper", name: "Housekeeper", icon: "bed.double"),
                HospitalityRole(id: "htl_biz_receptionist", name: "Receptionist", icon: "phone"),
                HospitalityRole(id: "htl_biz_room", name: "Room Attendant", icon: "bed.double"),
            ]),
            HospitalitySubcategory(id: "htl_food", name: "Food & Beverage", roles: [
                HospitalityRole(id: "htl_banquet_chef", name: "Banquet Chef", icon: "flame"),
                HospitalityRole(id: "htl_breakfast_cook", name: "Breakfast Cook", icon: "frying.pan"),
                HospitalityRole(id: "htl_fb_mgr", name: "F&B Manager", icon: "person.badge.key"),
                HospitalityRole(id: "htl_room_service", name: "Room Service Attendant", icon: "tray"),
                HospitalityRole(id: "htl_waiter", name: "Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "htl_front", name: "Front Office", roles: [
                HospitalityRole(id: "htl_bellboy", name: "Bellboy", icon: "suitcase"),
                HospitalityRole(id: "htl_concierge", name: "Concierge", icon: "person.wave.2"),
                HospitalityRole(id: "htl_fo_mgr", name: "Front Office Manager", icon: "person.badge.key"),
                HospitalityRole(id: "htl_night_auditor", name: "Night Auditor", icon: "moon"),
                HospitalityRole(id: "htl_receptionist", name: "Receptionist", icon: "phone"),
            ]),
            HospitalitySubcategory(id: "htl_house", name: "Housekeeping", roles: [
                HospitalityRole(id: "htl_hk_mgr", name: "Housekeeping Manager", icon: "person.badge.key"),
                HospitalityRole(id: "htl_laundry", name: "Laundry Attendant", icon: "washer"),
                HospitalityRole(id: "htl_room_attend", name: "Room Attendant", icon: "bed.double"),
                HospitalityRole(id: "htl_turndown", name: "Turndown Attendant", icon: "bed.double"),
            ]),
            HospitalitySubcategory(id: "htl_luxury", name: "Luxury Hotel", roles: [
                HospitalityRole(id: "htl_lux_bellboy", name: "Bellboy", icon: "suitcase"),
                HospitalityRole(id: "htl_lux_butler", name: "Butler", icon: "person"),
                HospitalityRole(id: "htl_lux_concierge", name: "Concierge", icon: "person.wave.2"),
                HospitalityRole(id: "htl_lux_front_desk", name: "Front Desk Agent", icon: "person.text.rectangle"),
                HospitalityRole(id: "htl_lux_gm", name: "General Manager", icon: "person.badge.key"),
                HospitalityRole(id: "htl_lux_housekeeper", name: "Housekeeper", icon: "bed.double"),
                HospitalityRole(id: "htl_lux_receptionist", name: "Receptionist", icon: "phone"),
                HospitalityRole(id: "htl_lux_room", name: "Room Attendant", icon: "bed.double"),
                HospitalityRole(id: "htl_lux_sommelier", name: "Sommelier", icon: "wineglass.fill"),
                HospitalityRole(id: "htl_lux_waiter", name: "Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "htl_maintenance", name: "Maintenance", roles: [
                HospitalityRole(id: "htl_engineer", name: "Maintenance Engineer", icon: "wrench.and.screwdriver"),
                HospitalityRole(id: "htl_maint_mgr", name: "Maintenance Manager", icon: "person.badge.key"),
                HospitalityRole(id: "htl_pool_tech", name: "Pool Technician", icon: "drop"),
            ]),
            HospitalitySubcategory(id: "htl_serviced", name: "Serviced Apartments", roles: [
                HospitalityRole(id: "htl_sa_front_desk", name: "Front Desk Agent", icon: "person.text.rectangle"),
                HospitalityRole(id: "htl_sa_gm", name: "General Manager", icon: "person.badge.key"),
                HospitalityRole(id: "htl_sa_housekeeper", name: "Housekeeper", icon: "bed.double"),
                HospitalityRole(id: "htl_sa_maintenance", name: "Maintenance Engineer", icon: "wrench.and.screwdriver"),
                HospitalityRole(id: "htl_sa_receptionist", name: "Receptionist", icon: "phone"),
            ]),
        ]),

        // ── Luxury Hospitality ──
        HospitalityCategory(id: "luxury", name: "Luxury Hospitality", icon: "crown", subcategories: [
            HospitalitySubcategory(id: "lux_estate", name: "Private Estate", roles: [
                HospitalityRole(id: "lux_butler", name: "Butler", icon: "person"),
                HospitalityRole(id: "lux_estate_chef", name: "Private Chef", icon: "flame"),
                HospitalityRole(id: "lux_estate_mgr", name: "Estate Manager", icon: "person.badge.key"),
                HospitalityRole(id: "lux_housekeeper", name: "Housekeeper", icon: "bed.double"),
            ]),
            HospitalitySubcategory(id: "lux_palace", name: "Palace Hotel", roles: [
                HospitalityRole(id: "lux_chef_concierge", name: "Chef Concierge", icon: "person.wave.2"),
                HospitalityRole(id: "lux_exec_chef", name: "Executive Chef", icon: "flame"),
                HospitalityRole(id: "lux_gm", name: "General Manager", icon: "person.badge.key"),
                HospitalityRole(id: "lux_sommelier", name: "Head Sommelier", icon: "wineglass.fill"),
                HospitalityRole(id: "lux_valet", name: "Valet", icon: "car"),
            ]),
            HospitalitySubcategory(id: "lux_villa", name: "Luxury Villa", roles: [
                HospitalityRole(id: "lux_villa_butler", name: "Villa Butler", icon: "person"),
                HospitalityRole(id: "lux_villa_chef", name: "Villa Chef", icon: "flame"),
                HospitalityRole(id: "lux_villa_host", name: "Villa Host", icon: "person.wave.2"),
                HospitalityRole(id: "lux_villa_mgr", name: "Villa Manager", icon: "person.badge.key"),
            ]),
        ]),

        // ── Private Dining ──
        HospitalityCategory(id: "private_dining", name: "Private Dining", icon: "fork.knife", subcategories: [
            HospitalitySubcategory(id: "pd_home", name: "Home Dining Experience", roles: [
                HospitalityRole(id: "pd_home_chef", name: "Private Chef", icon: "flame"),
                HospitalityRole(id: "pd_home_server", name: "Private Server", icon: "tray"),
                HospitalityRole(id: "pd_home_somm", name: "Sommelier", icon: "wineglass.fill"),
            ]),
            HospitalitySubcategory(id: "pd_members", name: "Members' Club", roles: [
                HospitalityRole(id: "pd_club_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "pd_club_chef", name: "Club Chef", icon: "flame"),
                HospitalityRole(id: "pd_club_host", name: "Host", icon: "person.wave.2"),
                HospitalityRole(id: "pd_club_mgr", name: "Club Manager", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "pd_supper", name: "Supper Club", roles: [
                HospitalityRole(id: "pd_supper_chef", name: "Chef", icon: "flame"),
                HospitalityRole(id: "pd_supper_host", name: "Host", icon: "person.wave.2"),
                HospitalityRole(id: "pd_supper_server", name: "Server", icon: "tray"),
            ]),
        ]),

        // ── Resorts ──
        HospitalityCategory(id: "resorts", name: "Resorts", icon: "sun.max", subcategories: [
            HospitalitySubcategory(id: "res_allinc", name: "All-Inclusive Resort", roles: [
                HospitalityRole(id: "res_activities", name: "Activities Coordinator", icon: "figure.run"),
                HospitalityRole(id: "res_ai_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "res_ai_chef", name: "Resort Chef", icon: "flame"),
                HospitalityRole(id: "res_ai_waiter", name: "Waiter", icon: "tray"),
                HospitalityRole(id: "res_entertainer", name: "Entertainer", icon: "music.note"),
            ]),
            HospitalitySubcategory(id: "res_beach", name: "Beach Resort", roles: [
                HospitalityRole(id: "res_beach_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "res_beach_concierge", name: "Concierge", icon: "person.wave.2"),
                HospitalityRole(id: "res_beach_gm", name: "General Manager", icon: "person.badge.key"),
                HospitalityRole(id: "res_beach_housekeeper", name: "Housekeeper", icon: "bed.double"),
                HospitalityRole(id: "res_beach_waiter", name: "Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "res_boutique", name: "Boutique Resort", roles: [
                HospitalityRole(id: "res_bout_chef", name: "Chef", icon: "flame"),
                HospitalityRole(id: "res_bout_concierge", name: "Concierge", icon: "person.wave.2"),
                HospitalityRole(id: "res_bout_gm", name: "General Manager", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "res_golf", name: "Golf Resort", roles: [
                HospitalityRole(id: "res_golf_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "res_golf_gm", name: "General Manager", icon: "person.badge.key"),
                HospitalityRole(id: "res_golf_pro", name: "Golf Pro", icon: "figure.golf"),
                HospitalityRole(id: "res_golf_receptionist", name: "Receptionist", icon: "phone"),
                HospitalityRole(id: "res_golf_waiter", name: "Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "res_ski", name: "Ski Resort", roles: [
                HospitalityRole(id: "res_chalet_host", name: "Chalet Host", icon: "house"),
                HospitalityRole(id: "res_ski_chef", name: "Chef", icon: "flame"),
                HospitalityRole(id: "res_ski_instructor", name: "Ski Instructor", icon: "figure.skiing.downhill"),
                HospitalityRole(id: "res_ski_server", name: "Server", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "res_spa", name: "Spa Resort", roles: [
                HospitalityRole(id: "res_spa_gm", name: "General Manager", icon: "person.badge.key"),
                HospitalityRole(id: "res_spa_receptionist", name: "Receptionist", icon: "phone"),
                HospitalityRole(id: "res_spa_therapist", name: "Spa Therapist", icon: "hand.raised"),
                HospitalityRole(id: "res_spa_waiter", name: "Waiter", icon: "tray"),
                HospitalityRole(id: "res_spa_wellness", name: "Wellness Coach", icon: "heart"),
            ]),
        ]),

        // ── Restaurants ──
        HospitalityCategory(id: "restaurants", name: "Restaurants", icon: "fork.knife", subcategories: [
            HospitalitySubcategory(id: "rest_casual", name: "Casual Dining", roles: [
                HospitalityRole(id: "rest_cas_chef", name: "Chef", icon: "flame"),
                HospitalityRole(id: "rest_cas_hostess", name: "Hostess", icon: "person.wave.2"),
                HospitalityRole(id: "rest_cas_line_cook", name: "Line Cook", icon: "frying.pan"),
                HospitalityRole(id: "rest_cas_mgr", name: "Restaurant Manager", icon: "person.badge.key"),
                HospitalityRole(id: "rest_cas_runner", name: "Food Runner", icon: "figure.walk"),
                HospitalityRole(id: "rest_cas_waiter", name: "Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "rest_fast", name: "Fast Casual", roles: [
                HospitalityRole(id: "rest_fc_cashier", name: "Cashier", icon: "creditcard"),
                HospitalityRole(id: "rest_fc_cook", name: "Cook", icon: "frying.pan"),
                HospitalityRole(id: "rest_fc_shift", name: "Shift Manager", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "rest_fine", name: "Fine Dining", roles: [
                HospitalityRole(id: "rest_cdp", name: "Chef de Partie", icon: "flame"),
                HospitalityRole(id: "rest_commis", name: "Commis Chef", icon: "flame"),
                HospitalityRole(id: "rest_exec_chef", name: "Executive Chef", icon: "flame"),
                HospitalityRole(id: "rest_kp", name: "Kitchen Porter", icon: "sink"),
                HospitalityRole(id: "rest_maitre_d", name: "Maitre D'", icon: "person.badge.key"),
                HospitalityRole(id: "rest_sommelier", name: "Sommelier", icon: "wineglass.fill"),
                HospitalityRole(id: "rest_sous_chef", name: "Sous Chef", icon: "flame"),
                HospitalityRole(id: "rest_waiter", name: "Waiter", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "rest_pizzeria", name: "Pizzeria", roles: [
                HospitalityRole(id: "rest_pizza_chef", name: "Pizzaiolo", icon: "flame"),
                HospitalityRole(id: "rest_pizza_helper", name: "Pizza Helper", icon: "frying.pan"),
                HospitalityRole(id: "rest_pizza_server", name: "Server", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "rest_qsr", name: "Quick Service", roles: [
                HospitalityRole(id: "rest_qsr_cashier", name: "Cashier", icon: "creditcard"),
                HospitalityRole(id: "rest_qsr_crew", name: "Crew Member", icon: "person"),
                HospitalityRole(id: "rest_qsr_mgr", name: "Store Manager", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "rest_specialty", name: "Specialty Restaurant", roles: [
                HospitalityRole(id: "rest_sp_chef", name: "Head Chef", icon: "flame"),
                HospitalityRole(id: "rest_sp_hostess", name: "Hostess", icon: "person.wave.2"),
                HospitalityRole(id: "rest_sp_mgr", name: "Restaurant Manager", icon: "person.badge.key"),
                HospitalityRole(id: "rest_sp_sous", name: "Sous Chef", icon: "flame"),
                HospitalityRole(id: "rest_sp_waiter", name: "Waiter", icon: "tray"),
            ]),
        ]),

        // ── Schools & Training ──
        HospitalityCategory(id: "schools", name: "Schools & Training", icon: "graduationcap", subcategories: [
            HospitalitySubcategory(id: "sch_barista", name: "Barista Academy", roles: [
                HospitalityRole(id: "sch_barista_trainer", name: "Barista Trainer", icon: "cup.and.saucer"),
                HospitalityRole(id: "sch_barista_coord", name: "Program Coordinator", icon: "calendar"),
                HospitalityRole(id: "sch_barista_admin", name: "School Administrator", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "sch_bartending", name: "Bartending Academy", roles: [
                HospitalityRole(id: "sch_bart_trainer", name: "Hospitality Trainer", icon: "wineglass"),
                HospitalityRole(id: "sch_bart_coord", name: "Program Coordinator", icon: "calendar"),
                HospitalityRole(id: "sch_bart_admin", name: "School Administrator", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "sch_culinary", name: "Culinary School", roles: [
                HospitalityRole(id: "sch_cul_chef_instr", name: "Chef Instructor", icon: "flame"),
                HospitalityRole(id: "sch_cul_instructor", name: "Culinary Instructor", icon: "frying.pan"),
                HospitalityRole(id: "sch_cul_coord", name: "Program Coordinator", icon: "calendar"),
                HospitalityRole(id: "sch_cul_admin", name: "School Administrator", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "sch_hospitality", name: "Hospitality School", roles: [
                HospitalityRole(id: "sch_hosp_academic", name: "Academic Coordinator", icon: "graduationcap"),
                HospitalityRole(id: "sch_hosp_trainer", name: "Hospitality Trainer", icon: "person.2"),
                HospitalityRole(id: "sch_hosp_ops", name: "Operations Manager", icon: "gearshape"),
                HospitalityRole(id: "sch_hosp_coord", name: "Program Coordinator", icon: "calendar"),
                HospitalityRole(id: "sch_hosp_admin", name: "School Administrator", icon: "person.badge.key"),
                HospitalityRole(id: "sch_hosp_student", name: "Student Services Officer", icon: "person.text.rectangle"),
            ]),
            HospitalitySubcategory(id: "sch_hotel_mgmt", name: "Hotel Management School", roles: [
                HospitalityRole(id: "sch_htl_academic", name: "Academic Coordinator", icon: "graduationcap"),
                HospitalityRole(id: "sch_htl_admissions", name: "Admissions Advisor", icon: "person.badge.plus"),
                HospitalityRole(id: "sch_htl_trainer", name: "Hospitality Trainer", icon: "person.2"),
                HospitalityRole(id: "sch_htl_coord", name: "Program Coordinator", icon: "calendar"),
                HospitalityRole(id: "sch_htl_admin", name: "School Administrator", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "sch_language", name: "Language & Hospitality Training", roles: [
                HospitalityRole(id: "sch_lang_admissions", name: "Admissions Advisor", icon: "person.badge.plus"),
                HospitalityRole(id: "sch_lang_trainer", name: "Hospitality Trainer", icon: "person.2"),
                HospitalityRole(id: "sch_lang_coord", name: "Program Coordinator", icon: "calendar"),
                HospitalityRole(id: "sch_lang_student", name: "Student Services Officer", icon: "person.text.rectangle"),
            ]),
            HospitalitySubcategory(id: "sch_pastry", name: "Pastry & Bakery Academy", roles: [
                HospitalityRole(id: "sch_pas_chef_instr", name: "Chef Instructor", icon: "flame"),
                HospitalityRole(id: "sch_pas_instructor", name: "Culinary Instructor", icon: "birthday.cake"),
                HospitalityRole(id: "sch_pas_coord", name: "Program Coordinator", icon: "calendar"),
                HospitalityRole(id: "sch_pas_admin", name: "School Administrator", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "sch_training", name: "Training Center", roles: [
                HospitalityRole(id: "sch_tc_trainer", name: "Hospitality Trainer", icon: "person.2"),
                HospitalityRole(id: "sch_tc_ops", name: "Operations Manager", icon: "gearshape"),
                HospitalityRole(id: "sch_tc_coord", name: "Program Coordinator", icon: "calendar"),
                HospitalityRole(id: "sch_tc_admin", name: "School Administrator", icon: "person.badge.key"),
            ]),
        ]),

        // ── Spa & Wellness ──
        HospitalityCategory(id: "spa", name: "Spa & Wellness", icon: "leaf", subcategories: [
            HospitalitySubcategory(id: "spa_day", name: "Day Spa", roles: [
                HospitalityRole(id: "spa_beauty", name: "Beauty Therapist", icon: "sparkles"),
                HospitalityRole(id: "spa_massage", name: "Massage Therapist", icon: "hand.raised"),
                HospitalityRole(id: "spa_reception", name: "Spa Receptionist", icon: "phone"),
            ]),
            HospitalitySubcategory(id: "spa_fitness", name: "Fitness & Gym", roles: [
                HospitalityRole(id: "spa_instructor", name: "Fitness Instructor", icon: "figure.run"),
                HospitalityRole(id: "spa_pt", name: "Personal Trainer", icon: "dumbbell"),
                HospitalityRole(id: "spa_yoga", name: "Yoga Instructor", icon: "figure.mind.and.body"),
            ]),
            HospitalitySubcategory(id: "spa_hotel", name: "Hotel Spa", roles: [
                HospitalityRole(id: "spa_attendant", name: "Spa Attendant", icon: "drop"),
                HospitalityRole(id: "spa_mgr", name: "Spa Manager", icon: "person.badge.key"),
                HospitalityRole(id: "spa_therapist", name: "Spa Therapist", icon: "hand.raised"),
            ]),
            HospitalitySubcategory(id: "spa_standalone", name: "Standalone Spa", roles: [
                HospitalityRole(id: "spa_sa_beauty", name: "Beauty Therapist", icon: "sparkles"),
                HospitalityRole(id: "spa_sa_massage", name: "Massage Therapist", icon: "hand.raised"),
                HospitalityRole(id: "spa_sa_mgr", name: "Spa Manager", icon: "person.badge.key"),
                HospitalityRole(id: "spa_sa_receptionist", name: "Receptionist", icon: "phone"),
                HospitalityRole(id: "spa_sa_therapist", name: "Spa Therapist", icon: "hand.raised"),
            ]),
            HospitalitySubcategory(id: "spa_wellness", name: "Wellness Center", roles: [
                HospitalityRole(id: "spa_wc_dietitian", name: "Dietitian", icon: "leaf"),
                HospitalityRole(id: "spa_wc_nutritionist", name: "Nutritionist", icon: "carrot"),
                HospitalityRole(id: "spa_wc_pt", name: "Personal Trainer", icon: "dumbbell"),
                HospitalityRole(id: "spa_wc_receptionist", name: "Receptionist", icon: "phone"),
                HospitalityRole(id: "spa_wc_therapist", name: "Spa Therapist", icon: "hand.raised"),
            ]),
        ]),

        // ── Specialty Kitchens ──
        HospitalityCategory(id: "specialty_kitchens", name: "Specialty Kitchens", icon: "flame", subcategories: [
            HospitalitySubcategory(id: "sk_cloud", name: "Cloud Kitchen", roles: [
                HospitalityRole(id: "sk_cloud_chef", name: "Cloud Kitchen Chef", icon: "flame"),
                HospitalityRole(id: "sk_cloud_mgr", name: "Kitchen Manager", icon: "person.badge.key"),
                HospitalityRole(id: "sk_cloud_packer", name: "Packer", icon: "shippingbox"),
            ]),
            HospitalitySubcategory(id: "sk_commissary", name: "Commissary Kitchen", roles: [
                HospitalityRole(id: "sk_comm_chef", name: "Production Chef", icon: "flame"),
                HospitalityRole(id: "sk_comm_porter", name: "Kitchen Porter", icon: "sink"),
                HospitalityRole(id: "sk_comm_prep", name: "Prep Cook", icon: "frying.pan"),
            ]),
            HospitalitySubcategory(id: "sk_test", name: "Test Kitchen / R&D", roles: [
                HospitalityRole(id: "sk_food_stylist", name: "Food Stylist", icon: "camera"),
                HospitalityRole(id: "sk_rd_chef", name: "R&D Chef", icon: "flask"),
                HospitalityRole(id: "sk_recipe_dev", name: "Recipe Developer", icon: "book"),
            ]),
        ]),

        // ── Support Services ──
        HospitalityCategory(id: "support", name: "Support Services", icon: "wrench.and.screwdriver", subcategories: [
            HospitalitySubcategory(id: "sup_cleaning", name: "Cleaning & Janitorial", roles: [
                HospitalityRole(id: "sup_cleaner", name: "Cleaner", icon: "sparkles"),
                HospitalityRole(id: "sup_janitor", name: "Janitor", icon: "trash"),
                HospitalityRole(id: "sup_supervisor", name: "Cleaning Supervisor", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "sup_fire_safety", name: "Fire Safety", roles: [
                HospitalityRole(id: "sup_fire_marshal", name: "Fire Marshal", icon: "flame.fill"),
                HospitalityRole(id: "sup_fire_officer", name: "Fire Safety Officer", icon: "flame"),
                HospitalityRole(id: "sup_fire_coord", name: "Safety Coordinator", icon: "checkmark.shield"),
            ]),
            HospitalitySubcategory(id: "sup_food_safety", name: "Food Safety", roles: [
                HospitalityRole(id: "sup_fs_manager", name: "Food Safety Manager", icon: "checkmark.shield"),
                HospitalityRole(id: "sup_fs_officer", name: "Food Safety Officer", icon: "leaf"),
                HospitalityRole(id: "sup_fs_haccp", name: "HACCP Officer", icon: "doc.text"),
                HospitalityRole(id: "sup_fs_qc", name: "Quality Control Officer", icon: "checkmark.circle"),
            ]),
            HospitalitySubcategory(id: "sup_health_safety", name: "Health & Safety", roles: [
                HospitalityRole(id: "sup_hs_compliance", name: "Compliance Officer", icon: "checkmark.shield"),
                HospitalityRole(id: "sup_hs_manager", name: "Health & Safety Manager", icon: "person.badge.key"),
                HospitalityRole(id: "sup_hs_officer", name: "Health & Safety Officer", icon: "cross.case"),
                HospitalityRole(id: "sup_hs_hse_coord", name: "HSE Coordinator", icon: "person.2"),
                HospitalityRole(id: "sup_hs_hse_officer", name: "HSE Officer", icon: "shield.checkered"),
                HospitalityRole(id: "sup_hs_risk", name: "Risk Assessor", icon: "exclamationmark.triangle"),
                HospitalityRole(id: "sup_hs_safety_sup", name: "Safety Supervisor", icon: "person.badge.key"),
            ]),
            HospitalitySubcategory(id: "sup_hygiene", name: "Hygiene & Compliance", roles: [
                HospitalityRole(id: "sup_hyg_compliance", name: "Compliance Manager", icon: "checkmark.shield"),
                HospitalityRole(id: "sup_hyg_food_safety", name: "Food Safety Officer", icon: "leaf"),
                HospitalityRole(id: "sup_hyg_haccp", name: "HACCP Coordinator", icon: "doc.text"),
                HospitalityRole(id: "sup_hyg_manager", name: "Hygiene Manager", icon: "person.badge.key"),
                HospitalityRole(id: "sup_hyg_officer", name: "Hygiene Officer", icon: "sparkles"),
                HospitalityRole(id: "sup_hyg_supervisor", name: "Hygiene Supervisor", icon: "person.badge.key"),
                HospitalityRole(id: "sup_hyg_qa", name: "Quality Assurance Officer", icon: "checkmark.circle"),
            ]),
            HospitalitySubcategory(id: "sup_logistics", name: "Logistics & Supply", roles: [
                HospitalityRole(id: "sup_delivery", name: "Delivery Driver", icon: "car"),
                HospitalityRole(id: "sup_purchasing", name: "Purchasing Manager", icon: "cart"),
                HospitalityRole(id: "sup_warehouse", name: "Warehouse Operative", icon: "shippingbox"),
            ]),
            HospitalitySubcategory(id: "sup_pest", name: "Pest Control", roles: [
                HospitalityRole(id: "sup_pest_hygiene", name: "Hygiene Technician", icon: "sparkles"),
                HospitalityRole(id: "sup_pest_coord", name: "Pest Control Coordinator", icon: "person.2"),
                HospitalityRole(id: "sup_pest_supervisor", name: "Pest Control Supervisor", icon: "person.badge.key"),
                HospitalityRole(id: "sup_pest_tech", name: "Pest Control Technician", icon: "wrench.and.screwdriver"),
            ]),
            HospitalitySubcategory(id: "sup_security", name: "Security", roles: [
                HospitalityRole(id: "sup_cctv", name: "CCTV Operator", icon: "video"),
                HospitalityRole(id: "sup_guard", name: "Security Guard", icon: "shield"),
                HospitalityRole(id: "sup_security_mgr", name: "Security Manager", icon: "shield.fill"),
            ]),
        ]),

        // ── Travel Hospitality ──
        HospitalityCategory(id: "travel", name: "Travel Hospitality", icon: "airplane", subcategories: [
            HospitalitySubcategory(id: "trv_airline", name: "Airline Catering", roles: [
                HospitalityRole(id: "trv_airline_chef", name: "Airline Chef", icon: "flame"),
                HospitalityRole(id: "trv_airline_loader", name: "Catering Loader", icon: "shippingbox"),
                HospitalityRole(id: "trv_airline_planner", name: "Menu Planner", icon: "list.bullet"),
            ]),
            HospitalitySubcategory(id: "trv_airport", name: "Airport Lounge", roles: [
                HospitalityRole(id: "trv_airport_bartender", name: "Bartender", icon: "wineglass"),
                HospitalityRole(id: "trv_airport_host", name: "Lounge Host", icon: "person.wave.2"),
                HospitalityRole(id: "trv_airport_server", name: "Server", icon: "tray"),
            ]),
            HospitalitySubcategory(id: "trv_train", name: "Train Dining", roles: [
                HospitalityRole(id: "trv_train_chef", name: "Chef", icon: "flame"),
                HospitalityRole(id: "trv_train_server", name: "Server", icon: "tray"),
                HospitalityRole(id: "trv_train_steward", name: "Steward", icon: "person.wave.2"),
            ]),
        ]),
    ]

    // MARK: - Popularity (UX — surface common choices first)

    /// Most popular main categories shown at the top of the picker
    static let popularCategoryIds: [String] = [
        "restaurants", "hotels", "bars", "cafes", "catering",
        "events", "resorts", "clubs", "delivery", "spa",
    ]

    /// Most popular subcategories per main category (shown first)
    static let popularSubcategoryIds: [String: [String]] = [
        "restaurants": ["rest_fine", "rest_casual", "rest_fast", "rest_qsr", "rest_specialty"],
        "hotels":      ["htl_luxury", "htl_boutique", "htl_business", "htl_serviced"],
        "bars":        ["bar_cocktail", "bar_rooftop", "bar_lounge", "bar_wine", "bar_pub"],
        "cafes":       ["cafe_coffee", "cafe_bakery", "cafe_brunch"],
        "catering":    ["cat_private", "cat_corporate", "cat_wedding", "cat_luxury"],
        "events":      ["evt_wedding", "evt_conference", "evt_gala", "evt_exhibition"],
        "resorts":     ["res_beach", "res_spa", "res_allinc", "res_golf"],
        "clubs":       ["club_night", "club_beach", "club_members"],
        "delivery":    ["del_restaurant", "del_dark", "del_catering"],
        "spa":         ["spa_hotel", "spa_wellness", "spa_standalone"],
    ]

    /// Popular role names — matched by name across all subcategories
    static let popularRoleNames: Set<String> = [
        "Waiter", "Runner", "Hostess", "Receptionist", "Bartender",
        "Barista", "Kitchen Porter", "Commis Chef", "Chef de Partie",
        "Sous Chef", "Head Chef", "Pastry Chef", "Room Attendant",
        "Housekeeper", "Front Desk Agent", "Restaurant Manager",
        "Floor Manager", "General Manager", "Event Waiter",
        "Event Bartender", "Spa Therapist", "Personal Trainer",
        "Nutritionist", "Dietitian", "Delivery Driver", "Delivery Rider",
    ]

    /// Check if a category is popular
    static func isCategoryPopular(_ id: String) -> Bool {
        popularCategoryIds.contains(id)
    }

    /// Returns (popular, other) subcategories for a category
    static func sortedSubcategories(for categoryId: String, from subs: [HospitalitySubcategory]) -> (popular: [HospitalitySubcategory], other: [HospitalitySubcategory]) {
        guard let order = popularSubcategoryIds[categoryId] else { return ([], subs) }
        var popular: [HospitalitySubcategory] = []
        var other: [HospitalitySubcategory] = []
        for sub in subs {
            if order.contains(sub.id) { popular.append(sub) }
            else { other.append(sub) }
        }
        // Sort popular by the defined order
        popular.sort { (order.firstIndex(of: $0.id) ?? .max) < (order.firstIndex(of: $1.id) ?? .max) }
        return (popular, other)
    }

    /// Returns (popular, other) roles for a subcategory
    static func sortedRoles(from roles: [HospitalityRole]) -> (popular: [HospitalityRole], other: [HospitalityRole]) {
        var popular: [HospitalityRole] = []
        var other: [HospitalityRole] = []
        for role in roles {
            if popularRoleNames.contains(role.name) { popular.append(role) }
            else { other.append(role) }
        }
        return (popular, other)
    }

    // MARK: - Lookup Helpers

    static func category(id: String) -> HospitalityCategory? {
        all.first { $0.id == id }
    }

    static func subcategory(id: String) -> HospitalitySubcategory? {
        all.flatMap(\.subcategories).first { $0.id == id }
    }

    static func role(id: String) -> HospitalityRole? {
        all.flatMap(\.subcategories).flatMap(\.roles).first { $0.id == id }
    }

    /// Display path: "Restaurants > Fine Dining > Sous Chef"
    static func displayPath(categoryId: String?, subcategoryId: String?, roleId: String?) -> String {
        var parts: [String] = []
        if let cid = categoryId, let c = category(id: cid) { parts.append(c.name) }
        if let sid = subcategoryId, let s = subcategory(id: sid) { parts.append(s.name) }
        if let rid = roleId, let r = role(id: rid) { parts.append(r.name) }
        return parts.joined(separator: " > ")
    }

    // MARK: - Search

    /// Searches across all 3 levels. Returns matching (category, subcategory?, role?) tuples.
    static func search(_ query: String) -> [SearchResult] {
        guard !query.isEmpty else { return [] }
        let q = query.lowercased()
        var results: [SearchResult] = []

        for cat in all {
            let catMatch = cat.name.lowercased().contains(q)
            for sub in cat.subcategories {
                let subMatch = sub.name.lowercased().contains(q)
                for role in sub.roles {
                    if role.name.lowercased().contains(q) || subMatch || catMatch {
                        results.append(SearchResult(category: cat, subcategory: sub, role: role))
                    }
                }
            }
        }
        return results.sorted { $0.role.name < $1.role.name }
    }

    struct SearchResult: Identifiable {
        let category: HospitalityCategory
        let subcategory: HospitalitySubcategory
        let role: HospitalityRole
        var id: String { role.id }
    }

    // MARK: - Smart Search (multi-level results)

    enum SmartResultKind { case category, subcategory, role }

    struct SmartSearchResult: Identifiable {
        let id: String
        let name: String
        let icon: String
        let kind: SmartResultKind
        let category: HospitalityCategory
        let subcategory: HospitalitySubcategory?
        let role: HospitalityRole?

        var kindLabel: String {
            switch kind {
            case .category:    return "Category"
            case .subcategory: return "Subcategory"
            case .role:        return "Role"
            }
        }

        var breadcrumb: String {
            switch kind {
            case .category:    return "\(category.subcategories.count) subcategories"
            case .subcategory: return category.name
            case .role:        return "\(category.name) → \(subcategory?.name ?? "")"
            }
        }
    }

    /// Searches across all 3 levels, returning typed results (category, subcategory, role).
    /// Categories and subcategories are deduplicated; roles are listed individually.
    static func smartSearch(_ query: String) -> [SmartSearchResult] {
        guard !query.isEmpty else { return [] }
        let q = query.lowercased()
        var results: [SmartSearchResult] = []
        var seenCats = Set<String>()
        var seenSubs = Set<String>()
        var seenRoleNames = Set<String>()

        // First pass: collect popular-category roles preferentially
        let popCatSet = Set(popularCategoryIds)
        let sortedCats = all.sorted { popCatSet.contains($0.id) && !popCatSet.contains($1.id) }

        for cat in sortedCats {
            // Category match
            if cat.name.lowercased().contains(q), !seenCats.contains(cat.id) {
                seenCats.insert(cat.id)
                results.append(SmartSearchResult(id: "cat_\(cat.id)", name: cat.name, icon: cat.icon, kind: .category, category: cat, subcategory: nil, role: nil))
            }
            for sub in cat.subcategories {
                // Subcategory match
                if sub.name.lowercased().contains(q), !seenSubs.contains(sub.id) {
                    seenSubs.insert(sub.id)
                    results.append(SmartSearchResult(id: "sub_\(sub.id)", name: sub.name, icon: cat.icon, kind: .subcategory, category: cat, subcategory: sub, role: nil))
                }
                // Role match — deduplicate by name, keep the first (popular category) occurrence
                for role in sub.roles {
                    if role.name.lowercased().contains(q), !seenRoleNames.contains(role.name) {
                        seenRoleNames.insert(role.name)
                        results.append(SmartSearchResult(id: "role_\(role.id)", name: role.name, icon: role.icon, kind: .role, category: cat, subcategory: sub, role: role))
                    }
                }
            }
        }

        // Sort: prefix matches first, then popular items, then rest — within each tier, by type then alpha
        let popCats = Set(popularCategoryIds)
        return results.sorted { a, b in
            let aPrefix = a.name.lowercased().hasPrefix(q)
            let bPrefix = b.name.lowercased().hasPrefix(q)
            if aPrefix != bPrefix { return aPrefix }

            let aPop = isPopular(a, popCats: popCats)
            let bPop = isPopular(b, popCats: popCats)
            if aPop != bPop { return aPop }

            if a.kind != b.kind { return a.kind.sortOrder < b.kind.sortOrder }
            return a.name < b.name
        }
    }

    private static func isPopular(_ r: SmartSearchResult, popCats: Set<String>) -> Bool {
        switch r.kind {
        case .category:    return popCats.contains(r.category.id)
        case .subcategory: return popularSubcategoryIds[r.category.id]?.contains(r.subcategory?.id ?? "") ?? false
        case .role:        return popularRoleNames.contains(r.name)
        }
    }
}

private extension HospitalityCatalog.SmartResultKind {
    var sortOrder: Int {
        switch self {
        case .category: return 0
        case .subcategory: return 1
        case .role: return 2
        }
    }
}
