import '../../models/country_code.dart';
import '../../models/dropdown_item.dart';
import '../../models/gender.dart';

class Data {
  static final Data _instance = Data._();

  factory Data() {
    return _instance;
  }

  Data._();

  static List<Gender> get genders => [
        Gender(id: "Male", name: "Male"),
        Gender(id: "Female", name: "Female"),
        Gender(id: "Other", name: "Other"),
      ];

  /*static List<Position> get positions => [
        Position(id: "63ea4ee911aef3765b25190d", name: "Manager", logo: MyAssets.manager),
        Position(id: "63eb91bfb306c20a75248a0a", name: "Barista", logo: MyAssets.barista),
        Position(id: "63ea4f5611aef3765b251917", name: "Chef", logo: MyAssets.chef),
        Position(id: "63ec995ecd1d636c8208f1c2", name: "Chef De Partie", logo: MyAssets.chefDePartie),
        Position(id: "63edf848cd1d636c8208f3ad", name: "Commis chef", logo: MyAssets.commisChef),
        Position(id: "63edf873cd1d636c8208f3b1", name: "Commis pizza chef", logo: MyAssets.commisPizzaChef),
        Position(id: "63edf888cd1d636c8208f3b5", name: "Commis waiter", logo: MyAssets.commisWaiter),
        Position(id: "63edf898cd1d636c8208f3b9", name: "Food runner", logo: MyAssets.foodRunner),
        Position(id: "63edf8a9cd1d636c8208f3bd", name: "Kp", logo: MyAssets.kitchenPorter),
        Position(id: "63edf8b8cd1d636c8208f3c1", name: "Pizza chef", logo: MyAssets.pizzaChef),
        Position(id: "63edf8cacd1d636c8208f3c5", name: "Room made", logo: MyAssets.roomMaid),
        Position(id: "63edf8d7cd1d636c8208f3c9", name: "Runner", logo: MyAssets.runner),
        Position(id: "63edf8e1cd1d636c8208f3cd", name: "Security", logo: MyAssets.security),
        Position(id: "63edf8f1cd1d636c8208f3d1", name: "Toilet assistant", logo: MyAssets.toiletAssistant),
        Position(id: "63edf8ffcd1d636c8208f3d5", name: "Waiter", logo: MyAssets.waiter),
        Position(id: "63edf90ccd1d636c8208f3d9", name: "Bartender", logo: MyAssets.bartender),
        Position(id: "63edf91acd1d636c8208f3dd", name: "Bar back", logo: MyAssets.barBack),
        Position(id: "63edf928cd1d636c8208f3e1", name: "Mixologist", logo: MyAssets.mixologist),
        Position(id: "64ad577f71001ecc2f6eab31", name: "Pastry Chef", logo: MyAssets.pastryChef),
        Position(id: "64b019e971001ecc2f6f292e", name: "Receptionist", logo: MyAssets.receptionist),
        Position(id: "64b569d6c04b3b501b00bbfd", name: "Sous Chef", logo: MyAssets.sousChef),
        Position(id: "64b65cb0784a99a8fb8844f7", name: "Assistant Manager", logo: MyAssets.assistantManager),
      ];*/

  static List<DropdownItem> get skills => [
        DropdownItem(id: "Manager", name: "Manager"),
        DropdownItem(id: "Barista", name: "Barista"),
        DropdownItem(id: "Chef", name: "Chef"),
        DropdownItem(id: "Chef_de_partie", name: "Chef De Partie"),
        DropdownItem(id: "Commis_chef", name: "Commis chef"),
        DropdownItem(id: "Commis_pizza_chef", name: "Commis pizza chef"),
        DropdownItem(id: "Commis_waiter", name: "Commis waiter"),
        DropdownItem(id: "Food_runner", name: "Food runner"),
        DropdownItem(id: "Kp", name: "Kp"),
        DropdownItem(id: "Pizza_chef", name: "Pizza chef"),
        DropdownItem(id: "Room_maid", name: "Room maid"),
        DropdownItem(id: "Runner", name: "Runner"),
        DropdownItem(id: "Security", name: "Security"),
        DropdownItem(id: "Toilet_assistant", name: "Toilet assistant"),
        DropdownItem(id: "Waiter", name: "Waiter"),
        DropdownItem(id: "Bartender", name: "Bartender"),
        DropdownItem(id: "Bar_back", name: "Bar back"),
        DropdownItem(id: "Mixologist", name: "Mixologist"),
      ];

