import 'package:flutter/material.dart';
import 'package:vaccacine_app/service_model.dart';
import 'package:vaccacine_app/student_model.dart';

class StudentsProvider extends ChangeNotifier {
  final GoogleSheetsService _service = GoogleSheetsService();
  
  List<Student> _masterList = []; // المخزن الرئيسي لكل اللي نزل من الشيت
  List<Student> _displayList = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _errorMessage = '';

  // Getters
  List<Student> get students => _displayList; // الـ UI بيقرأ من هنا
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String get errorMessage => _errorMessage;

  // فلاتر البحث
  String _selectedSchoolFilter = 'الكل';
  String _selectedClassFilter = 'الكل';
  String _selectedStatusFilter = 'الكل';

  // جلب كل الطلاب
  // 1. تحميل أول 20 طالب
  Future<void> fetchInitialStudents() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoading = true;
    _errorMessage = '';
    _masterList.clear();
    notifyListeners();

    try {
      final result = await _service.fetchStudentsPaged(page: _currentPage);
      _masterList = List.from(result['students']);
      _hasMore = result['hasMore'];
      _applyFilters(); // تحديث القائمة اللي بتتعرض
    } catch (e) {
      _errorMessage = 'فشل في تحميل البيانات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. تحميل المزيد عند التمرير (Pagination)
  Future<void> fetchMoreStudents() async {
    if (_isFetchingMore || !_hasMore || _isLoading) return;

    _isFetchingMore = true;
    notifyListeners();
    
    final nextPage = _currentPage + 1;

    try {
      final result = await _service.fetchStudentsPaged(page: nextPage);
      final newStudents = result['students'] as List<Student>;
      
      // ✅ منع التكرار بناءً على rowIndex
      final existingIds = _masterList.map((s) => s.rowIndex).toSet();
      final uniqueNewStudents = newStudents.where((s) => !existingIds.contains(s.rowIndex)).toList();
      
      _masterList.addAll(uniqueNewStudents);
      _currentPage = nextPage;
      _hasMore = result['hasMore'];
      
      _applyFilters(); // تطبيق الفلتر على الداتا الجديدة والقديمة سوا
    } catch (e) {
      print('❌ Error loading more: $e');
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  // 3. تطبيق الفلاتر
  void applyFilters({String? school, String? classLevel, String? status}) {
    _selectedSchoolFilter = school ?? _selectedSchoolFilter;
    _selectedClassFilter = classLevel ?? _selectedClassFilter;
    _selectedStatusFilter = status ?? _selectedStatusFilter;
    _applyFilters();
  }

  void _applyFilters() {
    // بنفلتر دايماً من الـ Master List عشان م نضيعش داتا
    _displayList = _masterList.where((student) {
      if (_selectedSchoolFilter != 'الكل' && student.school != _selectedSchoolFilter) return false;
      if (_selectedClassFilter != 'الكل' && student.classLevel != _selectedClassFilter) return false;
      if (_selectedStatusFilter != 'الكل' && student.vaccinationStatus != _selectedStatusFilter) return false;
      return true;
    }).toList();
    
    notifyListeners();
  }

  // 4. إعادة تعيين الفلاتر وتحميل من الأول
  void resetAndRefetch() {
    _selectedSchoolFilter = 'الكل';
    _selectedClassFilter = 'الكل';
    _selectedStatusFilter = 'الكل';
    fetchInitialStudents();
  }

  // تحديث حالة التطعيم
  // تحديث حالة التطعيم (تعديل احترافي)
  Future<bool> updateVaccinationStatus(
    Student student, 
    String newStatus, {
    String? reason, 
    String? vaccineName,
    BuildContext? context // أضفنا الكونتيكست عشان نطلع رسائل خطأ
  }) async {
    // حفظ الحالة القديمة عشان لو حصل فشل نرجع لها
    final oldStatus = student.vaccinationStatus;
    final oldReason = student.reason;
    final oldDate = student.vaccinationDate;
    final oldVaccineName = student.vaccineName;
    // 1. التحديث الفوري في الواجهة (Optimistic UI)
    student.vaccinationStatus = newStatus;
    if (reason != null) student.reason = reason;
    if (vaccineName != null) student.vaccineName = vaccineName;
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
      vaccineName: vaccineName,
    );
    
    // 3. معالجة حالة الفشل
    if (!success) {
      // لو فشل، نرجع البيانات القديمة
      student.vaccinationStatus = oldStatus;
      student.reason = oldReason;
      student.vaccinationDate = oldDate;
      student.vaccineName = oldVaccineName;
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
    // ✅ غيرنا _allStudents لـ _masterList
    final schools = _masterList.map((s) => s.school).toSet().toList();
    schools.sort();
    return ['الكل', ...schools];
  }

  // جلب قائمة الفصول للفلتر
  List<String> getUniqueClasses() {
    // ✅ غيرنا _allStudents لـ _masterList
    final classes = _masterList.map((s) => s.classLevel).toSet().toList();
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