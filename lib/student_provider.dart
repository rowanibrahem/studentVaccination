import 'package:flutter/material.dart';
import 'package:vaccacine_app/service_model.dart';
import 'package:vaccacine_app/student_model.dart';

class StudentsProvider extends ChangeNotifier {
  final GoogleSheetsService _service = GoogleSheetsService();
  
  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Student> get students => _filteredStudents;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // فلتر القيم
  String _selectedSchoolFilter = 'الكل';
  String _selectedClassFilter = 'الكل';
  String _selectedStatusFilter = 'الكل';

  String get selectedSchoolFilter => _selectedSchoolFilter;
  String get selectedClassFilter => _selectedClassFilter;
  String get selectedStatusFilter => _selectedStatusFilter;

  // جلب كل الطلاب
  Future<void> fetchStudents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _allStudents = await _service.fetchAllStudents();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'فشل في تحميل البيانات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تطبيق الفلاتر
  void applyFilters({
    String? school,
    String? classLevel,
    String? status,
  }) {
    _selectedSchoolFilter = school ?? _selectedSchoolFilter;
    _selectedClassFilter = classLevel ?? _selectedClassFilter;
    _selectedStatusFilter = status ?? _selectedStatusFilter;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredStudents = _allStudents.where((student) {
      // فلتر المدرسة
      if (_selectedSchoolFilter != 'الكل' && 
          student.school != _selectedSchoolFilter) {
        return false;
      }
      
      // فلتر الفصل
      if (_selectedClassFilter != 'الكل' && 
          student.classLevel != _selectedClassFilter) {
        return false;
      }
      
      // فلتر الحالة التطعيمية
      if (_selectedStatusFilter != 'الكل' && 
          student.vaccinationStatus != _selectedStatusFilter) {
        return false;
      }
      
      return true;
    }).toList();
    
    notifyListeners();
  }

  // تحديث حالة التطعيم
  // تحديث حالة التطعيم (تعديل احترافي)
  Future<bool> updateVaccinationStatus(
    Student student, 
    String newStatus, {
    String? reason, 
    BuildContext? context // أضفنا الكونتيكست عشان نطلع رسائل خطأ
  }) async {
    // حفظ الحالة القديمة عشان لو حصل فشل نرجع لها
    final oldStatus = student.vaccinationStatus;
    final oldReason = student.reason;
    final oldDate = student.vaccinationDate;

    // 1. التحديث الفوري في الواجهة (Optimistic UI)
    student.vaccinationStatus = newStatus;
    if (reason != null) student.reason = reason;
    
    // تسجيل التاريخ لو الحالة "تم التطعيم"
    String? updateDate;
    if (newStatus == 'تم التطعيم') {
      updateDate = DateTime.now().toIso8601String();
      student.vaccinationDate = updateDate;
    } else {
      updateDate = null; // مسح التاريخ لو الحالة اتغيرت لغير مطعم
      student.vaccinationDate = "";
    }
    
    notifyListeners(); // الأبلكيشن هيتحدث قدام عينك فوراً هنا

    // 2. محاولة التحديث في جوجل شيت
    final success = await _service.updateVaccinationStatus(
      rowIndex: student.rowIndex,
      status: newStatus,
      reason: student.reason,
      date: updateDate,
    );
    
    // 3. معالجة حالة الفشل
    if (!success) {
      // لو فشل، نرجع البيانات القديمة
      student.vaccinationStatus = oldStatus;
      student.reason = oldReason;
      student.vaccinationDate = oldDate;
      notifyListeners();

      // تنبيه المستخدم إن البيانات مأكتتش في الشيت
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ عذراً، تعذر تحديث البيانات في الشيت. تأكد من اتصالك بالإنترنت.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ تم تحديث حالة ${student.name} بنجاح'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    return true;
  }
  // جلب قائمة المدارس للفلتر
  List<String> getUniqueSchools() {
    final schools = _allStudents.map((s) => s.school).toSet().toList();
    schools.sort();
    return ['الكل', ...schools];
  }

  // جلب قائمة الفصول للفلتر
  List<String> getUniqueClasses() {
    final classes = _allStudents.map((s) => s.classLevel).toSet().toList();
    classes.sort();
    return ['الكل', ...classes];
  }

  // إعادة تعيين الفلاتر
  void resetFilters() {
    _selectedSchoolFilter = 'الكل';
    _selectedClassFilter = 'الكل';
    _selectedStatusFilter = 'الكل';
    _applyFilters();
  }
}