  static final List<Map<String, String>> _countryPickerItemList = [
    {
      "name": "Afghanistan",
      "dial_code": "+93",
      "code": "AF",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Aland Islands",
      "dial_code": "+358",
      "code": "AX",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Albania",
      "dial_code": "+355",
      "code": "AL",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Algeria",
      "dial_code": "+213",
      "code": "DZ",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "AmericanSamoa",
      "dial_code": "+1684",
      "code": "AS",
      "postCodeRegex": "^\\d{5}(-{1}\\d{4,6})\$"
    },
    {
      "name": "Andorra",
      "dial_code": "+376",
      "code": "AD",
      "postCodeRegex": "^[Aa][Dd]\\d{3}\$"
    },
    {"name": "Angola", "dial_code": "+244", "code": "AO", "postCodeRegex": ""},
    {
      "name": "Anguilla",
      "dial_code": "+1264",
      "code": "AI",
      "postCodeRegex": "^[Aa][I][-][2][6][4][0]\$"
    },
    {
      "name": "Antigua and Barbuda",
      "dial_code": "+1268",
      "code": "AG",
      "postCodeRegex": ""
    },
    {
      "name": "Argentina",
      "dial_code": "+54",
      "code": "AR",
      "postCodeRegex": "^\\d{4}|[A-Za-z]\\d{4}[a-zA-Z]{3}\$"
    },
    {
      "name": "Armenia",
      "dial_code": "+374",
      "code": "AM",
      "postCodeRegex": "^\\d{4}\$"
    },
    {"name": "Aruba", "dial_code": "+297", "code": "AW", "postCodeRegex": ""},
    {
      "name": "Australia",
      "dial_code": "+61",
      "code": "AU",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Austria",
      "dial_code": "+43",
      "code": "AT",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Azerbaijan",
      "dial_code": "+994",
      "code": "AZ",
      "postCodeRegex": "^[Aa][Zz]\\d{4}\$"
    },
    {
      "name": "Bahamas",
      "dial_code": "+1242",
      "code": "BS",
      "postCodeRegex": ""
    },
    {
      "name": "Bahrain",
      "dial_code": "+973",
      "code": "BH",
      "postCodeRegex": "^\\d{3,4}\$"
    },
    {
      "name": "Bangladesh",
      "dial_code": "+88",
      "code": "BD",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Barbados",
      "dial_code": "+1246",
      "code": "BB",
      "postCodeRegex": "^[Aa][Zz]\\d{5}\$"
    },
    {
      "name": "Belarus",
      "dial_code": "+375",
      "code": "BY",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Belgium",
      "dial_code": "+32",
      "code": "BE",
      "postCodeRegex": "^\\d{4}\$"
    },
    {"name": "Belize", "dial_code": "+501", "code": "BZ", "postCodeRegex": ""},
    {"name": "Benin", "dial_code": "+229", "code": "BJ", "postCodeRegex": ""},
    {
      "name": "Bermuda",
      "dial_code": "+1441",
      "code": "BM",
      "postCodeRegex": "^[A-Za-z]{2}\\s([A-Za-z]{2}|\\d{2})\$"
    },
    {
      "name": "Bhutan",
      "dial_code": "+975",
      "code": "BT",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Bolivia, Plurinational State of",
      "dial_code": "+591",
      "code": "BO",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Bosnia and Herzegovina",
      "dial_code": "+387",
      "code": "BA",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Botswana",
      "dial_code": "+267",
      "code": "BW",
      "postCodeRegex": ""
    },
    {
      "name": "Brazil",
      "dial_code": "+55",
      "code": "BR",
      "postCodeRegex": "^\\d{5}-\\d{3}\$"
    },
    {
      "name": "British Indian Ocean Territory",
      "dial_code": "+246",
      "code": "IO",
      "postCodeRegex": "^[Bb]{2}[Nn][Dd]\\s{0,1}[1][Zz]{2}\$"
    },
    {
      "name": "Brunei Darussalam",
      "dial_code": "+673",
      "code": "BN",
      "postCodeRegex": "^[A-Za-z]{2}\\d{4}\$"
    },
    {
      "name": "Bulgaria",
      "dial_code": "+359",
      "code": "BG",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Burkina Faso",
      "dial_code": "+226",
      "code": "BF",
      "postCodeRegex": ""
    },
    {"name": "Burundi", "dial_code": "+257", "code": "BI", "postCodeRegex": ""},
    {
      "name": "Cambodia",
      "dial_code": "+855",
      "code": "KH",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Cameroon",
      "dial_code": "+237",
      "code": "CM",
      "postCodeRegex": ""
    },
    {
      "name": "Canada",
      "dial_code": "+1",
      "code": "CA",
      "postCodeRegex":
      "^(?=[^DdFfIiOoQqUu\\d\\s])[A-Za-z]\\d(?=[^DdFfIiOoQqUu\\d\\s])[A-Za-z]\\s{0,1}\\d(?=[^DdFfIiOoQqUu\\d\\s])[A-Za-z]\\d\$"
    },
    {
      "name": "Cape Verde",
      "dial_code": "+238",
      "code": "CV",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Cayman Islands",
      "dial_code": "+ 345",
      "code": "KY",
      "postCodeRegex": "^[Kk][Yy]\\d[-\\s]{0,1}\\d{4}\$"
    },
    {
      "name": "Central African Republic",
      "dial_code": "+236",
      "code": "CF",
      "postCodeRegex": ""
    },
    {
      "name": "Chad",
      "dial_code": "+235",
      "code": "TD",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Chile",
      "dial_code": "+56",
      "code": "CL",
      "postCodeRegex": "^\\d{7}\\s\\(\\d{3}-\\d{4}\\)\$"
    },
    {
      "name": "China",
      "dial_code": "+86",
      "code": "CN",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Christmas Island",
      "dial_code": "+61",
      "code": "CX",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Cocos (Keeling) Islands",
      "dial_code": "+61",
      "code": "CC",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Colombia",
      "dial_code": "+57",
      "code": "CO",
      "postCodeRegex": "^\\d{6}\$"
    },
    {"name": "Comoros", "dial_code": "+269", "code": "KM", "postCodeRegex": ""},
    {"name": "Congo", "dial_code": "+242", "code": "CG", "postCodeRegex": ""},
    {
      "name": "Congo, The Democratic Republic of the Congo",
      "dial_code": "+243",
      "code": "CD",
      "postCodeRegex": "^[Cc][Dd]\$"
    },
    {
      "name": "Cook Islands",
      "dial_code": "+682",
      "code": "CK",
      "postCodeRegex": ""
    },
    {
      "name": "Costa Rica",
      "dial_code": "+506",
      "code": "CR",
      "postCodeRegex": "^\\d{4,5}\$"
    },
    {
      "name": "Cote d'Ivoire",
      "dial_code": "+225",
      "code": "CI",
      "postCodeRegex": ""
    },
    {
      "name": "Croatia",
      "dial_code": "+385",
      "code": "HR",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Cuba",
      "dial_code": "+53",
      "code": "CU",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Cyprus",
      "dial_code": "+357",
      "code": "CY",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Czech Republic",
      "dial_code": "+420",
      "code": "CZ",
      "postCodeRegex": "^\\d{5}\\s\\(\\d{3}\\s\\d{2}\\)\$"
    },
    {
      "name": "Denmark",
      "dial_code": "+45",
      "code": "DK",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Djibouti",
      "dial_code": "+253",
      "code": "DJ",
      "postCodeRegex": ""
    },
    {
      "name": "Dominica",
      "dial_code": "+1767",
      "code": "DM",
      "postCodeRegex": ""
    },
    {
      "name": "Dominican Republic",
      "dial_code": "+1849",
      "code": "DO",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Ecuador",
      "dial_code": "+593",
      "code": "EC",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Egypt",
      "dial_code": "+20",
      "code": "EG",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "El Salvador",
      "dial_code": "+503",
      "code": "SV",
      "postCodeRegex": "^1101\$"
    },
    {
      "name": "Equatorial Guinea",
      "dial_code": "+240",
      "code": "GQ",
      "postCodeRegex": ""
    },
    {"name": "Eritrea", "dial_code": "+291", "code": "ER", "postCodeRegex": ""},
    {
      "name": "Estonia",
      "dial_code": "+372",
      "code": "EE",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Ethiopia",
      "dial_code": "+251",
      "code": "ET",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Falkland Islands (Malvinas)",
      "dial_code": "+500",
      "code": "FK",
      "postCodeRegex": "^[Ff][Ii][Qq]{2}\\s{0,1}[1][Zz]{2}\$"
    },
    {
      "name": "Faroe Islands",
      "dial_code": "+298",
      "code": "FO",
      "postCodeRegex": "^\\d{3}\$"
    },
    {"name": "Fiji", "dial_code": "+679", "code": "FJ", "postCodeRegex": ""},
    {
      "name": "Finland",
      "dial_code": "+358",
      "code": "FI",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "France",
      "dial_code": "+33",
      "code": "FR",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "French Guiana",
      "dial_code": "+594",
      "code": "GF",
      "postCodeRegex": "^973\\d{2}\$"
    },
    {
      "name": "French Polynesia",
      "dial_code": "+689",
      "code": "PF",
      "postCodeRegex": "^987\\d{2}\$"
    },
    {
      "name": "Gabon",
      "dial_code": "+241",
      "code": "GA",
      "postCodeRegex": "^\\d{2}\\s[a-zA-Z-_ ]\\s\\d{2}\$"
    },
    {"name": "Gambia", "dial_code": "+220", "code": "GM", "postCodeRegex": ""},
    {
      "name": "Georgia",
      "dial_code": "+995",
      "code": "GE",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Germany",
      "dial_code": "+49",
      "code": "DE",
      "postCodeRegex": "^\\d{2}\$"
    },
    {"name": "Ghana", "dial_code": "+233", "code": "GH", "postCodeRegex": ""},
    {
      "name": "Gibraltar",
      "dial_code": "+350",
      "code": "GI",
      "postCodeRegex": "^[Gg][Xx][1]{2}\\s{0,1}[1][Aa]{2}\$"
    },
    {
      "name": "Greece",
      "dial_code": "+30",
      "code": "GR",
      "postCodeRegex": "^\\d{3}\\s{0,1}\\d{2}\$"
    },
    {
      "name": "Greenland",
      "dial_code": "+299",
      "code": "GL",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Grenada",
      "dial_code": "+1473",
      "code": "GD",
      "postCodeRegex": ""
    },
    {
      "name": "Guadeloupe",
      "dial_code": "+590",
      "code": "GP",
      "postCodeRegex": "^971\\d{2}\$"
    },
    {
      "name": "Guam",
      "dial_code": "+1671",
      "code": "GU",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Guatemala",
      "dial_code": "+502",
      "code": "GT",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Guernsey",
      "dial_code": "+44",
      "code": "GG",
      "postCodeRegex": "^[A-Za-z]{2}\\d\\s{0,1}\\d[A-Za-z]{2}\$"
    },
    {"name": "Guinea", "dial_code": "+224", "code": "GN", "postCodeRegex": ""},
    {
      "name": "Guinea-Bissau",
      "dial_code": "+245",
      "code": "GW",
      "postCodeRegex": "^\\d{4}\$"
    },
    {"name": "Guyana", "dial_code": "+595", "code": "GY", "postCodeRegex": ""},
    {
      "name": "Haiti",
      "dial_code": "+509",
      "code": "HT",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Holy See (Vatican City State)",
      "dial_code": "+379",
      "code": "VA",
      "postCodeRegex": "^120\$"
    },
    {
      "name": "Honduras",
      "dial_code": "+504",
      "code": "HN",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Hong Kong",
      "dial_code": "+852",
      "code": "HK",
      "postCodeRegex": ""
    },
    {
      "name": "Hungary",
      "dial_code": "+36",
      "code": "HU",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Iceland",
      "dial_code": "+354",
      "code": "IS",
      "postCodeRegex": "^\\d{3}\$"
    },
    {
      "name": "India",
      "dial_code": "+91",
      "code": "IN",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Indonesia",
      "dial_code": "+62",
      "code": "ID",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Iran, Islamic Republic of Persian Gulf",
      "dial_code": "+98",
      "code": "IR",
      "postCodeRegex": "^\\d{5}-\\d{5}\$"
    },
    {
      "name": "Iraq",
      "dial_code": "+964",
      "code": "IQ",
      "postCodeRegex": "^\\d{5}\$"
    },
    {"name": "Ireland", "dial_code": "+353", "code": "IE", "postCodeRegex": ""},
    {
      "name": "Isle of Man",
      "dial_code": "+44",
      "code": "IM",
      "postCodeRegex": "^[Ii[Mm]\\d{1,2}\\s\\d\\[A-Z]{2}\$"
    },
    {
      "name": "Israel",
      "dial_code": "+972",
      "code": "IL",
      "postCodeRegex": "^\\b\\d{5}(\\d{2})?\$"
    },
    {
      "name": "Italy",
      "dial_code": "+39",
      "code": "IT",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Jamaica",
      "dial_code": "+1876",
      "code": "JM",
      "postCodeRegex": "^\\d{2}\$"
    },
    {
      "name": "Japan",
      "dial_code": "+81",
      "code": "JP",
      "postCodeRegex": "^\\d{7}\\s\\(\\d{3}-\\d{4}\\)\$"
    },
    {
      "name": "Jersey",
      "dial_code": "+44",
      "code": "JE",
      "postCodeRegex": "^[Jj][Ee]\\d\\s{0,1}\\d[A-Za-z]{2}\$"
    },
    {
      "name": "Jordan",
      "dial_code": "+962",
      "code": "JO",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Kazakhstan",
      "dial_code": "+77",
      "code": "KZ",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Kenya",
      "dial_code": "+254",
      "code": "KE",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Kiribati",
      "dial_code": "+686",
      "code": "KI",
      "postCodeRegex": ""
    },
    {
      "name": "Korea, Democratic People's Republic of Korea",
      "dial_code": "+850",
      "code": "KP",
      "postCodeRegex": ""
    },
    {
      "name": "Korea, Republic of South Korea",
      "dial_code": "+82",
      "code": "KR",
      "postCodeRegex": "^\\d{6}\\s\\(\\d{3}-\\d{3}\\)\$"
    },
    {
      "name": "Kuwait",
      "dial_code": "+965",
      "code": "KW",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Kyrgyzstan",
      "dial_code": "+996",
      "code": "KG",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Laos",
      "dial_code": "+856",
      "code": "LA",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Latvia",
      "dial_code": "+371",
      "code": "LV",
      "postCodeRegex": "^[Ll][Vv][- ]{0,1}\\d{4}\$"
    },
    {
      "name": "Lebanon",
      "dial_code": "+961",
      "code": "LB",
      "postCodeRegex": "^\\d{4}\\s{0,1}\\d{4}\$"
    },
    {
      "name": "Lesotho",
      "dial_code": "+266",
      "code": "LS",
      "postCodeRegex": "^\\d{3}\$"
    },
    {
      "name": "Liberia",
      "dial_code": "+231",
      "code": "LR",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Libyan Arab Jamahiriya",
      "dial_code": "+218",
      "code": "LY",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Liechtenstein",
      "dial_code": "+423",
      "code": "LI",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Lithuania",
      "dial_code": "+370",
      "code": "LT",
      "postCodeRegex": "^[Ll][Tt][- ]{0,1}\\d{5}\$"
    },
    {
      "name": "Luxembourg",
      "dial_code": "+352",
      "code": "LU",
      "postCodeRegex": "^\\d{4}\$"
    },
    {"name": "Macao", "dial_code": "+853", "code": "MO", "postCodeRegex": ""},
    {
      "name": "Macedonia",
      "dial_code": "+389",
      "code": "MK",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Madagascar",
      "dial_code": "+261",
      "code": "MG",
      "postCodeRegex": "^\\d{3}\$"
    },
    {"name": "Malawi", "dial_code": "+265", "code": "MW", "postCodeRegex": ""},
    {
      "name": "Malaysia",
      "dial_code": "+60",
      "code": "MY",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Maldives",
      "dial_code": "+960",
      "code": "MV",
      "postCodeRegex": "^\\d{4,5}\$"
    },
    {"name": "Mali", "dial_code": "+223", "code": "ML", "postCodeRegex": ""},
    {
      "name": "Malta",
      "dial_code": "+356",
      "code": "MT",
      "postCodeRegex": "^[A-Za-z]{3}\\s{0,1}\\d{4}\$"
    },
    {
      "name": "Marshall Islands",
      "dial_code": "+692",
      "code": "MH",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Martinique",
      "dial_code": "+596",
      "code": "MQ",
      "postCodeRegex": "^972\\d{2}\$"
    },
    {
      "name": "Mauritania",
      "dial_code": "+222",
      "code": "MR",
      "postCodeRegex": ""
    },
    {
      "name": "Mauritius",
      "dial_code": "+230",
      "code": "MU",
      "postCodeRegex": ""
    },
    {
      "name": "Mayotte",
      "dial_code": "+262",
      "code": "YT",
      "postCodeRegex": "^976\\d{2}\$"
    },
    {
      "name": "Mexico",
      "dial_code": "+52",
      "code": "MX",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Micronesia, Federated States of Micronesia",
      "dial_code": "+691",
      "code": "FM",
      "postCodeRegex": "^\\d{5}(-{1}\\d{4})\$"
    },
    {
      "name": "Moldova",
      "dial_code": "+373",
      "code": "MD",
      "postCodeRegex": "^[Mm][Dd][- ]{0,1}\\d{4}\$"
    },
    {
      "name": "Monaco",
      "dial_code": "+377",
      "code": "MC",
      "postCodeRegex": "^980\\d{2}\$"
    },
    {
      "name": "Mongolia",
      "dial_code": "+976",
      "code": "MN",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Montenegro",
      "dial_code": "+382",
      "code": "ME",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Montserrat",
      "dial_code": "+1664",
      "code": "MS",
      "postCodeRegex": "^[Mm][Ss][Rr]\\s{0,1}\\d{4}\$"
    },
    {
      "name": "Morocco",
      "dial_code": "+212",
      "code": "MA",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Mozambique",
      "dial_code": "+258",
      "code": "MZ",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Myanmar",
      "dial_code": "+95",
      "code": "MM",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Namibia",
      "dial_code": "+264",
      "code": "NA",
      "postCodeRegex": "^\\d{5}\$"
    },
    {"name": "Nauru", "dial_code": "+674", "code": "NR", "postCodeRegex": ""},
    {
      "name": "Nepal",
      "dial_code": "+977",
      "code": "NP",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Netherlands",
      "dial_code": "+31",
      "code": "NL",
      "postCodeRegex": "^\\d{4}\\s{0,1}[A-Za-z]{2}\$"
    },
    {
      "name": "New Caledonia",
      "dial_code": "+687",
      "code": "NC",
      "postCodeRegex": "^988\\d{2}\$"
    },
    {
      "name": "New Zealand",
      "dial_code": "+64",
      "code": "NZ",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Nicaragua",
      "dial_code": "+505",
      "code": "NI",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Niger",
      "dial_code": "+227",
      "code": "NE",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Nigeria",
      "dial_code": "+234",
      "code": "NG",
      "postCodeRegex": "^\\d{6}\$"
    },
    {"name": "Niue", "dial_code": "+683", "code": "NU", "postCodeRegex": ""},
    {
      "name": "Norfolk Island",
      "dial_code": "+672",
      "code": "NF",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Northern Mariana Islands",
      "dial_code": "+1670",
      "code": "MP",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Norway",
      "dial_code": "+47",
      "code": "NO",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Oman",
      "dial_code": "+968",
      "code": "OM",
      "postCodeRegex": "^\\d{3}\$"
    },
    {
      "name": "Pakistan",
      "dial_code": "+92",
      "code": "PK",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Palau",
      "dial_code": "+680",
      "code": "PW",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Panama",
      "dial_code": "+507",
      "code": "PA",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Papua New Guinea",
      "dial_code": "+675",
      "code": "PG",
      "postCodeRegex": "^\\d{3}\$"
    },
    {
      "name": "Paraguay",
      "dial_code": "+595",
      "code": "PY",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Peru",
      "dial_code": "+51",
      "code": "PE",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Philippines",
      "dial_code": "+63",
      "code": "PH",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Pitcairn",
      "dial_code": "+872",
      "code": "PN",
      "postCodeRegex": "^[Pp][Cc][Rr][Nn]\\s{0,1}[1][Zz]{2}\$"
    },
    {
      "name": "Poland",
      "dial_code": "+48",
      "code": "PL",
      "postCodeRegex": "^\\d{2}[- ]{0,1}\\d{3}\$"
    },
    {
      "name": "Portugal",
      "dial_code": "+351",
      "code": "PT",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Puerto Rico",
      "dial_code": "+1939",
      "code": "PR",
      "postCodeRegex": "^\\d{5}\$"
    },
    {"name": "Qatar", "dial_code": "+974", "code": "QA", "postCodeRegex": ""},
    {
      "name": "Romania",
      "dial_code": "+40",
      "code": "RO",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Russia",
      "dial_code": "+7",
      "code": "RU",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Reunion",
      "dial_code": "+262",
      "code": "RE",
      "postCodeRegex": "^974\\d{2}\$"
    },
    {
      "name": "Saint Barthelemy",
      "dial_code": "+590",
      "code": "BL",
      "postCodeRegex": "^97133\$"
    },
    {
      "name": "Saint Helena, Ascension and Tristan Da Cunha",
      "dial_code": "+290",
      "code": "SH",
      "postCodeRegex": "^[Ss][Tt][Hh][Ll]\\s{0,1}[1][Zz]{2}\$"
    },
    {
      "name": "Saint Kitts and Nevis",
      "dial_code": "+1869",
      "code": "KN",
      "postCodeRegex": ""
    },
    {
      "name": "Saint Lucia",
      "dial_code": "+1758",
      "code": "LC",
      "postCodeRegex": ""
    },
    {
      "name": "Saint Martin",
      "dial_code": "+590",
      "code": "MF",
      "postCodeRegex": "^97150\$"
    },
    {
      "name": "Saint Pierre and Miquelon",
      "dial_code": "+508",
      "code": "PM",
      "postCodeRegex": "^97500\$"
    },
    {
      "name": "Saint Vincent and the Grenadines",
      "dial_code": "+1784",
      "code": "VC",
      "postCodeRegex": "^[Vv][Cc]\\d{4}\$"
    },
    {
      "name": "San Marino",
      "dial_code": "+378",
      "code": "SM",
      "postCodeRegex": "^4789\\d\$"
    },
    {
      "name": "Sao Tome and Principe",
      "dial_code": "+239",
      "code": "ST",
      "postCodeRegex": ""
    },
    {
      "name": "Saudi Arabia",
      "dial_code": "+966",
      "code": "SA",
      "postCodeRegex": "^\\d{5}(-{1}\\d{4})?\$"
    },
    {
      "name": "Senegal",
      "dial_code": "+221",
      "code": "SN",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Serbia",
      "dial_code": "+381",
      "code": "RS",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Seychelles",
      "dial_code": "+248",
      "code": "SC",
      "postCodeRegex": ""
    },
    {
      "name": "Sierra Leone",
      "dial_code": "+232",
      "code": "SL",
      "postCodeRegex": ""
    },
    {
      "name": "Singapore",
      "dial_code": "+65",
      "code": "SG",
      "postCodeRegex": "^\\d{2}\$"
    },
    {
      "name": "Slovakia",
      "dial_code": "+421",
      "code": "SK",
      "postCodeRegex": "^\\d{5}\\s\\(\\d{3}\\s\\d{2}\\)\$"
    },
    {
      "name": "Slovenia",
      "dial_code": "+386",
      "code": "SI",
      "postCodeRegex": "^([Ss][Ii][- ]{0,1}){0,1}\\d{4}\$"
    },
    {
      "name": "Solomon Islands",
      "dial_code": "+677",
      "code": "SB",
      "postCodeRegex": ""
    },
    {"name": "Somalia", "dial_code": "+252", "code": "SO", "postCodeRegex": ""},
    {
      "name": "South Africa",
      "dial_code": "+27",
      "code": "ZA",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "South Georgia and the South Sandwich Islands",
      "dial_code": "+500",
      "code": "GS",
      "postCodeRegex": "^[Ss][Ii][Qq]{2}\\s{0,1}[1][Zz]{2}\$"
    },
    {
      "name": "Spain",
      "dial_code": "+34",
      "code": "ES",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Sri Lanka",
      "dial_code": "+94",
      "code": "LK",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Sudan",
      "dial_code": "+249",
      "code": "SD",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Suriname",
      "dial_code": "+597",
      "code": "SR",
      "postCodeRegex": ""
    },
    {
      "name": "Svalbard and Jan Mayen",
      "dial_code": "+47",
      "code": "SJ",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Swaziland",
      "dial_code": "+268",
      "code": "SZ",
      "postCodeRegex": "^[A-Za-z]\\d{3}\$"
    },
    {
      "name": "Sweden",
      "dial_code": "+46",
      "code": "SE",
      "postCodeRegex": "^\\d{3}\\s*\\d{2}\$"
    },
    {
      "name": "Switzerland",
      "dial_code": "+41",
      "code": "CH",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Syrian Arab Republic",
      "dial_code": "+963",
      "code": "SY",
      "postCodeRegex": ""
    },
    {
      "name": "Taiwan",
      "dial_code": "+886",
      "code": "TW",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Tajikistan",
      "dial_code": "+992",
      "code": "TJ",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Tanzania, United Republic of Tanzania",
      "dial_code": "+255",
      "code": "TZ",
      "postCodeRegex": ""
    },
    {
      "name": "Thailand",
      "dial_code": "+66",
      "code": "TH",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Timor-Leste",
      "dial_code": "+670",
      "code": "TL",
      "postCodeRegex": ""
    },
    {"name": "Togo", "dial_code": "+228", "code": "TG", "postCodeRegex": ""},
    {"name": "Tokelau", "dial_code": "+690", "code": "TK", "postCodeRegex": ""},
    {"name": "Tonga", "dial_code": "+676", "code": "TO", "postCodeRegex": ""},
    {
      "name": "Trinidad and Tobago",
      "dial_code": "+1868",
      "code": "TT",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Tunisia",
      "dial_code": "+216",
      "code": "TN",
      "postCodeRegex": "^\\d{4}\$"
    },
    {
      "name": "Turkey",
      "dial_code": "+90",
      "code": "TR",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Turkmenistan",
      "dial_code": "+993",
      "code": "TM",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Turks and Caicos Islands",
      "dial_code": "+1649",
      "code": "TC",
      "postCodeRegex": "^[Tt][Kk][Cc][Aa]\\s{0,1}[1][Zz]{2}\$"
    },
    {"name": "Tuvalu", "dial_code": "+688", "code": "TV", "postCodeRegex": ""},
    {"name": "Uganda", "dial_code": "+256", "code": "UG", "postCodeRegex": ""},
    {
      "name": "Ukraine",
      "dial_code": "+380",
      "code": "UA",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "United Arab Emirates",
      "dial_code": "+971",
      "code": "AE",
      "postCodeRegex": ""
    },
    {
      "name": "United Kingdom",
      "dial_code": "+44",
      "code": "GB",
      "postCodeRegex": "^[A-Z]{1,2}[0-9R][0-9A-Z]?\\s*[0-9][A-Z-[CIKMOV]]{2}"
    },
    {
      "name": "United States",
      "dial_code": "+1",
      "code": "US",
      "postCodeRegex": "^\\b\\d{5}\\b(?:[- ]{1}\\d{4})?\$"
    },
    {
      "name": "Uruguay",
      "dial_code": "+598",
      "code": "UY",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Uzbekistan",
      "dial_code": "+998",
      "code": "UZ",
      "postCodeRegex": "^\\d{3} \\d{3}\$"
    },
    {"name": "Vanuatu", "dial_code": "+678", "code": "VU", "postCodeRegex": ""},
    {
      "name": "Venezuela, Bolivarian Republic of Venezuela",
      "dial_code": "+58",
      "code": "VE",
      "postCodeRegex": "^\\d{4}(\\s[a-zA-Z]{1})?\$"
    },
    {
      "name": "Vietnam",
      "dial_code": "+84",
      "code": "VN",
      "postCodeRegex": "^\\d{6}\$"
    },
    {
      "name": "Virgin Islands, British",
      "dial_code": "+1284",
      "code": "VG",
      "postCodeRegex": "^[Vv][Gg]\\d{4}\$"
    },
    {
      "name": "Virgin Islands, U.S.",
      "dial_code": "+1340",
      "code": "VI",
      "postCodeRegex": "^\\d{5}\$"
    },
    {
      "name": "Wallis and Futuna",
      "dial_code": "+681",
      "code": "WF",
      "postCodeRegex": "^986\\d{2}\$"
    },
    {"name": "Yemen", "dial_code": "+967", "code": "YE", "postCodeRegex": ""},
    {
      "name": "Zambia",
      "dial_code": "+260",
      "code": "ZM",
      "postCodeRegex": "^\\d{5}\$"
    },
    {"name": "Zimbabwe", "dial_code": "+263", "code": "ZW", "postCodeRegex": ""}
  ];

