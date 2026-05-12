import Foundation

// All 32 NHL teams.
// Primary/secondary colors sourced from official team brand guidelines.
let allNHLTeams: [NHLTeam] = [
    NHLTeam(
        id: "ANA",
        fullName: "Anaheim Ducks",
        nickname: "DUCKS",
        primaryColor: "FC4C02",
        secondaryColor: "B9975B",
        youtubeVideoID: "MCTdtosB55k"
    ),
    NHLTeam(
        id: "BOS",
        fullName: "Boston Bruins",
        nickname: "BRUINS",
        primaryColor: "FFB81C",
        secondaryColor: "000000",
        youtubeVideoID: "aBa4pwIlWsQ"
    ),
    NHLTeam(
        id: "BUF",
        fullName: "Buffalo Sabres",
        nickname: "SABRES",
        primaryColor: "003087",
        secondaryColor: "FFB81C",
        youtubeVideoID: "rMocjBuFSlE"
    ),
    NHLTeam(
        id: "CGY",
        fullName: "Calgary Flames",
        nickname: "FLAMES",
        primaryColor: "C8102E",
        secondaryColor: "F1BE48",
        youtubeVideoID: "WGD0t-6c7Bw"
    ),
    NHLTeam(
        id: "CAR",
        fullName: "Carolina Hurricanes",
        nickname: "CANES",
        primaryColor: "CC0000",
        secondaryColor: "000000",
        youtubeVideoID: "uTRm_cJSx9c"
    ),
    NHLTeam(
        id: "CHI",
        fullName: "Chicago Blackhawks",
        nickname: "HAWKS",
        primaryColor: "CF0A2C",
        secondaryColor: "FF671B",
        youtubeVideoID: "On-BEbezpIQ"
    ),
    NHLTeam(
        id: "COL",
        fullName: "Colorado Avalanche",
        nickname: "AVS",
        primaryColor: "6F263D",
        secondaryColor: "236192",
        youtubeVideoID: "A0Fd-m1BruM"
    ),
    NHLTeam(
        id: "CBJ",
        fullName: "Columbus Blue Jackets",
        nickname: "JACKETS",
        primaryColor: "002654",
        secondaryColor: "CE1126",
        youtubeVideoID: "4qjQ399G1wE"
    ),
    NHLTeam(
        id: "DAL",
        fullName: "Dallas Stars",
        nickname: "STARS",
        primaryColor: "006847",
        secondaryColor: "8F8F8C",
        youtubeVideoID: "4he2-N8BSyc"
    ),
    NHLTeam(
        id: "DET",
        fullName: "Detroit Red Wings",
        nickname: "WINGS",
        primaryColor: "CE1126",
        secondaryColor: "FFFFFF",
        youtubeVideoID: "dsUpffGEqj8"
    ),
    NHLTeam(
        id: "EDM",
        fullName: "Edmonton Oilers",
        nickname: "OILERS",
        primaryColor: "041E42",
        secondaryColor: "FF4C00",
        youtubeVideoID: "jemolIFePeI"
    ),
    NHLTeam(
        id: "FLA",
        fullName: "Florida Panthers",
        nickname: "PANTHERS",
        primaryColor: "041E42",
        secondaryColor: "C8102E",
        youtubeVideoID: "bGKsCtPabaE"
    ),
    NHLTeam(
        id: "LAK",
        fullName: "Los Angeles Kings",
        nickname: "KINGS",
        primaryColor: "111111",
        secondaryColor: "A2AAAD",
        youtubeVideoID: "taJ0ahipgxc"
    ),
    NHLTeam(
        id: "MIN",
        fullName: "Minnesota Wild",
        nickname: "WILD",
        primaryColor: "154734",
        secondaryColor: "A6192E",
        youtubeVideoID: "odrlS9iKc7E"
    ),
    NHLTeam(
        id: "MTL",
        fullName: "Montreal Canadiens",
        nickname: "HABS",
        primaryColor: "AF1E2D",
        secondaryColor: "192168",
        youtubeVideoID: "3KMMFklxQQg"
    ),
    NHLTeam(
        id: "NSH",
        fullName: "Nashville Predators",
        nickname: "PREDS",
        primaryColor: "FFB81C",
        secondaryColor: "041E42",
        youtubeVideoID: "LFEjnV3LBnY"
    ),
    NHLTeam(
        id: "NJD",
        fullName: "New Jersey Devils",
        nickname: "DEVILS",
        primaryColor: "CE1126",
        secondaryColor: "000000",
        youtubeVideoID: "pJVQJ5RnwCo"
    ),
    NHLTeam(
        id: "NYI",
        fullName: "New York Islanders",
        nickname: "ISLES",
        primaryColor: "00539B",
        secondaryColor: "F47D30",
        youtubeVideoID: "QQgIAoH9oB0"
    ),
    NHLTeam(
        id: "NYR",
        fullName: "New York Rangers",
        nickname: "RANGERS",
        primaryColor: "0038A8",
        secondaryColor: "CE1126",
        youtubeVideoID: "Uz1lSs1S1FI"
    ),
    NHLTeam(
        id: "OTT",
        fullName: "Ottawa Senators",
        nickname: "SENS",
        primaryColor: "C52032",
        secondaryColor: "C69214",
        youtubeVideoID: "aNIr31P5zNU"
    ),
    NHLTeam(
        id: "PHI",
        fullName: "Philadelphia Flyers",
        nickname: "FLYERS",
        primaryColor: "F74902",
        secondaryColor: "000000",
        youtubeVideoID: "04MQPfSOx0U"
    ),
    NHLTeam(
        id: "PIT",
        fullName: "Pittsburgh Penguins",
        nickname: "PENS",
        primaryColor: "000000",
        secondaryColor: "FCB514",
        youtubeVideoID: "YkdaxmSiWx8"
    ),
    NHLTeam(
        id: "SJS",
        fullName: "San Jose Sharks",
        nickname: "SHARKS",
        primaryColor: "006D75",
        secondaryColor: "EA7200",
        youtubeVideoID: "q9i2f7ZckKc"
    ),
    NHLTeam(
        id: "SEA",
        fullName: "Seattle Kraken",
        nickname: "KRAKEN",
        primaryColor: "001628",
        secondaryColor: "99D9D9",
        youtubeVideoID: "YpjEi8t858Y"
    ),
    NHLTeam(
        id: "STL",
        fullName: "St. Louis Blues",
        nickname: "BLUES",
        primaryColor: "002F87",
        secondaryColor: "FCB514",
        youtubeVideoID: "23aykU6HX9o"
    ),
    NHLTeam(
        id: "TBL",
        fullName: "Tampa Bay Lightning",
        nickname: "BOLTS",
        primaryColor: "002868",
        secondaryColor: "FFFFFF",
        youtubeVideoID: "ONRedRJ6CS0"
    ),
    NHLTeam(
        id: "TOR",
        fullName: "Toronto Maple Leafs",
        nickname: "LEAFS",
        primaryColor: "00205B",
        secondaryColor: "FFFFFF",
        youtubeVideoID: "cHR1GBMwvTQ"
    ),
    NHLTeam(
        id: "UTA",
        fullName: "Utah Mammoth",
        nickname: "MAMMOTH",
        primaryColor: "69B3E7",
        secondaryColor: "010101",
        youtubeVideoID: "LbikgCiHcXk"
    ),
    NHLTeam(
        id: "VAN",
        fullName: "Vancouver Canucks",
        nickname: "CANUCKS",
        primaryColor: "00205B",
        secondaryColor: "00843D",
        youtubeVideoID: "ACXh-1CUPFY"
    ),
    NHLTeam(
        id: "VGK",
        fullName: "Vegas Golden Knights",
        nickname: "KNIGHTS",
        primaryColor: "B4975A",
        secondaryColor: "333F42",
        youtubeVideoID: "K7KoErYHzCI"
    ),
    NHLTeam(
        id: "WSH",
        fullName: "Washington Capitals",
        nickname: "CAPS",
        primaryColor: "041E42",
        secondaryColor: "C8102E",
        youtubeVideoID: "WEwfvsmXLz8"
    ),
    NHLTeam(
        id: "WPG",
        fullName: "Winnipeg Jets",
        nickname: "JETS",
        primaryColor: "041E42",
        secondaryColor: "004C97",
        youtubeVideoID: "kwnvLjJj6Xk"
    ),
]
