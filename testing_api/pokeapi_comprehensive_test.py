"""
PokeAPI Comprehensive Test
Testing endpoints relevant for PokéAtlas application

Base URL: https://pokeapi.co/api/v2
Documentation: https://pokeapi.co/docs/v2

Test Date: 2026-09-27
Purpose: Understanding API structure before Flutter implementation
"""

import requests
import json
from typing import Dict, Any

BASE_URL = "https://pokeapi.co/api/v2"

def print_section(title: str):
    """Print section header"""
    print("\n" + "="*80)
    print(f"  {title}")
    print("="*80 + "\n")

def print_subsection(title: str):
    """Print subsection header"""
    print(f"\n--- {title} ---\n")

def test_request(endpoint: str, description: str) -> Dict[str, Any]:
    """Make API request and display result"""
    url = f"{BASE_URL}{endpoint}"
    print(f"Testing: {description}")
    print(f"URL: {url}")
    
    try:
        response = requests.get(url, timeout=10)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response Preview:")
            print(json.dumps(data, indent=2)[:1000] + "...\n")
            return data
        else:
            print(f"Error: {response.status_code}\n")
            return {}
    except Exception as e:
        print(f"Exception: {e}\n")
        return {}

def analyze_field(data: Dict, field_name: str, max_depth: int = 2):
    """Analyze important field structure"""
    if field_name in data:
        value = data[field_name]
        print(f"  {field_name}: {type(value).__name__}")
        
        if isinstance(value, list) and len(value) > 0:
            print(f"    - List length: {len(value)}")
            print(f"    - First item: {value[0]}")
        elif isinstance(value, dict):
            print(f"    - Keys: {list(value.keys())[:5]}")
        else:
            print(f"    - Value: {value}")

# =============================================================================
# TEST 1: GET /pokemon - Pokemon List
# =============================================================================
print_section("TEST 1: GET /pokemon - Pokemon List")

print_subsection("1.1 Basic List (Default)")
data = test_request("/pokemon", "Get default Pokemon list")
if data:
    print("Important Fields:")
    analyze_field(data, "count")
    analyze_field(data, "next")
    analyze_field(data, "previous")
    analyze_field(data, "results")
    
    if "results" in data and len(data["results"]) > 0:
        print("\nFirst Pokemon:")
        print(json.dumps(data["results"][0], indent=2))

print_subsection("1.2 List with Pagination")
data = test_request("/pokemon?limit=5&offset=0", "Get 5 Pokemon (page 1)")
data = test_request("/pokemon?limit=5&offset=5", "Get 5 Pokemon (page 2)")

print_subsection("1.3 Key Observations")
print("""
- Total count available for pagination calculation
- Each item has: name, url
- Need to fetch detail from url for more info
- Default limit: 20
- Good for Explore page with infinite scroll
""")

# =============================================================================
# TEST 2: GET /pokemon/{id} - Pokemon Detail
# =============================================================================
print_section("TEST 2: GET /pokemon/{id} - Pokemon Detail")

print_subsection("2.1 Detail by ID")
data = test_request("/pokemon/25", "Get Pikachu by ID (25)")
if data:
    print("Important Fields for PokéAtlas:")
    analyze_field(data, "id")
    analyze_field(data, "name")
    analyze_field(data, "height")
    analyze_field(data, "weight")
    analyze_field(data, "types")
    analyze_field(data, "abilities")
    analyze_field(data, "stats")
    analyze_field(data, "sprites")
    analyze_field(data, "moves")
    analyze_field(data, "species")
    
    # Detailed sprite analysis
    if "sprites" in data:
        print("\nSprite URLs:")
        sprites = data["sprites"]
        print(f"  front_default: {sprites.get('front_default')}")
        print(f"  front_shiny: {sprites.get('front_shiny')}")
        
        if "other" in sprites:
            print("\n  Official Artwork:")
            official = sprites["other"].get("official-artwork", {})
            print(f"    front_default: {official.get('front_default')}")
    
    # Types
    if "types" in data:
        print("\nTypes:")
        for t in data["types"]:
            print(f"  - {t['type']['name']} (slot: {t['slot']})")
    
    # Stats
    if "stats" in data:
        print("\nBase Stats:")
        for s in data["stats"]:
            print(f"  - {s['stat']['name']}: {s['base_stat']}")
    
    # Abilities
    if "abilities" in data:
        print("\nAbilities:")
        for a in data["abilities"]:
            hidden = " (hidden)" if a.get("is_hidden") else ""
            print(f"  - {a['ability']['name']}{hidden}")

