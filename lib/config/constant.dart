import 'package:pokeatlas/config/env/env.dart';

/// App Config
const String appName = "PokéAtlas";
const String appVersion = "1.0.0";

/// Network Config
const String baseApi = Env.baseUrl;
const int timeOutDuration = 30;

/// Pagination
const int defaultPageSize = 20;
const int initialOffset = 0;

/// Cache Duration (in minutes)
const int pokemonDetailCacheDuration = 60;
const int typeListCacheDuration = 1440; // 24 hours

/// Image config
const double imageMaxHeight = 720;
const double imageMaxWidth = 720;

/// API Endpoints
class ApiEndpoints {
  // Pokemon
  static const String pokemon = '/pokemon';
  static String pokemonDetail(dynamic id) => '/pokemon/$id';
  
  // Type
  static const String type = '/type';
  static String typeDetail(dynamic id) => '/type/$id';
  
  // Species
  static String pokemonSpecies(int id) => '/pokemon-species/$id';
  
  // Evolution
  static String evolutionChain(int id) => '/evolution-chain/$id';
  
  // Ability
  static String ability(int id) => '/ability/$id';
  
  // Move
  static String move(int id) => '/move/$id';
  
  // Generation
  static String generation(int id) => '/generation/$id';
}
