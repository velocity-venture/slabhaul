import 'package:slabhaul/features/weather/providers/weather_providers.dart';

/// Pre-configured lake coordinates for weather/generation tracking.
/// Includes TVA reservoirs, Corps of Engineers lakes, and major crappie fisheries.
class TvaLakes {
  // ===== TVA RESERVOIRS (Tennessee Valley) =====
  static const kentucky = WeatherLakeCoords(
    lat: 36.6,
    lon: -88.1,
    name: 'Kentucky Lake',
    maxDepthFt: 75,
    areaAcres: 160309,
  );

  static const barkley = WeatherLakeCoords(
    lat: 36.85,
    lon: -87.9,
    name: 'Lake Barkley',
    maxDepthFt: 60,
    areaAcres: 57920,
  );

  static const pickwick = WeatherLakeCoords(
    lat: 35.05,
    lon: -88.26,
    name: 'Pickwick Lake',
    maxDepthFt: 57,
    areaAcres: 43100,
  );

  static const wheeler = WeatherLakeCoords(
    lat: 34.6,
    lon: -87.1,
    name: 'Wheeler Lake',
    maxDepthFt: 50,
    areaAcres: 67100,
  );

  static const guntersville = WeatherLakeCoords(
    lat: 34.4,
    lon: -86.3,
    name: 'Guntersville Lake',
    maxDepthFt: 60,
    areaAcres: 69100,
  );

  static const chickamauga = WeatherLakeCoords(
    lat: 35.25,
    lon: -85.2,
    name: 'Chickamauga Lake',
    maxDepthFt: 53,
    areaAcres: 35400,
  );

  static const wattsBar = WeatherLakeCoords(
    lat: 35.7,
    lon: -84.8,
    name: 'Watts Bar Lake',
    maxDepthFt: 70,
    areaAcres: 39000,
  );

  static const norris = WeatherLakeCoords(
    lat: 36.35,
    lon: -84.1,
    name: 'Norris Lake',
    maxDepthFt: 200,
    areaAcres: 34200,
  );

  static const cherokee = WeatherLakeCoords(
    lat: 36.2,
    lon: -83.4,
    name: 'Cherokee Lake',
    maxDepthFt: 150,
    areaAcres: 28780,
  );

  static const douglas = WeatherLakeCoords(
    lat: 36.0,
    lon: -83.4,
    name: 'Douglas Lake',
    maxDepthFt: 140,
    areaAcres: 28420,
  );

  static const fortLoudoun = WeatherLakeCoords(
    lat: 35.85,
    lon: -84.2,
    name: 'Fort Loudoun Lake',
    maxDepthFt: 70,
    areaAcres: 14600,
  );

  // ===== TENNESSEE (Non-TVA) =====
  static const reelfoot = WeatherLakeCoords(
    lat: 36.387,
    lon: -89.387,
    name: 'Reelfoot Lake',
    maxDepthFt: 18,
    areaAcres: 15000,
  );

  static const daleHollow = WeatherLakeCoords(
    lat: 36.55,
    lon: -85.4,
    name: 'Dale Hollow Lake',
    maxDepthFt: 135,
    areaAcres: 27700,
  );

  static const centerHill = WeatherLakeCoords(
    lat: 36.05,
    lon: -85.85,
    name: 'Center Hill Lake',
    maxDepthFt: 180,
    areaAcres: 18220,
  );

  static const oldHickory = WeatherLakeCoords(
    lat: 36.3,
    lon: -86.55,
    name: 'Old Hickory Lake',
    maxDepthFt: 60,
    areaAcres: 22500,
  );

  static const percyPriest = WeatherLakeCoords(
    lat: 36.1,
    lon: -86.5,
    name: 'Percy Priest Lake',
    maxDepthFt: 95,
    areaAcres: 14200,
  );

  // ===== ARKANSAS =====
  static const horseshoe = WeatherLakeCoords(
    lat: 34.932,
    lon: -90.35,
    name: 'Horseshoe Lake',
    maxDepthFt: 20,
    areaAcres: 2700,
  );

  static const beaver = WeatherLakeCoords(
    lat: 36.35,
    lon: -93.9,
    name: 'Beaver Lake',
    maxDepthFt: 200,
    areaAcres: 28370,
  );

  static const norfork = WeatherLakeCoords(
    lat: 36.4,
    lon: -92.25,
    name: 'Norfork Lake',
    maxDepthFt: 180,
    areaAcres: 22000,
  );

  static const bullShoals = WeatherLakeCoords(
    lat: 36.45,
    lon: -92.6,
    name: 'Bull Shoals Lake',
    maxDepthFt: 200,
    areaAcres: 45440,
  );