print_subsection("2.2 Detail by Name")
data = test_request("/pokemon/charizard", "Get Charizard by name")

print_subsection("2.3 Key Observations")
print("""
- ID and name both work as identifier
- Height in decimetres (divide by 10 for meters)
- Weight in hectograms (divide by 10 for kg)
- Sprites: multiple versions available
  * front_default: best for list/card
  * official-artwork: best for detail page (high quality)
- Types: array with slot (primary/secondary)
- Stats: base_stat value + stat name
- Abilities: can be hidden
- Moves: huge array, need filtering
- Species: URL for more info (generation, evolution)
""")

# =============================================================================
# TEST 3: GET /type - Pokemon Types
# =============================================================================
print_section("TEST 3: GET /type - Pokemon Types List")

data = test_request("/type", "Get all Pokemon types")
if data:
    print("Available Types:")
    if "results" in data:
        for t in data["results"]:
            print(f"  - {t['name']}")

print_subsection("3.1 Key Observations")
print("""
- 18+ types available
- Useful for filter chips in Explore page
- Each type has detail endpoint
""")

# =============================================================================
# TEST 4: GET /type/{id} - Type Detail
# =============================================================================
print_section("TEST 4: GET /type/{id} - Type Detail")

data = test_request("/type/fire", "Get Fire type detail")
if data:
    print("Important Fields:")
    analyze_field(data, "id")
    analyze_field(data, "name")
    analyze_field(data, "pokemon")
    
    if "pokemon" in data:
        print(f"\nTotal Fire Pokemon: {len(data['pokemon'])}")
        print("First 5 Fire Pokemon:")
        for i, p in enumerate(data["pokemon"][:5]):
            print(f"  {i+1}. {p['pokemon']['name']}")

print_subsection("4.1 Key Observations")
print("""
- Returns list of all Pokemon with that type
- Useful for filter by type feature
- Can be cached since rarely changes
""")

# =============================================================================
# TEST 5: GET /pokemon-species/{id} - Pokemon Species
# =============================================================================
print_section("TEST 5: GET /pokemon-species/{id} - Pokemon Species")

data = test_request("/pokemon-species/25", "Get Pikachu species")
if data:
    print("Important Fields:")
    analyze_field(data, "id")
    analyze_field(data, "name")
    analyze_field(data, "generation")
    analyze_field(data, "evolution_chain")
    analyze_field(data, "flavor_text_entries")
    analyze_field(data, "genera")
    
    if "generation" in data:
        print(f"\nGeneration: {data['generation']['name']}")
    
    if "evolution_chain" in data:
        print(f"Evolution Chain URL: {data['evolution_chain']['url']}")
    
    if "flavor_text_entries" in data and len(data["flavor_text_entries"]) > 0:
        # Get English description
        for entry in data["flavor_text_entries"]:
            if entry["language"]["name"] == "en":
                print(f"\nDescription: {entry['flavor_text'][:100]}...")
                break

print_subsection("5.1 Key Observations")
print("""
- Contains generation info
- Evolution chain URL (need separate request)
- Flavor text (Pokemon description)
- Genera (species category like "Mouse Pokemon")
- Good for detail page additional info
""")

# =============================================================================
# TEST 6: GET /evolution-chain/{id} - Evolution Chain
# =============================================================================
print_section("TEST 6: GET /evolution-chain/{id} - Evolution Chain")

data = test_request("/evolution-chain/10", "Get Pikachu evolution chain")
if data:
    print("Chain Structure:")
    if "chain" in data:
        chain = data["chain"]
        
        def print_evolution(chain_data, level=0):
            indent = "  " * level
            species_name = chain_data["species"]["name"]
            print(f"{indent}- {species_name}")
            
            if "evolves_to" in chain_data and len(chain_data["evolves_to"]) > 0:
                for evolution in chain_data["evolves_to"]:
                    print_evolution(evolution, level + 1)
        
        print_evolution(chain)

print_subsection("6.1 Key Observations")
print("""
- Nested structure: species -> evolves_to -> evolves_to
- Each evolution has evolution_details (level, item, etc)
- Useful for evolution tree visualization
- Complex feature, can be Phase 2
""")

# =============================================================================
# TEST 7: GET /ability/{id} - Ability Detail
# =============================================================================
print_section("TEST 7: GET /ability/{id} - Ability Detail")

