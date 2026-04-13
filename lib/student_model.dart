class Student {
  final int rowIndex; // مهم للتحديث
  final String school;
  final String classLevel;
  final String serial;
  final String name;
  String vaccinationStatus;
  String reason;
  final String phone;
  String vaccinationDate;
  String vaccineName;

  Student({
    required this.rowIndex,
    required this.school,
    required this.classLevel,
    required this.serial,
    required this.name,
    required this.vaccinationStatus,
    required this.reason,
    required this.phone,
    required this.vaccinationDate,
    required this.vaccineName,
  });

  // من JSON لـ Object
  factory Student.fromJson(Map<String, dynamic> json, int index) {
    return Student(
      rowIndex: index,
      school: json['المدرسة']?.toString() ?? '',
      classLevel: json['الفصل']?.toString() ?? '',
      serial: json['مسلسل']?.toString() ?? '',
      name: json['اسم الطالب']?.toString() ?? '',
      vaccinationStatus: json['الحالة التطعيمية']?.toString() ?? 'غير مطعم',
      reason: json['سبب عدم التطعيم']?.toString() ?? '',
      phone: json['رقم التليفون']?.toString() ?? '',
      vaccinationDate: json['تاريخ التطعيم']?.toString() ?? '',
      vaccineName: json['اسم الطعم']?.toString() ?? '',
    );
  }

  // لـ JSON للتحديث
  Map<String, dynamic> toJson() {
    return {
      'rowIndex': rowIndex,
      'الحالة_التطعيمية': vaccinationStatus,
      'سبب_عدم_التطعيم': reason,
      'تاريخ_التطعيم': vaccinationDate,
      'اسم الطعم': vaccineName,
    };
  }
}