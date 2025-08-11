import 'package:dio/dio.dart';

class VworldRepository {
  final Dio _client = Dio(
    BaseOptions(
      // 설정안할 시 실패 응답 시 throw
      validateStatus: (status) => true,
    ),
  );

  Future<List<String>> findByLatLng({
    required double lat,
    required double lng,
  }) async {
    final response = await _client.get(
      'https://api.vworld.kr/req/data',
      queryParameters: {
        'request': 'GetFeature',
        'key': 'DB2D9AAB-AAA3-3A9D-811E-FEE87CAD91F7',
        'data': 'LT_C_ADEMD_INFO',
        'geomfilter': 'point($lng $lat)', // ✅ 소문자 point
        'geometry': 'false',
        'size': 100,
      },
    );

    print('🌍 API 응답: ${response.data}');

    if (response.statusCode == 200 &&
        response.data['response']['status'] == 'OK') {
      final features =
          response.data['response']['result']['featureCollection']['features']
              as List;

      return features
          .map((e) => e['properties']['full_nm'].toString())
          .toList();
    }

    return [];
  }
}