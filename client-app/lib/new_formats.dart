// ignore_for_file: avoid_print

class Timetable {
  final Meta meta;
  final Map<String, Map<String, Period>> data;

  Timetable({required this.meta, required this.data});

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      meta: Meta.fromJson(json['meta']),
      data: Map.fromEntries(
        (json['data'] as Map).entries.map(
              (entry) => MapEntry(
                entry.key,
                Map.fromEntries(
                  (entry.value as Map).entries.map(
                        (periodEntry) => MapEntry(
                          periodEntry.key,
                          Period.fromJson(periodEntry.value),
                        ),
                      ),
                ),
              ),
            ),
      ),
    );
  }
}

class Meta {
  final String section;
  final String type;
  final String revision;
  final String effectiveDate;
  final String contributor;
  final bool isTimetableUpdating;

  Meta({
    required this.section,
    required this.type,
    required this.revision,
    required this.effectiveDate,
    required this.contributor,
    required this.isTimetableUpdating,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      section: json['section'],
      type: json['type'],
      revision: json['revision'],
      effectiveDate: json['effective-date'],
      contributor: json['contributor'],
      isTimetableUpdating: json['isTimetableUpdating'],
    );
  }
}

class Period {
  final String subject;
  final String room;

  Period({required this.subject, required this.room});

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      subject: json['subject'],
      room: json['room'],
    );
  }
}

void main() {
// Parse the JSON string into a Map
  final jsonMap = {
    "meta": {
      "section": "b17",
      "type": "norm-class",
      "revision": "Revision 1.0",
      "effective-date": "Aug 31, 2023",
      "contributor": "PlanSync Wizard",
      "isTimetableUpdating": false
    },
    "data": {
      "monday": {
        "08:20 - 09:20": {"subject": "BEE", "room": "123-xhj"},
        "09:20 - 10:20": {"subject": "Chem.", "room": "123-xhj"},
        "10:20 - 11:20": {"subject": "YHC", "room": "123-xhj"},
        "11:20 - 12:00": {"subject": "***", "room": "123-xhj"},
        "12:00 - 13:00": {"subject": "Workshop Practical", "room": "123-xhj"},
        "13:00 - 14:00": {"subject": "Workshop Practical", "room": "123-xhj"}
      },
      "tuesday": {
        "08:00 - 09:00": {"subject": "Electives", "room": "123-xhj"},
        "09:20 - 10:20": {"subject": "DE & LA.", "room": "123-xhj"},
        "10:20 - 11:20": {"subject": "B.Etc", "room": "123-xhj"},
        "11:20 - 12:00": {"subject": "***", "room": "123-xhj"},
        "12:00 - 13:00": {"subject": "Engg. Lab", "room": "123-xhj"},
        "13:00 - 14:00": {"subject": "Engg. Lab", "room": "123-xhj"}
      },
      "wednesday": {
        "08:20 - 09:20": {"subject": "***", "room": "123-xhj"},
        "09:20 - 10:20": {"subject": "Eng.", "room": "123-xhj"},
        "10:20 - 11:20": {"subject": "DE & LA", "room": "123-xhj"},
        "11:20 - 12:00": {"subject": "***", "room": "123-xhj"},
        "12:00 - 13:00": {"subject": "Chem. Lab", "room": "123-xhj"},
        "13:00 - 14:00": {"subject": "Chem. Lab", "room": "123-xhj"}
      },
      "thursday": {
        "08:00 - 09:00": {"subject": "Electives", "room": "123-xhj"},
        "09:20 - 10:20": {"subject": "Eng.", "room": "123-xhj"},
        "10:20 - 11:20": {"subject": "B.Etc", "room": "123-xhj"},
        "11:20 - 12:20": {"subject": "DE & LA", "room": "123-xhj"},
        "12:20 - 13:20": {"subject": "Chem", "room": "123-xhj"},
        "13:20 - 14:20": {"subject": "***", "room": "123-xhj"}
      },
      "friday": {
        "08:20 - 09:20": {"subject": "BEE", "room": "123-xhj"},
        "09:20 - 10:20": {"subject": "Comm. Lab", "room": "123-xhj"},
        "10:20 - 11:20": {"subject": "Comm. Lab", "room": "123-xhj"},
        "11:20 - 12:20": {"subject": "Chem", "room": "123-xhj"},
        "12:20 - 13:20": {"subject": "DE & LA", "room": "123-xhj"},
        "13:20 - 14:20": {"subject": "***", "room": "123-xhj"}
      }
    }
  };

// Create a Timetable instance from the JSON data
  final timetable = Timetable.fromJson(jsonMap);

// Access the meta data
  print('Section: ${timetable.meta.section}');
  print('Effective Date: ${timetable.meta.effectiveDate}');

// Access the periods for a specific day
  final mondayPeriods = timetable.data['tuesday'];
  if (mondayPeriods != null) {
    print('Monday Periods:');
    mondayPeriods.forEach((time, period) {
      print('$time: ${period.subject} (Room: ${period.room})');
    });
  }
}
