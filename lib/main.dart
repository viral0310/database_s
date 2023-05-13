import 'package:database/dbhelper.dart';
import 'package:flutter/material.dart';

import 'model.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Student>> getData;
  final GlobalKey<FormState> insertKey = GlobalKey<FormState>();
  final GlobalKey<FormState> upKey = GlobalKey<FormState>();
  final TextEditingController nameCon = TextEditingController();
  final TextEditingController nameUpCon = TextEditingController();
  final TextEditingController dobCon = TextEditingController();
  final TextEditingController dobUpCon = TextEditingController();
  String? name;
  String? dob;
  int? id;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData = DBHelper.dbHelper.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("database"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.teal,
            ),
          ),
          Expanded(
            flex: 12,
            child: FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    List<Student> data = snapshot.data as List<Student>;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return ListTile(
                          leading: Text("${data[i].id}"),
                          title: Text(data[i].name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(data[i].dob),
                              IconButton(
                                  onPressed: () {
                                    upData(data: data[i]);
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    DBHelper.dbHelper.delete(id: data[i].id);
                                    setState(() {
                                      getData = DBHelper.dbHelper.fetch();
                                    });
                                  },
                                  icon: const Icon(Icons.delete))
                            ],
                          ),
                        );
                      },
                      itemCount: data.length,
                    );
                    /*ListView(
                      children: [
                        DataTable(
                            columns: [
                              DataColumn(
                                label: Text("id"),
                              ),
                              DataColumn(
                                label: Text("name"),
                              ),
                              DataColumn(
                                label: Text("bod"),
                              ),
                            ],
                            rows: list.map((e) {
                              return DataRow(cells: [
                                DataCell(
                                  Text("$e['id']"),
                                )
                              ]);
                            }).toList())
                      ],
                    );*/
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                future: getData),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            insertData();
          },
          child: const Icon(Icons.add)),
    );
  }

  void insertData() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add data"),
            content: Form(
              key: insertKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCon,
                    onSaved: (val) {
                      setState(() {
                        name = val!;
                      });
                    },
                    validator: (val) {
                      return (val!.isEmpty) ? "enter name first" : null;
                    },
                    decoration: InputDecoration(label: Text("name")),
                  ),
                  TextFormField(
                    controller: dobCon,
                    onSaved: (val) {
                      setState(() {
                        dob = val;
                      });
                    },
                    validator: (val) {
                      return (val!.isEmpty) ? "---" : null;
                    },
                    decoration: InputDecoration(label: Text("date of birth")),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    if (insertKey.currentState!.validate()) {
                      insertKey.currentState!.save();
                      int id = await DBHelper.dbHelper
                          .insertRecord(name: name ?? "", dob: dob ?? "");
                      if (id > 0) {
                        print("----done recors $name $dob");
                        setState(() {
                          getData = DBHelper.dbHelper.fetch();
                        });
                      }

                      print("saved $name $dob");
                      nameCon.clear();
                      dobCon.clear();
                      setState(() {
                        name = null;
                        dob = null;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("insert")),
              ElevatedButton(
                  onPressed: () {
                    nameCon.clear();
                    dobCon.clear();
                    setState(() {
                      name = null;
                      dob = null;
                    });
                    print("clear");
                    Navigator.of(context).pop();
                  },
                  child: Text("cancel")),
            ],
          );
        });
  }

  void upData({required Student data}) async {
    name = data.name.toString();
    dob = data.dob.toString();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add data"),
            content: Form(
              key: upKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameUpCon,
                    onSaved: (val) {
                      setState(() {
                        name = val!;
                      });
                    },
                    validator: (val) {
                      return (val!.isEmpty) ? "enter name first" : null;
                    },
                    decoration: InputDecoration(label: Text("$name")),
                  ),
                  TextFormField(
                    controller: dobUpCon,
                    onSaved: (val) {
                      setState(() {
                        dob = val;
                      });
                    },
                    validator: (val) {
                      return (val!.isEmpty) ? "---" : null;
                    },
                    decoration: InputDecoration(label: Text("$dob")),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    if (upKey.currentState!.validate()) {
                      upKey.currentState!.save();
                      int id = await DBHelper.dbHelper.update(
                          name: name ?? "", dob: dob ?? "", id: data.id);
                      if (id > 0) {
                        print("----done recors $name $dob");
                        setState(() {
                          getData = DBHelper.dbHelper.fetch();
                        });
                      }

                      print("saved $name $dob");
                      nameUpCon.clear();
                      dobUpCon.clear();
                      setState(() {
                        name = null;
                        dob = null;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("insert")),
              ElevatedButton(
                  onPressed: () {
                    nameUpCon.clear();
                    dobUpCon.clear();
                    setState(() {
                      name = null;
                      dob = null;
                    });
                    print("clear");
                    Navigator.of(context).pop();
                  },
                  child: Text("cancel")),
            ],
          );
        });
  }
}