data = test_request("/ability/9", "Get Static ability (Pikachu)")
if data:
    print("Important Fields:")
    analyze_field(data, "id")
    analyze_field(data, "name")
    analyze_field(data, "effect_entries")
    
    if "effect_entries" in data:
        for entry in data["effect_entries"]:
            if entry["language"]["name"] == "en":
                print(f"\nEffect: {entry['effect'][:150]}...")
                print(f"Short Effect: {entry['short_effect']}")
                break

print_subsection("7.1 Key Observations")
print("""
- Full effect description available
- Short effect for quick display
- Useful for ability detail popup/modal
""")

# =============================================================================
# TEST 8: GET /move/{id} - Move Detail
# =============================================================================
print_section("TEST 8: GET /move/{id} - Move Detail")

data = test_request("/move/85", "Get Thunderbolt move")
if data:
    print("Important Fields:")
    analyze_field(data, "id")
    analyze_field(data, "name")
    analyze_field(data, "type")
    analyze_field(data, "power")
    analyze_field(data, "accuracy")
    analyze_field(data, "pp")
    analyze_field(data, "effect_entries")
    
    if "type" in data:
        print(f"\nType: {data['type']['name']}")
    print(f"Power: {data.get('power', 'N/A')}")
    print(f"Accuracy: {data.get('accuracy', 'N/A')}")
    print(f"PP: {data.get('pp', 'N/A')}")

print_subsection("8.1 Key Observations")
print("""
- Complete move information
- Type, power, accuracy, PP
- Effect description
- Pokemon has 50+ moves, need filtering/pagination
- Can be Phase 2 feature
""")

# =============================================================================
# TEST 9: GET /generation/{id} - Generation
# =============================================================================
print_section("TEST 9: GET /generation/{id} - Generation Detail")

data = test_request("/generation/1", "Get Generation I (Kanto)")
if data:
    print("Important Fields:")
    analyze_field(data, "id")
    analyze_field(data, "name")
    analyze_field(data, "main_region")
    analyze_field(data, "pokemon_species")
    
    if "main_region" in data:
        print(f"\nRegion: {data['main_region']['name']}")
    
    if "pokemon_species" in data:
        print(f"Total Pokemon: {len(data['pokemon_species'])}")
        print("\nFirst 10 Pokemon:")
        for i, p in enumerate(data["pokemon_species"][:10]):
            print(f"  {i+1}. {p['name']}")

print_subsection("9.1 Key Observations")
print("""
- Generation I-IX available
- Each has region name
- List of all Pokemon in generation
- Useful for generation filter feature
""")

# =============================================================================
# FINAL SUMMARY
# =============================================================================
print_section("FINAL SUMMARY & RECOMMENDATIONS")

print_subsection("A. Endpoints for MVP (Phase 1)")
print("""
1. GET /pokemon?limit={n}&offset={n}
   - For Explore page list
   - Pagination support

2. GET /pokemon/{id}
   - For Pokemon detail page
   - Contains: id, name, types, stats, sprites, abilities, height, weight

3. GET /type
   - For filter chips

4. GET /type/{id}
   - For filter by type
""")

print_subsection("B. Endpoints for Advanced Features (Phase 2+)")
print("""
5. GET /pokemon-species/{id}
   - Generation info
   - Description text
   - Evolution chain URL

6. GET /evolution-chain/{id}
   - Evolution tree visualization

7. GET /ability/{id}
   - Ability detail popup

8. GET /generation/{id}
   - Filter by generation

9. GET /move/{id}
   - Move detail (if showing moves)
""")

print_subsection("C. Dart Models Needed")
print("""
Core Models (MVP):
1. PokemonListResponse
   - count: int
   - next: String?
   - previous: String?
   - results: List<PokemonListItem>

2. PokemonListItem
   - name: String
   - url: String

3. PokemonDetail
   - id: int
   - name: String
   - height: int
   - weight: int
   - types: List<PokemonType>
   - abilities: List<PokemonAbility>
   - stats: List<PokemonStat>
   - sprites: PokemonSprites
   - species: SpeciesReference

4. PokemonType
   - slot: int
   - type: TypeReference

5. PokemonStat
   - base_stat: int
   - stat: StatReference

6. PokemonSprites
   - front_default: String?
   - front_shiny: String?
   - other: Map? (for official-artwork)

7. TypeListResponse
   - results: List<TypeListItem>

8. TypeDetail
   - id: int
   - name: String
   - pokemon: List<TypePokemon>

Additional Models (Phase 2):
9. PokemonSpecies
10. EvolutionChain
11. AbilityDetail
12. MoveDetail
13. GenerationDetail
""")

