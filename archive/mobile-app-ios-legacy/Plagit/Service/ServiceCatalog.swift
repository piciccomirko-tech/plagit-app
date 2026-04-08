//
//  ServiceCatalog.swift
//  Plagit
//
//  Service categories for the Find Services marketplace flow.
//  2-level structure: Category → Subcategories
//  Scalable: add new entries — no UI rewrite needed.
//

import Foundation

// MARK: - Data Models

struct ServiceCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let keywords: [String]
    let subcategories: [ServiceSubcategory]
}

struct ServiceSubcategory: Identifiable, Hashable {
    let id: String
    let name: String
}

struct ServiceCompany: Identifiable {
    let id: String
    let name: String
    let categoryId: String
    let subcategoryId: String
    let location: String
    let description: String
    let isVerified: Bool
    let isPremium: Bool
    let isAvailable: Bool
    let avatarHue: Double
    let rating: Double?
    let reviewCount: Int
    let latitude: Double?
    let longitude: Double?

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 { return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased() }
        return String(name.prefix(2)).uppercased()
    }

    /// Resolved subcategory display name
    var subcategoryName: String {
        ServiceCatalog.subcategory(id: subcategoryId)?.name ?? subcategoryId
    }

    /// Resolved category display name
    var categoryName: String {
        ServiceCatalog.category(id: categoryId)?.name ?? categoryId
    }
}

// MARK: - Catalog

enum ServiceCatalog {

    // MARK: - Full Catalog (alphabetically sorted)

