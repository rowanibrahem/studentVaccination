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
  // 1. تعريف الـ ScrollController
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // ربط مستمع للـ Scroll عشان ينادي الـ Pagination
    _scrollController.addListener(_onScroll);

    // نداء البيانات لأول مرة بعد ما الـ Frame يخلص
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentsProvider>().fetchInitialStudents();
    });
  }

  // دالة مراقبة حركة القائمة
  void _onScroll() {
    final provider = context.read<StudentsProvider>();
    // لو المستخدم وصل قبل نهاية القائمة بـ 200 بكسل
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      provider.fetchMoreStudents();
    }
  }

  @override
  void dispose() {
    // 2. إغلاق الكنترولر للحفاظ على الذاكرة
    _scrollController.dispose();
    super.dispose();
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<StudentsProvider>().resetAndRefetch(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            onPressed: () => context.read<StudentsProvider>().resetFilters(),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Consumer<StudentsProvider>(
          builder: (context, provider, child) {
            // حالة التحميل الأولية
            if (provider.isLoading && provider.students.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 16),
                    Text('جاري تحميل البيانات...'),
                  ],
                ),
              );
            }

            // حالة الخطأ
            if (provider.errorMessage.isNotEmpty && provider.students.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage, textAlign: TextAlign.center),
                    ElevatedButton(
                      onPressed: () => provider.fetchInitialStudents(),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: const Text('حاول مرة أخرى'),
                    ),
                  ],
                ),
              );
            }

            // حالة عدم وجود نتائج
            if (provider.students.isEmpty) {
              return const Center(child: Text('لا يوجد طلاب مطابقين للفلتر'));
            }

            return Column(
              children: [
                const FilterSection(),
                
                // إحصائية سريعة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.teal.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إجمالي المحمل: ${provider.students.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'مطعمين: ${provider.students.where((s) => s.vaccinationStatus == "تم التطعيم").length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // القائمة مع الـ Pagination
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController, // ربط الكنترولر هنا
                    padding: const EdgeInsets.all(8),
                    // نزود صف واحد لو فيه داتا تانية لسه هتتحمل عشان نظهر الـ Loader
                    itemCount: provider.students.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < provider.students.length) {
                        final student = provider.students[index];
                        return StudentCard(
                          student: student,
                          onStatusChanged: (newStatus, reason, {vaccineName}) async {
                            await provider.updateVaccinationStatus(
                              student,
                              newStatus,
                              reason: reason,
                              vaccineName: vaccineName,
                              context: context,
                            );
                          },
                        );
                      } else {
                        // مؤشر تحميل صغير يظهر في أسفل القائمة أثناء تحميل الصفحات الجديدة
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        );
                      }
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