import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:core';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyTheme(),
      child: Consumer<MyTheme>(
        builder: (context, theme, _) {
          return MaterialApp(
            theme: theme.current,
            debugShowCheckedModeBanner: false,
            home: const MyPicker(),
          );
        },
      ),
    );
  }
}

class MyTheme extends ChangeNotifier {
  ThemeData current = ThemeData.light();
  int index = 0;

  checkTheme() {
    switch (index) {
      case 0:
        return ThemeData.light();
      case 1:
        return ThemeData.dark();

      case 2:
        return blueTheme;
    }
  }

  toggle() {
    ++index;
    if (index >= 3) index = 0;
    current = checkTheme();
    notifyListeners();
  }
}

class MyPicker extends StatefulWidget {
  const MyPicker({Key? key}) : super(key: key);
  @override
  _MyPickerState createState() => _MyPickerState();
}

class _MyPickerState extends State<MyPicker> {
  late DateTime _startDate, _endDate;
  late TimeOfDay _startTime, _endTime;

  @override
  void initState() {
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(hours: 1));
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);

    super.initState();
  }

  String get _differenceDays {
    final result = _endDate.difference(_startDate).inDays +
        ((_endTime.hour - _startTime.hour) +
                (_endTime.minute - _startTime.minute) / 60) /
            24;
    return (result.toStringAsFixed(2).length < 7)
        ? result.toStringAsFixed(2)
        : result.toStringAsExponential(1);
  }

  String get _differenceHours {
    final result = _endDate.difference(_startDate).inHours +
        (_endTime.hour - _startTime.hour) +
        (_endTime.minute - _startTime.minute) / 60;
    return (result.toStringAsFixed(2).length < 7)
        ? result.toStringAsFixed(2)
        : result.toStringAsExponential(1);
  }

  String get _differenceMinutes {
    final result = _endDate.difference(_startDate).inMinutes +
        (_endTime.hour - _startTime.hour) * 60 +
        (_endTime.minute - _startTime.minute);
    return ('$result'.length < 7) ? '$result' : result.toStringAsExponential(2);
  }

  String get _differenceSeconds {
    final result = _endDate.difference(_startDate).inSeconds +
        (_endTime.hour - _startTime.hour) * 60 * 60 +
        (_endTime.minute - _startTime.minute) * 60;
    return ('$result'.length < 7) ? '$result' : result.toStringAsExponential(2);
  }

  String get _differenceDayHourMin {
    final total = (_endTime.hour - _startTime.hour) * 60 +
        (_endTime.minute - _startTime.minute);

    return '${total ~/ 60}/${total % 60}';
  }

  Widget get _buildResult {
    return Column(
      children: [
        const Text("結果 (差)"),
        /*Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Text('日: $_differenceDays',
                  style: const TextStyle(fontSize: 30)),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Text('時間: $_differenceHours',
                  style: const TextStyle(fontSize: 30)),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Text('分: $_differenceMinutes',
                  style: const TextStyle(fontSize: 30)),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Text('秒: $_differenceSeconds',
                  style: const TextStyle(fontSize: 30)),
            ),
          ],
        ),*/
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Text('時間/分: $_differenceDayHourMin',
                  style: const TextStyle(fontSize: 30)),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _startPicker = DateTimePicker(
      date: _startDate,
      onChangeDate: (date) => setState(() => _startDate = date),
      onChangeTime: (time) => setState(() => _startTime = time),
    );
    final _endPicker = DateTimePicker(
      date: _endDate,
      onChangeDate: (date) => setState(() => _endDate = date),
      onChangeTime: (time) => setState(() => _endTime = time),
    );

    return Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [const Text("開始日時"), _startPicker]),
                  const SizedBox(height: 0),
                  Column(children: [const Text("終了日時"), _endPicker]),
                ],
              ),
              _buildResult,
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Provider.of<MyTheme>(context, listen: false).toggle();
          },
          child: const Icon(Icons.autorenew),
        ));
  }
}

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({
    Key? key,
    required this.date,
    required this.onChangeDate,
    required this.onChangeTime,
  }) : super(key: key);

  final DateTime date;
  final Function(DateTime date) onChangeDate;
  final Function(TimeOfDay time) onChangeTime;

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late double _height;
  late double _width;

  late String _hour, _minute, _time;

  late String dateTime;

  late DateTime selectedDate;

  TimeOfDay selectedTime = TimeOfDay.now();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(selectedDate);
        widget.onChangeDate(selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
        widget.onChangeTime(selectedTime);
      });
    }
  }

  @override
  void initState() {
    selectedDate = widget.date;
    _dateController.text = DateFormat.yMd().format(selectedDate);

    _timeController.text = formatDate(
        DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedDate.hour,
          selectedDate.minute,
        ),
        [hh, ':', nn, " ", am]).toString();
    super.initState();
  }

  Widget _displayText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontStyle: FontStyle.italic,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _displaySelector(Function _func, TextEditingController _controller) {
    return Ink(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: InkWell(
        onTap: () => _func(context),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          width: _width / 1.5,
          height: _height / 15,
          alignment: Alignment.center,
          child: TextFormField(
            style: const TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
            enabled: false,
            keyboardType: TextInputType.text,
            controller: _controller,
          ),
        ),
      ),
    );
  }

  Widget get _buildSelectDate {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _displayText("日付"),
          _displaySelector(_selectDate, _dateController),
        ],
      ),
    );
  }

  Widget get _buildSelectTime {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _displayText("時間"),
          _displaySelector(_selectTime, _timeController),
        ],
      ),
    );
  }

  Widget _buildSelect() {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //_buildSelectDate,
        _buildSelectTime,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    dateTime = DateFormat.yMd().format(DateTime.now());
    return _buildSelect();
  }
}
