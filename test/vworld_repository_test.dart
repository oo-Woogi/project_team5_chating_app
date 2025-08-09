import 'package:flutter_test/flutter_test.dart';
import 'package:project_team5_chating_app/data/repository/vworld_repository.dart';

void main() {
  final vwolrdRepo = VworldRepository();

  test('VworldRepository : findByLatLng test', () async {
    // 35.2210076 129.0826365
    final result = await vwolrdRepo.findByLatLng(lat: 35.2210076, lng: 129.0826365);
    print(result);
    expect(result.isEmpty, false);

    final result2 = await vwolrdRepo.findByLatLng(lat: 32.2210076, lng: 129.0826365);
    print(result);
    expect(result2.isEmpty, true);
  });
}
