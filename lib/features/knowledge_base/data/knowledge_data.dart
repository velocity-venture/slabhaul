import 'package:slabhaul/core/models/knowledge_article.dart';

// ---------------------------------------------------------------------------
// Seasonal Patterns - real crappie fishing data by season
// ---------------------------------------------------------------------------

const List<SeasonalPattern> kSeasonalPatterns = [
  SeasonalPattern(
    season: 'Winter',
    tempRange: '<50\u00B0F',
    depthRange: '15-30+ ft',
    locations: [
      'Deep creek channels',
      'River channel ledges',
      'Submerged brush piles in deep holes',
      'Bridge pilings in deep water',
      'Standing timber near channel swings',
    ],
    techniques: [
      'Vertical jigging with electronics',
      'Slow trolling over deep structure',
      'LiveScope vertical sniping',
      'Tight-line drop shotting',
    ],
    baits: 'Compact tungsten jig heads (1/16-1/4 oz) tipped with small plastics or minnows. Downsize presentation - fish are lethargic in cold water.',
    colors: [
      'Bone white',
      'Chartreuse',
      'Electric chicken',
      'Pearl/ghost',
      'Monkey milk',
    ],
    notes:
        'Crappie school tightly in deep water during winter. Use electronics to mark suspended fish near channels and drops. Slow, subtle presentations are key - barely hop your jig or hold it still. Fish feed in short windows, often midday when water temps peak. Tungsten jigs sink faster and transmit more feel than lead in deep water.',
  ),
  SeasonalPattern(
    season: 'Pre-Spawn',
    tempRange: '50-60\u00B0F',
    depthRange: '8-15 ft',
    locations: [
      'Creek arms and secondary points',
      'Protected bays near spawning flats',
      'Brush piles on migration routes',
      'Main lake points tapering to flats',
      'Stumps and laydowns along creek channels',
    ],
    techniques: [
      'Long line trolling',
      'Spider rigging',
      'Casting jigs to brush',
      'Slip-bobber rigs over brush piles',
    ],
    baits: '2-3 inch shad profile bodies on 1/8-3/16 oz jig heads. Minnows under slip bobbers are deadly when fish are staged and reluctant to chase.',
    colors: [
      'Natural shad',
      'Chartreuse/white',
      'Blue/pearl',
      'Junebug',
      'Threadfin shad',
    ],
    notes:
        'Pre-spawn crappie stage on mid-depth structure before moving shallow. They follow creek channels and stop on points and brush along migration routes. Water temp drives timing - the first sustained push above 55\u00B0F triggers major movement. Focus on north-facing banks that warm first. Spider rigging multiple rods at varied depths is the most efficient way to find staging fish.',
  ),
  SeasonalPattern(
    season: 'Spawn',
    tempRange: '61-68\u00B0F',
    depthRange: '1.5-6 ft',
    locations: [
      'Shallow brush and stake beds',
      'Submerged vegetation edges',
      'Stumps and laydowns in back of creeks',
      'Boat dock pilings and walkways',
      'Riprap and seawalls',
    ],
    techniques: [
      'Single pole jigging',
      'Float and fly',
      'Push-poling shallow cover',
      'Shooting docks',
      'Sight fishing with polarized glasses',
    ],
    baits: 'Tubes, hair jigs, and live minnows on light 1/32-1/16 oz heads. Finesse is critical - spawning fish are guarding beds and will hit out of aggression, but heavy presentations spook them.',
    colors: [
      'Pink',
      'Chartreuse',
      'White',
      'Orange/chartreuse',
      'Black/chartreuse',
    ],
    notes:
        'Males move shallow first to fan out beds, followed by females. Males guard the nest and are more aggressive - females stage just off beds in slightly deeper water. Target wood and brush in 2-5 ft with slow, hovering presentations. Quiet boat positioning is critical in shallow water. Fish early morning and late evening when boat traffic is minimal. This is trophy season - females are heaviest pre-deposit.',
  ),
  SeasonalPattern(
    season: 'Post-Spawn / Summer',
    tempRange: '>70\u00B0F',
    depthRange: 'Variable (deep)',
    locations: [
      'Standing timber near thermocline',
      'Bridge and dock pilings',
      'Offshore brush piles',
      'Creek channel intersections',
      'Deep points with bait activity',
    ],
    techniques: [
      'Dock shooting',
      'Power trolling (spider rigging at speed)',
      'Vertical jigging with LiveScope',
      'Long line trolling open water',
      'Crankbait trolling ledges',
    ],
    baits: 'Small fry imitations 1-1.5 inch on light heads for dock shooting. Larger 2-3 inch profiles for trolling. Match the hatch - young-of-year shad and bluegill are primary forage.',
    colors: [
      'Translucent/natural',
      'Green pumpkin',
      'Watermelon/red flake',
      'Smoke/silver',
      'Shad gray',
    ],
    notes:
        'Post-spawn crappie scatter and become harder to pattern. Fish relate to the thermocline in stratified lakes - use electronics to find the depth where oxygen and temperature align. Dock shooting excels during summer as crappie seek shade. Night fishing under lights near bridges is productive when surface temps exceed 80\u00B0F. Trolling covers water efficiently to locate roaming schools.',
  ),
  SeasonalPattern(
    season: 'Fall',
    tempRange: 'Cooling (70\u2192 55\u00B0F)',
    depthRange: '10-20 ft',
    locations: [
      'Creek mouths and feeder creek junctions',
      'Main lake points near shad activity',
      'Submerged humps and ridges',
      'Brush piles along migration routes',
      'Wind-blown banks concentrating bait',
    ],
    techniques: [
      'Casting and retrieving',
      'Long lining',
      'Spider rigging creek arms',
      'Trolling crankbaits',
      'Vertical jigging drops',
    ],
    baits: '2-3 inch shad profile bodies are the top producers. Crankbaits that match threadfin shad size (1.5-2 inch) work well trolled at 1.0-1.5 mph.',
    colors: [
      'Blue/purple (clear water)',
      'Chartreuse (stained water)',
      'Silver/black back',
      'Smoke/sparkle',
      'Red/chartreuse',
    ],
    notes:
        'Fall is the great equalizer - crappie feed aggressively as they follow shad into creek arms. Cooling water pushes baitfish into creeks and crappie follow. The fall turnover (when the thermocline breaks down) temporarily scatters fish, but they regroup quickly once water stabilizes. Key on baitfish - where you find shad schools, crappie are nearby. Wind-blown points that concentrate bait are prime targets.',
  ),
];

