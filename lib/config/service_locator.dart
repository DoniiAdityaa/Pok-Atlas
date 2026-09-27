import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pokeatlas/repository/pokemon_list/pokemon_list_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/api_service.dart';
import '../features/home/cubit/home_cubit.dart';
import 'constant.dart';

/// Global [GetIt.instance].
final GetIt serviceLocator = GetIt.instance;

/// Set up [GetIt] locator.
Future<void> setUpLocator() async {
  // SharedPreferences for local storage (favorites)
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(prefs);

  // Dio HTTP client (Singleton)
  serviceLocator.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseApi,
        connectTimeout: const Duration(seconds: timeOutDuration),
        receiveTimeout: const Duration(seconds: timeOutDuration),
        sendTimeout: const Duration(seconds: timeOutDuration),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        AwesomeDioInterceptor(
          logRequestTimeout: true,
          logRequestHeaders: true,
          logResponseHeaders: false,
        ),
      );
    }

    return dio;
  });

  // API Service (Retrofit Singleton)
  serviceLocator.registerLazySingleton<ApiService>(
    () => ApiService(
      serviceLocator.get<Dio>(),
      baseUrl: baseApi,
    ),
  );

  // Repositories
  serviceLocator.registerLazySingleton<PokemonListRepository>(
    () => PokemonListRepository(api: serviceLocator.get<ApiService>()),
  );

  // Cubits / BLoCs (Factory: instance baru tiap kali dipanggil/dibuka)
  serviceLocator.registerFactory<HomeCubit>(
    () => HomeCubit(
      repository: serviceLocator.get<PokemonListRepository>(),
    ),
  );
}
