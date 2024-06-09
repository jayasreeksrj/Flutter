import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Age & BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepOrange),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String myAge = '';
  String bmiResult = '';
  String report = '';
  bool isLeapYear = false;
  int daysToNextBirthday = 0;
  bool isEligibleToVote = false;
  bool _showResults = false;

  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _animation = ColorTween(begin: Colors.blue[200], end: Colors.deepOrange[200])
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final birthDate = DateTime.parse(_dobController.text);
    calculateAge(birthDate);
    calculateBmi();
    setState(() {
      _showResults = true;
    });
  }

  void _reset() {
    setState(() {
      myAge = '';
      bmiResult = '';
      report = '';
      isLeapYear = false;
      daysToNextBirthday = 0;
      isEligibleToVote = false;
      _showResults = false;
      _nameController.clear();
      _dobController.clear();
      _heightController.clear();
      _weightController.clear();
    });
  }

  void pickDob(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        _dobController.text = '${pickedDate.toLocal()}'.split(' ')[0];
      }
    });
  }

  void calculateAge(DateTime birth) {
    DateTime now = DateTime.now();
    Duration ageDuration = now.difference(birth);
    int years = ageDuration.inDays ~/ 365;
    int months = (ageDuration.inDays % 365) ~/ 30;
    int days = (ageDuration.inDays % 365) % 30;

    setState(() {
      myAge = '$years years, $months months, and $days days';
      isLeapYear = (birth.year % 4 == 0 && birth.year % 100 != 0) || (birth.year % 400 == 0);
      DateTime nextBirthday = DateTime(now.year, birth.month, birth.day);
      if (nextBirthday.isBefore(now)) {
        nextBirthday = DateTime(now.year + 1, birth.month, birth.day);
      }
      daysToNextBirthday = nextBirthday.difference(now).inDays;
      isEligibleToVote = years >= 18;
    });
  }

  void calculateBmi() {
    double height = double.parse(_heightController.text) / 100;
    double weight = double.parse(_weightController.text);
    double bmi = weight / (height * height);

    String bmiCategory;
    if (bmi < 18.5) {
      bmiCategory = 'Underweight';
    } else if (bmi < 24.9) {
      bmiCategory = 'Normal weight';
    } else if (bmi < 29.9) {
      bmiCategory = 'Overweight';
    } else {
      bmiCategory = 'Obesity';
    }

    setState(() {
      bmiResult = bmi.toStringAsFixed(2);
      report = 'Your BMI category is $bmiCategory';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Age & BMI Calculator"),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).primaryColorDark,
        ),
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            color: _animation.value,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _showResults ? _buildResults() : _buildForm(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dobController,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            hintText: 'Tap to pick date',
          ),
          onTap: () => pickDob(context),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _heightController,
          decoration: const InputDecoration(labelText: 'Height in cm'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _weightController,
          decoration: const InputDecoration(labelText: 'Weight in kg'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
    Text('Hello ${_nameController.text}!', style: Theme.of(context).textTheme.headlineLarge),
    const SizedBox(height: 16),
    Text('Your age is:', style: Theme.of(context).textTheme.headlineMedium),
    Text(myAge, style: Theme.of(context).textTheme.bodyLarge),
    const SizedBox(height: 16),
    Text('Your BMI is:', style: Theme.of(context).textTheme.headlineMedium),
    Text(bmiResult, style: Theme.of(context).textTheme.bodyLarge),
    const SizedBox(height: 16),
    Text(report, style: Theme.of(context).textTheme.bodyLarge),
    const SizedBox(height: 16),
    Text(isLeapYear ? 'You were born in a leap year.' : 'You were not born in a leap year.', style: Theme.of(context).textTheme.bodyLarge),
    const SizedBox(height: 16),
    Text('Days to next birthday: $daysToNextBirthday', style: Theme.of(context).textTheme.bodyLarge),
    const SizedBox(height: 16),
    Text(
    isEligibleToVote
    ? 'You are eligible to vote and acquire a driving license.'
        : 'You are not eligible to vote and acquire a driving license.',
      style: Theme.of(context).textTheme.bodyLarge,
    ),
          const SizedBox(height: 16),
          Text(
            'BMI Predictions for the Next 5 Years:',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: BmiChartPainter(double.parse(bmiResult)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _reset,
            child: const Text('Reset'),
          ),
        ],
    );
  }
}

class BmiChartPainter extends CustomPainter {
  final double currentBmi;
  BmiChartPainter(this.currentBmi);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10;

    final textStyle = TextStyle(color: Colors.black, fontSize: 12);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final barWidth = size.width / 6;
    for (int i = 0; i < 5; i++) {
      double predictedBmi = currentBmi + i * 0.5; // Simple linear prediction
      double barHeight = (predictedBmi / 40) * size.height; // Assuming max BMI to be 40

      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth + barWidth / 2 - 5,
          size.height - barHeight,
          10,
          barHeight,
        ),
        paint,
      );

      textPainter.text = TextSpan(
        text: '${2024 + i}',
        style: textStyle,
      );
      textPainter.layout(minWidth: 0, maxWidth: barWidth);
      textPainter.paint(
        canvas,
        Offset(i * barWidth + barWidth / 2 - textPainter.width / 2, size.height - barHeight - 20),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