// ---------------------------------------------------------------------------
// Techniques - real crappie fishing methods with detailed data
// ---------------------------------------------------------------------------

const List<Technique> kTechniques = [
  Technique(
    name: 'Spider Rigging',
    description:
        'Slow-trolling with 6-8 rods fanned out in rod holders across the bow of the boat. The quintessential crappie tournament technique that covers water efficiently while presenting baits at precise depths.',
    setupTips:
        'Mount 8 rod holders in a fan pattern across the bow. Use 10-12 ft B\'n\'M poles or similar long crappie rods. Spool with 6-8 lb mono or 10 lb braid. Rig jigs at varying depths using different sinker weights and line lengths. Use a GPS-enabled trolling motor to maintain 0.3-0.8 mph along waypoint routes.',
    bestConditions:
        'Pre-spawn staging areas, creek channels, submerged brush lines. Best in 8-25 ft of water. Works in clear to moderately stained water. Ideal when fish are scattered along structure rather than holding tight to a single spot.',
    pros: [
      'Covers a wide swath of water - most efficient technique',
      'Presents multiple baits at different depths simultaneously',
      'Precise depth control with the calculator',
      'Tournament-proven: dominates team crappie events',
      'Low-effort once dialed in - let the boat do the work',
    ],
    cons: [
      'Requires significant rod/holder investment',
      'Learning curve for managing 8 rods simultaneously',
      'Limited to open water - cannot fish tight cover',
      'Regulations vary by state (rod limits)',
      'Tangles can be frustrating in wind or current',
    ],
    proTips:
        'Stagger your rod depths in 2-foot increments to find the bite zone quickly. Once you catch two fish at the same depth, set all rods to that zone. Use your SlabHaul depth calculator to dial in exact sinker weight and line length combos. Mark productive GPS waypoints and troll repeated passes. Paint your jig heads with a UV marker for an edge in stained water.',
  ),
  Technique(
    name: 'Dock Shooting',
    description:
        'A specialized technique where anglers use a spinning reel to slingshot lightweight jigs far back under boat docks, walkways, and other overhead cover that crappie use for shade and ambush points.',
    setupTips:
        'Use a 5.5-6.5 ft light-action spinning rod with a size 1000-2000 reel spooled with 4-6 lb fluorocarbon. Rig a 1/16-1/8 oz jig head with a small soft plastic (1-1.5 inch). Hold the jig between your index finger and thumb, load the rod tip, and release to skip the jig under docks. Practice in your yard first.',
    bestConditions:
        'Summer and post-spawn when crappie seek shade under docks. Best during midday heat when fish push tight to cover. Works best at marinas and residential docks with deep water nearby. Clear to moderately stained water.',
    pros: [
      'Accesses fish that no other technique can reach',
      'Extremely effective in summer heat',
      'One of the most fun techniques - highly visual and active',
      'Light tackle means amazing fights on big crappie',
      'Low cost - minimal gear required',
    ],
    cons: [
      'Steep learning curve for accurate shooting',
      'Risk of backlash and snagging dock hardware',
      'Limited to areas with dock/overhead cover',
      'Trespassing concerns on private docks',
      'Hand fatigue during long sessions',
    ],
    proTips:
        'The key is a low, flat trajectory that skips the jig like a stone. Aim for the back wall or the darkest shadow under the dock. Let the jig pendulum-fall on slack line - crappie often hit on the initial drop. Work docks systematically: outside corners first, then walkway joints, then deepest shade. Fish fast and move on - dock crappie commit in the first 10 seconds or not at all.',
  ),
  Technique(
    name: 'LiveScope Sniping',
    description:
        'Using forward-facing sonar (Garmin LiveScope, Lowrance ActiveTarget, or Humminbird MEGA Live) to visually locate and target individual crappie in real time. The angler watches the screen, drops or casts to the fish, and watches the bite happen live.',
    setupTips:
        'Mount a forward-facing sonar transducer on a trolling motor or pole mount. Use a long crappie rod (10-14 ft) for vertical presentations or a 7 ft spinning rod for casting. Drop jigs directly to fish seen on screen. Maintain boat position with Spot-Lock or anchor.',
    bestConditions:
        'Any depth where fish can be marked on electronics. Most effective in deep water (15+ ft) where fish suspend off structure. Works year-round but dominates winter and summer vertical patterns. Clear water gives the best sonar returns.',
    pros: [
      'See fish in real time - eliminates guesswork',
      'Extremely precise targeting of individual fish',
      'Works at any depth',
      'Can identify size before committing to a fish',
      'Game-changing for deep winter and suspended fish',
    ],
    cons: [
      'Very expensive - \$2,500-4,000+ for quality units',
      'Significant learning curve for reading the screen',
      'Battery-intensive - requires lithium batteries',
      'Some consider it unsportsmanlike',
      'Can lead to over-harvesting if not practiced responsibly',
    ],
    proTips:
        'Watch your jig on screen and keep it 1-2 feet above fish until they rise to it. If a fish turns away, jiggle your bait to trigger a reaction strike. Crappie that are "looking up" on screen are feeding - target those first. Fish that are tight to the bottom or facing down are neutral and harder to trigger. Save waypoints of productive structure and revisit during similar conditions.',
  ),
  Technique(
    name: 'Long Line Trolling',
    description:
        'Trolling jigs or crankbaits on long lines (50-100+ ft) behind the boat at controlled speeds. Unlike spider rigging which uses rods fanned from the bow, long lining trails baits directly behind the boat to cover expansive flats and channels.',
    setupTips:
        'Use 10-14 ft crappie rods in rear-facing rod holders. Deploy 50-100 ft of line behind the boat with 1/8-1/4 oz jig heads. Troll at 0.5-1.2 mph using a GPS trolling motor. Use planer boards to spread lines laterally and avoid tangles. Stagger line lengths to cover different distances.',
    bestConditions:
        'Pre-spawn and fall when crappie are roaming creek channels and staging on structure. Effective over submerged brush lines, channel ledges, and open-water flats. Best in stained to moderately clear water where the long distance from the boat prevents spooking fish.',
    pros: [
      'Covers the most water of any crappie technique',
      'Distance from boat reduces spooking in clear water',
      'Effective for locating scattered, roaming fish',
      'Planer boards add lateral spread',
      'Works well in combination with spider rigging',
    ],
    cons: [
      'Requires a large boat area for long rod management',
      'Line tangles are common, especially in turns',
      'Less depth precision than vertical techniques',
      'Difficult in heavy boat traffic',
      'Turning requires careful line management',
    ],
    proTips:
        'Make wide, gradual turns to prevent tangles. Use different colored line or bead markers to quickly identify which rod is which length. The outside lines in a turn speed up and run shallower - adjust weights accordingly. Troll into the wind for better boat control and more natural bait presentation. Mark every catch on GPS and build a trolling route that connects productive waypoints.',
  ),
  Technique(
    name: 'Single Pole Jigging',
    description:
        'The classic crappie fishing method - one rod, one jig, vertical presentation to specific cover. The angler positions the boat over or beside structure and drops or dips a jig into brush piles, stake beds, timber, and other hard targets.',
    setupTips:
        'Use a 10-16 ft jigging pole (telescopic or multi-piece) with a sensitive tip. Spool a small spincast or baitcast reel with 6-10 lb line. Rig a 1/32-1/8 oz jig head tipped with a tube, curly tail, or minnow. Lower the jig vertically into cover using the long rod for precise placement.',
    bestConditions:
        'Spawn and post-spawn when fish are tight to specific cover. Brush piles, stake beds, stumps, and laydowns in 3-15 ft. Calm conditions allow better boat control. Works in all water clarities but excels in stained water where fish hold tighter to cover.',
    pros: [
      'Most precise cover fishing technique',
      'Simple setup - one rod, minimal gear',
      'Excellent for beginners',
      'Feel every bite on a sensitive pole',
      'Works in the tightest cover where other techniques fail',
    ],
    cons: [
      'Covers water slowly - one spot at a time',
      'Requires knowing where fish hold (structure knowledge)',
      'Long poles are cumbersome in wind',
      'Limited to fish directly below the rod tip',
      'Not tournament-efficient against spider riggers',
    ],
    proTips:
        'Dip your jig into every part of the brush pile - top, middle, bottom, and edges. Crappie often suspend just above the cover canopy. If you feel your jig hit brush, hold it still for 5 seconds before moving - fish often watch your jig settle and then commit. Use your trolling motor to hover silently over the target. Mark productive brush piles in SlabHaul and build a milk run of proven spots.',
  ),
];

