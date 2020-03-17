import 'package:calendart/calendart.dart';
import 'package:demo_items/demo_items.dart';
import 'package:editors/editors.dart';
import 'package:flutter/material.dart';

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
        SimpleCalendarWithSingleSelection(),
    'Simple Calendar with Multi Selection': SimpleCalendarWithSingleSelection(),
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
  final _calendarProperties = CalendarProperties();
  GlobalKey<CalendarState> _calendarKey2;

  DateTime _singleSelected;
  final _multiSelected = <DateTime>{};
  DateTime _rangeSelectedFrom;
  DateTime _rangeSelectedTo;
  DateTime _hovered;

  bool _isSelected(SelectionType selectionType, DateTime date) {
    switch (selectionType) {
      case SelectionType.single:
        return date == _singleSelected;
      case SelectionType.multi:
        return _multiSelected.contains(date);
      case SelectionType.range:
        if (_rangeSelectedFrom == null) return false;
        DateTime from;
        DateTime to;
        if (_rangeSelectedTo == null) {
          final hovered = _hovered ?? _rangeSelectedFrom;
          final isBefore = hovered.isBefore(_rangeSelectedFrom);
          from = isBefore ? hovered : _rangeSelectedFrom;
          to = isBefore ? _rangeSelectedFrom : hovered;
        } else {
          from = _rangeSelectedFrom;
          to = _rangeSelectedTo;
        }
        return !date.isBefore(from) && !date.isAfter(to);
      default:
        return false;
    }
  }

  void _setSelected(SelectionType selectionType, DateTime date) {
    switch (selectionType) {
      case SelectionType.single:
        if (_singleSelected != date) setState(() => _singleSelected = date);
        break;
      case SelectionType.multi:
        setState(() => (_multiSelected.contains(date)
            ? _multiSelected.remove
            : _multiSelected.add)(date));
        break;
      case SelectionType.range:
        setState(() {
          if (_rangeSelectedFrom == null || _rangeSelectedTo != null) {
            _rangeSelectedFrom = date;
            _rangeSelectedTo = null;
            _hovered = null;
          } else {
            if (date.isBefore(_rangeSelectedFrom)) {
              _rangeSelectedTo = _rangeSelectedFrom;
              _rangeSelectedFrom = date;
            } else {
              _rangeSelectedTo = date;
            }
          }
        });
        break;
      default:
        break;
    }
  }

  double _width;
  double _height;

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.all(16),
        children: [
          Column(
            children: [
              DemoItem<CalendarProperties>(
                properties: _calendarProperties,
                childBuilder: (properties) {
                  final width = properties.width.value.toDouble() *
                      properties.columns.value;
                  final height = properties.height.value.toDouble() *
                      properties.rows.value;
                  // update calendar widget if size changed
                  if (width != _width || height != _height) {
                    _width = width;
                    _height = height;
                    _calendarKey2 = GlobalKey<CalendarState>();
                  }

                  return ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: width, maxHeight: height),
                      child: Calendar(
                        key: _calendarKey2,
                        displayDate: DateTime(
                            properties.year.value, properties.month.value),
                        columns: properties.columns.value,
                        rows: properties.rows.value,
                        scrollDirection: properties.scrollDirection.value,
                        showDaysOfWeek: properties.showDaysOfWeek.value,
                        firstDayOfWeekIndex:
                            properties.firstDayOfWeekIndex.value,
                        dayBuilder: (context, date, type, column, row) {
                          final selectionType = properties.selectionType.value;
                          final hoverMode =
                              selectionType == SelectionType.range &&
                                  _rangeSelectedFrom != null &&
                                  _rangeSelectedTo == null;
                          var day = Calendar.buildDefaultDay(
                              context, date, type, column, row);
                          if (type != DayType.extraLow &&
                              type != DayType.extraHigh) {
                            day = SelectableCalendar.buildDefaultSelection(
                                context, date, type, column, row,
                                day: day,
                                isSelected: (_) =>
                                    _.month == date.month &&
                                    _isSelected(selectionType, _),
                                preselect: hoverMode);
                          }

                          return selectionType != SelectionType.none &&
                                  (type == DayType.today ||
                                      type == DayType.current)
                              ? InkResponse(
                                  child: day,
                                  onTap: () =>
                                      _setSelected(selectionType, date),
                                  onHover: hoverMode
                                      ? (hovered) {
                                          if (hovered) {
                                            setState(() => _hovered = date);
                                          }
                                        }
                                      : null,
                                )
                              : day;
                        },
                        buildCalendarDecorator: (context, date, calendar) =>
                            Row(
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
                      ));
                },
              ),
            ],
          ),
        ],
      );
}

enum SelectionType { none, single, multi, range }

class DemoItem<TProperties extends CalendarProperties>
    extends DemoItemBase<TProperties> {
  const DemoItem({
    Key key,
    @required TProperties properties,
    @required ChildBuilder<TProperties> childBuilder,
  }) : super(key: key, properties: properties, childBuilder: childBuilder);
  @override
  _DemoItemState<TProperties> createState() => _DemoItemState<TProperties>();
}

class _DemoItemState<TProperties extends CalendarProperties>
    extends DemoItemStateBase<TProperties> {
  @override
  Widget buildProperties() {
    final editors = widget.properties.editors;
    return EditorsContext(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: editors.length,
        itemBuilder: (context, index) => editors[index].build(),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
      ),
    );
  }
}

class CalendarProperties {
  final year = IntEditor(title: 'Year', value: DateTime.now().year);
  final month = IntEditor(
      title: 'Month', value: DateTime.now().month, minValue: 1, maxValue: 12);
  final width = IntEditor(title: 'Width', value: 300);
  final height = IntEditor(title: 'Height', value: 300);
  final columns = IntEditor(title: 'Columns', value: 1, minValue: 1);
  final rows = IntEditor(title: 'Rows', value: 1, minValue: 1);
  final scrollDirection = EnumEditor<Axis>(
      title: 'Scroll Direction',
      getList: () => Axis.values,
      value: Axis.horizontal);
  final selectionType = EnumEditor<SelectionType>(
      title: 'Selection Type',
      getList: () => SelectionType.values,
      value: SelectionType.single);
  final showDaysOfWeek = BoolEditor(title: 'Show Days of Week', value: true);
  final firstDayOfWeekIndex = EnumEditor<int>(
      title: 'First Day of Week Index',
      value: 0,
      getList: () => [0, 1, 2, 3, 4, 5, 6]);

  List<Editor> get editors => [
        year,
        month,
        width,
        height,
        columns,
        rows,
        scrollDirection,
        selectionType,
        showDaysOfWeek,
        firstDayOfWeekIndex,
      ];
}
