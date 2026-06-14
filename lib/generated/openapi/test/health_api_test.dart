import 'package:test/test.dart';
import 'package:mbe_api_client/mbe_api_client.dart';


/// tests for HealthApi
void main() {
  final instance = MbeApiClient().getHealthApi();

  group(HealthApi, () {
    // Health Check
    //
    //Future<BuiltMap<String, String>> healthCheckApiV1HealthGet() async
    test('test healthCheckApiV1HealthGet', () async {
      // TODO
    });

  });
}
