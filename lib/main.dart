import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
        themeMode: ThemeMode.dark);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _carController = TextEditingController();
  final TextEditingController _horespowerController = TextEditingController();
  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('products');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _carController.text = documentSnapshot['car'];
      _horespowerController.text = documentSnapshot['horespower'].toString();
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _carController,
                  decoration: const InputDecoration(labelText: 'car'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _horespowerController,
                  decoration: const InputDecoration(
                    labelText: 'horespower',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? car = _carController.text;
                    final double? horespower =
                        double.tryParse(_horespowerController.text);
                    if (car != null && horespower != null) {
                      if (action == 'create') {
                        await _productss
                            .add({"car": car, "horespower": horespower});
                      }
                      if (action == 'update') {
                        await _productss
                            .doc(documentSnapshot!.id)
                            .update({"car": car, "horespower": horespower});
                      }

                      _carController.text = '';
                      _horespowerController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

// Deleteing a product by id
  Future<void> _deleteProduct(String productId) async {
    await _productss.doc(productId).delete();
// Show a snackbar
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Car Sucessfully deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('19IT055 Farhan Khatri'),
      ),
      body: StreamBuilder(
        stream: _productss.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    tileColor: Colors.blue,
                    title: Text("The Car is: " + documentSnapshot['car']),
                    subtitle: Text("The amount of horespower is: " +
                        documentSnapshot['horespower'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
