#!/bin/bash

# PokeAPI Comprehensive Test using curl
# Testing endpoints relevant for PokéAtlas application

BASE_URL="https://pokeapi.co/api/v2"

echo "================================================================================"
echo "  PokeAPI Comprehensive Test for PokéAtlas"
echo "  Base URL: $BASE_URL"
echo "  Test Date: $(date)"
echo "================================================================================"
echo ""

# Function to print section
print_section() {
    echo ""
    echo "================================================================================"
    echo "  $1"
    echo "================================================================================"
    echo ""
}

# Function to test endpoint
test_endpoint() {
    local endpoint=$1
    local description=$2
    
    echo "Testing: $description"
    echo "URL: ${BASE_URL}${endpoint}"
    echo ""
    
    response=$(curl -s "${BASE_URL}${endpoint}")
    status=$?
    
    if [ $status -eq 0 ]; then
        echo "Status: Success"
        echo "Response Preview:"
        echo "$response" | python3 -m json.tool | head -100
        echo ""
        echo "$response"
    else
        echo "Status: Failed (curl error $status)"
    fi
    
    echo "---"
    echo ""
}

# =============================================================================
# TEST 1: GET /pokemon - Pokemon List
# =============================================================================
print_section "TEST 1: GET /pokemon - Pokemon List"

echo "1.1 Basic List (Default)"
response=$(curl -s "${BASE_URL}/pokemon")
echo "Total Pokemon: $(echo $response | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['count'])")"
echo "Next URL: $(echo $response | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('next', 'null'))")"
echo ""
echo "First 5 Pokemon:"
echo "$response" | python3 -m json.tool | grep -A 2 "results" | head -20
echo ""

echo "1.2 List with Pagination (limit=5, offset=0)"
curl -s "${BASE_URL}/pokemon?limit=5&offset=0" | python3 -m json.tool | head -40
echo ""

echo "Key Observations:"
echo "- Total count: 1351 Pokemon available"
echo "- Pagination support: limit & offset parameters"
echo "- Each item: name + url for detail"
echo "- Default limit: 20"
echo ""

# =============================================================================
# TEST 2: GET /pokemon/{id} - Pokemon Detail
# =============================================================================
print_section "TEST 2: GET /pokemon/25 - Pikachu Detail"

pikachu=$(curl -s "${BASE_URL}/pokemon/25")

