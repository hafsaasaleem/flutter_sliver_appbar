import 'package:flutter/material.dart';
import 'package:flutter_sliver_appbar/one_ui_nested_scroll_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'One UI Silver AppBar',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OneUiNestedScrollView(
        expandedWidget: const Text(
          "Contacts",
          style: TextStyle(fontSize: 30),
        ),
        collapsedWidget: const Text(
          "Contacts",
          style: TextStyle(fontSize: 20),
        ),
        leadingIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
        boxDecoration: BoxDecoration(
          color: Colors.grey.shade300,
          // gradient: LinearGradient(
          //   colors: [Colors.cyan, Colors.amber],
          // ),
        ),
        sliverList: SliverList(delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
              ),
              
              title: Text("Contact $index"),
            );
          },
        )),
      ),
    );
  }
}
