import 'package:dio/dio.dart';
import 'package:pokeatlas/models/pokemon_list_model.dart';
import 'package:retrofit/retrofit.dart';
import '../../config/constant.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: baseApi, parser: Parser.JsonSerializable)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET('/pokemon')
  Future<HttpResponse<PokemonListModel>> getPokemonList({
    @Query('limit') int limit = 20,
    @Query('offset') int offset = 0,
  });
}
