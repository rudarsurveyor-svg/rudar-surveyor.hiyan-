import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'RUDAR SURVEYOR',
    theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
    home: const Home(),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, String>> data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => data = (p.getStringList('data') ?? [])
        .map((e) => Map<String, String>.from(jsonDecode(e))).toList());
  }

  Future<void> saveData(Map<String, String> x) async {
    data.add(x);
    final p = await SharedPreferences.getInstance();
    await p.setStringList('data', data.map(jsonEncode).toList());
    setState(() {});
  }

  Future<void> delete(int i) async {
    data.removeAt(i);
    final p = await SharedPreferences.getInstance();
    await p.setStringList('data', data.map(jsonEncode).toList());
    setState(() {});
  }

  void pdf(Map<String, String> x) async {
    final d = pw.Document();
    d.addPage(pw.Page(
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('RUDAR SURVEYOR',
              style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          ...x.entries.map((e) => pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('${e.key}: ${e.value}'),
          )),
        ],
      ),
    ));
    await Printing.sharePdf(
      bytes: await d.save(),
      filename: 'RUDAR_SURVEYOR_Report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('RUDAR SURVEYOR')),
    body: Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlue],
          ),
        ),
        child: const Column(children: [
          Icon(Icons.satellite_alt, color: Colors.white, size: 55),
          Text('RUDAR SURVEYOR',
              style: TextStyle(color: Colors.white,
                  fontSize: 25, fontWeight: FontWeight.bold)),
          Text('જમીન માપણી અને Calculator',
              style: TextStyle(color: Colors.white)),
        ]),
      ),
      const SizedBox(height: 15),
      menu(context, 'જમીન માપણી માહિતી', Icons.edit_location,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => FormPage(saveData)))),
      menu(context, 'જમીનનું Calculator', Icons.calculate,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const Calc()))),
      const Divider(),
      Expanded(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, i) => Card(
            child: ListTile(
              title: Text(data[i]['માલિકનું નામ'] ?? ''),
              subtitle: Text(data[i]['ગામ'] ?? ''),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () => pdf(data[i]),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => delete(i),
                ),
              ]),
            ),
          ),
        ),
      ),
    ]),
  );

  Widget menu(BuildContext c, String t, IconData i, VoidCallback f) =>
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: ListTile(
          leading: Icon(i, size: 35, color: Colors.blue),
          title: Text(t, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: f,
        ),
      );
}

class FormPage extends StatefulWidget {
  final Function(Map<String, String>) save;
  const FormPage(this.save, {super.key});
  @override
  State<FormPage> createState() => _FormState();
}

class _FormState extends State<FormPage> {
  final c = List.generate(7, (_) => TextEditingController());
  final names = [
    'માલિકનું નામ', 'ગામ', 'તાલુકો', 'સર્વે નંબર',
    'તારીખ', 'પેમેન્ટ', 'મોબાઇલ નંબર'
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('જમીન માપણી માહિતી')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (int i = 0; i < names.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: c[i],
              keyboardType: i == 6 ? TextInputType.phone : TextInputType.text,
              decoration: InputDecoration(
                labelText: names[i],
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        FilledButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Save'),
          onPressed: () {
            final x = <String, String>{};
            for (int i = 0; i < names.length; i++) {
              x[names[i]] = c[i].text;
            }
            widget.save(x);
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

class Calc extends StatefulWidget {
  const Calc({super.key});
  @override
  State<Calc> createState() => _CalcState();
}

class _CalcState extends State<Calc> {
  final l = TextEditingController();
  final w = TextEditingController();
  double result = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('જમીનનું Calculator')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        TextField(
          controller: l,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'લંબાઈ (Meter)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: w,
          keyboardType: TextInputType.number,
                   decoration: const InputDecoration(
            labelText: 'લંબાઈ (Meter)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: w,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'પહોળાઈ (Meter)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () {
            setState(() {
              result =
                  (double.tryParse(l.text) ?? 0) *
                  (double.tryParse(w.text) ?? 0);
            });
          },
          child: const Text('Calculate'),
        ),
        const SizedBox(height: 30),
        const Text(
          'કુલ વિસ્તાર',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${result.toStringAsFixed(2)} ચો. મીટર',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Example: 25 m × 40 m = 1000 ચો. મીટર',
          textAlign: TextAlign.center,
        ),
      ]),
    ),
  );
}
