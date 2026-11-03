import 'dart:convert';
import 'package:http/http.dart' as http;

class IbgeCityService {
  static const String _ibgeScUrl =
      'https://servicodados.ibge.gov.br/api/v1/localidades/estados/SC/municipios?orderBy=nome';

  List<String>? _cachedCities;

  Future<List<String>> fetchSantaCatarinaCities() async {
    if (_cachedCities != null && _cachedCities!.isNotEmpty) {
      return _cachedCities!;
    }
    try {
      final response = await http
          .get(Uri.parse(_ibgeScUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final cities = data.map((item) => item['nome'].toString()).toList();
        if (cities.isNotEmpty) {
          _cachedCities = cities;
          return cities;
        }
      }
      return fallbackRegionalCities;
    } catch (_) {
      // Caso o celular esteja sem internet na hora da apresentação, usa lista de segurança
      return fallbackRegionalCities;
    }
  }

  static const List<String> fallbackRegionalCities = [
    'Rio do Sul',
    'Lontras',
    'Ibirama',
    'Agronômica',
    'Laurentino',
    'Presidente Getúlio',
    'Aurora',
    'Taió',
    'Trombudo Central',
    'Pouso Redondo',
    'Ituporanga',
    'Salete',
    'Rio do Oeste',
    'Braço do Trombudo',
    'Agrolândia',
    'Atalanta',
    'Chapadão do Lageado',
    'Dona Emma',
    'Imbuia',
    'José Boiteux',
    'Mirim Doce',
    'Petrolândia',
    'Presidente Nereu',
    'Rio do Campo',
    'Santa Terezinha',
    'Vidal Ramos',
    'Vitor Meireles',
    'Witmarsum',
  ];
}
