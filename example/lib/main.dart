import 'dart:math' as math;
import 'dart:ui';

import 'package:calendart/calendart.dart';
import 'package:combos/combos.dart';
import 'package:demo_items/demo_items.dart';
import 'package:editors/editors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:combos_example/main.dart' as combos;

void main() => runApp(_App());

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MaterialApp(home: CalendartExamplePage());
}

class CalendartExamplePage extends StatefulWidget {
  @override
  _CalendartExamplePageState createState() => _CalendartExamplePageState();
}

class _CalendartExamplePageState extends State<CalendartExamplePage> {
  final _calendarProperties = CalendarProperties();
  final _comboProperties = CalendarComboProperties();
  CalendarSelection _calendarSelection;
  CalendarSelection _comboSelection;
  GlobalKey<CalendarState> _calendarKey;
  final _comboKey = GlobalKey<CalendarComboState>();
  double _width;
  double _height;
  double _separatorWidth;
  double _separatorHeight;

  @override
  Widget build(BuildContext context) {
    CalendarSelectionBase getSelection(CalendarProperties properties) {
      final canSelectExtra = properties.canSelectExtra.value;
      final autoClosePopupAfterSelectionChanged =
          properties.autoClosePopupAfterSelectionChanged.value;
      switch (properties.selectionType.value) {
        case SelectionType.single:
          return autoClosePopupAfterSelectionChanged == null
              ? CalendarSelections.single(
                  selected: properties.selected is DateTime
                      ? properties.selected
                      : null,
                  canSelectExtra: canSelectExtra,
                  onSelectedChanged: (_) =>
                      setState(() => properties.selected = _),
                )
              : CalendarSelections.single(
                  selected: properties.selected is DateTime
                      ? properties.selected
                      : null,
                  canSelectExtra: canSelectExtra,
                  onSelectedChanged: (_) =>
                      setState(() => properties.selected = _),
                  autoClosePopupAfterSelectionChanged:
                      autoClosePopupAfterSelectionChanged,
                );
        case SelectionType.singleOrNone:
          return autoClosePopupAfterSelectionChanged == null
              ? CalendarSelections.singleOrNone(
                  selected: properties.selected is DateTime
                      ? properties.selected
                      : null,
                  canSelectExtra: canSelectExtra,
                  onSelectedChanged: (_) =>
                      setState(() => properties.selected = _),
                )
              : CalendarSelections.singleOrNone(
                  selected: properties.selected is DateTime
                      ? properties.selected
                      : null,
                  canSelectExtra: canSelectExtra,
                  onSelectedChanged: (_) =>
                      setState(() => properties.selected = _),
                  autoClosePopupAfterSelectionChanged:
                      autoClosePopupAfterSelectionChanged,
                );
        case SelectionType.multi:
          return autoClosePopupAfterSelectionChanged == null
              ? CalendarSelections.multi(
                  selected: properties.selected is Set<DateTime>
                      ? properties.selected
                      : null,
                  canSelectExtra: canSelectExtra,
                  onSelectedChanged: (_) =>
                      setState(() => properties.selected = _),
                )
              : CalendarSelections.multi(
                  selected: properties.selected is Set<DateTime>
                      ? properties.selected
                      : null,
                  canSelectExtra: canSelectExtra,
                  onSelectedChanged: (_) =>
                      setState(() => properties.selected = _),
                  autoClosePopupAfterSelectionChanged:
                      autoClosePopupAfterSelectionChanged,
                );
        case SelectionType.range:
          return autoClosePopupAfterSelectionChanged == null
              ? CalendarSelections.range(
                  selected: properties.selected is DatesRange
                      ? properties.selected
                      : null,
                  canSelectExtra: canSelectExtra,
                  onSelectedChanged: (_) =>
                      setState(() => properties.selected = _),
                )
              : CalendarSelections.range(
                  selected: properties.selected is DatesRange
                      ? properties.selected
                      : null,
                  canSelectExtra: canSelectExtra,
                  onSelectedChanged: (_) =>
                      setState(() => properties.selected = _),
                  autoClosePopupAfterSelectionChanged:
                      autoClosePopupAfterSelectionChanged,
                );
        default:
          properties.selected = null;
          return autoClosePopupAfterSelectionChanged == null
              ? CalendarSelections.none(canSelectExtra: canSelectExtra)
              : CalendarSelections.none(
                  canSelectExtra: canSelectExtra,
                  autoClosePopupAfterSelectionChanged:
                      autoClosePopupAfterSelectionChanged);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Calendart sample app')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Column(
            children: [
              _CalendartDemoItem<CalendarProperties>(
                properties: _calendarProperties,
                childBuilder: (properties) {
                  final separatorWidth =
                      properties.separatorWidth.value?.toDouble() ?? 0.0;
                  final separatorHeight =
                      properties.separatorHeight.value?.toDouble() ?? 0.0;
                  final width = properties.columns.value *
                          (properties.width.value.toDouble() + separatorWidth) -
                      separatorWidth;
                  final height = properties.rows.value *
                          (properties.height.value.toDouble() +
                              separatorHeight) -
                      separatorHeight;

                  // update calendar widget if size changed
                  if (width != _width ||
                      height != _height ||
                      separatorWidth != _separatorWidth ||
                      separatorHeight != _separatorHeight) {
                    _width = width;
                    _height = height;
                    _separatorWidth = separatorWidth;
                    _separatorHeight = separatorHeight;
                    _calendarKey = GlobalKey<CalendarState>();
                  }
                  return Row(
                    children: [
                      ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: width, maxHeight: height),
                        child: Calendar(
                          key: _calendarKey,
                          displayDate: DateTime(
                              properties.year.value, properties.month.value),
                          columns: properties.columns.value,
                          rows: properties.rows.value,
                          selection: _calendarSelection =
                              getSelection(properties),
                          onDisplayDateChanged: (date) {
                            properties.year.value = date.year;
                            properties.month.value = date.month;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.clear),
                        color: Colors.blueAccent,
                        tooltip: 'Clear Selection',
                        onPressed: _calendarSelection?.hasSelection == true
                            ? () {
                                if (_calendarSelection is CalendarSelection) {
                                  _calendarSelection.clear();
                                }
                              }
                            : null,
                      )
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _CalendartDemoItem<CalendarProperties>(
                comboKey: _comboKey,
                properties: _comboProperties,
                childBuilder: (properties) {
                  final separatorWidth =
                      properties.separatorWidth.value?.toDouble() ?? 0.0;
                  final separatorHeight =
                      properties.separatorHeight.value?.toDouble() ?? 0.0;
                  final width = properties.columns.value *
                          (properties.width.value.toDouble() + separatorWidth) -
                      separatorWidth;
                  final height = properties.rows.value *
                          (properties.height.value.toDouble() +
                              separatorHeight) -
                      separatorHeight;
                  return Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 300),
                        child: CalendarCombo(
                          key: _comboKey,
                          displayDate: DateTime(
                              properties.year.value, properties.month.value),
                          columns: properties.columns.value,
                          rows: properties.rows.value,
                          selection: _comboSelection = getSelection(properties),
                          title: 'Calendar Combo',
                          popupSize: Size(width, height),
                          onDisplayDateChanged: (date) {
                            properties.year.value = date.year;
                            properties.month.value = date.month;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.clear),
                        color: Colors.blueAccent,
                        tooltip: 'Clear Selection',
                        onPressed: _comboSelection?.hasSelection == true
                            ? () {
                                if (_comboSelection is CalendarSelection) {
                                  _comboSelection.clear();
                                }
                              }
                            : null,
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendartDemoItem<TProperties extends CalendarProperties>
    extends DemoItemBase<TProperties> {
  const _CalendartDemoItem({
    Key key,
    this.comboKey,
    @required TProperties properties,
    @required ChildBuilder<TProperties> childBuilder,
  }) : super(key: key, properties: properties, childBuilder: childBuilder);

  final GlobalKey<CalendarComboState> comboKey;

  @override
  _CalendartDemoItemState<TProperties> createState() =>
      _CalendartDemoItemState<TProperties>();
}

class _CalendartDemoItemState<TProperties extends CalendarProperties>
    extends DemoItemStateBase<TProperties> {
  final _colors = Iterable.generate(31)
      .map((e) => Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0))
      .toList();

  @override
  _CalendartDemoItem<TProperties> get widget => super.widget;

  PreferredSizeWidget _buildHorizontalSeparator(double width, bool custom) {
    final size = Size.fromWidth(width);
    return PreferredSize(
      preferredSize: size,
      child: SizedBox.fromSize(
          size: size,
          child: custom
              ? Container(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blueAccent.withOpacity(0),
                              Colors.blueAccent,
                              Colors.blueAccent.withOpacity(0),
                            ]),
                      ),
                    ),
                  ),
                )
              : null),
    );
  }

  PreferredSizeWidget _buildVerticalSeparator(double height, bool custom) {
    final size = Size.fromHeight(height);
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: SizedBox.fromSize(
          size: size,
          child: custom
              ? Container(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      alignment: Alignment.center,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.blueAccent.withOpacity(0),
                          Colors.blueAccent,
                          Colors.blueAccent.withOpacity(0),
                        ]),
                      ),
                    ),
                  ),
                )
              : null),
    );
  }

  @override
  Widget buildChild() {
    final properties = widget.properties;
    final comboProperties = widget.properties is CalendarComboProperties
        ? widget.properties as CalendarComboProperties
        : null;
    final separatorWidth = properties.separatorWidth.value?.toDouble() ?? 0.0;
    final separatorHeight = properties.separatorHeight.value?.toDouble() ?? 0.0;
    final calendarContext = CalendarContext(
        parameters: CalendarParameters(
            firstDayOfWeekIndex: properties.firstDayOfWeekIndex.value,
            showDaysOfWeek: properties.showDaysOfWeek.value,
            decoratorBuilder: properties.showDecorator.value
                ? (context, date, calendar) => Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.blueAccent,
                          Colors.blueAccent.withOpacity(0),
                        ],
                        stops: [0.0, 0.5],
                      )),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('${date.month} ${date.year}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: calendar),
                      ]),
                    )
                : null,
            horizontalSeparator: separatorWidth == 0.0
                ? const PreferredSize(
                    preferredSize: Size.fromWidth(0), child: SizedBox())
                : _buildHorizontalSeparator(
                    separatorWidth, properties.customSeparators.value),
            verticalSeparator: separatorHeight == 0.0
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(0), child: SizedBox())
                : _buildVerticalSeparator(
                    separatorHeight, properties.customSeparators.value),
            scrollDirection: properties.scrollDirection.value,
            comboTextTitlePlacement: comboProperties?.textTitlePlacement?.value,
            singleSelectionBuilder: properties.customSelection.value
                ? (context, parameters, date, column, row, day, preselect,
                        bool Function(DateTime date) isSelected) =>
                    isSelected(date)
                        ? Container(
                            child: DefaultTextStyle(
                                child: day,
                                style: const TextStyle(color: Colors.white)),
                            decoration: BoxDecoration(
                                gradient: RadialGradient(colors: [
                              Colors.blueAccent
                                  .withOpacity(preselect ? 0.5 : 1.0),
                              Colors.blueAccent.withOpacity(0.0)
                            ])),
                          )
                        : day
                : null,
            multiSelectionBuilder: properties.customSelection.value
                ? (context, parameters, date, column, row, day, preselect,
                        bool Function(DateTime date) isSelected) =>
                    isSelected(date)
                        ? Container(
                            child: DefaultTextStyle(
                                child: day,
                                style: const TextStyle(color: Colors.white)),
                            decoration: BoxDecoration(
                                gradient: RadialGradient(colors: [
                              Colors.blueAccent
                                  .withOpacity(preselect ? 0.5 : 1.0),
                              Colors.blueAccent.withOpacity(0.0)
                            ])),
                          )
                        : day
                : null,
            dayOfWeekBuilder: properties.customDaysOfWeek.value
                ? (context, index) => Center(
                        child: Text(
                      DateFormat.E()
                          .format(DateTime(0, 1, 2).add(Duration(days: index))),
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ))
                : null,
            dayBuilder: properties.customDays.value
                ? (context, parameters, date, type, column, row) => Center(
                      child: Text(date.day.toString(),
                          style: TextStyle(
                            color: _colors[date.day - 1],
                            fontWeight: FontWeight.bold,
                            decoration: type == DayType.today
                                ? TextDecoration.underline
                                : null,
                          )),
                    )
                : null),
        child: super.buildChild());

    return comboProperties == null
        ? calendarContext
        : comboProperties.comboProperties.apply(child: calendarContext);
  }

  @override
  Widget buildProperties() {
    final properties = widget.properties;
    final editors = properties.editors;
    final comboEditors = properties is CalendarComboProperties
        ? properties.comboProperties.editors
        : null;
    final allEditors = [...editors, ...(comboEditors ?? [])];

    return Theme(
      data: ThemeData(
          inputDecorationTheme:
              InputDecorationTheme(border: OutlineInputBorder())),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: allEditors.length,
        itemBuilder: (context, index) => allEditors[index].build(),
        separatorBuilder: (context, index) => index == editors.length
            ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('- Combo Properties -',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
              )
            : const SizedBox(height: 16),
      ),
    );
  }
}

