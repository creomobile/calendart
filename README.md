# Calendart

## About

High customizable Flutter calendar widgets with popup view and multi-columns/rows of months, multi-scroll directions, multi-selections.

### Example:

```dart
Scaffold(
  body: Center(
    child: SizedBox(
      width: 300,
      child: ComboContext(
        parameters: ComboParameters(position: PopupPosition.bottomMinMatch),
        child: CalendarContext(
          parameters: CalendarParameters(firstDayOfWeekIndex: 0),
          child: CalendarCombo(
            columns: 2,
            popupSize: const Size(600, 300),
            selection: CalendarSelections.range(
                canSelectExtra: true,
                onSelectedChanged: (range) =>
                    print('from: ${range.from}, to: ${range.to}')),
            placeholder: ListTile(title: Text('Demo Calendar')),
          ),
        ),
      ),
    ),
  ),
);
```
