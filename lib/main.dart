import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SalawaatApp());

class SalawaatApp extends StatelessWidget {
  const SalawaatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salawaat',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0E0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEFE2C3),
          surface: Color(0xFF1A1F20),
        ),
        useMaterial3: true,
      ),
      home: const SalawaatShell(),
    );
  }
}

class SalawaatShell extends StatefulWidget {
  const SalawaatShell({super.key});

  @override
  State<SalawaatShell> createState() => _SalawaatShellState();
}

class _SalawaatShellState extends State<SalawaatShell> {
  static const accent = Color(0xFFEFE2C3);
  static const panel = Color(0xFF1A1F20);
  static const muted = Color(0xFFA9B0AE);

  bool onboarded = false;
  int tab = 0;
  int count = 27;
  int minutes = 10;
  String platform = 'iOS';
  String strength = 'gentle';
  bool recovery = true;

  void record() {
    setState(() => count++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recorded'), duration: Duration(milliseconds: 700)),
    );
  }

  void showReminder() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('Salawāt'),
        message: const Column(
          children: [
            SizedBox(height: 8),
            Text('Send ṣalāh upon the Prophet ﷺ'),
            SizedBox(height: 12),
            Text(
              'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              record();
            },
            child: const Text('Done'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Snoozed for 5 minutes')),
              );
            },
            child: const Text('Snooze 5 minutes'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              setState(() => tab = 0);
            },
            child: const Text('Open app'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Dismiss'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!onboarded) {
      return _Onboarding(
        onBegin: () => setState(() => onboarded = true),
        onSchedule: () => setState(() {
          onboarded = true;
          tab = 1;
        }),
      );
    }

    final pages = [
      _Today(
        count: count,
        minutes: minutes,
        onRecord: record,
        onSimulate: showReminder,
      ),
      _Rhythm(
        minutes: minutes,
        platform: platform,
        strength: strength,
        recovery: recovery,
        onMinutes: (value) => setState(() => minutes = value),
        onPlatform: (value) => setState(() => platform = value),
        onStrength: (value) => setState(() => strength = value),
        onRecovery: (value) => setState(() => recovery = value),
      ),
      const _Why(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.circle), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Rhythm'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Why'),
        ],
      ),
    );
  }
}

class _Onboarding extends StatelessWidget {
  const _Onboarding({required this.onBegin, required this.onSchedule});

  final VoidCallback onBegin;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: _Pill('A remembrance companion')),
              const SizedBox(height: 24),
              const Text(
                'Increase your ṣalāh upon him ﷺ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              const _Arabic('فَإِنْ زِدْتَ فَهُوَ خَيْرٌ لَكَ'),
              const SizedBox(height: 20),
              const _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('“If you increase it, that is better for you.”', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text('From the narration of Ubayy ibn Kaʿb رضي الله عنه.', style: TextStyle(color: _SalawaatShellState.muted)),
                    SizedBox(height: 10),
                    _Pill('Jāmiʿ al-Tirmidhī 2457'),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(onPressed: onBegin, child: const Text('Begin')),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: onSchedule, child: const Text('Set reminder first')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Today extends StatelessWidget {
  const _Today({required this.count, required this.minutes, required this.onRecord, required this.onSimulate});

  final int count;
  final int minutes;
  final VoidCallback onRecord;
  final VoidCallback onSimulate;

  @override
  Widget build(BuildContext context) {
    final cadence = minutes == 60 ? 'Every hour' : 'Every $minutes min';
    final next = minutes == 60 ? 'in 1 hour' : 'in $minutes minutes';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('TODAY', style: _Styles.eyebrow),
        const Text('Salawāt', style: _Styles.title),
        const Text('Return to the remembrance throughout your day.', style: TextStyle(color: _SalawaatShellState.muted, height: 1.45)),
        const SizedBox(height: 26),
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2A3031), width: 10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$count', style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w800)),
                const Text('completed today', style: TextStyle(color: _SalawaatShellState.muted)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _Arabic('اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ'),
        const SizedBox(height: 18),
        FilledButton(onPressed: onRecord, child: const Text('I said it')),
        const SizedBox(height: 12),
        _Card(
          child: Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Next reminder', style: TextStyle(fontWeight: FontWeight.w700)), Text(next, style: const TextStyle(color: _SalawaatShellState.muted))])),
              _Pill(cadence),
            ],
          ),
        ),
        OutlinedButton(onPressed: onSimulate, child: const Text('Simulate reminder')),
      ],
    );
  }
}