  static const greersFerry = WeatherLakeCoords(
    lat: 35.55,
    lon: -92.0,
    name: 'Greers Ferry Lake',
    maxDepthFt: 220,
    areaAcres: 31500,
  );

  static const lakeDardanelle = WeatherLakeCoords(
    lat: 35.35,
    lon: -93.3,
    name: 'Lake Dardanelle',
    maxDepthFt: 50,
    areaAcres: 34300,
  );

  static const degray = WeatherLakeCoords(
    lat: 34.25,
    lon: -93.15,
    name: 'DeGray Lake',
    maxDepthFt: 180,
    areaAcres: 13400,
  );

  static const ouachita = WeatherLakeCoords(
    lat: 34.55,
    lon: -93.25,
    name: 'Lake Ouachita',
    maxDepthFt: 200,
    areaAcres: 40100,
  );

  static const millwood = WeatherLakeCoords(
    lat: 33.75,
    lon: -93.95,
    name: 'Millwood Lake',
    maxDepthFt: 45,
    areaAcres: 29200,
  );

  static const lakeConway = WeatherLakeCoords(
    lat: 34.9,
    lon: -92.15,
    name: 'Lake Conway',
    maxDepthFt: 12,
    areaAcres: 6700,
  );

  static const lakeChicot = WeatherLakeCoords(
    lat: 33.32,
    lon: -91.22,
    name: 'Lake Chicot',
    maxDepthFt: 30,
    areaAcres: 5085,
  );

  // ===== MISSISSIPPI =====
  static const grenada = WeatherLakeCoords(
    lat: 33.83,
    lon: -89.75,
    name: 'Grenada Lake',
    maxDepthFt: 70,
    areaAcres: 35000,
  );

  static const enid = WeatherLakeCoords(
    lat: 34.16,
    lon: -89.9,
    name: 'Enid Lake',
    maxDepthFt: 55,
    areaAcres: 28000,
  );

  static const sardis = WeatherLakeCoords(
    lat: 34.43,
    lon: -89.78,
    name: 'Sardis Lake',
    maxDepthFt: 60,
    areaAcres: 32100,
  );

  static const rossBarnett = WeatherLakeCoords(
    lat: 32.45,
    lon: -90.02,
    name: 'Ross Barnett Reservoir',
    maxDepthFt: 35,
    areaAcres: 33000,
  );

  // ===== ALABAMA =====
  static const weiss = WeatherLakeCoords(
    lat: 34.15,
    lon: -85.65,
    name: 'Weiss Lake',
    maxDepthFt: 45,
    areaAcres: 30200,
  );

  static const eufaula = WeatherLakeCoords(
    lat: 31.93,
    lon: -85.1,
    name: 'Lake Eufaula',
    maxDepthFt: 90,
    areaAcres: 45180,
  );

  // ===== KENTUCKY =====
  static const cumberland = WeatherLakeCoords(
    lat: 36.9,
    lon: -85.0,
    name: 'Lake Cumberland',
    maxDepthFt: 200,
    areaAcres: 50250,
  );

  static const greenRiver = WeatherLakeCoords(
    lat: 37.25,
    lon: -85.3,
    name: 'Green River Lake',
    maxDepthFt: 100,
    areaAcres: 8200,
  );

  static const barrenRiver = WeatherLakeCoords(
    lat: 36.9,
    lon: -86.15,
    name: 'Barren River Lake',
    maxDepthFt: 100,
    areaAcres: 10000,
  );

  static const caveRun = WeatherLakeCoords(
    lat: 38.1,
    lon: -83.55,
    name: 'Cave Run Lake',
    maxDepthFt: 80,
    areaAcres: 8270,
  );

  // ===== MISSOURI =====
  static const tableRock = WeatherLakeCoords(
    lat: 36.6,
    lon: -93.35,
    name: 'Table Rock Lake',
    maxDepthFt: 220,
    areaAcres: 43100,
  );

  static const stockton = WeatherLakeCoords(
    lat: 37.65,
    lon: -93.8,
    name: 'Stockton Lake',
    maxDepthFt: 110,
    areaAcres: 24900,
  );

  static const truman = WeatherLakeCoords(
    lat: 38.2,
    lon: -93.5,
    name: 'Truman Lake',
    maxDepthFt: 90,
    areaAcres: 55600,
  );

  static const lakeOzarks = WeatherLakeCoords(
    lat: 38.1,
    lon: -92.7,
    name: 'Lake of the Ozarks',
    maxDepthFt: 130,
    areaAcres: 54000,
  );

  static const pommeDeTerre = WeatherLakeCoords(
    lat: 37.85,
    lon: -93.35,
    name: 'Pomme de Terre Lake',
    maxDepthFt: 90,
    areaAcres: 7800,
  );

