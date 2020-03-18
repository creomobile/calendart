library multicalendar;

import 'dart:ui';

import 'package:flutter/material.dart';

enum DayType { extraLow, current, today, extraHigh }
typedef DayBuilder = Widget Function(
    BuildContext context, DateTime date, DayType type, int colunm, int row);
typedef CalendarDecoratorBuilder = Widget Function(
    BuildContext context, DateTime displayDate, Widget calendar);

class CalendarParameters {
  const CalendarParameters({
    this.firstDayOfWeekIndex,
    this.showDaysOfWeek,
    this.dayOfWeekBuilder,
    this.dayBuilder,
    this.decoratorBuilder,
    this.horizontalSeparator,
    this.verticalSeparator,
    this.scrollDirection,
  });

  static const defaultParameters = CalendarParameters(
    showDaysOfWeek: true,
    dayOfWeekBuilder: buildDefaultDayOfWeek,
    dayBuilder: buildDefaultDay,
    horizontalSeparator: PreferredSize(
        preferredSize: Size.fromWidth(32), child: SizedBox(width: 32)),
    verticalSeparator: PreferredSize(
        preferredSize: Size.fromHeight(32), child: SizedBox(height: 32)),
    scrollDirection: Axis.horizontal,
  );

  final int firstDayOfWeekIndex;
  final bool showDaysOfWeek;
  final IndexedWidgetBuilder dayOfWeekBuilder;
  final DayBuilder dayBuilder;
  final CalendarDecoratorBuilder decoratorBuilder;
  final PreferredSizeWidget horizontalSeparator;
  final PreferredSizeWidget verticalSeparator;
  final Axis scrollDirection;

  CalendarParameters copyWith({
    int firstDayOfWeekIndex,
    bool showDaysOfWeek,
    IndexedWidgetBuilder dayOfWeekBuilder,
    DayBuilder dayBuilder,
    CalendarDecoratorBuilder decoratorBuilder,
    PreferredSizeWidget horizontalSeparator,
    PreferredSizeWidget verticalSeparator,
    Axis scrollDirection,
  }) =>
      CalendarParameters(
        firstDayOfWeekIndex: firstDayOfWeekIndex ?? this.firstDayOfWeekIndex,
        showDaysOfWeek: showDaysOfWeek ?? this.showDaysOfWeek,
        dayOfWeekBuilder: dayOfWeekBuilder ?? this.dayOfWeekBuilder,
        dayBuilder: dayBuilder ?? this.dayBuilder,
        decoratorBuilder: decoratorBuilder ?? this.decoratorBuilder,
        horizontalSeparator: horizontalSeparator ?? this.horizontalSeparator,
        verticalSeparator: verticalSeparator ?? this.verticalSeparator,
        scrollDirection: scrollDirection ?? this.scrollDirection,
      );

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
}

class CalendarContext extends StatelessWidget {
  const CalendarContext({
    Key key,
    @required this.parameters,
    @required this.child,
  })  : assert(parameters != null),
        assert(child != null),
        super(key: key);

  final CalendarParameters parameters;
  final Widget child;

  static CalendarContextData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CalendarContextData>();

  @override
  Widget build(BuildContext context) {
    final parentData = CalendarContext.of(context);
    final def = parentData == null
        ? CalendarParameters.defaultParameters
        : parentData.parameters;
    final my = parameters;
    final merged = CalendarParameters(
      firstDayOfWeekIndex: my.firstDayOfWeekIndex ?? def.firstDayOfWeekIndex,
      showDaysOfWeek: my.showDaysOfWeek ?? def.showDaysOfWeek,
      dayOfWeekBuilder: my.dayOfWeekBuilder ?? def.dayOfWeekBuilder,
      dayBuilder: my.dayBuilder ?? def.dayBuilder,
      decoratorBuilder: my.decoratorBuilder ?? def.decoratorBuilder,
      horizontalSeparator: my.horizontalSeparator ?? def.horizontalSeparator,
      verticalSeparator: my.verticalSeparator ?? def.verticalSeparator,
      scrollDirection: my.scrollDirection ?? def.scrollDirection,
    );

    return CalendarContextData(this, child, merged);
  }
}

class CalendarContextData extends InheritedWidget {
  const CalendarContextData(this._widget, Widget child, this.parameters)
      : super(child: child);

  final CalendarContext _widget;
  final CalendarParameters parameters;

