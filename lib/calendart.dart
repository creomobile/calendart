library calendart;

import 'dart:ui';

import 'package:combos/combos.dart';
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

typedef DatesSelectionWidgetBuilder<TSelection> = Widget Function(
    BuildContext context, CalendarParameters parameters, TSelection selection);

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
    this.singleSelectionTitleBuilder,
    this.multiSelectionTitleBuilder,
    this.rangeSelectionTitleBuilder,
    this.selectionTitleBuilder,
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
    singleSelectionTitleBuilder: buildDefaultSingleSelectionTitle,
    multiSelectionTitleBuilder: buildDefaultMultiSelectionTitle,
    rangeSelectionTitleBuilder: buildDefaultRangeSelectionTitle,
    selectionTitleBuilder: buildDefaultSelectionTitle,
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
  final DatesSelectionWidgetBuilder<DateTime> singleSelectionTitleBuilder;
  final DatesSelectionWidgetBuilder<Set<DateTime>> multiSelectionTitleBuilder;
  final DatesSelectionWidgetBuilder<DatesRange> rangeSelectionTitleBuilder;
  final DatesSelectionWidgetBuilder selectionTitleBuilder;

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
    DatesSelectionWidgetBuilder<DateTime> singleSelectionTitleBuilder,
    DatesSelectionWidgetBuilder<Set<DateTime>> multiSelectionTitleBuilder,
    DatesSelectionWidgetBuilder<DatesRange> rangeSelectionTitleBuilder,
    DatesSelectionWidgetBuilder selectionTitleBuilder,
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
        singleSelectionTitleBuilder:
            singleSelectionTitleBuilder ?? this.singleSelectionTitleBuilder,
        multiSelectionTitleBuilder:
            multiSelectionTitleBuilder ?? this.multiSelectionTitleBuilder,
        rangeSelectionTitleBuilder:
            rangeSelectionTitleBuilder ?? this.rangeSelectionTitleBuilder,
        selectionTitleBuilder:
            selectionTitleBuilder ?? this.selectionTitleBuilder,
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
    final borderSide =
        BorderSide(color: preselect ? color.withOpacity(0.3) : color);
    return Container(
      child: DefaultTextStyle(child: day, style: TextStyle(color: color)),
      decoration: BoxDecoration(
        color: preselect ? color.withOpacity(0.05) : color.withOpacity(0.1),
        border: Border(
          left: leftSelected ? BorderSide.none : borderSide,
          right: rightSelected ? BorderSide.none : borderSide,
          top: topSelected ? BorderSide.none : borderSide,
          bottom: bottomSelected ? BorderSide.none : borderSide,
        ),
      ),
    );
  }

  static Widget buildDefaultSingleSelectionTitle(BuildContext context,
          CalendarParameters parameters, DateTime selected) =>
      Text(MaterialLocalizations.of(context).formatFullDate(selected),
          overflow: TextOverflow.ellipsis);

  static Widget buildDefaultMultiSelectionTitle(BuildContext context,
      CalendarParameters parameters, Set<DateTime> selected) {
    final localizations = MaterialLocalizations.of(context);
    final dates =
        selected?.map((e) => localizations.formatMediumDate(e))?.join(', ');
    return Text(dates?.isNotEmpty == true ? dates : '',
        overflow: TextOverflow.ellipsis);
  }

  static Widget buildDefaultRangeSelectionTitle(BuildContext context,
      CalendarParameters parameters, DatesRange selected) {
    final localizations = MaterialLocalizations.of(context);
    final range = localizations.formatMediumDate(selected.from) +
        ' - ' +
        localizations.formatMediumDate(selected.to);
    return Text(range);
  }

  static Widget getSelectionTitle(
          BuildContext context, CalendarParameters parameters, selected) =>
      selected == null
          ? const SizedBox()
          : selected is DateTime
              ? parameters.singleSelectionTitleBuilder(
                  context, parameters, selected)
              : selected is Set<DateTime>
                  ? parameters.multiSelectionTitleBuilder(
                      context, parameters, selected)
                  : selected is DatesRange
                      ? parameters.rangeSelectionTitleBuilder(
                          context, parameters, selected)
                      : throw FormatException(
                          'Invalid calendar selection type.');

  static Widget buildDefaultSelectionTitle(
          BuildContext context, CalendarParameters parameters, selected) =>
      ListTile(
          title: selected == null
              ? const SizedBox()
              : getSelectionTitle(context, parameters, selected));
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
      singleSelectionTitleBuilder:
          my.singleSelectionTitleBuilder ?? def.singleSelectionTitleBuilder,
      multiSelectionTitleBuilder:
          my.multiSelectionTitleBuilder ?? def.multiSelectionTitleBuilder,
      rangeSelectionTitleBuilder:
          my.rangeSelectionTitleBuilder ?? def.rangeSelectionTitleBuilder,
      selectionTitleBuilder:
          my.selectionTitleBuilder ?? def.selectionTitleBuilder,
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