  // ===== OKLAHOMA / TEXAS =====
  static const grandLake = WeatherLakeCoords(
    lat: 36.55,
    lon: -94.78,
    name: "Grand Lake O' the Cherokees",
    maxDepthFt: 140,
    areaAcres: 46500,
  );

  static const texoma = WeatherLakeCoords(
    lat: 33.88,
    lon: -96.58,
    name: 'Lake Texoma',
    maxDepthFt: 100,
    areaAcres: 89000,
  );

  static const lakeFork = WeatherLakeCoords(
    lat: 32.85,
    lon: -95.55,
    name: 'Lake Fork',
    maxDepthFt: 70,
    areaAcres: 27690,
  );

  static const toledoBend = WeatherLakeCoords(
    lat: 31.4,
    lon: -93.7,
    name: 'Toledo Bend Reservoir',
    maxDepthFt: 100,
    areaAcres: 185000,
  );

  static const samRayburn = WeatherLakeCoords(
    lat: 31.1,
    lon: -94.2,
    name: 'Sam Rayburn Reservoir',
    maxDepthFt: 80,
    areaAcres: 114500,
  );

  // ===== LOUISIANA =====
  static const dArbonne = WeatherLakeCoords(
    lat: 32.7,
    lon: -92.35,
    name: "Lake D'Arbonne",
    maxDepthFt: 25,
    areaAcres: 15250,
  );

  static const claiborne = WeatherLakeCoords(
    lat: 32.85,
    lon: -92.9,
    name: 'Lake Claiborne',
    maxDepthFt: 60,
    areaAcres: 6400,
  );

  static const caddo = WeatherLakeCoords(
    lat: 32.7,
    lon: -94.05,
    name: 'Caddo Lake',
    maxDepthFt: 20,
    areaAcres: 26800,
  );

  static const falseRiver = WeatherLakeCoords(
    lat: 30.7,
    lon: -91.4,
    name: 'False River',
    maxDepthFt: 20,
    areaAcres: 3000,
  );

  // ===== FLORIDA =====
  static const okeechobee = WeatherLakeCoords(
    lat: 26.95,
    lon: -80.8,
    name: 'Lake Okeechobee',
    maxDepthFt: 12,
    areaAcres: 451000,
  );

  static const istokpoga = WeatherLakeCoords(
    lat: 27.39,
    lon: -81.3,
    name: 'Lake Istokpoga',
    maxDepthFt: 10,
    areaAcres: 27692,
  );

  static const talquin = WeatherLakeCoords(
    lat: 30.45,
    lon: -84.65,
    name: 'Lake Talquin',
    maxDepthFt: 28,
    areaAcres: 8850,
  );

  // ===== GEORGIA / SOUTH CAROLINA =====
  static const seminole = WeatherLakeCoords(
    lat: 30.8,
    lon: -84.8,
    name: 'Lake Seminole',
    maxDepthFt: 35,
    areaAcres: 37500,
  );

  static const westPoint = WeatherLakeCoords(
    lat: 33.08,
    lon: -85.18,
    name: 'West Point Lake',
    maxDepthFt: 85,
    areaAcres: 25900,
  );

  static const lanier = WeatherLakeCoords(
    lat: 34.2,
    lon: -83.95,
    name: 'Lake Lanier',
    maxDepthFt: 160,
    areaAcres: 38000,
  );

  static const clarksHill = WeatherLakeCoords(
    lat: 33.8,
    lon: -82.3,
    name: 'Clarks Hill Lake',
    maxDepthFt: 160,
    areaAcres: 71100,
  );

  static const lakeMurray = WeatherLakeCoords(
    lat: 34.1,
    lon: -81.4,
    name: 'Lake Murray',
    maxDepthFt: 180,
    areaAcres: 50000,
  );

  static const santeeCooper = WeatherLakeCoords(
    lat: 33.45,
    lon: -80.2,
    name: 'Lake Marion & Moultrie',
    maxDepthFt: 75,
    areaAcres: 171000,
  );

  // ===== NORTH CAROLINA / VIRGINIA =====
  static const kerr = WeatherLakeCoords(
    lat: 36.55,
    lon: -78.4,
    name: 'Kerr Lake',
    maxDepthFt: 100,
    areaAcres: 50000,
  );

  static const falls = WeatherLakeCoords(
    lat: 36.02,
    lon: -78.7,
    name: 'Falls Lake',
    maxDepthFt: 50,
    areaAcres: 12410,
  );

  static const jordan = WeatherLakeCoords(
    lat: 35.75,
    lon: -79.05,
    name: 'Jordan Lake',
    maxDepthFt: 60,
    areaAcres: 14000,
  );

