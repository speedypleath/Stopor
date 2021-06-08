import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stopor/database/database_service.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockDatabaseService extends Mock implements DatabaseService {}

main() {
  MockFirestore firestore;
  MockDocumentSnapshot snapshot;
  MockDocumentReference docRef;
  Map<String, dynamic> responseMap;
  DatabaseService databaseService = new DatabaseService();

  setUp(() {
    firestore = MockFirestore();
    docRef = MockDocumentReference();
    snapshot = MockDocumentSnapshot();
  });

  test('should return data when the call to remote source is successful.',
      () async {
    when(firestore.collection('events').doc(any)).thenReturn(docRef);
    when(docRef.get()).thenAnswer((_) async => snapshot);
    when(snapshot.data()).thenReturn(responseMap);
    final result = await databaseService.getUser('user_id');
  });
}
