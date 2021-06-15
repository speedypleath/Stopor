/*import 'package:algolia/algolia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopor/api_keys.dart';

main() {
  Algolia algolia;
  setUp(() {
    algolia = APIKeys.algolia;
  });
  test('should return data when the call to algolia is successful.', () async {
    AlgoliaQuery query = algolia.instance.index('stopor');
    AlgoliaQuerySnapshot snap = await query.getObjects();
    assert(snap.nbHits > 0);
  });
}
*/