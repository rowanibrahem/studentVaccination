import 'package:flutter/material.dart';
import 'package:vaccacine_app/student_model.dart';

class StudentCard extends StatefulWidget {
  final Student student;
  final Function(String newStatus, String? reason , {String? vaccineName}) onStatusChanged;

  const StudentCard({
    super.key,
    required this.student,
    required this.onStatusChanged,
  });

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVaccinated = widget.student.vaccinationStatus == 'تم التطعيم';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isVaccinated ? Colors.teal.shade100 : Colors.orange.shade100,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          _showStudentDetailsDialog(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف العلوي: الاسم والمسلسل
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isVaccinated ? Colors.teal.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        widget.student.serial,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isVaccinated ? Colors.teal.shade800 : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.student.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.school, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              widget.student.school,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.class_, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              widget.student.classLevel,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // شارة الحالة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isVaccinated ? Colors.teal : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.student.vaccinationStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // سبب عدم التطعيم (لو موجود)
              if (!isVaccinated && widget.student.reason.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'السبب: ${widget.student.reason}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // أزرار التحكم
              Row(
                children: [
                  // زر تغيير الحالة
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showStatusDialog(context);
                      },
                      icon: Icon(
                        isVaccinated ? Icons.health_and_safety : Icons.medical_services,
                        size: 18,
                      ),
                      label: Text(
                        isVaccinated ? 'تعديل الحالة' : 'تسجيل تطعيم',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isVaccinated ? Colors.grey.shade200 : Colors.teal,
                        foregroundColor: isVaccinated ? Colors.black87 : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // زر عرض التفاصيل
                  IconButton(
                    onPressed: () {
                      _showStudentDetailsDialog(context);
                    },
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'التفاصيل',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== نافذة تسجيل/تعديل التطعيم ====================
  void _showStatusDialog(BuildContext context) {
    final isVaccinated = widget.student.vaccinationStatus == 'تم التطعيم';
    final TextEditingController customReasonController = TextEditingController();
    String? selectedReason;
    bool showReasonField = false;
   String? selectedVaccine = widget.student.vaccineName.isNotEmpty 
      ? widget.student.vaccineName 
      : null;
  bool showVaccineField = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isVaccinated ? 'تعديل حالة التطعيم' : 'تسجيل تطعيم'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isVaccinated) ...[
                    const Text(
                      'هل تم تطعيم الطالب؟',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    
                    // زر "نعم" و "لا" في صف واحد
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Navigator.pop(dialogContext);
                              // widget.onStatusChanged('تم التطعيم', null);
                              setDialogState(() {
                              showVaccineField = true;
                            });
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('نعم، تم التطعيم'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                showReasonField = true;
                              });
                            },
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('لا، لم يتم'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (showVaccineField) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'اختر نوع الطعم:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    DropdownButtonFormField<String>(
                      value: selectedVaccine,
                      decoration: InputDecoration(
                        hintText: 'اختر نوع الطعم...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: const Icon(Icons.vaccines, size: 20),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'سحائي ثنائي', child: Text('💉سحائي ثنائي')),
                        DropdownMenuItem(value: 'ثنائي', child: Text('💉 ثنائي')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedVaccine = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // زر تأكيد التطعيم
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedVaccine == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى اختيار نوع الطعم'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          
                          Navigator.pop(dialogContext);
                          widget.onStatusChanged('تم التطعيم', null, vaccineName: selectedVaccine);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('تأكيد التطعيم'),
                      ),
                    ),
                  ],
                    // حقل السبب (يظهر بعد الضغط على "لا")
                    if (showReasonField) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'سبب عدم التطعيم:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      // Dropdown للأسباب الجاهزة
                      DropdownButtonFormField<String>(
                        value: selectedReason,
                        decoration: InputDecoration(
                          hintText: 'اختر سبباً من القائمة...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          prefixIcon: const Icon(Icons.list_alt, size: 20),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'رفض ولي الأمر', child: Text('رفض ولي الأمر')),
                          DropdownMenuItem(value: 'غياب الطالب', child: Text('غياب الطالب')),
                          DropdownMenuItem(value: 'مشكلة صحية مؤقتة', child: Text('مشكلة صحية مؤقتة')),
                          DropdownMenuItem(value: 'تم التطعيم خارج المدرسة', child: Text('تم التطعيم خارج المدرسة')),
                          DropdownMenuItem(value: 'أخرى', child: Text('أخرى (اكتب السبب)')),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedReason = value;
                            if (value != 'أخرى') {
                              customReasonController.clear();
                            }
                          });
                        },
                      ),
                      
                      // TextField للسبب المخصص (لو اختار "أخرى")
                      if (selectedReason == 'أخرى') ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: customReasonController,
                          decoration: InputDecoration(
                            hintText: 'اكتب سبب عدم التطعيم هنا...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.edit_note, size: 20),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.right,
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      // زر تأكيد السبب
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            String finalReason = '';
                            
                            if (selectedReason == 'أخرى') {
                              finalReason = customReasonController.text.trim();
                              if (finalReason.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('يرجى كتابة سبب عدم التطعيم'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                            } else if (selectedReason != null && selectedReason!.isNotEmpty) {
                              finalReason = selectedReason!;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('يرجى اختيار سبب عدم التطعيم'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            
                            Navigator.pop(dialogContext);
                            widget.onStatusChanged('غير مطعم', finalReason);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('تأكيد وتسجيل السبب'),
                        ),
                      ),
                    ],
                  ] else ...[
                    // لو كان مطعماً بالفعل
                    const Text(
                    'تعديل حالة التطعيم',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // عرض اسم الطعم الحالي
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.vaccines, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          'الطعم الحالي: ${widget.student.vaccineName.isNotEmpty ? widget.student.vaccineName : "غير محدد"}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    'هل تريد تغيير الحالة إلى "غير مطعم"؟',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _showReasonDialog(context);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('نعم، تغيير'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.cancel),
                          label: const Text('إلغاء'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}

  // ==================== نافذة سبب عدم التطعيم (للتعديل من مطعم لغير مطعم) ====================
  void _showReasonDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    String? selectedReason = 'رفض ولي الأمر';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('سبب عدم التطعيم'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'رفض ولي الأمر', child: Text('رفض ولي الأمر')),
                      DropdownMenuItem(value: 'غياب الطالب', child: Text('غياب الطالب')),
                      DropdownMenuItem(value: 'مريض', child: Text('مريض')),
                      DropdownMenuItem(value: 'راسب من العام السابق', child: Text('راسب من العام السابق')),
                      DropdownMenuItem(value: 'موانع تطعيم ', child: Text('موانع تطعيم ')),
                      DropdownMenuItem(value: 'انقطاع', child: Text('انقطاع')),
                      DropdownMenuItem(value: 'مسافر', child: Text('مسافر')),
                      DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                  if (selectedReason == 'أخرى')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: reasonController,
                        decoration: const InputDecoration(
                          hintText: 'اكتب السبب...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final finalReason = selectedReason == 'أخرى'
                        ? reasonController.text.trim()
                        : selectedReason;
                    if (finalReason != null && finalReason.isNotEmpty) {
                      Navigator.pop(context);
                      widget.onStatusChanged('غير مطعم', finalReason);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text('تأكيد'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== نافذة تفاصيل الطالب ====================
  void _showStudentDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.student.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('المدرسة', widget.student.school),
              _detailRow('الفصل', widget.student.classLevel),
              _detailRow('المسلسل', widget.student.serial),
              _detailRow('رقم التليفون', widget.student.phone),
              _detailRow('الحالة', widget.student.vaccinationStatus),
              _detailRow('نوع الطعم', widget.student.vaccineName.isNotEmpty ? widget.student.vaccineName : 'غير محدد'),
              if (widget.student.reason.isNotEmpty)
                _detailRow('سبب عدم التطعيم', widget.student.reason),
              if (widget.student.vaccinationDate.isNotEmpty)
                _detailRow('تاريخ التطعيم', widget.student.vaccinationDate.split('T').first),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  // ==================== صف التفاصيل المساعد ====================
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}