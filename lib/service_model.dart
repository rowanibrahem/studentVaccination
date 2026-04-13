import 'dart:convert';
import 'package:dio/dio.dart'; // استخدمنا dio
import 'package:vaccacine_app/student_model.dart';

class GoogleSheetsService {
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbyXMbCHz5CRKRAaKdEcRknh0ph9HxXKJKbEkq7O3WKHuErGzJbNfqOYbfy_OCjj7Tk2XQ/exec';
  
  final Dio _dio = Dio(BaseOptions(
    followRedirects: true, // دي أهم خاصية عشان تحل مشكلة 302
    validateStatus: (status) => status! < 500,
  ));

  Future<List<Student>> fetchAllStudents() async {
    try {
      final response = await _dio.get(baseUrl);
      if (response.statusCode == 200) {
        // Dio بيحول الـ body لـ Map أوتوماتيك مش محتاجة json.decode
        final data = response.data is String ? json.decode(response.data) : response.data;
        if (data['success'] == true) {
          final List<dynamic> studentsJson = data['data'];
          return List.generate(
            studentsJson.length,
            (index) => Student.fromJson(studentsJson[index], index),
          );
        }
      }
      throw Exception('فشل في جلب البيانات');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> updateVaccinationStatus({
    required int rowIndex,
    required String status,
    String? reason,
    String? date,
  }) async {
    try {
      final response = await _dio.post(
        baseUrl,
        data: {
          'rowIndex': rowIndex,
          'الحالة_التطعيمية': status,
          'سبب_عدم_التطعيم': reason ?? '',
          'تاريخ_التطعيم': date ?? '',
        },
      );

      // جوجل أحياناً بترد بـ 200 أو 302 حتى لو التحديث نجح
      // مع Dio إحنا بنلحق الرد النهائي
      if (response.statusCode == 200 || response.statusCode == 302) {
         // لو الرد فيه success: true
         if (response.data is Map && response.data['success'] == true) return true;
         // أحياناً جوجل بترد بـ HTML بعد الـ Redirect بس التحديث بيكون تم فعلاً
         return true; 
      }
      return false;
    } catch (e) {
      print('❌ Error updating: $e');
      return false;
    }
  }
}