typedef CalendarSelectionCanSelect = bool Function(
    DateTime date, DayType type, int column, int row);

abstract class CalendarSelectionBase {
  const CalendarSelectionBase({
    this.canSelectExtra = false,
    CalendarSelectionCanSelect canSelect,
    this.onDayTap,
    this.autoClosePopupAfterSelectionChanged = true,
  })  : assert(canSelectExtra != null),
        assert(autoClosePopupAfterSelectionChanged != null),
        _canSelect = canSelect;
  final bool canSelectExtra;
  final CalendarSelectionCanSelect _canSelect;
  final ValueSetter<DateTime> onDayTap;
  final bool autoClosePopupAfterSelectionChanged;

  @protected
  bool canSelect(DateTime date, DayType type, int column, int row) =>
      (canSelectExtra ||
          (type != DayType.extraLow && type != DayType.extraHigh)) &&
      (_canSelect == null || _canSelect(date, type, column, row));

  @protected
  void select(DateTime date) {
    if (onDayTap != null) onDayTap(date);
  }

  @protected
  bool isSelected(DateTime date, DayType type, int column, int row);

  bool get hasSelection;
}

class CalendarNoneSelection extends CalendarSelectionBase {
  const CalendarNoneSelection({
    bool canSelectExtra = false,
    CalendarSelectionCanSelect canSelect,
    ValueSetter<DateTime> onDayTap,
    bool autoClosePopupAfterSelectionChanged = true,
  }) : super(
          canSelectExtra: canSelectExtra,
          canSelect: canSelect,
          onDayTap: onDayTap,
          autoClosePopupAfterSelectionChanged:
              autoClosePopupAfterSelectionChanged,
        );

  @override
  bool canSelect(DateTime date, DayType type, int column, int row) =>
      onDayTap != null && super.canSelect(date, type, column, row);

  @override
  bool isSelected(DateTime date, DayType type, int column, int row) => false;

  @override
  bool get hasSelection => false;
}

abstract class CalendarSelection<T> extends CalendarSelectionBase {
  CalendarSelection({
    T selected,
    this.onSelectedChanged,
    bool canSelectExtra = false,
    CalendarSelectionCanSelect canSelect,
    ValueSetter<DateTime> onDayTap,
    bool autoClosePopupAfterSelectionChanged = true,
  })  : _selected = selected,
        super(
          canSelectExtra: canSelectExtra,
          canSelect: canSelect,
          onDayTap: onDayTap,
          autoClosePopupAfterSelectionChanged:
              autoClosePopupAfterSelectionChanged,
        );
  final _listeners = <ValueChanged<T>>[];
  void addListener(ValueChanged<T> listener) => _listeners.add(listener);
  void removeListener(ValueChanged<T> listener) => _listeners.remove(listener);

  T _selected;
  T get selected => _selected;
  set selected(T value) {
    _selected = value;
    if (onSelectedChanged != null) {
      onSelectedChanged(selected);
    }
    _listeners.forEach((e) => e(value));
  }

  final ValueChanged<T> onSelectedChanged;
  DateTime _hovered;
  @protected
  DateTime get hovered => _hovered;
  @protected
  set hovered(DateTime value) => _hovered = value;
  @protected
  bool get preselect => false;

  @override
  bool get hasSelection => _selected != null;
}

class CalendarSingleSelection extends CalendarSelection<DateTime> {
  CalendarSingleSelection({
    DateTime selected,
    ValueChanged<DateTime> onSelectedChanged,
    bool canSelectExtra = false,
    CalendarSelectionCanSelect canSelect,
    ValueSetter<DateTime> onDayTap,
    bool autoClosePopupAfterSelectionChanged = true,
  }) : super(
          selected: selected,
          onSelectedChanged: onSelectedChanged,
          canSelectExtra: canSelectExtra,
          canSelect: canSelect,
          onDayTap: onDayTap,
          autoClosePopupAfterSelectionChanged:
              autoClosePopupAfterSelectionChanged,
        );

