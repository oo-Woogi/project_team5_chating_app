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
}

final addressViewModel =
    AutoDisposeNotifierProvider<AddressViewModel, List<String>>(
      AddressViewModel.new,
    );
