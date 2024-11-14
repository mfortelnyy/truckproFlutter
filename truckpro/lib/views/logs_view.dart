import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:truckpro/views/pdf_view.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/models/userDto.dart';
import 'package:truckpro/views/manager_approve_view.dart';
import '../utils/report_api_service.dart';
import 'drvinglog_images_view.dart';

class LogsView extends StatefulWidget {
  final Future<List<LogEntry>> logsFuture;
  final String token;
  final int driverId;
  final bool approve;
  final void Function()? onApprove;
  final UserDto? userDto;

  const LogsView({
    super.key,
    required this.logsFuture,
    required this.token,
    required this.approve,
    this.userDto,
    this.onApprove,
    required this.driverId,
  });

  @override
  _LogsViewState createState() => _LogsViewState();
}

class _LogsViewState extends State<LogsView> {
  DateTime? startDate;
  DateTime? endDate;
  LogEntryType? selectedLogType;
  late Future<List<LogEntry>> filteredLogsFuture;
  bool showFilters = false;
  bool isGeneratingPdf = false; // flag to disable interactions during PDF generation
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    filteredLogsFuture = widget.logsFuture.then((logs) => logs ?? []);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredLogsFuture = widget.logsFuture.then((logs) {
        logs = logs ?? [];
        if (startDate != null && endDate != null) {
          logs = logs.where((log) {
            return log.startTime.isAfter(startDate!) && log.startTime.isBefore(endDate!);
          }).toList();
        }
        if (selectedLogType != null) {
          logs = logs.where((log) => log.logEntryType == selectedLogType).toList();
        }
        return logs;
      });
    });
  }

  bool get isFilterActive => startDate != null || endDate != null || selectedLogType != null;

  Future<void> _generatePdf() async {
    setState(() {
      isGeneratingPdf = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF...')),
    );

    ReportApiService apiService = ReportApiService();
    Uint8List? pdfBytes = await apiService.generatePDF(startDate!, endDate!, widget.token, widget.driverId);

    if (pdfBytes != null) {
      setState(() {
        _pdfBytes = pdfBytes;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate PDF.')),
      );
    }

    setState(() {
      isGeneratingPdf = false;
    });
  }

  void _resetFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      selectedLogType = null;
      filteredLogsFuture = widget.logsFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isGeneratingPdf, // disable all interactions while generating PDF
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Logs'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () {
                    setState(() {
                      showFilters = !showFilters;
                    });
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Visibility(
                  visible: showFilters,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 16.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () => _selectDate(context, true),
                          child: Text(
                            startDate == null
                                ? 'Select Start Date'
                                : DateFormat('MMMM dd, yyyy').format(startDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(
                            endDate == null
                                ? 'Select End Date'
                                : DateFormat('MMMM dd, yyyy').format(endDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownButton<LogEntryType>(
                          value: selectedLogType,
                          hint: const Text("Select Type"),
                          onChanged: (LogEntryType? newType) {
                            setState(() {
                              selectedLogType = newType;
                              _applyFilters();
                            });
                          },
                          items: LogEntryType.values.map((LogEntryType type) {
                            return DropdownMenuItem<LogEntryType>(
                              value: type,
                              child: Text(type.toString().split('.').last),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isFilterActive)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Generate PDF'),
                      onPressed: _generatePdf,
                    ),
                  ),
                if (_pdfBytes != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('View PDF'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: PDFViewerWidget(pdfBytes: _pdfBytes!),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: FutureBuilder<List<LogEntry>>(
                    future: filteredLogsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading logs'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No logs found. Try adjusting the filters.',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _resetFilters,
                                child: const Text('Reset Filters'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        final logs = snapshot.data!;
                        return ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            var log = logs[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 4,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      "${log.logEntryType?.toString().split(".")[1] ?? 'Unknown'} Log by ${log.user?.firstName ?? widget.userDto!.firstName} ${log.user?.lastName ?? widget.userDto!.lastName}",
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: log.logEntryType == LogEntryType.Driving
                                        ? _buildDrivingLogInfo(log)
                                        : _buildNonDrivingLogInfo(log),
                                    trailing: Text(
                                      log.user?.email ?? widget.userDto!.email,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    onTap: widget.approve
                                        ? () async {
                                            if (log.logEntryType == LogEntryType.Driving) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ManagerApproveView(
                                                    imageUrls: Future.value(log.imageUrls),
                                                    log: log,
                                                    token: widget.token,
                                                    onApprove: widget.onApprove,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('This is not a driving log!')),
                                              );
                                            }
                                          }
                                        : () async {
                                            if (log.logEntryType == LogEntryType.Driving) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DrivingLogImagesView(
                                                    imageUrls: Future.value(log.imageUrls),
                                                    log: log,
                                                    token: widget.token,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('This is not a driving log!')),
                                              );
                                            }
                                          },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isGeneratingPdf)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildDrivingLogInfo(LogEntry log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Log Start Date: ${formatDateTime(log.startTime)}'),
        log.endTime != null
            ? Text('Log End Date: ${formatDateTime(log.endTime!)}')
            : const Text('Log In Progress'),
        Text('Approved By Manager: ${boolToString(log.isApprovedByManager)}'),
        Text('Images attached: ${log.imageUrls?.length ?? 0}'),
      ],
    );
  }

  Widget _buildNonDrivingLogInfo(LogEntry log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Log Start Date: ${formatDateTime(log.startTime)}'),
        log.endTime != null
            ? Text('Log End Date: ${formatDateTime(log.endTime!)}')
            : const Text('In Progress', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  String boolToString(bool val) {
    return val ? "Yes" : "No";
  }

  String formatDateTime(DateTime dateTime) {
    DateFormat formatter = DateFormat('MMMM dd, yyyy \'at\' hh:mm a');
    return formatter.format(dateTime);
  }
}