  @override
  bool isSelected(DateTime date, DayType type, int column, int row) =>
      canSelect(date, type, column, row) && date == selected;

  @override
  void select(DateTime date) {
    selected = date;
    super.select(date);
  }
}

class CalendarMultiSelection extends CalendarSelection<Set<DateTime>> {
  CalendarMultiSelection({
    Set<DateTime> selected,
    ValueChanged<Set<DateTime>> onSelectedChanged,
    bool canSelectExtra = false,
    CalendarSelectionCanSelect canSelect,
    ValueSetter<DateTime> onDayTap,
    bool autoClosePopupAfterSelectionChanged = false,
  }) : super(
          selected: selected,
          onSelectedChanged: onSelectedChanged,
          canSelectExtra: canSelectExtra,
          canSelect: canSelect,
          onDayTap: onDayTap,
          autoClosePopupAfterSelectionChanged:
              autoClosePopupAfterSelectionChanged,
        );

  @override
  bool isSelected(DateTime date, DayType type, int column, int row) =>
      canSelect(date, type, column, row) && selected?.contains(date) == true;

  @override
  void select(DateTime date) {
    final selected = this.selected ?? {};
    (selected?.contains(date) == true ? selected.remove : selected.add)(date);
    this.selected = selected;
    super.select(date);
  }

  @override
  bool get hasSelection => super.hasSelection && selected.isNotEmpty;
}

class DatesRange {
  DatesRange(this.from, this.to)
      : assert(from != null),
        assert(to != null);
  final DateTime from;
  final DateTime to;
}

class CalendarRangeSelection extends CalendarSelection<DatesRange> {
  CalendarRangeSelection({
    DatesRange selected,
    ValueChanged<DatesRange> onSelectedChanged,
    bool canSelectExtra = false,
    ValueSetter<DateTime> onDayTap,
    bool autoClosePopupAfterSelectionChanged = true,
  })  : _from = selected?.from,
        _to = selected?.to,
        super(
          selected: selected,
          onSelectedChanged: onSelectedChanged,
          canSelectExtra: canSelectExtra,
          onDayTap: onDayTap,
          autoClosePopupAfterSelectionChanged:
              autoClosePopupAfterSelectionChanged,
        );

  DateTime _from;
  DateTime _to;

  @override
  bool get preselect => _from != null && _to == null;

  @override
  bool isSelected(DateTime date, DayType type, int column, int row) {
    if (!canSelect(date, type, column, row) || (_to == null && _from == null)) {
      return false;
    }
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
  void select(DateTime date) {
    if (preselect) {
      if (date.isBefore(_from)) {
        _to = _from;
        _from = date;
      } else {
        _to = date;
      }
      selected = DatesRange(
          _from, DateTime.utc(_to.year, _to.month, _to.day, 23, 59, 59, 999));
    } else {
      _from = date;
      _to = null;
      hovered = null;
    }
    super.select(date);
  }
}

class CalendarSelections {
  static CalendarNoneSelection none({
    bool canSelectExtra = false,
    CalendarSelectionCanSelect canSelect,
    ValueSetter<DateTime> onDayTap,
    bool autoClosePopupAfterSelectionChanged = true,
  }) =>
      CalendarNoneSelection(
        canSelectExtra: canSelectExtra,
        canSelect: canSelect,
        onDayTap: onDayTap,
        autoClosePopupAfterSelectionChanged:
            autoClosePopupAfterSelectionChanged,
      );

  static CalendarSingleSelection single({
    DateTime selected,
    ValueChanged<DateTime> onSelectedChanged,
    bool canSelectExtra = false,
    CalendarSelectionCanSelect canSelect,
    ValueSetter<DateTime> onDayTap,
    bool autoClosePopupAfterSelectionChanged = true,
  }) =>
      CalendarSingleSelection(
        selected: selected,
        onSelectedChanged: onSelectedChanged,
        canSelectExtra: canSelectExtra,
        canSelect: canSelect,
        onDayTap: onDayTap,
        autoClosePopupAfterSelectionChanged:
            autoClosePopupAfterSelectionChanged,
      );