  // ===== ILLINOIS / INDIANA / OHIO =====
  static const shelbyville = WeatherLakeCoords(
    lat: 39.45,
    lon: -88.8,
    name: 'Lake Shelbyville',
    maxDepthFt: 75,
    areaAcres: 11100,
  );

  static const carlyle = WeatherLakeCoords(
    lat: 38.65,
    lon: -89.4,
    name: 'Carlyle Lake',
    maxDepthFt: 35,
    areaAcres: 26000,
  );

  static const rendLake = WeatherLakeCoords(
    lat: 38.15,
    lon: -88.95,
    name: 'Rend Lake',
    maxDepthFt: 35,
    areaAcres: 18900,
  );

  static const patoka = WeatherLakeCoords(
    lat: 38.4,
    lon: -86.65,
    name: 'Patoka Lake',
    maxDepthFt: 62,
    areaAcres: 8880,
  );

  static const monroeLake = WeatherLakeCoords(
    lat: 39.05,
    lon: -86.5,
    name: 'Monroe Lake',
    maxDepthFt: 55,
    areaAcres: 10750,
  );

  /// All configured lakes grouped by region for UI organization.
  static List<WeatherLakeCoords> get all => [
        // Tennessee Valley (TVA)
        reelfoot,
        kentucky,
        barkley,
        pickwick,
        wheeler,
        guntersville,
        chickamauga,
        wattsBar,
        fortLoudoun,
        norris,
        cherokee,
        douglas,
        // Tennessee (Corps/State)
        daleHollow,
        centerHill,
        oldHickory,
        percyPriest,
        // Arkansas
        horseshoe,
        beaver,
        norfork,
        bullShoals,
        greersFerry,
        lakeDardanelle,
        degray,
        ouachita,
        millwood,
        lakeConway,
        lakeChicot,
        // Mississippi
        grenada,
        enid,
        sardis,
        rossBarnett,
        // Alabama
        weiss,
        eufaula,
        // Kentucky
        cumberland,
        greenRiver,
        barrenRiver,
        caveRun,
        // Missouri
        tableRock,
        stockton,
        truman,
        lakeOzarks,
        pommeDeTerre,
        // Oklahoma/Texas
        grandLake,
        texoma,
        lakeFork,
        toledoBend,
        samRayburn,
        // Louisiana
        dArbonne,
        claiborne,
        caddo,
        falseRiver,
        // Florida
        okeechobee,
        istokpoga,
        talquin,
        // Georgia/South Carolina
        seminole,
        westPoint,
        lanier,
        clarksHill,
        lakeMurray,
        santeeCooper,
        // North Carolina/Virginia
        kerr,
        falls,
        jordan,
        // Illinois/Indiana/Ohio
        shelbyville,
        carlyle,
        rendLake,
        patoka,
        monroeLake,
      ];

  /// Regional groupings for dropdown/filter organization.
  static Map<String, List<WeatherLakeCoords>> get byRegion => {
        'Tennessee Valley (TVA)': [
          reelfoot,
          kentucky,
          barkley,
          pickwick,
          wheeler,
          guntersville,
          chickamauga,
          wattsBar,
          fortLoudoun,
          norris,
          cherokee,
          douglas,
        ],
        'Tennessee': [
          daleHollow,
          centerHill,
          oldHickory,
          percyPriest,
        ],
        'Arkansas': [
          horseshoe,
          beaver,
          norfork,
          bullShoals,
          greersFerry,
          lakeDardanelle,
          degray,
          ouachita,
          millwood,
          lakeConway,
          lakeChicot,
        ],
        'Mississippi': [
          grenada,
          enid,
          sardis,
          rossBarnett,
        ],
        'Alabama': [
          weiss,
          eufaula,
        ],
        'Kentucky': [
          cumberland,
          greenRiver,
          barrenRiver,
          caveRun,
        ],
        'Missouri': [
          tableRock,
          stockton,
          truman,
          lakeOzarks,
          pommeDeTerre,
        ],
        'Oklahoma & Texas': [
          grandLake,
          texoma,
          lakeFork,
          toledoBend,
          samRayburn,
        ],
        'Louisiana': [
          dArbonne,
          claiborne,
          caddo,
          falseRiver,
        ],
        'Florida': [
          okeechobee,
          istokpoga,
          talquin,
        ],
        'Georgia & South Carolina': [
          seminole,
          westPoint,
          lanier,
          clarksHill,
          lakeMurray,
          santeeCooper,
        ],
        'North Carolina & Virginia': [
          kerr,
          falls,
          jordan,
        ],
        'Illinois, Indiana & Ohio': [
          shelbyville,
          carlyle,
          rendLake,
          patoka,
          monroeLake,
        ],
      };
}