// ---------------------------------------------------------------------------
// Baits & Lures - real crappie baits ranked by effectiveness
// ---------------------------------------------------------------------------

const List<BaitLure> kBaitsAndLures = [
  BaitLure(
    type: 'Tube Jigs',
    ranking: '#1 Overall',
    topSizes: '1.5 inch (spawn/finesse), 2 inch (all-around), 2.5 inch (big fish)',
    bestColors: [
      'Chartreuse/white',
      'Monkey milk',
      'Electric chicken',
      'Black/chartreuse',
      'Pearl/pink',
      'Junebug',
    ],
    riggingMethods:
        'Thread onto a 1/32-1/4 oz tube jig head (match weight to depth and current). For spider rigging, use 1/8-1/4 oz heads. For single pole jigging, use 1/32-1/16 oz. Can also be rigged on a drop shot for suspended fish. Tip with a small piece of minnow or gulp for added scent in tough bites.',
  ),
  BaitLure(
    type: 'Soft Plastic Minnows',
    ranking: '#1 Dock Shooting',
    topSizes: '1 inch (dock shooting), 1.5 inch (finesse), 2 inch (trolling/casting)',
    bestColors: [
      'Smoke/silver flake',
      'Shad gray',
      'Translucent chartreuse',
      'Watermelon/red flake',
      'Blue ice',
      'Pearl/white',
    ],
    riggingMethods:
        'Thread onto a 1/16-1/8 oz round or darter-style jig head. For dock shooting, use 1/16 oz with a 1 inch body for maximum skip distance. For trolling, use a 1/8 oz head with a 2 inch body. The minnow profile matches the primary crappie forage (threadfin shad) and triggers feeding responses in all seasons.',
  ),
  BaitLure(
    type: 'Curly Tail Grubs',
    ranking: 'Most Durable',
    topSizes: '1.5 inch (light bite), 2 inch (standard), 3 inch (trophy hunting)',
    bestColors: [
      'Chartreuse',
      'White',
      'Pink/white',
      'Motor oil',
      'Pumpkin/chartreuse',
      'Red/chartreuse',
    ],
    riggingMethods:
        'Thread onto a 1/16-3/16 oz ball-head jig. The curly tail provides vibration and action on the fall and during a slow retrieve. Most durable soft plastic option - one grub can catch dozens of fish. Works on all retrieval methods: cast and retrieve, slow troll, vertical jig, and under a float. Add a small spinner blade above the jig head for extra flash in stained water.',
  ),
  BaitLure(
    type: 'Hair Jigs',
    ranking: 'Best Finesse',
    topSizes: '1/32 oz (ultra-light), 1/16 oz (standard), 1/8 oz (deeper presentations)',
    bestColors: [
      'White',
      'Chartreuse',
      'Pink',
      'Brown/orange',
      'Olive/white',
      'Black',
    ],
    riggingMethods:
        'Hair jigs are fished as-is - no trailer needed, though you can add a small plastic body for bulk. The marabou or craft hair undulates naturally in the water with minimal angler input. Best fished vertically with slow hops or under a slip float. The subtle action excels when crappie are finicky - winter cold fronts, high-pressure bluebird days, and heavily pressured waters. Tie direct to fluorocarbon for the most natural presentation.',
  ),
];