  @override
  bool updateShouldNotify(CalendarContextData oldWidget) =>
      _widget.parameters != oldWidget._widget.parameters;
}

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
    this.dayBuilder = CalendarParameters.buildDefaultDay,
    this.onDisplayDateChanged,
    this.columns = 1,
    this.rows = 1,
  })  : assert(dayBuilder != null),
        assert(columns > 0),
        assert(rows > 0),
        super(key: key);

  final DateTime displayDate;
  final DayBuilder dayBuilder;
  final ValueChanged<DateTime> onDisplayDateChanged;
  final int columns;
  final int rows;

  @override
  CalendarState createState() => CalendarState(displayDate);
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
  Axis _scrollDirection;
  double get _lenght =>
      _scrollDirection == Axis.horizontal ? _calendarWidth : _calendarHeight;

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
        (CalendarContext.of(context)?.parameters ??
                    CalendarParameters.defaultParameters)
                .scrollDirection !=
            _scrollDirection ||
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
        _scrollDirection == Axis.horizontal ? 1 : widget.columns;
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
  Widget build(BuildContext context) {
    final parameters = CalendarContext.of(context)?.parameters ??
        CalendarParameters.defaultParameters;
    _scrollDirection = parameters.scrollDirection;
    return LayoutBuilder(builder: (context, constrants) {
      final horizontalSeparator = parameters.horizontalSeparator;
      final verticalSeparator = parameters.verticalSeparator;
      final separatorWidth = horizontalSeparator?.preferredSize?.width ?? 0.0;
      final separatorHeight = verticalSeparator?.preferredSize?.height ?? 0.0;

      final scrollDirection = parameters.scrollDirection;
      final horizontal = scrollDirection == Axis.horizontal;

      final maxWidth =
          constrants.maxWidth + (horizontal ? separatorWidth : 0.0);
      final maxHeight =
          constrants.maxHeight + (!horizontal ? separatorHeight : 0.0);

      _calendarWidth = maxWidth / widget.columns;
      _calendarHeight = maxHeight / widget.rows;

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
              Widget calendar = _Calendar(
                displayDate: date,
                firstDayOfWeekIndex: parameters.firstDayOfWeekIndex,
                showDaysOfWeek: parameters.showDaysOfWeek,
                dayOfWeekBuilder: parameters.dayOfWeekBuilder,
                dayBuilder: widget.dayBuilder,
              );
              if (parameters.decoratorBuilder != null) {
                calendar = parameters.decoratorBuilder(context, date, calendar);
              }
              final separator =
                  horizontal ? horizontalSeparator : verticalSeparator;
              if (separator != null) {
                final separatedItems = [Expanded(child: calendar), separator];
                calendar = horizontal
                    ? Row(children: separatedItems)
                    : Column(children: separatedItems);
              }

              return SizedBox(
                  width: _calendarWidth,
                  height: _calendarHeight,
                  child: calendar);
            }

            var calendars =
                Iterable.generate(horizontal ? widget.rows : widget.columns)
                    .map((_) => build(
                        horizontal ? index + _ * widget.columns : index,
                        horizontal ? 0 : _))
                    .toList();
            if (calendars.length == 1) return calendars[0];

            final separator = horizontal
                ? verticalSeparator == null
                    ? null
                    : SizedBox(
                        width: _calendarWidth - separatorWidth,
                        child: verticalSeparator)
                : horizontalSeparator == null
                    ? null
                    : SizedBox(
                        height: _calendarHeight - separatorHeight,
                        child: horizontalSeparator);
            if (separator != null) {
              calendars = calendars
                  .map((e) =>
                      [if (e != calendars[0]) separator, Expanded(child: e)])
                  .expand((e) => e)
                  .toList();
            }

            return horizontal
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: calendars)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: calendars);
          },
        ),
      );
    });
  }

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

typedef SelectionBuilder = Widget Function(
    BuildContext context, DateTime date, DayType type, int colunm, int row,
    {@required Widget day,
    @required bool Function(DateTime date) isSelected,
    @required bool preselect});

class SelectableCalendar<TSelection> extends StatefulWidget {
  const SelectableCalendar({
    Key key,
    this.selected,
    this.onSelectedChanged,
    this.buildSelection = buildDefaultSelection,
  }) : super(key: key);

  final TSelection selected;
  final ValueChanged<TSelection> onSelectedChanged;
  final SelectionBuilder buildSelection;

  @override
  SelectableCalendarState createState() => SelectableCalendarState();

  static Widget buildDefaultSelection(
      BuildContext context, DateTime date, DayType type, int column, int row,
      {@required Widget day,
      @required bool Function(DateTime date) isSelected,
      bool preselect = false,
      Color color = Colors.blueAccent,
      double opacity}) {
    final selected = isSelected(date);
    final leftSelected =
        column != 0 && isSelected(date.subtract(const Duration(days: 1)));
    final rightSelected = column != DateTime.daysPerWeek - 1 &&
        isSelected(date.add(const Duration(days: 1)));
    final topSelected = row != 0 &&
        isSelected(date.subtract(const Duration(days: DateTime.daysPerWeek)));
    final bottomSelected = row != 5 &&
        isSelected(date.add(const Duration(days: DateTime.daysPerWeek)));

    final opacityColor = color.withOpacity(opacity ?? preselect ? 0.3 : 1.0);
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

class SelectableCalendarState extends State<SelectableCalendar> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

typedef CalendarsDecoratorBuilder = Widget Function(BuildContext context,
    bool mirrored, DateTime displayDate, Widget calendars);
