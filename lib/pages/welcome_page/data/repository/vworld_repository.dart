import 'package:dio/dio.dart';

class VworldRepository {
  final Dio _client = Dio(
    BaseOptions(
      // 설정 안할 시 실패 응답오면 throw 던져서 에러남
      validateStatus: (status) => true,
    ),
  );

  // 1. 이름으로 검색하는 기능

  Future<List<String>> findByName(String query) async {
    // https://api.vworld.kr/req/search
    // request = search
    // key =  D1657506-73F7-3365-8F9B-79246A205C64
    // Query = 온천동
    // type = DISTRICT
    // category = L4

    try {
      final response = await _client.get(
        'https://api.vworld.kr/req/search',
        queryParameters: {
          'request': 'search',
          'key': 'D1657506-73F7-3365-8F9B-79246A205C64',
          'query': query,
          'type': 'DISTRICT',
          'category': 'L4',
        },
      );
      if (response.statusCode == 200 &&
          response.data['response']['status'] == 'ok') {
        // response > result > items >> title
        final items = response.data['response']['result']['items'];
        final itemList = List.from(items);
        final iterable = itemList.map((item) {
          return '${item['title']}';
        });
        return iterable.toList();
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  // 2. 위도경도로 검색하는 기능
  // response > result > features >> properties > full_nm
  Future<List<String>> findByLatLng(double lat, double lng) async {
    // https://api.vworld.kr/req/data
    // request  = GetFeature
    // key =  D1657506-73F7-3365-8F9B-79246A205C64
    // data = LT_C_ADEMD_INFO
    // geomFilter =  POINT(129.0826365  35.2210076)
    // geometry = false
    // Size = 100
    try {
      final response = await _client.get(
        'https://api.vworld.kr/req/data',
        queryParameters: {
          'request': 'GetFeature',
          'key': 'D1657506-73F7-3365-8F9B-79246A205C64',
          'data': 'LT_C_ADEMD_INFO',
          'geomFilter': 'POINT($lng $lat)', // 경도, 위도
          'geometry': 'false',
          'size': '100',
        },
      );
      if (response.statusCode == 200 &&
          response.data['response']['status'] == 'ok') {
        // response > result > featureCollection > features >> properties > full_nm
        final features = response
            .data['response']['result']['featureCollection']['features'];
        final featuresList = List.from(features);
        final iterable = featuresList.map((feat) {
          return '${feat['properties']['full_nm']}';
        });
        return iterable.toList();
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }
}
