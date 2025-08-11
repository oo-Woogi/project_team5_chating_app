// 1. 상태클래스 만들기

// 2. 뷰모델 만들기
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_team5_chating_app/data/repository/vworld_repository.dart';

class AddressViewModel extends AutoDisposeNotifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  final vworldRepository = VworldRepository();

Future<List> searchByLocation(double lat, double lng) async {
    final result = await vworldRepository.findByLatLng(lat: lat, lng: lng);
    state = result;
    return result;
  }
}

// 3. 뷰모델 관리자 만들기
final addressViewModel =
    NotifierProvider.autoDispose<AddressViewModel, List<String>>(() {
      return AddressViewModel();
    });
