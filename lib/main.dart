import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const RudarSurveyorApp());
}

class RudarSurveyorApp extends StatelessWidget {
  const RudarSurveyorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RUDAR SURVEYOR',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: 'sans',
      ),
      home: const HomeScreen(),
    );
  }
}

class SurveyRecord {
  String owner;
  String village;
  String taluka;
  String surveyNo;
  String date;
  String payment;
  String mobile;

  SurveyRecord({
    required this.owner,
    required this.village,
    required this.taluka,
    required this.surveyNo,
    required this.date,
    required this.payment,
    required this.mobile,
  });

  Map<String, dynamic> toJson() => {
        'owner': owner,
        'village': village,
        'taluka': taluka,
        'surveyNo': surveyNo,
        'date': date,
        'payment': payment,
        'mobile': mobile,
      };

  factory SurveyRecord.fromJson(Map<String, dynamic> json) {
    return SurveyRecord(
      owner: json['owner'] ?? '',
      village: json['village'] ?? '',
      taluka: json['taluka'] ?? '',
      surveyNo: json['surveyNo'] ?? '',
      date: json['date'] ?? '',
      payment: json['payment'] ?? '',
      mobile: json['mobile'] ?? '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SurveyRecord> records = [];

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('records') ?? [];

    setState(() {
      records = data
          .map((e) => SurveyRecord.fromJson(jsonDecode(e)))
          .toList();
    });
  }

  Future<void>saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'records',
      records.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  void openForm({SurveyRecord? record, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurveyFormScreen(
          record: record,
          onSave: (newRecord) async {
            if (index != null) {
              records[index] = newRecord;
            } else {
              records.add(newRecord);
            }

            await saveRecords();
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> deleteRecord(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('રેકોર્ડ Delete કરવો છે?'),
        content: const Text('આ રેકોર્ડ કાયમ માટે Delete થશે.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ના'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('હા, Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      records.removeAt(index);
      await saveRecords();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1976D2), Color(0xff42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.architecture,
                          size: 38,
                          color: Color(0xff1976D2),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RUDAR SURVEYOR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'જમીન માપણી માટેનું સરળ એપ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  MenuCard(
                    icon: Icons.assignment,
                    title: 'જમીન માપણી માહિતી',
                    subtitle: 'માલિક અને જમીનની માહિતી Save કરો',
                    onTap: () => openForm(),
                  ),
                  const SizedBox(height: 15),
                  MenuCard(
                    icon: Icons.calculate,
                    title: 'જમીનનું Calculator',
                    subtitle: 'Length × Width થી જમીનનું ક્ષેત્રફળ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalculatorScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  if (records.isNotEmpty) ...[
                    const Text(
                      'Saved Records',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...records.asMap().entries.map(
                      (entry) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(entry.value.owner),
                          subtitle: Text(
                            'ગામ: ${entry.value.village}  •  સર્વે: ${entry.value.surveyNo}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'view') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecordViewScreen(
                                      record: entry.value,
                                    ),
                                  ),
                                );
                              } else if (value == 'edit') {
                                openForm(
                                  record: entry.value,
                                  index: entry.key,
                                );
                              } else if (value == 'delete') {
                                deleteRecord(entry.key);
                              } else if (value == 'pdf') {
                                createPdf(entry.value);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'view',
                                child: Text('View'),
                              ),
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'pdf',
                                child: Text('Generate PDF'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Customer Care',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Y.M. DHUNDHALAVA',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '8487847474',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createPdf(SurveyRecord record) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RUDAR SURVEYOR',
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('LAND SURVEY REPORT'),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text('Owner Name: ${record.owner}'),
                pw.Text('Village: ${record.village}'),
                pw.Text('Taluka: ${record.taluka}'),
                pw.Text('Survey Number: ${record.surveyNo}'),
                pw.Text('Date: ${record.date}'),
                pw.Text('Payment: ${record.payment}'),
                pw.Text('Mobile: ${record.mobile}'),
                pw.SizedBox(height: 40),
                pw.Text('Generated by RUDAR SURVEYOR'),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'RUDAR_SURVEYOR_REPORT.pdf',
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                child: Icon(icon, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class SurveyFormScreen extends StatefulWidget {
  final SurveyRecord? record;
  final Function(SurveyRecord) onSave;

  const SurveyFormScreen({
    super.key,
    this.record,
    required this.onSave,
  });

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  final owner = TextEditingController();
  final village = TextEditingController();
  final taluka = TextEditingController();
  final surveyNo = TextEditingController();
  final date = TextEditingController();
  final payment = TextEditingController();
  final mobile = TextEditingController();

  @override
  void initState() {
    super.initState();

    final r = widget.record;
    if (r != null) {
      owner.text = r.owner;
      village.text = r.village;
      taluka.text = r.taluka;
      surveyNo.text = r.surveyNo;
      date.text = r.date;
      payment.text = r.payment;
      mobile.text = r.mobile;
    } else {
      date.text =
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    }
  }

  @override
  void dispose() {
    owner.dispose();
    village.dispose();
    taluka.dispose();
    surveyNo.dispose();
    date.dispose();
    payment.dispose();
    mobile.dispose();
    super.dispose();
  }

  InputDecoration decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  void save() {
    if (owner.text.trim().isEmpty ||
        village.text.trim().isEmpty ||
        surveyNo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('માલિકનું નામ, ગામ અને સર્વે નંબર જરૂરી છે.'),
        ),
      );
      return;
    }

    widget.onSave(
      SurveyRecord(
        owner: owner.text.trim(),
        village: village.text.trim(),
        taluka: taluka.text.trim(),
        surveyNo: surveyNo.text.trim(),
        date: date.text.trim(),
        payment: payment.text.trim(),
        mobile: mobile.text.trim(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.record == null
              ? 'જમીન માપણી માહિતી'
              : 'માહિતી Edit કરો',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: owner,
            decoration: decoration('માલિકનું નામ', Icons.person),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: village,
            decoration: decoration('ગામ', Icons.location_city),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: taluka,
            decoration: decoration('તાલુકો', Icons.map),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: surveyNo,
            decoration: decoration('સર્વે નંબર', Icons.numbers),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: date,
            decoration: decoration('તારીખ', Icons.calendar_month),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: payment,
            keyboardType: TextInputType.number,
            decoration: decoration('પેમેન્ટ', Icons.currency_rupee),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: mobile,
            keyboardType: TextInputType.phone,
            decoration: decoration('મોબાઇલ નંબર', Icons.phone),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: const Text(
                'Save',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecordViewScreen extends StatelessWidget {
  final SurveyRecord record;

  const RecordViewScreen({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final items = {
      'માલિકનું નામ': record.owner,
      'ગામ': record.village,
      'તાલુકો': record.taluka,
      'સર્વે નંબર': record.surveyNo,
      'તારીખ': record.date,
      'પેમેન્ટ': record.payment,
      'મોબાઇલ નંબર': record.mobile,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Survey Details')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: items.entries
            .map(
              (e) => Card(
                child: ListTile(
                  title: Text(e.key),
                  subtitle: Text(
                    e.value.isEmpty ? '-' : e.value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final length = TextEditingController();
  final width = TextEditingController();

  double result = 0;

  void calculate() {
    final l = double.tryParse(length.text) ?? 0;
    final w = double.tryParse(width.text) ?? 0;

    setState(() {
      result = l * w;
    });
  }

  @override
  void dispose() {
    length.dispose();
    width.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('જમીનનું Calcu
