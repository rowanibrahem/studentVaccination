import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaccacine_app/student_provider.dart';

class FilterSection extends StatefulWidget {
  const FilterSection({super.key});

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  String selectedSchool = 'الكل';
  String selectedClass = 'الكل';
  String selectedStatus = 'الكل';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentsProvider>();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.filter_alt, size: 20, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'تصفية النتائج',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // فلتر المدرسة
          _buildFilterRow(
            label: 'المدرسة',
            icon: Icons.school,
            value: selectedSchool,
            items: provider.getUniqueSchools(),
            onChanged: (value) {
              setState(() {
                selectedSchool = value!;
                selectedClass = 'الكل'; // إعادة تعيين الفصل عند تغيير المدرسة
              });
              provider.applyFilters(
                school: selectedSchool,
                classLevel: selectedClass,
                status: selectedStatus,
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // فلتر الفصل
          _buildFilterRow(
            label: 'الفصل',
            icon: Icons.class_,
            value: selectedClass,
            items: provider.getUniqueClasses(),
            onChanged: (value) {
              setState(() {
                selectedClass = value!;
              });
              provider.applyFilters(
                school: selectedSchool,
                classLevel: selectedClass,
                status: selectedStatus,
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // فلتر الحالة التطعيمية
          _buildFilterRow(
            label: 'الحالة',
            icon: Icons.health_and_safety,
            value: selectedStatus,
            items: const ['الكل', 'تم التطعيم', 'غير مطعم'],
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
              });
              provider.applyFilters(
                school: selectedSchool,
                classLevel: selectedClass,
                status: selectedStatus,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.teal),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}