  static List<CountryCode> get getAllCountry => _countryPickerItemList
      .map((e) => CountryCode(
            e["name"]!,
            e["dial_code"]!,
            e["code"]!,
            e["postCodeRegex"]!,
          ))
      .toList();

  static List<String> language = [
    "Afrikaans",
    "Arabic",
    "Bengali",
    "Bulgarian",
    "Catalan",
    "Cantonese",
    "Croatian",
    "Czech",
    "Danish",
    "Dutch",
    "Lithuanian",
    "Malay",
    "Malayalam",
    "Panjabi",
    "Tamil",
    "English",
    "Finnish",
    "French",
    "German",
    "Greek",
    "Hebrew",
    "Hindi",
    "Hungarian",
    "Indonesian",
    "Italian",
    "Japanese",
    "Javanese",
    "Korean",
    "Norwegian",
    "Polish",
    "Portuguese",
    "Romanian",
    "Russian",
    "Serbian",
    "Slovak",
    "Slovene",
    "Spanish",
    "Swedish",
    "Telugu",
    "Thai",
    "Turkish",
    "Ukrainian",
    "Vietnamese",
    "Welsh",
    "Sign language",
    "Algerian",
    "Aramaic",
    "Armenian",
    "Berber",
    "Burmese",
    "Bosnian",
    "Brazilian",
    "Bulgarian",
    "Cypriot",
    "Corsica",
    "Creole",
    "Scottish",
    "Egyptian",
    "Esperanto",
    "Estonian",
    "Finn",
    "Flemish",
    "Georgian",
    "Hawaiian",
    "Indonesian",
    "Inuit",
    "Irish",
    "Icelandic",
    "Latin",
    "Mandarin",
    "Nepalese",
    "Sanskrit",
    "Tagalog",
    "Tahitian",
    "Tibetan",
    "Gypsy",
    "Wu"
  ];
}
