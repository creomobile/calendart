import 'package:calendart/calendart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: HomePage());
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _demos = <String, Widget>{
    'Simple Calendar with Single Selection':
        const SimpleCalendarWithSingleSelection(),
    'Simple Calendar with Multi Selection':
        const SimpleCalendarWithSingleSelection(),
  };

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: _demos.length,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Calendar Sample App'),
              bottom: TabBar(
                  tabs: _demos.keys.map((_) => Tab(child: Text(_))).toList()),
            ),
            body: TabBarView(children: _demos.values.toList())),
      );
}

class SimpleCalendarWithSingleSelection extends StatefulWidget {
  const SimpleCalendarWithSingleSelection();

  @override
  _SimpleCalendarWithSingleSelectionState createState() =>
      _SimpleCalendarWithSingleSelectionState();
}

class _SimpleCalendarWithSingleSelectionState
    extends State<SimpleCalendarWithSingleSelection> {
  final _calendarKey = GlobalKey<CalendarState>();
  final _calendarWidthController = TextEditingController(text: '300');
  final _calendarHeightController = TextEditingController(text: '300');
  final _columnsController = TextEditingController(text: '1');
  final _rowsController = TextEditingController(text: '1');
  var _calendarWidth = 300;
  var _calendarHeight = 300;
  var _columns = 1;
  int get columns => _columns > 0 ? _columns : 1;
  var _rows = 1;
  int get rows => _rows > 0 ? _rows : 1;
  var _scrollDirection = Axis.horizontal;

  var _displayed = DateTime.now();
  DateTime _selected;

  @override
  Widget build(BuildContext context) {
    Widget buildIntSelector(TextEditingController controller, String labelText,
            void Function(int value) setValue,
            [enabled = true]) =>
        SizedBox(
          width: 200,
          child: TextField(
            controller: controller,
            enabled: enabled,
            inputFormatters: [
              IntTextInputFormatter(minValue: 0, maxValue: 5000)
            ],
            decoration: InputDecoration(labelText: labelText),
            onChanged: (_) => setState(() => setValue(int.tryParse(_) ?? 0)),
          ),
        );

    Widget buildEnumSelector<T>(String title, Iterable<T> values, T value,
            void Function(T value) setValue) =>
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(title,
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          DropdownButton<T>(
            items: values
                .map((_) => DropdownMenuItem<T>(
                    value: _, child: Text(TextHelper.enumToString(_))))
                .toList(),
            value: value,
            onChanged: (_) => setState(() => setValue(_)),
          ),
        ]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(spacing: 24, runSpacing: 16, children: [
            // calendar width
            buildIntSelector(_calendarWidthController, 'Calendar Width',
                (_) => _calendarWidth = _),
            // calendar height
            buildIntSelector(_calendarHeightController, 'Calendar Height',
                (_) => _calendarHeight = _),
            // columns
            buildIntSelector(
                _columnsController, 'Columns', (_) => _columns = _),
            // rows
            buildIntSelector(_rowsController, 'Rows', (_) => _rows = _),

            // scroll direction
            buildEnumSelector<Axis>('Scroll Direction:', Axis.values,
                _scrollDirection, (_) => _scrollDirection = _),

            // dec
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => _calendarKey.currentState?.dec()),

            // inc
            IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () => _calendarKey.currentState?.inc()),
          ]),
        ),
        Text(_displayed.toString()),
        Expanded(
          child: Center(
            child: Container(
              key: ValueKey(_scrollDirection),
              constraints: BoxConstraints(
                  maxWidth: _calendarWidth.toDouble() * columns,
                  maxHeight: _calendarHeight.toDouble() * rows),
              padding: const EdgeInsets.all(16),
              child: Calendar(
                key: _calendarKey,
                columns: columns,
                rows: rows,
                displayDate: _displayed,
                scrollDirection: _scrollDirection,
                onDisplayDateChanged: (_) => setState(() => _displayed = _),
                dayBuilder: (date, type, column, row) {
                  final day = Calendar.buildDefaultDay(date, type, column, row,
                      selected: _selected == date);
                  return type == DayType.today || type == DayType.current
                      ? InkResponse(
                          child: day,
                          onTap: () => setState(() => _selected = date))
                      : day;
                },
                buildCalendarDecorator: (date, calendar) => Row(
                  children: [
                    Expanded(
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('${date.month} ${date.year}',
                              style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: calendar),
                      ]),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IntTextInputFormatter extends TextInputFormatter {
  IntTextInputFormatter({this.minValue, this.maxValue});

  final int minValue;
  final int maxValue;

  String format(String oldValue, String newValue) {
    if (newValue?.isNotEmpty != true) return '';
    if (newValue.contains('-')) return oldValue;

    var i = int.tryParse(newValue);
    if (i == null) return oldValue;
    if (minValue != null && i < minValue) i = minValue;
    if (maxValue != null && i > maxValue) i = maxValue;

    return i.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final value = format(oldValue.text, newValue.text);
    return value != newValue.text
        ? newValue.copyWith(
            text: value,
            selection: TextSelection.collapsed(offset: value.length))
        : newValue.copyWith(text: value);
  }
}

class TextHelper {
  static String _camelToWords(String value) {
    final codes = value.runes
        .skip(1)
        .map((_) => String.fromCharCode(_))
        .map((_) => _.toUpperCase() == _ ? ' $_' : _)
        .expand((_) => _.runes);

    return value[0].toUpperCase() + String.fromCharCodes(codes);
  }

  static String enumToString(dynamic value) =>
      value == null ? '' : _camelToWords(value.toString().split('.')[1]);
}
