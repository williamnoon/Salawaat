import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SalawaatApp());
}

class SalawaatApp extends StatelessWidget {
  const SalawaatApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0B0E0F);
    const panel = Color(0xFF1A1F20);
    const accent = Color(0xFFEFE2C3);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salawaat',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          surface: panel,
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
  bool _onboarded = false;
  int _tab = 0;
  int _count = 27;
  int _minutes = 10;
  String _platform = 'iOS';
  String _strength = 'gentle';
  bool _recovery = true;

  static const accent = Color(0xFFEFE2C3);
  static const panel = Color(0xFF1A1F20);
  static const muted = Color(0xFFA9B0AE);

  void _recordSalawat() {
    setState(() => _count += 1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recorded'),
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  void _showReminder() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Salawāt'),
        message: const Column(
          children: [
            SizedBox(height: 6),
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
              Navigator.pop(context);
              _recordSalawat();
            },
            child: const Text('Done'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Text('Snoozed for 5 minutes'),
                  duration: Duration(milliseconds: 900),
                ),
              );
            },
            child: const Text('Snooze 5 minutes'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _tab = 0);
            },
            child: const Text('Open app'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Dismiss'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboarded) {
      return _Onboarding(
        onBegin: () => setState(() => _onboarded = true),
        onSchedule: () => setState(() {
          _onboarded = true;
          _tab = 1;
        }),
      );
    }

    final pages = <Widget>[
      _TodayPage(
        count: _count,
        minutes: _minutes,
        onRecord: _recordSalawat,
        onSimulate: _showReminder,
      ),
      _RhythmPage(
        minutes: _minutes,
        platform: _platform,
        strength: _strength,
        recovery: _recovery,
        onMinutesChanged: (value) => setState(() => _minutes = value),
        onPlatformChanged: (value) => setState(() => _platform = value),
        onStrengthChanged: (value) => setState(() => _strength = value),
        onRecoveryChanged: (value) => setState(() => _recovery = value),
      ),
      const _WhyPage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
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
              const Text(
                'فَإِنْ زِدْتَ فَهُوَ خَيْرٌ لَكَ',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, color: _SalawaatShellState.accent),
              ),
              const SizedBox(height: 24),
              const _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“If you increase it, that is better for you.”',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'From the narration of Ubayy ibn Kaʿb رضي الله عنه.',
                      style: TextStyle(color: _SalawaatShellState.muted),
                    ),
                    SizedBox(height: 10),
                    _Pill('Jāmiʿ al-Tirmidhī 2457'),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(onPressed: onBegin, child: const Text('Begin')),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onSchedule,
                child: const Text('Set reminder first'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayPage extends StatelessWidget {
  const _TodayPage({
    required this.count,
    required this.minutes,
    required this.onRecord,
    required this.onSimulate,
  });

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
        const SizedBox(height: 5),
        const Text('Salawāt', style: _Styles.title),
        const Text(
          'Return to the remembrance throughout your day.',
          style: TextStyle(color: _SalawaatShellState.muted, height: 1.45),
        ),
        const SizedBox(height: 26),
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A3031), width: 10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w800),
                ),
                const Text(
                  'completed today',
                  style: TextStyle(color: _SalawaatShellState.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, height: 1.7, color: _SalawaatShellState.accent),
        ),
        const SizedBox(height: 18),
        FilledButton(onPressed: onRecord, child: const Text('I said it')),
        const SizedBox(height: 12),
        _Card(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Next reminder', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(next, style: const TextStyle(color: _SalawaatShellState.muted)),
                  ],
                ),
              ),
              _Pill(cadence),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: onSimulate,
          child: const Text('Simulate reminder'),
        ),
      ],
    );
  }
}

class _RhythmPage extends StatelessWidget {
  const _RhythmPage({
    required this.minutes,
    required this.platform,
    required this.strength,
    required this.recovery,
    required this.onMinutesChanged,
    required this.onPlatformChanged,
    required this.onStrengthChanged,
    required this.onRecoveryChanged,
  });

