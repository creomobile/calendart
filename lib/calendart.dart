library multicalendar;

import 'dart:ui';

import 'package:flutter/material.dart';

enum DayType { extraLow, current, today, extraHigh }
typedef DayBuilder = Widget Function(
    BuildContext context,
    CalendarParameters parameters,
    DateTime date,
    DayType type,
    int column,
    int row);
typedef SelectionBuilder = Widget Function(
    BuildContext context,
    CalendarParameters parameters,
    DateTime date,
    int column,
    int row,
    Widget day,
    bool preselect,
    bool Function(DateTime date) isSelected);
typedef CalendarDecoratorBuilder = Widget Function(
    BuildContext context, DateTime displayDate, Widget calendar);

class CalendarParameters {
  const CalendarParameters({
    this.firstDayOfWeekIndex,
    this.showDaysOfWeek,
    this.dayOfWeekBuilder,
    this.dayBuilder,
    this.selectionBuilder,
    this.decoratorBuilder,
    this.horizontalSeparator,
    this.verticalSeparator,
    this.scrollDirection,
  });

  static const defaultParameters = CalendarParameters(
    showDaysOfWeek: true,
    dayOfWeekBuilder: buildDefaultDayOfWeek,
    dayBuilder: buildDefaultDay,
    selectionBuilder: buildDefaultSelection,
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
  final SelectionBuilder selectionBuilder;
  final CalendarDecoratorBuilder decoratorBuilder;
  final PreferredSizeWidget horizontalSeparator;
  final PreferredSizeWidget verticalSeparator;
  final Axis scrollDirection;

  CalendarParameters copyWith({
    int firstDayOfWeekIndex,
    bool showDaysOfWeek,
    IndexedWidgetBuilder dayOfWeekBuilder,
    DayBuilder dayBuilder,
    SelectionBuilder selectionBuilder,
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
        selectionBuilder: selectionBuilder ?? this.selectionBuilder,
        decoratorBuilder: decoratorBuilder ?? this.decoratorBuilder,
        horizontalSeparator: horizontalSeparator ?? this.horizontalSeparator,
        verticalSeparator: verticalSeparator ?? this.verticalSeparator,
        scrollDirection: scrollDirection ?? this.scrollDirection,
      );

  static Widget buildDefaultDayOfWeek(BuildContext context, int index) =>
      Center(
          child: Text(MaterialLocalizations.of(context).narrowWeekdays[index],
              style: TextStyle(color: Colors.blueAccent)));

  static Widget buildDefaultDay(
          BuildContext context,
          CalendarParameters parameters,
          DateTime date,
          DayType type,
          int column,
          int row) =>
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

  static Widget buildDefaultSelection(
      BuildContext context,
      CalendarParameters parameters,
      DateTime date,
      int column,
      int row,
      Widget day,
      bool preselect,
      bool Function(DateTime date) isSelected,
      {Color color = Colors.blueAccent}) {
    if (!isSelected(date)) return day;
    final leftSelected =
        column != 0 && isSelected(date.subtract(const Duration(days: 1)));
    final rightSelected = column != DateTime.daysPerWeek - 1 &&
        isSelected(date.add(const Duration(days: 1)));
    final topSelected = row != 0 &&
        isSelected(date.subtract(const Duration(days: DateTime.daysPerWeek)));
    final bottomSelected = row != 5 &&
        isSelected(date.add(const Duration(days: DateTime.daysPerWeek)));
    final opacityColor = preselect ? color.withOpacity(0.3) : color;
    final borderSide = BorderSide(color: opacityColor);
    return Container(
      child: DefaultTextStyle(child: day, style: TextStyle(color: color)),
      decoration: BoxDecoration(
        color: opacityColor.withOpacity(0.1),
        border: Border(
          left: leftSelected ? BorderSide.none : borderSide,
          right: rightSelected ? BorderSide.none : borderSide,
          top: topSelected ? BorderSide.none : borderSide,
          bottom: bottomSelected ? BorderSide.none : borderSide,
        ),
      ),
    );
  }
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
      selectionBuilder: my.selectionBuilder ?? def.selectionBuilder,
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

class DatesRange {
  DatesRange(this.from, this.to)
      : assert(from != null),
        assert(to != null);
  final DateTime from;
  final DateTime to;
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    Key key,
    @required this.parameters,
    this.displayDate,
    @required this.dayBuilder,
  })  : assert(parameters != null),
        assert(dayBuilder != null),
        super(key: key);

  final CalendarParameters parameters;
  final DateTime displayDate;
  final DayBuilder dayBuilder;

  @override
  Widget build(BuildContext context) {
    final parameters = this.parameters;
    final firstDayOfWeekIndex = parameters.firstDayOfWeekIndex ??
        MaterialLocalizations.of(context).firstDayOfWeekIndex ??
        0;
    final daysOfWeekFactor = parameters.showDaysOfWeek ? 1 : 0;

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

      return dayBuilder(context, parameters, date, type, column, row);
    }

    return Column(
      children: Iterable.generate(6 + daysOfWeekFactor)
          .map(
            (row) => Expanded(
              child: Row(
                children: Iterable.generate(DateTime.daysPerWeek)
                    .map(
                      (column) => Expanded(
                          child: parameters.showDaysOfWeek && row == 0
                              ? parameters.dayOfWeekBuilder(
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

class Calendar<TSelection> extends StatefulWidget {
  const Calendar({
    Key key,
    this.displayDate,
    this.onDisplayDateChanged,
    this.columns = 1,
    this.rows = 1,
    this.selected,
    this.onSelectedChanged,
  })  : assert(columns > 0),
        assert(rows > 0),
        super(key: key);

  final DateTime displayDate;
  final ValueChanged<DateTime> onDisplayDateChanged;
  final int columns;
  final int rows;
  final TSelection selected;
  final ValueChanged<TSelection> onSelectedChanged;

  @override
  CalendarState createState() {
    if (TSelection != dynamic) {
      if (TSelection == DateTime) {
        return SingleSelectionCalendarState(displayDate, selected as DateTime);
      } else if (const <DateTime>{} is TSelection) {
        return MultiSelectionCalendarState(
            displayDate, selected as Set<DateTime>);
      } else if (TSelection == DatesRange) {
        return RangeSelectionCalendarState(displayDate, selected as DatesRange);
      }
    }
    return CalendarState(displayDate);
  }
}

class CalendarState<TSelection> extends State<Calendar<TSelection>> {
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

  @protected
  Widget buildDay(BuildContext context, CalendarParameters parameters,
          DateTime date, DayType type, int column, int row) =>
      parameters.dayBuilder(context, parameters, date, type, column, row);

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
                parameters: parameters,
                displayDate: date,
                dayBuilder: buildDay,
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

abstract class CalendarWithSelectionState<TSelection>
    extends CalendarState<TSelection> {
  CalendarWithSelectionState(DateTime displayDate, this.selected)
      : super(displayDate);
  @protected
  TSelection selected;
  @protected
  DateTime hovered;

  @override
  void didUpdateWidget(Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != selected) setState(() {});
  }

  @protected
  bool get preselect => false;
  @protected
  bool isSelected(DateTime date);
  @protected
  void onDayTap(DateTime date) {
    if (widget.onSelectedChanged != null) {
      widget.onSelectedChanged(selected);
    }
  }

  @override
  Widget buildDay(BuildContext context, CalendarParameters parameters,
      DateTime date, DayType type, int column, int row) {
    final day = super.buildDay(context, parameters, date, type, column, row);
    final extraLow = type == DayType.extraLow;
    final extraHigh = type == DayType.extraHigh;
    final month = date.month +
        (extraLow
            ? date.month == 12 ? -11 : 1
            : extraHigh ? date.month == 1 ? 11 : -1 : 0);
    final selection = parameters.selectionBuilder(
      context,
      parameters,
      date,
      column,
      row,
      day,
      preselect,
      (e) => e.month == month && isSelected(e),
    );
    return extraLow || extraHigh
        ? selection
        : InkResponse(
            child: selection,
            onTap: () => setState(() => onDayTap(date)),
            onHover: (hovered) {
              if (hovered) setState(() => this.hovered = date);
            },
          );
  }
}

class SingleSelectionCalendarState
    extends CalendarWithSelectionState<DateTime> {
  SingleSelectionCalendarState(DateTime displayDate, DateTime selected)
      : super(displayDate, selected);

  @override
  bool isSelected(DateTime date) => date == selected;

  @override
  void onDayTap(DateTime date) {
    selected = date;
    super.onDayTap(date);
  }
}

class MultiSelectionCalendarState
    extends CalendarWithSelectionState<Set<DateTime>> {
  MultiSelectionCalendarState(DateTime displayDate, Set<DateTime> selected)
      : super(displayDate, selected);

  @override
  bool isSelected(DateTime date) => selected?.contains(date) == true;

  @override
  void onDayTap(DateTime date) {
    (selected?.contains(date) == true
        ? selected.remove
        : (selected ??= {}).add)(date);
    super.onDayTap(date);
  }
}

class RangeSelectionCalendarState
    extends CalendarWithSelectionState<DatesRange> {
  RangeSelectionCalendarState(DateTime displayDate, DatesRange selected)
      : _from = selected?.from,
        _to = selected?.to,
        super(displayDate, selected);
  DateTime _from;
  DateTime _to;

  @override
  bool get preselect => _from != null && _to == null;

  @override
  bool isSelected(DateTime date) {
    if (_to == null && _from == null) return false;
    DateTime from;
    DateTime to;
    if (_to == null) {
      final hovered = this.hovered ?? _from;
      final isBefore = hovered.isBefore(_from);
      from = isBefore ? hovered : _from;
      to = isBefore ? _from : hovered;
    } else {
      from = _from;
      to = _to;
    }
    return !date.isBefore(from) && !date.isAfter(to);
  }

  @override
  void onDayTap(DateTime date) {
    if (preselect) {
      if (date.isBefore(_from)) {
        _to = _from;
        _from = date;
      } else {
        _to = date;
      }
      selected = DatesRange(
          _from,
          _to
              .add(const Duration(days: 1))
              .subtract(const Duration(milliseconds: 1)));
      super.onDayTap(date);
    } else {
      _from = date;
      _to = null;
      hovered = null;
    }
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