  static CalendarMultiSelection multi({
    Set<DateTime> selected,
    ValueChanged<Set<DateTime>> onSelectedChanged,
    bool canSelectExtra = false,
    CalendarSelectionCanSelect canSelect,
    ValueSetter<DateTime> onDayTap,
    bool autoClosePopupAfterSelectionChanged = false,
  }) =>
      CalendarMultiSelection(
        selected: selected,
        onSelectedChanged: onSelectedChanged,
        canSelectExtra: canSelectExtra,
        canSelect: canSelect,
        onDayTap: onDayTap,
        autoClosePopupAfterSelectionChanged:
            autoClosePopupAfterSelectionChanged,
      );

  static CalendarRangeSelection range({
    DatesRange selected,
    ValueChanged<DatesRange> onSelectedChanged,
    bool canSelectExtra = false,
    ValueSetter<DateTime> onDayTap,
    bool autoClosePopupAfterSelectionChanged = true,
  }) =>
      CalendarRangeSelection(
        selected: selected,
        onSelectedChanged: onSelectedChanged,
        canSelectExtra: canSelectExtra,
        onDayTap: onDayTap,
        autoClosePopupAfterSelectionChanged:
            autoClosePopupAfterSelectionChanged,
      );
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
        DateTime.utc(date.year, date.month, date.day);

    final today = getDate(DateTime.now());
    final date = this.displayDate ?? today;
    final displayDate = DateTime.utc(date.year, date.month);

    var firstDate = DateTime.utc(displayDate.year, displayDate.month, 1);
    final shift =
        (firstDate.weekday == DateTime.sunday ? 0 : firstDate.weekday) -
            firstDayOfWeekIndex;
    firstDate = firstDate.subtract(
        Duration(days: shift < 0 ? shift + DateTime.daysPerWeek : shift));
    if (firstDate.month == 2 &&
        firstDate.day == 1 &&
        DateTime.utc(firstDate.year, 3, 1).difference(firstDate).inDays == 28) {
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

abstract class _Selectable implements StatefulWidget {
  CalendarSelectionBase get selection;
}

mixin _SelectionListenerMixin<T extends _Selectable> on State<T> {
  @override
  void initState() {
    super.initState();
    subscribe();
  }

  @override
  void didUpdateWidget(_Selectable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selection != oldWidget.selection) {
      unsubscribe(oldWidget);
      subscribe();
    }
  }

  @protected
  void subscribe() {
    if (widget.selection is CalendarSelection) {
      (widget.selection as CalendarSelection).addListener(didSelectionChanged);
    }
  }

  @protected
  void unsubscribe(_Selectable widget) {
    if (widget.selection is CalendarSelection) {
      (widget.selection as CalendarSelection)
          .removeListener(didSelectionChanged);
    }
  }

  @protected
  void didSelectionChanged(_) {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    unsubscribe(widget);
    super.dispose();
  }
}

class Calendar extends StatefulWidget implements _Selectable {
  const Calendar({
    Key key,
    this.displayDate,
    this.onDisplayDateChanged,
    this.columns = 1,
    this.rows = 1,
    this.selection = const CalendarNoneSelection(),
  })  : assert(columns > 0),
        assert(rows > 0),
        assert(selection != null),
        super(key: key);

  final DateTime displayDate;
  final ValueChanged<DateTime> onDisplayDateChanged;
  final int columns;
  final int rows;
  @override
  final CalendarSelectionBase selection;

  @override
  CalendarState createState() => CalendarState(displayDate);
}

class CalendarState extends State<Calendar> with _SelectionListenerMixin {
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
    return DateTime.utc(d.year, d.month);
  }

