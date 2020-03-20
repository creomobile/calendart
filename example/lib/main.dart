import 'package:calendart/calendart.dart';
import 'package:combos/combos.dart';
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
              DemoItem<CalendarProperties>(
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
              DemoItem<CalendarProperties>(
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
                          placeholder: const ListTile(
                              title: Text('Calendar Combo',
                                  style: TextStyle(color: Colors.grey))),
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

enum SelectionType { none, single, singleOrNone, multi, range }

class DemoItem<TProperties extends CalendarProperties>
    extends DemoItemBase<TProperties> {
  const DemoItem({
    Key key,
    this.comboKey,
    @required TProperties properties,
    @required ChildBuilder<TProperties> childBuilder,
  }) : super(key: key, properties: properties, childBuilder: childBuilder);

  final GlobalKey<CalendarComboState> comboKey;

  @override
  _DemoItemState<TProperties> createState() => _DemoItemState<TProperties>();
}

class _DemoItemState<TProperties extends CalendarProperties>
    extends DemoItemStateBase<TProperties> {
  @override
  DemoItem<TProperties> get widget => super.widget;

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

  Widget _buildChildDecoration(BuildContext context, ComboParameters parameters,
          bool opened, Widget child) =>
      Container(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(16),
        ),
      );
  Widget _buildPopupDecoration(
          BuildContext context, ComboParameters parameters, Widget child) =>
      Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueAccent),
            gradient: LinearGradient(colors: [
              Colors.blueAccent.withOpacity(0.1),
              Colors.blueAccent.withOpacity(0.0),
              Colors.blueAccent.withOpacity(0.1),
            ]),
          ),
          child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Theme(
                  data: ThemeData(
                    highlightColor: Colors.blueAccent.withOpacity(0.1),
                    splashColor: Colors.blueAccent.withOpacity(0.3),
                  ),
                  child: Stack(
                    children: [
                      child,
                      Positioned(
                        left: 16,
                        right: 16,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_left),
                                color: Colors.white,
                                onPressed: () =>
                                    widget.comboKey.currentState.dec(),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_right),
                                color: Colors.white,
                                onPressed: () =>
                                    widget.comboKey.currentState.inc(),
                              ),
                            ]),
                      ),
                    ],
                  ))),
        ),
      );

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
        ),
        child: super.buildChild());

    return comboProperties == null
        ? calendarContext
        : ComboContext(
            parameters: ComboParameters(
              position: comboProperties.position.value,
              offset: Offset(
                comboProperties.offsetX.value?.toDouble(),
                comboProperties.offsetY.value?.toDouble(),
              ),
              autoMirror: comboProperties.autoMirror.value,
              screenPadding: EdgeInsets.symmetric(
                horizontal:
                    comboProperties.screenPaddingHorizontal.value.toDouble(),
                vertical:
                    comboProperties.screenPaddingVertical.value.toDouble(),
              ),
              autoOpen: comboProperties.autoOpen.value,
              autoClose: comboProperties.autoClose.value,
              enabled: comboProperties.enabled.value,
              animation: comboProperties.animation.value,
              animationDuration: Duration(
                  milliseconds: comboProperties.animationDurationMs.value),
              childContentDecoratorBuilder:
                  comboProperties.useChildDecorator.value
                      ? _buildChildDecoration
                      : null,
              childDecoratorBuilder: comboProperties.useChildDecorator.value
                  ? (context, parameters, opened, child) => Material(
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: child)
                  : null,
              popupDecoratorBuilder: comboProperties.usePopupDecorator.value
                  ? _buildPopupDecoration
                  : null,
            ),
            child: calendarContext);
  }

  @override
  Widget buildProperties() {
    final properties = widget.properties;
    final editors = properties.editors;
    final comboEditors =
        properties is CalendarComboProperties ? properties.comboEditors : null;

    return EditorsContext(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: editors.length +
            (comboEditors == null ? 0 : comboEditors.length + 1),
        itemBuilder: (context, index) {
          final length = editors.length;
          if (index == length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('- Combo Properties -',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            );
          }
          return index > length
              ? comboEditors[index - length - 1].build()
              : editors[index].build();
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
      ),
    );
  }
}

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

  final position = EnumEditor<PopupPosition>(
      title: 'Position',
      value: PopupPosition.bottomMinMatch,
      getList: () => PopupPosition.values);
  final offsetX = IntEditor(title: 'Offset X', value: 0);
  final offsetY = IntEditor(title: 'Offset Y', value: 0);
  final autoMirror = BoolEditor(title: 'Auto Mirror', value: true);
  final requiredSpace = IntEditor(title: 'Required Space');
  final screenPaddingHorizontal =
      IntEditor(title: 'Screen Padding X', value: 16);
  final screenPaddingVertical = IntEditor(title: 'Screen Padding Y', value: 16);
  final autoOpen = EnumEditor<ComboAutoOpen>(
      title: 'Auto Open',
      value: ComboAutoOpen.tap,
      getList: () => ComboAutoOpen.values);
  final autoClose = EnumEditor<ComboAutoClose>(
      title: 'Auto Close',
      value: ComboAutoClose.tapOutsideWithChildIgnorePointer,
      getList: () => ComboAutoClose.values);
  final enabled = BoolEditor(title: 'Enabled', value: true);
  final animation = EnumEditor<PopupAnimation>(
      title: 'Animation',
      value: PopupAnimation.fade,
      getList: () => PopupAnimation.values);
  final animationDurationMs = IntEditor(
      title: 'Animation Duration',
      value: ComboParameters.defaultAnimationDuration.inMilliseconds);
  final useChildDecorator =
      BoolEditor(title: 'Use Custom Child Decorator', value: false);
  final usePopupDecorator =
      BoolEditor(title: 'Use Custom Popup Decorator', value: false);

  List<Editor> get comboEditors => [
        position,
        offsetX,
        offsetY,
        autoMirror,
        requiredSpace,
        screenPaddingHorizontal,
        screenPaddingVertical,
        autoOpen,
        autoClose,
        enabled,
        animation,
        animationDurationMs,
        useChildDecorator,
        usePopupDecorator,
      ];
}
