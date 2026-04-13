import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaccacine_app/filter_section.dart';
import 'package:vaccacine_app/student_card.dart';
import 'package:vaccacine_app/student_provider.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  @override
  void initState() {
    super.initState();
    // بننادي على البيانات أول ما الشاشة تفتح
    Future.microtask(() => context.read<StudentsProvider>().fetchStudents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة التطعيمات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // زر تحديث البيانات
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StudentsProvider>().fetchStudents();
            },
          ),
          // زر إعادة تعيين الفلاتر
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            onPressed: () {
              context.read<StudentsProvider>().resetFilters();
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Consumer<StudentsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                    SizedBox(height: 16),
                    Text('جاري تحميل البيانات...'),
                  ],
                ),
              );
            }
        
            if (provider.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchStudents(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text('حاول مرة أخرى'),
                    ),
                  ],
                ),
              );
            }
        
            if (provider.students.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'لا يوجد طلاب مطابقين للفلتر',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }
        
            return Column(
              children: [
                // قسم الفلاتر
                const FilterSection(),
        
                // إحصائية سريعة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.teal.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إجمالي الطلاب: ${provider.students.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'مطعمين: ${provider.students.where((s) => s.vaccinationStatus == "تم التطعيم").length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        
                // قائمة الطلاب
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: provider.students.length,
                    itemBuilder: (context, index) {
                      final student = provider.students[index];
                      return StudentCard(
                        student: student,
                        onStatusChanged:
                            (newStatus, reason, {String? vaccineName}) async {
                              await provider.updateVaccinationStatus(
                                student,
                                newStatus,
                                reason: reason,
                                context: context,
                                vaccineName:
                                    vaccineName, // بنمرر الكونتيكست عشان نطلع رسائل الخطأ والنجاح
                              );
        
                              // عرض رسالة نجاح
                              // if (context.mounted) {
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     SnackBar(
                              //       content: Text(
                              //         'تم تحديث حالة ${student.name} إلى "$newStatus"',
                              //       ),
                              //       backgroundColor: Colors.teal,
                              //       duration: const Duration(seconds: 2),
                              //     ),
                              //   );
                              // }
                            },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
