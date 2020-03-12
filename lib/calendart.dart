library multicalendar;

import 'package:flutter/material.dart';

enum DayType { extraLow, current, today, extraHigh }
typedef DayBuilder = Widget Function(
    BuildContext context, DateTime date, DayType type, int colunm, int row);
typedef CalendarDecoratorBuilder = Widget Function(
    BuildContext context, DateTime displayDate, Widget calendar);

class _Calendar extends StatelessWidget {
  const _Calendar({
    Key key,
    this.displayDate,
    this.firstDayOfWeekIndex,
    this.showDaysOfWeek = true,
    @required this.dayOfWeekBuilder,
    @required this.dayBuilder,
  })  : assert(showDaysOfWeek != null),
        assert(dayOfWeekBuilder != null),
        assert(dayBuilder != null),
        super(key: key);

  final DateTime displayDate;
  final int firstDayOfWeekIndex;
  final bool showDaysOfWeek;
  final IndexedWidgetBuilder dayOfWeekBuilder;
  final DayBuilder dayBuilder;

  @override
  Widget build(BuildContext context) {
    final firstDayOfWeekIndex = this.firstDayOfWeekIndex ??
        MaterialLocalizations.of(context).firstDayOfWeekIndex ??
        0;
    final daysOfWeekFactor = showDaysOfWeek ? 1 : 0;

    DateTime getDate(DateTime date) =>
        DateTime(date.year, date.month, date.day);

    final today = getDate(DateTime.now());
    final date = this.displayDate ?? today;
    final displayDate = DateTime(date.year, date.month);

    var firstDate = DateTime(displayDate.year, displayDate.month, 1);
    final shift =
        (firstDate.weekday == DateTime.sunday ? 0 : firstDate.weekday) -
            firstDayOfWeekIndex;
    firstDate = firstDate.subtract(
        Duration(days: shift < 0 ? shift + DateTime.daysPerWeek : shift));
    if (firstDate.month == 2 &&
        firstDate.day == 1 &&
        DateTime(firstDate.year, 3, 1).difference(firstDate).inDays == 28) {
      firstDate =
          firstDate.subtract(const Duration(days: DateTime.daysPerWeek));
    }

    Widget buildDay(int column, int row) {
      final date =
          firstDate.add(Duration(days: row * DateTime.daysPerWeek + column));
      final type = date.isBefore(displayDate)
          ? DayType.extraLow
          : date.month == displayDate.month
              ? date == today ? DayType.today : DayType.current
              : DayType.extraHigh;

      return dayBuilder(context, date, type, column, row);
    }

    return Column(
      children: Iterable.generate(6 + daysOfWeekFactor)
          .map(
            (row) => Expanded(
              child: Row(
                children: Iterable.generate(DateTime.daysPerWeek)
                    .map(
                      (column) => Expanded(
                          child: showDaysOfWeek && row == 0
                              ? dayOfWeekBuilder(
                                  context,
                                  (column + firstDayOfWeekIndex) %
                                      DateTime.daysPerWeek)
                              : buildDay(column, row - daysOfWeekFactor)),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({
    Key key,
    this.displayDate,
    this.firstDayOfWeekIndex,
    this.showDaysOfWeek = true,
    this.dayOfWeekBuilder = buildDefaultDayOfWeek,
    this.dayBuilder = buildDefaultDay,
    this.onDisplayDateChanged,
    this.columns = 1,
    this.rows = 1,
    this.scrollDirection = Axis.horizontal,
    this.buildCalendarDecorator,
  })  : assert(showDaysOfWeek != null),
        assert(dayOfWeekBuilder != null),
        assert(dayBuilder != null),
        assert(columns > 0),
        assert(rows > 0),
        assert(scrollDirection != null),
        super(key: key);

  final DateTime displayDate;
  final int firstDayOfWeekIndex;
  final bool showDaysOfWeek;
  final IndexedWidgetBuilder dayOfWeekBuilder;
  final DayBuilder dayBuilder;
  final ValueChanged<DateTime> onDisplayDateChanged;
  final int columns;
  final int rows;
  final Axis scrollDirection;
  final CalendarDecoratorBuilder buildCalendarDecorator;

  @override
  CalendarState createState() => CalendarState(displayDate);

  static Widget buildDefaultDayOfWeek(BuildContext context, int index) =>
      Center(
          child: Text(MaterialLocalizations.of(context).narrowWeekdays[index],
              style: TextStyle(color: Colors.blueAccent)));

  static Widget buildDefaultDay(BuildContext context, DateTime date,
          DayType type, int column, int row) =>
      Center(
          child: Text(
        date.day.toString(),
        style: TextStyle(
          color: type == DayType.extraLow || type == DayType.extraHigh
              ? Colors.grey
              : null,
          decoration: type == DayType.today ? TextDecoration.underline : null,
        ),
      ));

  static Widget buildSimpleSelection(
      BuildContext context, DateTime date, DayType type, int column, int row,
      {@required Widget day,
      @required bool selected,
      bool selectExtra = false,
      Color color = Colors.blueAccent,
      double opacity = 1.0,
      Radius radius = const Radius.circular(9999)}) {
    final select = selected &&
        (selectExtra ||
            (type != DayType.extraLow && type != DayType.extraHigh));
    return Container(
      child: select
          ? DefaultTextStyle(child: day, style: TextStyle(color: color))
          : day,
      decoration: select
          ? BoxDecoration(
              color: color.withOpacity(0.1 * opacity),
              border: Border.all(color: color.withOpacity(opacity)),
              borderRadius: BorderRadius.all(radius),
            )
          : null,
    );
  }

  static Widget buildSmoothSelection(
      DateTime date, DayType type, int column, int row,
      {@required Widget day,
      bool Function(DateTime date) isSelected,
      Color color = Colors.blueAccent,
      double opacity = 1.0,
      Radius radius = const Radius.circular(9999)}) {
    final selected = isSelected(date);
    final leftSelected =
        column != 0 && isSelected(date.subtract(const Duration(days: 1)));
    final rightSelected = column != DateTime.daysPerWeek - 1 &&
        isSelected(date.add(const Duration(days: 1)));
    final topSelected = row != 0 &&
        isSelected(date.subtract(const Duration(days: DateTime.daysPerWeek)));
    final bottomSelected = row != 5 &&
        isSelected(date.add(const Duration(days: DateTime.daysPerWeek)));

    final opacityColor = color.withOpacity(opacity);
    final borderSide = BorderSide(color: opacityColor);
    return Container(
      child: selected
          ? DefaultTextStyle(child: day, style: TextStyle(color: color))
          : day,
      decoration: selected
          ? BoxDecoration(
              color: opacityColor.withOpacity(0.1),
              border: Border(
                left: leftSelected ? BorderSide.none : borderSide,
                right: rightSelected ? BorderSide.none : borderSide,
                top: topSelected ? BorderSide.none : borderSide,
                bottom: bottomSelected ? BorderSide.none : borderSide,
              ),
            )
          : null,
    );
  }
}

class CalendarState extends State<Calendar> {
  CalendarState(DateTime displayDate)
      : _displayDate = _getMonthDate(displayDate);
  static const _itemsBefore = 2;

  UniqueKey _listKey;
  ScrollController _controller;
  DateTime _displayDate;
  double _calendarWidth;
  double _calendarHeight;
  double get _lenght => widget.scrollDirection == Axis.horizontal
      ? _calendarWidth
      : _calendarHeight;

  static DateTime _getMonthDate(DateTime date) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month);
  }

  @override
  void didUpdateWidget(Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final displayDate = _getMonthDate(widget.displayDate);
    if ((_getMonthDate(oldWidget.displayDate) != displayDate &&
            _displayDate != displayDate) ||
        oldWidget.scrollDirection != widget.scrollDirection ||
        oldWidget.columns != widget.columns ||
        oldWidget.rows != widget.rows) {
      _reset(displayDate);
    }
  }

  void _reset(DateTime date) => setState(() {
        _controller.dispose();
        _controller = null;
        _listKey = null;
        _displayDate = date;
      });

  void _move(double offset) =>
      _controller.animateTo(_controller.position.pixels + offset,
          duration: const Duration(milliseconds: 300), curve: Curves.bounceOut);

  void inc() => _move(_lenght);
  void dec() => _move(-_lenght);

  DateTime _getDate(int row, [int column = 0]) {
    final crossFactor =
        widget.scrollDirection == Axis.horizontal ? 1 : widget.columns;
    final monthCount = _displayDate.year * DateTime.monthsPerYear +
        _displayDate.month -
        _itemsBefore * crossFactor -
        1 +
        row * crossFactor +
        column;
    final month = (monthCount + 1) % DateTime.monthsPerYear;
    return DateTime(
        monthCount ~/ DateTime.monthsPerYear, month == 0 ? 12 : month);
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constrants) {
        _calendarWidth = constrants.maxWidth / widget.columns;
        _calendarHeight = constrants.maxHeight / widget.rows;
        final scrollDirection = widget.scrollDirection;
        final horizontal = scrollDirection == Axis.horizontal;

        return NotificationListener<ScrollEndNotification>(
          onNotification: (_) {
            final date = _getDate(_controller.position.pixels ~/ _lenght);
            if (date != _displayDate) {
              _reset(date);
              if (widget.onDisplayDateChanged != null) {
                widget.onDisplayDateChanged(date);
              }
            }
            return true;
          },
          child: ListView.builder(
            key: _listKey ??= UniqueKey(),
            controller: _controller ??=
                ScrollController(initialScrollOffset: _itemsBefore * _lenght),
            physics: _SnapScrollPhysics(itemSize: _lenght),
            scrollDirection: scrollDirection,
            itemBuilder: (context, index) {
              Widget build(int row, [int column = 0]) {
                final date = _getDate(row, column);
                final calendar = _Calendar(
                  displayDate: date,
                  firstDayOfWeekIndex: widget.firstDayOfWeekIndex,
                  showDaysOfWeek: widget.showDaysOfWeek,
                  dayOfWeekBuilder: widget.dayOfWeekBuilder,
                  dayBuilder: widget.dayBuilder,
                );
                return SizedBox(
                  width: _calendarWidth,
                  height: _calendarHeight,
                  child: widget.buildCalendarDecorator == null
                      ? calendar
                      : widget.buildCalendarDecorator(context, date, calendar),
                );
              }

              final calendars =
                  Iterable.generate(horizontal ? widget.rows : widget.columns)
                      .map((_) => build(
                          horizontal ? index + _ * widget.columns : index,
                          horizontal ? 0 : _))
                      .toList();
              return calendars.length == 1
                  ? calendars[0]
                  : horizontal
                      ? Column(children: calendars)
                      : Row(children: calendars);
            },
          ),
        );
      });

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class _SnapScrollPhysics extends ScrollPhysics {
  const _SnapScrollPhysics({ScrollPhysics parent, @required this.itemSize})
      : assert(itemSize > 0),
        super(parent: parent);

  final double itemSize;

  @override
  _SnapScrollPhysics applyTo(ScrollPhysics ancestor) =>
      _SnapScrollPhysics(parent: buildParent(ancestor), itemSize: itemSize);

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = this.tolerance;
    final target = (position.pixels / itemSize +
                ((velocity < -tolerance.velocity)
                    ? -0.5
                    : velocity > tolerance.velocity ? 0.5 : 0))
            .roundToDouble() *
        itemSize;
    return target == position.pixels
        ? null
        : ScrollSpringSimulation(spring, position.pixels, target, velocity,
            tolerance: tolerance);
  }

  @override
  bool get allowImplicitScrolling => false;
}
