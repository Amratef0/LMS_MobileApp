import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

/// The /reports/* endpoints (ReportsController) don't return JSON — they
/// stream back an actual .xlsx or .pdf file. We download the bytes, write
/// them to the app's temp directory, then hand the file to the OS share
/// sheet so the person can open it in Excel/a PDF viewer or save it
/// wherever they like.
class ReportsRepository {
  ReportsRepository(this._api);
  final ApiClient _api;

  Future<void> attendanceReport(int groupId, String groupName) => _downloadAndShare(
        ApiConstants.reportAttendance,
        {'groupId': groupId},
        'Attendance_${_slug(groupName)}.xlsx',
      );

  Future<void> gradesReport(int groupId, String groupName) => _downloadAndShare(
        ApiConstants.reportGrades,
        {'groupId': groupId},
        'Grades_${_slug(groupName)}.xlsx',
      );

  Future<void> groupSummaryReport(int groupId, String groupName) => _downloadAndShare(
        ApiConstants.reportGroupSummary,
        {'groupId': groupId},
        'GroupSummary_${_slug(groupName)}.xlsx',
      );

  Future<void> studentProgressReport({int? studentId, String? studentName}) => _downloadAndShare(
        ApiConstants.reportStudentProgress,
        studentId == null ? null : {'studentId': studentId},
        'ProgressReport_${_slug(studentName ?? 'me')}.pdf',
      );

  Future<void> _downloadAndShare(String path, Map<String, dynamic>? query, String fileName) async {
    final bytes = await _api.downloadBytes(path, query: query);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], text: fileName);
  }

  String _slug(String s) => s.trim().replaceAll(RegExp(r'\s+'), '_');
}