echo "Basic Info:"
echo "$pikachu" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"ID: {data['id']}\")
print(f\"Name: {data['name']}\")
print(f\"Height: {data['height']} decimetres ({data['height']/10}m)\")
print(f\"Weight: {data['weight']} hectograms ({data['weight']/10}kg)\")
"
echo ""

echo "Types:"
echo "$pikachu" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for t in data['types']:
    print(f\"  - {t['type']['name']} (slot {t['slot']})\")
"
echo ""

echo "Base Stats:"
echo "$pikachu" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for s in data['stats']:
    print(f\"  - {s['stat']['name']}: {s['base_stat']}\")
"
echo ""

echo "Abilities:"
echo "$pikachu" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for a in data['abilities']:
    hidden = ' (hidden)' if a.get('is_hidden') else ''
    print(f\"  - {a['ability']['name']}{hidden}\")
"
echo ""

echo "Sprites:"
echo "$pikachu" | python3 -c "
import sys, json
data = json.load(sys.stdin)
sprites = data['sprites']
print(f\"  front_default: {sprites.get('front_default')}\")
print(f\"  front_shiny: {sprites.get('front_shiny')}\")
if 'other' in sprites and 'official-artwork' in sprites['other']:
    print(f\"  official-artwork: {sprites['other']['official-artwork'].get('front_default')}\")
"
echo ""

echo "Key Observations:"
echo "- Complete Pokemon data available"
echo "- Best image: sprites.other.official-artwork.front_default"
echo "- Stats: 6 base stats (hp, attack, defense, sp-atk, sp-def, speed)"
echo "- Types: array with slot (1=primary, 2=secondary)"
echo ""

# =============================================================================
# TEST 3: GET /type - Pokemon Types
# =============================================================================
print_section "TEST 3: GET /type - Pokemon Types List"

types=$(curl -s "${BASE_URL}/type")
echo "Available Types:"
echo "$types" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for t in data['results']:
    print(f\"  - {t['name']}\")
"
echo ""

# =============================================================================
# TEST 4: GET /type/fire - Fire Type Detail
# =============================================================================
print_section "TEST 4: GET /type/fire - Fire Type Detail"

fire_type=$(curl -s "${BASE_URL}/type/fire")
echo "Fire Type Pokemon (first 10):"
echo "$fire_type" | python3 -c "
import sys, json
data = json.load(sys.stdin)
pokemon = data['pokemon']
print(f\"Total: {len(pokemon)} Pokemon\")
print(\"\\nFirst 10:\")
for i, p in enumerate(pokemon[:10]):
    print(f\"  {i+1}. {p['pokemon']['name']}\")
"
echo ""

# =============================================================================
# TEST 5: GET /pokemon-species/25 - Pikachu Species
# =============================================================================
print_section "TEST 5: GET /pokemon-species/25 - Pikachu Species"

species=$(curl -s "${BASE_URL}/pokemon-species/25")
echo "Species Info:"
echo "$species" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"Generation: {data['generation']['name']}\")
print(f\"Evolution Chain: {data['evolution_chain']['url']}\")
print(\"\\nDescription (English):\")
for entry in data['flavor_text_entries']:
    if entry['language']['name'] == 'en':
        print(f\"  {entry['flavor_text'][:100]}...\")
        break
"
echo ""

# =============================================================================
# TEST 6: GET /generation/1 - Generation I
# =============================================================================
print_section "TEST 6: GET /generation/1 - Generation I (Kanto)"

gen1=$(curl -s "${BASE_URL}/generation/1")
echo "Generation I Info:"
echo "$gen1" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"Name: {data['name']}\")
print(f\"Region: {data['main_region']['name']}\")
print(f\"Total Pokemon: {len(data['pokemon_species'])}\")
print(\"\\nFirst 10 Pokemon:\")
for i, p in enumerate(data['pokemon_species'][:10]):
    print(f\"  {i+1}. {p['name']}\")
"
echo ""

# =============================================================================
# SUMMARY
# =============================================================================
print_section "SUMMARY & RECOMMENDATIONS"

cat << 'EOF'
A. ENDPOINTS FOR MVP (Phase 1):
   ✓ GET /pokemon?limit={n}&offset={n}  - List with pagination
   ✓ GET /pokemon/{id}                   - Detail page
   ✓ GET /type                           - Filter chips
   ✓ GET /type/{id}                      - Filter by type

B. ENDPOINTS FOR PHASE 2:
   - GET /pokemon-species/{id}           - Generation, description
   - GET /evolution-chain/{id}           - Evolution tree
   - GET /ability/{id}                   - Ability detail
   - GET /generation/{id}                - Filter by generation

C. KEY DART MODELS NEEDED:
   1. PokemonListResponse (count, next, previous, results)
   2. PokemonListItem (name, url)
   3. PokemonDetail (id, name, types, stats, sprites, abilities, etc)
   4. PokemonType
   5. PokemonStat
   6. PokemonSprites
   7. TypeListResponse
   8. TypeDetail

D. IMAGE STRATEGY:
   - List cards: sprites.front_default
   - Detail page: sprites.other.official-artwork.front_default
   - Use CachedNetworkImage with placeholder

E. PAGINATION STRATEGY:
   - Initial load: limit=20, offset=0
   - Load more: offset += 20
   - Total available from response.count

F. IMPLEMENTATION NOTES:
   1. Use Dio for HTTP client
   2. Retrofit for API generation
   3. Repository pattern
   4. Cubit for state management
   5. Cache images with CachedNetworkImage
   6. Local storage for favorites (SharedPreferences/Hive)

G. NEXT STEPS:
   1. Setup folder structure (features/pokemon/data/models)
   2. Create Dart models with json_serializable
   3. Setup Dio + Retrofit API service
   4. Create repository
   5. Implement PokemonListCubit & PokemonDetailCubit
   6. Build UI (Explore + Detail pages)

✨ API Test Completed! Ready for Flutter implementation.
EOF

echo ""
echo "================================================================================"
echo "  TEST COMPLETED"
echo "================================================================================"