  @override
  void didUpdateWidget(Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final displayDate = _getMonthDate(widget.displayDate);
    if ((displayDate != _getMonthDate(oldWidget.displayDate) &&
            displayDate != _displayDate) ||
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
    return DateTime.utc(
        monthCount ~/ DateTime.monthsPerYear, month == 0 ? 12 : month);
  }

  @protected
  Widget buildDay(BuildContext context, CalendarParameters parameters,
      DateTime date, DayType type, int column, int row) {
    final selection = widget.selection;
    final modifiableSelection =
        selection is CalendarSelection ? selection : null;
    var day =
        parameters.dayBuilder(context, parameters, date, type, column, row);
    final month = date.month +
        (type == DayType.extraLow
            ? date.month == 12 ? -11 : 1
            : type == DayType.extraHigh ? date.month == 1 ? 11 : -1 : 0);
    if (!(selection is CalendarNoneSelection)) {
      day = parameters.selectionBuilder(
        context,
        parameters,
        date,
        column,
        row,
        day,
        modifiableSelection?.preselect == true,
        (e) =>
            modifiableSelection?.isSelected(
                e,
                // today is not provided to avoid DateTime.now() calls
                e.month == month
                    ? DayType.current
                    : (e.month == 1 && month == 12) || e.month < month
                        ? DayType.extraLow
                        : DayType.extraHigh,
                column,
                row) ==
            true,
      );
    }

    return selection.canSelect(date, type, column, row)
        ? InkResponse(
            child: day,
            onTap: () => setState(() => selection.select(date)),
            onHover: modifiableSelection == null
                ? null
                : (hovered) {
                    if (hovered) {
                      setState(() => modifiableSelection.hovered = date);
                    }
                  },
          )
        : day;
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

class CalendarCombo extends StatefulWidget implements _Selectable {
  const CalendarCombo({
    Key key,
    this.displayDate,
    this.onDisplayDateChanged,
    this.columns = 1,
    this.rows = 1,
    this.placeholder,
    this.popupSize = const Size.square(300),
    this.selection = const CalendarNoneSelection(),
    this.openedChanged,
    this.hoveredChanged,
    this.onTap,
  })  : assert(columns > 0),
        assert(rows > 0),
        assert(selection != null),
        assert(popupSize != null),
        super(key: key);

  final DateTime displayDate;
  final ValueChanged<DateTime> onDisplayDateChanged;
  final int columns;
  final int rows;
  final Widget placeholder;
  final Size popupSize;
  @override
  final CalendarSelectionBase selection;
  final ValueChanged<bool> openedChanged;
  final ValueChanged<bool> hoveredChanged;
  final GestureTapCallback onTap;

  @override
  CalendarComboState createState() => CalendarComboState(displayDate);
}

class CalendarComboState<TSelection> extends State<CalendarCombo>
    with _SelectionListenerMixin {
  CalendarComboState(this._displayDate);
  final _comboKey = GlobalKey<ComboState>();
  final _calendarKey = GlobalKey<CalendarState>();
  DateTime _displayDate;

  @override
  void didUpdateWidget(CalendarCombo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.displayDate != oldWidget.displayDate &&
            widget.displayDate != _displayDate) ||
        widget.columns != oldWidget.columns ||
        widget.rows != oldWidget.rows ||
        widget.popupSize != oldWidget.popupSize) {
      setState(() => _displayDate = widget.displayDate);
    }
  }

  void open() => _comboKey.currentState?.open();
  void close() => _comboKey.currentState?.close();

  void inc() => _calendarKey.currentState.inc();
  void dec() => _calendarKey.currentState.dec();

  @override
  void didSelectionChanged(_) {
    super.didSelectionChanged(_);
    if (widget.selection.autoClosePopupAfterSelectionChanged) close();
  }

  @override
  Widget build(BuildContext context) {
    final data = CalendarContext.of(context);
    final parameters = data?.parameters ?? CalendarParameters.defaultParameters;
    final comboParameters = ComboContext.of(context)?.parameters ??
        ComboParameters.defaultParameters;
    final popupDecorator = comboParameters.popupDecoratorBuilder;
    final selection = widget.selection;

    return Combo(
      key: _comboKey,
      child: widget.selection.hasSelection
          ? parameters.selectionTitleBuilder(
              context, parameters, (selection as CalendarSelection).selected)
          : (widget.placeholder ?? ListTile()),
      popupBuilder: (context, mirrored) {
        Widget calendar = SizedBox.fromSize(
          size: widget.popupSize,
          child: Calendar(
            key: _calendarKey,
            displayDate: _displayDate,
            onDisplayDateChanged: (date) {
              _displayDate = date;
              if (widget.onDisplayDateChanged != null) {
                widget.onDisplayDateChanged(date);
              }
            },
            columns: widget.columns,
            rows: widget.rows,
            selection: selection,
          ),
        );

        if (popupDecorator == null) {
          calendar = Material(elevation: 4, child: calendar);
        }

        return data == null
            ? calendar
            : CalendarContext(parameters: parameters, child: calendar);
      },
      openedChanged: widget.openedChanged,
      hoveredChanged: widget.hoveredChanged,
      onTap: widget.onTap,
    );
  }
}