  final int minutes;
  final String platform;
  final String strength;
  final bool recovery;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<String> onPlatformChanged;
  final ValueChanged<String> onStrengthChanged;
  final ValueChanged<bool> onRecoveryChanged;

  @override
  Widget build(BuildContext context) {
    const choices = [10, 15, 30, 60];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('SCHEDULE', style: _Styles.eyebrow),
        const Text('Your rhythm', style: _Styles.title),
        const Text(
          'Choose the cadence. The app handles iOS and Android scheduling differences underneath.',
          style: TextStyle(color: _SalawaatShellState.muted, height: 1.45),
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'iOS', label: Text('iPhone')),
            ButtonSegment(value: 'Android', label: Text('Android')),
          ],
          selected: {platform},
          onSelectionChanged: (value) => onPlatformChanged(value.first),
        ),
        const SizedBox(height: 14),
        _Card(
          child: Column(
            children: choices.map((value) {
              final title = value == 60 ? 'Every hour' : 'Every $value minutes';
              return RadioListTile<int>(
                contentPadding: EdgeInsets.zero,
                value: value,
                groupValue: minutes,
                onChanged: (next) {
                  if (next != null) onMinutesChanged(next);
                },
                title: Text(title),
                subtitle: value == 10 ? const Text("Habib's rhythm") : null,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Alert strength', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _Card(
          child: Column(
            children: [
              _StrengthTile(
                title: 'Gentle',
                subtitle: 'Normal notification',
                selected: strength == 'gentle',
                onTap: () => onStrengthChanged('gentle'),
              ),
              _StrengthTile(
                title: 'On time',
                subtitle: 'Exact timing when the platform permits',
                selected: strength == 'ontime',
                onTap: () => onStrengthChanged('ontime'),
              ),
              _StrengthTile(
                title: 'Hard to miss',
                subtitle: platform == 'iOS'
                    ? 'AlarmKit for selected reminders'
                    : 'Alarm-style Android alert',
                selected: strength == 'strong',
                onTap: () => onStrengthChanged('strong'),
              ),
            ],
          ),
        ),
        _Card(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: recovery,
            onChanged: onRecoveryChanged,
            title: const Text('Keep reminders going'),
            subtitle: Text(
              platform == 'iOS'
                  ? 'Use a recovery reminder before the local queue runs low.'
                  : 'Restore schedules after reboot or permission changes.',
            ),
          ),
        ),
      ],
    );
  }
}

class _StrengthTile extends StatelessWidget {
  const _StrengthTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

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
      trailing: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? _SalawaatShellState.accent : _SalawaatShellState.muted,
      ),
    );
  }
}

class _WhyPage extends StatelessWidget {
  const _WhyPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text('WHY', style: _Styles.eyebrow),
        Text('Increase it.', style: _Styles.title),
        SizedBox(height: 18),
        Text(
          'فَإِنْ زِدْتَ فَهُوَ خَيْرٌ لَكَ',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, color: _SalawaatShellState.accent),
        ),
        SizedBox(height: 18),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“If you increase it, that is better for you.”',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10),
              _Pill('Jāmiʿ al-Tirmidhī 2457'),
            ],
          ),
        ),
        _Card(
          child: Column(
            children: [
              Text(
                'مَنْ صَلَّى عَلَيَّ وَاحِدَةً صَلَّى اللَّهُ عَلَيْهِ عَشْرًا',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, height: 1.6, color: _SalawaatShellState.accent),
              ),
              SizedBox(height: 10),
              Text(
                '“Whoever sends ṣalāh upon me once, Allah sends ṣalāh upon him ten times.”',
                style: TextStyle(height: 1.45),
              ),
              SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: _Pill('Ṣaḥīḥ Muslim 408')),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _SalawaatShellState.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF303637)),
      ),
      child: child,
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
      decoration: BoxDecoration(
        color: const Color(0xFF252B2C),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _SalawaatShellState.accent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Styles {
  static const eyebrow = TextStyle(
    color: Color(0xFFCDBF9E),
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
  );

  static const title = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.7,
  );
}