print_subsection("D. Endpoint Relations")
print("""
Flow Diagram:

/pokemon (list)
    └─> /pokemon/{id} (detail)
            ├─> /type/{id} (type detail)
            ├─> /ability/{id} (ability detail)
            ├─> /pokemon-species/{id} (species)
            │       └─> /evolution-chain/{id} (evolution)
            └─> /move/{id} (move detail)

/type (list)
    └─> /type/{id} (filter by type)

/generation/{id} (filter by generation)
""")

print_subsection("E. Image/Sprite Strategy")
print("""
Available Image Sources:
1. sprites.front_default
   - Small size (~96px)
   - Use for: List cards

2. sprites.other.official-artwork.front_default
   - High quality PNG
   - Use for: Detail page main image

3. sprites.front_shiny
   - Shiny variant
   - Use for: Easter egg or special feature

Recommendation:
- Use CachedNetworkImage for caching
- Show placeholder while loading
- Fallback if image fails
""")

print_subsection("F. Implementation Notes for Flutter")
print("""
1. API Client Setup:
   - Use Dio for HTTP client
   - Base URL: https://pokeapi.co/api/v2
   - No authentication needed
   - Rate limit: Be reasonable (cache responses)

2. Repository Pattern:
   PokemonRepository
     ├─> PokemonRemoteDataSource (Dio)
     └─> PokemonLocalDataSource (Cache/Hive - optional)

3. State Management (Cubit):
   - PokemonListCubit (Explore page)
   - PokemonDetailCubit (Detail page)
   - TypeFilterCubit (Filter)
   - FavoritesCubit (Local only)

4. Pagination Strategy:
   - Initial: limit=20, offset=0
   - Load more: offset += 20
   - Infinite scroll with ListView.builder

5. Caching Strategy:
   - Cache pokemon detail (1 hour)
   - Cache type list (forever - rarely changes)
   - Cache images (CachedNetworkImage auto)
   - No need to cache list (always fresh)

6. Error Handling:
   - Network error: Show retry button
   - 404: Pokemon not found
   - Timeout: Show timeout message

7. Loading States:
   - Initial: Show shimmer skeleton
   - Loading more: Show bottom loader
   - Refreshing: Pull to refresh indicator

8. Search Implementation:
   - Client-side: Filter loaded list
   - Or: Direct API call /pokemon/{name}
   - Debounce search input (500ms)

9. Favorites:
   - Store locally (SharedPreferences or Hive)
   - Store pokemon ID only
   - Fetch detail when viewing favorites

10. Performance:
    - Lazy load images
    - Paginate moves list (huge)
    - Don't load all Pokemon at once
    - Use const widgets where possible
""")

print_subsection("G. API Limitations & Workarounds")
print("""
1. No Search Endpoint:
   - Workaround: Use /pokemon/{name} direct
   - Or: Load all names and filter client-side

2. No User System:
   - Workaround: Use local storage for favorites
   - Phase 2: Add Firebase for sync

3. Images Sometimes Missing:
   - Workaround: Always check null and show placeholder

4. Huge Moves Array:
   - Workaround: Show only first 10 or paginate

5. Rate Limiting:
   - Workaround: Cache aggressively
   - Be nice to API (reasonable requests)
""")

print_subsection("H. Recommended Development Flow")
print("""
Phase 1 - MVP (2 weeks):
Day 1-2: Setup project, models, API client
Day 3-4: Pokemon list with pagination
Day 5-6: Pokemon detail page
Day 7-8: Type filter
Day 9-10: Search feature
Day 11-12: Polish UI, loading states, errors
Day 13-14: Testing, bug fixes

Phase 2 - Enhanced (1-2 weeks):
- Favorites (local)
- Compare feature
- Generation filter
- Species info
- Better animations

Phase 3 - Advanced (1-2 weeks):
- Evolution chain
- Abilities detail
- Moves detail
- Firebase sync
- Dark mode

Phase 4 - Polish (1 week):
- Performance optimization
- Caching strategy
- Offline mode
- Analytics
- Testing
""")

print("\n" + "="*80)
print("  TEST COMPLETED")
print("="*80)
print("\nNext Steps:")
print("1. Review this test output")
print("2. Confirm endpoint selection for MVP")
print("3. Start Flutter implementation:")
print("   - Setup folder structure")
print("   - Create Dart models")
print("   - Setup Dio + Retrofit")
print("   - Create repositories")
print("   - Implement Cubits")
print("   - Build UI")
print("\nReady to start Flutter implementation? ✨")
