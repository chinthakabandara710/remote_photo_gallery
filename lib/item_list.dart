import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'add_item.dart';

class ItemList extends StatelessWidget {
  ItemList({Key? key}) : super(key: key) {
    _stream = _reference.snapshots();
  }

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('gallery');

  late Stream<QuerySnapshot> _stream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'gallery';

  Future<void> _deleteDocuments(final url) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where('image', isEqualTo: url)
          .get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        await documentSnapshot.reference.delete();
        print('Document deleted successfully');
      }
    } catch (e) {
      print('Error deleting documents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remote Photo Gallery'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //Check error
          if (snapshot.hasError) {
            return Center(child: Text('Some error occurred ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot.docs;
            List<Map> items = documents.map((e) => e.data() as Map).toList();

            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  Map thisItem = items[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              child: Image.network(
                                '${thisItem['image']}',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ));
                    },
                    onLongPress: () {
                      Alert(
                        context: context,
                        type: AlertType.warning,
                        desc: "Do you want to remove this photo ?",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Yes",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              _deleteDocuments(thisItem['image']);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Deleted successfully')),
                              );
                            },
                            color: Color.fromRGBO(241, 69, 69, 1.0),
                          ),
                          DialogButton(
                            child: Text(
                              "No",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            color: Color.fromRGBO(0, 179, 134, 1.0),
                          )
                        ],
                      ).show();
                    },
                    child: Card(
                      child: Center(
                        child: Image.network('${thisItem['image']}'),
                      ),
                    ),
                  );
                });
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddItem()));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