    static let all: [ServiceCategory] = [

        ServiceCategory(id: "svc_catering", name: "Catering", icon: "takeoutbag.and.cup.and.straw", keywords: ["food", "catering", "chef", "meals"], subcategories: [
            ServiceSubcategory(id: "cat_corporate", name: "Corporate Catering"),
            ServiceSubcategory(id: "cat_event", name: "Event Catering"),
            ServiceSubcategory(id: "cat_luxury", name: "Luxury Catering"),
            ServiceSubcategory(id: "cat_private", name: "Private Catering"),
            ServiceSubcategory(id: "cat_wedding", name: "Wedding Catering"),
        ]),

        ServiceCategory(id: "svc_cleaning", name: "Cleaning Services", icon: "sparkles", keywords: ["clean", "janitorial", "housekeeping", "sanitation"], subcategories: [
            ServiceSubcategory(id: "cln_deep", name: "Deep Cleaning"),
            ServiceSubcategory(id: "cln_event", name: "Event Cleaning"),
            ServiceSubcategory(id: "cln_hotel", name: "Hotel Cleaning"),
            ServiceSubcategory(id: "cln_kitchen", name: "Kitchen Cleaning"),
            ServiceSubcategory(id: "cln_post_event", name: "Post-Event Cleaning"),
            ServiceSubcategory(id: "cln_restaurant", name: "Restaurant Cleaning"),
        ]),

        ServiceCategory(id: "svc_entertainment", name: "Entertainment", icon: "music.note", keywords: ["dj", "music", "band", "performer", "singer", "dancer", "entertainment"], subcategories: [
            ServiceSubcategory(id: "ent_dancers", name: "Dancers"),
            ServiceSubcategory(id: "ent_dj", name: "DJ"),
            ServiceSubcategory(id: "ent_kids", name: "Kids Entertainment"),
            ServiceSubcategory(id: "ent_bands", name: "Live Bands"),
            ServiceSubcategory(id: "ent_singers", name: "Live Singers"),
            ServiceSubcategory(id: "ent_mc", name: "MC / Host"),
            ServiceSubcategory(id: "ent_musicians", name: "Musicians"),
            ServiceSubcategory(id: "ent_performers", name: "Performers"),
        ]),

        ServiceCategory(id: "svc_floral", name: "Florists & Decoration", icon: "leaf.fill", keywords: ["flowers", "floral", "bouquet", "florist", "decor", "decoration", "styling"], subcategories: [
            ServiceSubcategory(id: "fld_balloon", name: "Balloon Decoration"),
            ServiceSubcategory(id: "fld_event", name: "Event Decoration"),
            ServiceSubcategory(id: "fld_floral", name: "Floral Design"),
            ServiceSubcategory(id: "fld_table", name: "Table Styling"),
            ServiceSubcategory(id: "fld_venue", name: "Venue Styling"),
            ServiceSubcategory(id: "fld_wedding", name: "Wedding Decoration"),
        ]),

        ServiceCategory(id: "svc_furniture", name: "Furniture & Event Hire", icon: "chair", keywords: ["hire", "rental", "furniture", "equipment", "event"], subcategories: [
            ServiceSubcategory(id: "fur_chairs", name: "Chair Hire"),
            ServiceSubcategory(id: "fur_cutlery", name: "Cutlery Hire"),
            ServiceSubcategory(id: "fur_glass", name: "Glassware Hire"),
            ServiceSubcategory(id: "fur_linen", name: "Linen Hire"),
            ServiceSubcategory(id: "fur_tables", name: "Table Hire"),
            ServiceSubcategory(id: "fur_kitchen", name: "Temporary Kitchen Equipment Hire"),
        ]),

        ServiceCategory(id: "svc_health", name: "Health & Safety", icon: "cross.case", keywords: ["safety", "compliance", "health", "hse", "risk", "haccp", "fire"], subcategories: [
            ServiceSubcategory(id: "hs_fire", name: "Fire Safety"),
            ServiceSubcategory(id: "hs_food", name: "Food Safety"),
            ServiceSubcategory(id: "hs_haccp", name: "HACCP Support"),
            ServiceSubcategory(id: "hs_audits", name: "Health & Safety Audits"),
            ServiceSubcategory(id: "hs_risk", name: "Risk Assessment"),
            ServiceSubcategory(id: "hs_training", name: "Staff Training"),
        ]),

        ServiceCategory(id: "svc_laundry", name: "Laundry & Linen", icon: "washer", keywords: ["laundry", "linen", "towel", "uniform", "wash"], subcategories: [
            ServiceSubcategory(id: "lnd_commercial", name: "Commercial Laundry"),
            ServiceSubcategory(id: "lnd_rental", name: "Linen Rental"),
            ServiceSubcategory(id: "lnd_uniform", name: "Staff Uniform Laundry"),
            ServiceSubcategory(id: "lnd_table", name: "Table Linen Service"),
            ServiceSubcategory(id: "lnd_towel", name: "Towel Supply"),
        ]),

        ServiceCategory(id: "svc_logistics", name: "Logistics & Delivery", icon: "shippingbox", keywords: ["delivery", "logistics", "transport", "courier", "setup"], subcategories: [
            ServiceSubcategory(id: "log_catering", name: "Catering Delivery"),
            ServiceSubcategory(id: "log_cold", name: "Cold Chain Delivery"),
            ServiceSubcategory(id: "log_equipment", name: "Equipment Delivery"),
            ServiceSubcategory(id: "log_event", name: "Event Logistics"),
            ServiceSubcategory(id: "log_lastmile", name: "Last Mile Delivery"),
            ServiceSubcategory(id: "log_setup", name: "Setup Transport"),
        ]),

        ServiceCategory(id: "svc_maintenance", name: "Maintenance", icon: "wrench.and.screwdriver", keywords: ["repair", "maintenance", "plumbing", "electrical", "hvac"], subcategories: [
            ServiceSubcategory(id: "mnt_hvac", name: "AC / HVAC"),
            ServiceSubcategory(id: "mnt_electrical", name: "Electrical"),
            ServiceSubcategory(id: "mnt_general", name: "General Repairs"),
            ServiceSubcategory(id: "mnt_kitchen", name: "Kitchen Equipment Maintenance"),
            ServiceSubcategory(id: "mnt_plumbing", name: "Plumbing"),
            ServiceSubcategory(id: "mnt_refrigeration", name: "Refrigeration"),
        ]),

        ServiceCategory(id: "svc_marketing", name: "Marketing & Media", icon: "megaphone", keywords: ["marketing", "branding", "social", "website", "design", "ads", "media"], subcategories: [
            ServiceSubcategory(id: "mkt_branding", name: "Branding"),
            ServiceSubcategory(id: "mkt_social", name: "Hospitality Social Media"),
            ServiceSubcategory(id: "mkt_menu", name: "Menu Design"),
            ServiceSubcategory(id: "mkt_ads", name: "Paid Ads"),
            ServiceSubcategory(id: "mkt_video", name: "Promo Video"),
            ServiceSubcategory(id: "mkt_web", name: "Website Design"),
        ]),

        ServiceCategory(id: "svc_pest", name: "Pest Control", icon: "ant", keywords: ["pest", "exterminator", "fumigation"], subcategories: [
            ServiceSubcategory(id: "pst_emergency", name: "Emergency Pest Control"),
            ServiceSubcategory(id: "pst_kitchen", name: "Kitchen Pest Control"),
            ServiceSubcategory(id: "pst_preventive", name: "Preventive Pest Control"),
            ServiceSubcategory(id: "pst_resort", name: "Resort Pest Control"),
            ServiceSubcategory(id: "pst_restaurant", name: "Restaurant Pest Control"),
        ]),

        ServiceCategory(id: "svc_photo", name: "Photography & Videography", icon: "camera", keywords: ["photo", "video", "photographer", "videographer", "photography", "content"], subcategories: [
            ServiceSubcategory(id: "pho_event", name: "Event Photographer"),
            ServiceSubcategory(id: "pho_food", name: "Food Photographer"),
            ServiceSubcategory(id: "pho_content", name: "Hospitality Content Creator"),
            ServiceSubcategory(id: "pho_videographer", name: "Videographer"),
            ServiceSubcategory(id: "pho_wedding", name: "Wedding Photographer"),
            ServiceSubcategory(id: "pho_wed_video", name: "Wedding Videographer"),
        ]),

        ServiceCategory(id: "svc_security", name: "Security Services", icon: "shield.fill", keywords: ["security", "guard", "cctv", "door", "vip"], subcategories: [
            ServiceSubcategory(id: "sec_cctv", name: "CCTV Monitoring"),
            ServiceSubcategory(id: "sec_door", name: "Door Supervisors"),
            ServiceSubcategory(id: "sec_event", name: "Event Security"),
            ServiceSubcategory(id: "sec_hotel", name: "Hotel Security"),
            ServiceSubcategory(id: "sec_vip", name: "VIP Security"),
        ]),

        ServiceCategory(id: "svc_staffing", name: "Staffing Agencies", icon: "person.2", keywords: ["agency", "staffing", "temp", "recruitment"], subcategories: [
            ServiceSubcategory(id: "stf_bar", name: "Bar Staff Agency"),
            ServiceSubcategory(id: "stf_chef", name: "Chef Agency"),
            ServiceSubcategory(id: "stf_event", name: "Event Staff Agency"),
            ServiceSubcategory(id: "stf_hostess", name: "Hostess Agency"),
            ServiceSubcategory(id: "stf_temp", name: "Temporary Staff Agency"),
            ServiceSubcategory(id: "stf_waiter", name: "Waiter Agency"),
        ]),

        ServiceCategory(id: "svc_suppliers", name: "Suppliers", icon: "cart", keywords: ["food", "supplier", "produce", "wholesale", "ingredients", "beverage", "packaging"], subcategories: [
            ServiceSubcategory(id: "sup_beverage", name: "Beverage Suppliers"),
            ServiceSubcategory(id: "sup_food", name: "Food Suppliers"),
            ServiceSubcategory(id: "sup_fresh", name: "Fresh Produce"),
            ServiceSubcategory(id: "sup_frozen", name: "Frozen Food"),
            ServiceSubcategory(id: "sup_meat", name: "Meat & Seafood"),
            ServiceSubcategory(id: "sup_packaging", name: "Packaging Suppliers"),
            ServiceSubcategory(id: "sup_tableware", name: "Tableware Suppliers"),
        ]),

        ServiceCategory(id: "svc_tech", name: "Technology & Systems", icon: "desktopcomputer", keywords: ["pos", "booking", "system", "tech", "wifi", "cctv", "qr", "reservation"], subcategories: [
            ServiceSubcategory(id: "tec_booking", name: "Booking Systems"),
            ServiceSubcategory(id: "tec_cctv", name: "CCTV Systems"),
            ServiceSubcategory(id: "tec_pos", name: "POS Systems"),
            ServiceSubcategory(id: "tec_qr", name: "QR Menu Solutions"),
            ServiceSubcategory(id: "tec_reservation", name: "Reservation Systems"),
            ServiceSubcategory(id: "tec_wifi", name: "WiFi / Network Setup"),
        ]),

        ServiceCategory(id: "svc_training", name: "Training Providers", icon: "graduationcap", keywords: ["training", "course", "certification", "academy"], subcategories: [
            ServiceSubcategory(id: "trn_barista", name: "Barista Training"),
            ServiceSubcategory(id: "trn_bartending", name: "Bartending Training"),
            ServiceSubcategory(id: "trn_culinary", name: "Culinary Training"),
            ServiceSubcategory(id: "trn_food_safety", name: "Food Safety Training"),
            ServiceSubcategory(id: "trn_hospitality", name: "Hospitality Training"),
            ServiceSubcategory(id: "trn_language", name: "Language Training"),
        ]),

        ServiceCategory(id: "svc_uniforms", name: "Uniforms & Printing", icon: "tshirt", keywords: ["uniform", "clothing", "workwear", "apparel", "print", "embroidery", "signage"], subcategories: [
            ServiceSubcategory(id: "uni_printing", name: "Branded Printing"),
            ServiceSubcategory(id: "uni_custom", name: "Custom Uniforms"),
            ServiceSubcategory(id: "uni_embroidery", name: "Embroidery"),
            ServiceSubcategory(id: "uni_menu", name: "Menu Printing"),
            ServiceSubcategory(id: "uni_signage", name: "Signage"),
            ServiceSubcategory(id: "uni_staff", name: "Staff Uniform Suppliers"),
        ]),
    ]

