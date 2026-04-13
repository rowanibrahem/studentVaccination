import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vaccacine_app/student_model.dart';

class GoogleSheetsService {
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbzXAtBl75Q3_Lvg-g--WarJ9LMKR9lQwPfIxVRiRI-FCrmBbU2OKuYiRY1ookqGuWSv9w/exec';
  
  final Dio _dio = Dio(BaseOptions(
    followRedirects: true,
    validateStatus: (status) => status! < 500,
  ));

  // ✅ الدالة الجديدة بعد تعديلها للـ Pagination
  Future<Map<String, dynamic>> fetchStudentsPaged({
    required int page, 
    int pageSize = 50, // خليناها 20 عشان السرعة والتوافق
  }) async {
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data is String 
            ? json.decode(response.data) 
            : response.data;
            
        if (data['success'] == true) {
          final List<dynamic> list = data['data'];
          
          // تحويل البيانات لـ Objects مع استخدام الـ rowIndex القادم من الشيت
          final students = list.map((item) => Student.fromJson(
            item, 
            item['rowIndex'] as int
          )).toList();
          
          return {
            'students': students,
            'hasMore': data['hasMore'] as bool,
            'total': data['total'] as int,
            'currentPage': data['currentPage'] as int,
          };
        }
      }
      throw Exception('فشل في جلب البيانات من السيرفر');
    } catch (e) {
      print('❌ Error in fetchStudentsPaged: $e');
      rethrow;
    }
  }

  // دالة التحديث بتبقى زي ما هي (شغالة تمام بـ Dio)
  Future<bool> updateVaccinationStatus({
    required int rowIndex,
    required String status,
    String? reason,
    String? date,
    String? vaccineName,
  }) async {
    try {
      final body = {
        'rowIndex': rowIndex,
        'الحالة_التطعيمية': status,
        'سبب_عدم_التطعيم': reason ?? '',
        'تاريخ_التطعيم': date ?? '',
        'اسم_الطعم': vaccineName ?? '',   
      };
      
      final response = await _dio.post(baseUrl, data: body);
          
      if (response.statusCode == 200 || response.statusCode == 302) {
         if (response.data is Map && response.data['success'] == true) return true;
         return true; 
      }
      return false;
    } catch (e) {
      print('❌ Error updating: $e');
      return false;
    }
  }
}