class _Rhythm extends StatelessWidget {
  const _Rhythm({required this.minutes, required this.platform, required this.strength, required this.recovery, required this.onMinutes, required this.onPlatform, required this.onStrength, required this.onRecovery});

  final int minutes;
  final String platform;
  final String strength;
  final bool recovery;
  final ValueChanged<int> onMinutes;
  final ValueChanged<String> onPlatform;
  final ValueChanged<String> onStrength;
  final ValueChanged<bool> onRecovery;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('SCHEDULE', style: _Styles.eyebrow),
        const Text('Your rhythm', style: _Styles.title),
        const Text('Choose the cadence. The app handles iOS and Android scheduling differences underneath.', style: TextStyle(color: _SalawaatShellState.muted, height: 1.45)),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: const [ButtonSegment(value: 'iOS', label: Text('iPhone')), ButtonSegment(value: 'Android', label: Text('Android'))],
          selected: {platform},
          onSelectionChanged: (value) => onPlatform(value.first),
        ),
        const SizedBox(height: 14),
        _Card(
          child: Column(
            children: [10, 15, 30, 60].map((value) {
              final label = value == 60 ? 'Every hour' : 'Every $value minutes';
              return InkWell(
                onTap: () => onMinutes(value),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), if (value == 10) const Text("Habib's rhythm", style: TextStyle(color: _SalawaatShellState.muted, fontSize: 12))])),
                      Icon(minutes == value ? Icons.radio_button_checked : Icons.radio_button_off, color: minutes == value ? _SalawaatShellState.accent : _SalawaatShellState.muted),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Text('Alert strength', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _Card(
          child: Column(
            children: [
              _Strength('Gentle', 'Normal notification', strength == 'gentle', () => onStrength('gentle')),
              _Strength('On time', 'Exact timing when the platform permits', strength == 'ontime', () => onStrength('ontime')),
              _Strength('Hard to miss', platform == 'iOS' ? 'AlarmKit for selected reminders' : 'Alarm-style Android alert', strength == 'strong', () => onStrength('strong')),
            ],
          ),
        ),
        _Card(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: recovery,
            onChanged: onRecovery,
            title: const Text('Keep reminders going'),
            subtitle: Text(platform == 'iOS' ? 'Use a recovery reminder before the local queue runs low.' : 'Restore schedules after reboot or permission changes.'),
          ),
        ),
      ],
    );
  }
}

class _Strength extends StatelessWidget {
  const _Strength(this.title, this.subtitle, this.selected, this.onTap);
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? _SalawaatShellState.accent : _SalawaatShellState.muted),
    );
  }
}

class _Why extends StatelessWidget {
  const _Why();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text('WHY', style: _Styles.eyebrow),
        Text('Increase it.', style: _Styles.title),
        SizedBox(height: 18),
        _Arabic('فَإِنْ زِدْتَ فَهُوَ خَيْرٌ لَكَ'),
        SizedBox(height: 18),
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('“If you increase it, that is better for you.”', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), SizedBox(height: 10), _Pill('Jāmiʿ al-Tirmidhī 2457')])),
        _Card(child: Column(children: [_Arabic('مَنْ صَلَّى عَلَيَّ وَاحِدَةً صَلَّى اللَّهُ عَلَيْهِ عَشْرًا', size: 22), SizedBox(height: 10), Text('“Whoever sends ṣalāh upon me once, Allah sends ṣalāh upon him ten times.”', style: TextStyle(height: 1.45)), SizedBox(height: 10), Align(alignment: Alignment.centerLeft, child: _Pill('Ṣaḥīḥ Muslim 408'))])),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _SalawaatShellState.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF303637))),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF252B2C), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: _SalawaatShellState.accent, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _Arabic extends StatelessWidget {
  const _Arabic(this.text, {this.size = 26});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => Text(text, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: TextStyle(fontSize: size, height: 1.7, color: _SalawaatShellState.accent));
}

class _Styles {
  static const eyebrow = TextStyle(color: Color(0xFFCDBF9E), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2);
  static const title = TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.7);
}