    // MARK: - Lookup

    static func category(id: String) -> ServiceCategory? {
        all.first { $0.id == id }
    }

    static func subcategory(id: String) -> ServiceSubcategory? {
        all.flatMap(\.subcategories).first { $0.id == id }
    }

    /// Parent category for a subcategory
    static func parentCategory(forSubcategory subId: String) -> ServiceCategory? {
        all.first { $0.subcategories.contains { $0.id == subId } }
    }

    // MARK: - Search

    /// Search categories by name, keywords, or subcategory names
    static func searchCategories(_ query: String) -> [ServiceCategory] {
        guard !query.isEmpty else { return all }
        let q = query.lowercased()
        return all.filter { cat in
            cat.name.lowercased().contains(q)
            || cat.keywords.contains { $0.contains(q) }
            || cat.subcategories.contains { $0.name.lowercased().contains(q) }
        }
    }

    /// Filter companies
    static func searchCompanies(
        query: String,
        categoryId: String?,
        subcategoryId: String? = nil,
        verifiedOnly: Bool = false,
        premiumOnly: Bool = false,
        availableOnly: Bool = false
    ) -> [ServiceCompany] {
        var results: [ServiceCompany] = []
        if let catId = categoryId, !catId.isEmpty {
            results = results.filter { $0.categoryId == catId }
        }
        if let subId = subcategoryId, !subId.isEmpty {
            results = results.filter { $0.subcategoryId == subId }
        }
        if verifiedOnly { results = results.filter { $0.isVerified } }
        if premiumOnly { results = results.filter { $0.isPremium } }
        if availableOnly { results = results.filter { $0.isAvailable } }
        if !query.isEmpty {
            let q = query.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(q)
                || $0.subcategoryName.lowercased().contains(q)
                || $0.categoryName.lowercased().contains(q)
                || $0.description.lowercased().contains(q)
                || $0.location.lowercased().contains(q)
            }
        }
        return results.sorted { ($0.isPremium ? 0 : 1) < ($1.isPremium ? 0 : 1) }
    }

}