enum SelectionType { none, single, singleOrNone, multi, range }

class CalendarProperties {
  final year = IntEditor(title: 'Year', value: DateTime.now().year);
  final month = IntEditor(
      title: 'Month', value: DateTime.now().month, minValue: 1, maxValue: 12);
  dynamic selected;
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
  final canSelectExtra = BoolEditor(title: 'Can Select Extra', value: false);
  final customSelection = BoolEditor(title: 'Custom Selection', value: false);
  final customDays = BoolEditor(title: 'Custom Days', value: false);
  final customDaysOfWeek =
      BoolEditor(title: 'Custom Days of Week', value: false);
  bool get showAutoClosePopup => false;
  final autoClosePopupAfterSelectionChanged = EnumEditor<bool>(
      title: 'Auto Close Popup After Selection Changed',
      getList: () => [null, true, false],
      value: null);
  final showDaysOfWeek = BoolEditor(title: 'Show Days of Week', value: true);
  final showDecorator = BoolEditor(title: 'Show Custom Decorator', value: true);
  final separatorWidth = IntEditor(title: 'Separator Width', value: 32);
  final separatorHeight = IntEditor(title: 'Separator Height', value: 32);
  final customSeparators = BoolEditor(title: 'Custom Separators', value: true);
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
        canSelectExtra,
        customSelection,
        customDays,
        customDaysOfWeek,
        if (showAutoClosePopup) autoClosePopupAfterSelectionChanged,
        showDaysOfWeek,
        showDecorator,
        separatorWidth,
        separatorHeight,
        customSeparators,
        firstDayOfWeekIndex,
      ];
}

class CalendarComboProperties extends CalendarProperties {
  @override
  bool get showAutoClosePopup => true;

  final textTitlePlacement = EnumEditor<ComboTextTitlePlacement>(
      title: 'Text Title Placement',
      value: ComboTextTitlePlacement.label,
      getList: () => ComboTextTitlePlacement.values);

  final comboProperties = combos.ComboProperties(withChildDecorator: false);

  @override
  List<Editor> get editors => [...super.editors, textTitlePlacement];
}

// extension CalendarPropertiesExtension on CalendarProperties {
//   Widget apply({@required Widget child}) {
//     //
//   }
// }
