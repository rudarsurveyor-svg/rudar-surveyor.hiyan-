import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// MODEL
// ============================================================

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

  Map<String, dynamic> toJson() {
    return {
      'owner': owner,
      'village': village,
      'taluka': taluka,
      'surveyNo': surveyNo,
      'date': date,
      'payment': payment,
      'mobile': mobile,
    };
  }

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

// ============================================================
// HOME SCREEN
// ============================================================

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
          .map(
            (e) => SurveyRecord.fromJson(
              jsonDecode(e) as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }

  Future<void> saveRecords() async {
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

            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Future<void> deleteRecord(int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('રેકોર્ડ Delete કરવો છે?'),
          content: const Text(
            'આ રેકોર્ડ કાયમ માટે Delete થશે.',
          ),
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
        );
      },
    );

    if (result == true) {
      records.removeAt(index);
      await saveRecords();

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                28,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff1565C0),
                    Color(0xff42A5F5),
                  ],
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
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.architecture,
                          size: 38,
                          color: Color(0xff1565C0),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
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
                              'Land Measurement & Calculator',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'RUDAR SURVEYOR',
                            applicationVersion: '1.0.0',
                            applicationLegalese:
                                'Land Survey & Calculator App',
                          );
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'જમીન માપણી • ગણતરી • રિપોર્ટ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // MENU
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  MenuCard(
                    icon: Icons.straighten,
                    title: 'જમીન માપણી માહિતી',
                    subtitle:
                        'માલિક અને જમીનની માહિતી Save કરો',
                    onTap: () => openForm(),
                  ),
                  const SizedBox(height: 14),
                  MenuCard(
                    icon: Icons.calculate,
                    title: 'જમીનનું Calculator',
                    subtitle:
                        'Length × Width દ્વારા વિસ્તાર ગણો',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CalculatorScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // SAVED RECORDS
                  if (records.isNotEmpty)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Saved Records',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(
                              records.length,
                              (index) {
                                final record = records[index];

                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        '${index + 1}',
                                      ),
                                    ),
                                    title: Text(
                                      record.owner.isEmpty
                                          ? 'નામ ઉપલબ્ધ નથી'
                                          : record.owner,
                                    ),
                                    subtitle: Text(
                                      '${record.village} • '
                                      '${record.surveyNo}',
                                    ),
                                    trailing: PopupMenuButton(
                                      itemBuilder:
                                          (context) => [
                                        const PopupMenuItem(
                                          value: 'view',
                                          child: Text('View'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'pdf',
                                          child: Text(
                                            'Generate PDF',
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'view') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  RecordViewScreen(
                                                record: record,
                                              ),
                                            ),
                                          );
                                        } else if (value == 'edit') {
                                          openForm(
                                            record: record,
                                            index: index,
                                          );
                                        } else if (value == 'pdf') {
                                          generatePdf(record);
                                        } else if (value ==
                                            'delete') {
                                          deleteRecord(index);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'RUDAR SURVEYOR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Customer Care: Y.M. DHUNDHALAVA',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '8487847474',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
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
}

// ============================================================
// MENU CARD
// ============================================================

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
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
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

// ============================================================
// SURVEY FORM
// ============================================================

class SurveyFormScreen extends StatefulWidget {
  final SurveyRecord? record;
  final Future<void> Function(SurveyRecord record) onSave;

  const SurveyFormScreen({
    super.key,
    this.record,
    required this.onSave,
  });

  @override
  State<SurveyFormScreen> createState() =>
      _SurveyFormScreenState();
}

class _SurveyFormScreenState
    extends State<SurveyFormScreen> {
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
      final now = DateTime.now();
      date.text =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year}';
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

  Future<void> selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        date.text =
            '${selected.day.toString().padLeft(2, '0')}/'
            '${selected.month.toString().padLeft(2, '0')}/'
            '${selected.year}';
      });
    }
  }

  Future<void> save() async {
    if (owner.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('માલિકનું નામ નાખો'),
        ),
      );
      return;
    }

    final record = SurveyRecord(
      owner: owner.text.trim(),
      village: village.text.trim(),
      taluka: taluka.text.trim(),
      surveyNo: surveyNo.text.trim(),
      date: date.text.trim(),
      payment: payment.text.trim(),
      mobile: mobile.text.trim(),
    );

    await widget.onSave(record);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.record != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'માહિતી Edit કરો'
              : 'જમીન માપણી માહિતી',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AppTextField(
            controller: owner,
            label: 'માલિકનું નામ',
            icon: Icons.person,
          ),
          AppTextField(
            controller: village,
            label: 'ગામ',
            icon: Icons.location_city,
          ),
          AppTextField(
            controller: taluka,
            label: 'તાલુકો',
            icon: Icons.map,
          ),
          AppTextField(
            controller: surveyNo,
            label: 'સર્વે નંબર',
            icon: Icons.numbers,
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
        title: const Text('જમીનનું Calculator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'જમીનનું ક્ષેત્રફળ Calculator',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: length,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Length (Meter)',
              prefixIcon: const Icon(Icons.straighten),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: width,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Width (Meter)',
              prefixIcon: const Icon(Icons.swap_horiz),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: calculate,
              icon: const Icon(Icons.calculate),
              label: const Text(
                'Calculate',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const Text(
                    'કુલ વિસ્તાર',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${result.toStringAsFixed(2)} ચો. મીટર',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Example: 25 m × 40 m = 1000 ચો. મીટર',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
