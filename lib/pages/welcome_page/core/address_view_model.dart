import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/pages/welcome_page/data/repository/vworld_repository.dart';

class AddressViewModel extends AutoDisposeNotifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  final vworldRepository = VworldRepository();

  Future<void> searchByName(String query) async {
    final result = await vworldRepository.findByName(query);
    state = result;
  }

  Future<void> searchByLocation(double lat, double lng) async {
    final result = await vworldRepository.findByLatLng(lat, lng);
    state = result;
  }

  /// 주소 문자열에서 시/도(sido)와 시/군/구(sigungu)를 추출해 표준화합니다.
  /// 예) "서울특별시 중구 태평로1가" -> (sido: "서울", sigungu: "중구")
  AddressRegion parseRegion(String address) {
    return AddressRegion.parse(address);
  }
}


final addressViewModel =
    AutoDisposeNotifierProvider<AddressViewModel, List<String>>(
      AddressViewModel.new,
    );

/// 지역 파싱/표준화 유틸
class AddressRegion {
  final String sido;
  final String sigungu;
  const AddressRegion({required this.sido, required this.sigungu});

  // 시/도 표준화 매핑
  static const Map<String, String> _sidoAliases = {
    '서울특별시': '서울',
    '서울': '서울',
    '경기도': '경기',
    '경기': '경기',
    '부산광역시': '부산',
    '부산': '부산',
    '대구광역시': '대구',
    '대구': '대구',
    '인천광역시': '인천',
    '인천': '인천',
    '광주광역시': '광주',
    '광주': '광주',
    '대전광역시': '대전',
    '대전': '대전',
    '울산광역시': '울산',
    '울산': '울산',
    '세종특별자치시': '세종',
    '세종': '세종',
    '강원도': '강원',
    '강원': '강원',
    '충청북도': '충북',
    '충북': '충북',
    '충청남도': '충남',
    '충남': '충남',
    '전라북도': '전북',
    '전북': '전북',
    '전라남도': '전남',
    '전남': '전남',
    '경상북도': '경북',
    '경북': '경북',
    '경상남도': '경남',
    '경남': '경남',
    '제주특별자치도': '제주',
    '제주': '제주',
  };

  /// "서울특별시 중구 태평로1가" 같이 공백으로 구분된 주소에서
  /// 0번째 토큰으로 시/도, 1번째 토큰으로 시/군/구를 읽고 표준화합니다.
  static AddressRegion parse(String address) {
    if (address.trim().isEmpty) {
      return const AddressRegion(sido: '', sigungu: '');
    }
    final parts = address.trim().split(RegExp(r'\s+'));
    final rawSido = parts.isNotEmpty ? parts[0] : '';
    final rawSigungu = parts.length >= 2 ? parts[1] : '';

    // 시/도 표준화
    String sido = rawSido;
    // 가장 긴 alias부터 매칭되도록 정렬
    final keys = _sidoAliases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final k in keys) {
      if (rawSido.startsWith(k)) {
        sido = _sidoAliases[k]!;
        break;
      }
    }

    final sigungu = rawSigungu; // 필요시 여기서도 추가 표준화 가능
    return AddressRegion(sido: sido, sigungu: sigungu);
  }
}
