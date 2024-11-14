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
  List<LogEntryType> selectedLogTypes = LogEntryType.values; 
  late Future<List<LogEntry>> filteredLogsFuture;
  bool showFilters = false;
  bool isGeneratingPdf = false;
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
        if (selectedLogTypes.isNotEmpty) {
          logs = logs.where((log) => selectedLogTypes.contains(log.logEntryType)).toList();
        }
        return logs;
      });
    });
  }

  bool get isFilterActive => startDate != null || endDate != null || selectedLogTypes.isNotEmpty;

  void _resetFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      selectedLogTypes = LogEntryType.values;
      filteredLogsFuture = widget.logsFuture;
    });
  }

  Future<void> _generatePdf() async {
    setState(() {
      isGeneratingPdf = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF...')),
    );

    ReportApiService apiService = ReportApiService();
    Uint8List? pdfBytes = await apiService.generatePDF(startDate!, endDate!, widget.token, widget.driverId, selectedLogTypes);

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

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isGeneratingPdf,
      child: Scaffold(
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
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 16.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text(
                        startDate == null
                            ? 'Select Start Date'
                            : DateFormat('MMMM dd, yyyy').format(startDate!),
                        style: TextStyle(color: startDate == null ? Colors.grey : Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text(
                        endDate == null
                            ? 'Select End Date'
                            : DateFormat('MMMM dd, yyyy').format(endDate!),
                        style: TextStyle(color: endDate == null ? Colors.grey : Colors.blue),
                      ),
                    ),
                   ElevatedButton(
                    onPressed: () async {
                      List<LogEntryType>? selected = await showDialog(
                        context: context,
                        builder: (context) {
                          List<LogEntryType> tempSelected = List.from(selectedLogTypes);

                          return StatefulBuilder(
                            builder: (context, setStateDialog) {
                              return AlertDialog(
                                title: const Text("Select Log Types"),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Select All / Deselect All Button
                                      TextButton(
                                        onPressed: () {
                                          setStateDialog(() {
                                            if (tempSelected.length == LogEntryType.values.length) {
                                              tempSelected.clear();
                                            } else {
                                              // get all log types
                                              tempSelected = List.from(LogEntryType.values);
                                            }
                                          });
                                        },
                                        child: Text(
                                          tempSelected.length == LogEntryType.values.length
                                              ? "Deselect All"
                                              : "Select All",
                                          style: const TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      // Checkbox List of Log Entry Types
                                      ...LogEntryType.values.map((type) {
                                        return CheckboxListTile(
                                          title: Text(type.toString().split('.').last),
                                          value: tempSelected.contains(type),
                                          onChanged: (bool? checked) {
                                            setStateDialog(() {
                                              if (checked == true) {
                                                if (!tempSelected.contains(type)) {
                                                  tempSelected.add(type);
                                                }
                                              } else {
                                                tempSelected.remove(type);
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, tempSelected); 
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );

                      if (selected != null) {
                        setState(() {
                          //upd the parent widget's selectedLogTypes with the new list
                          selectedLogTypes = selected;
                          // apply filters with the updated selected types
                          _applyFilters(); 
                        });
                      }
                    },
                    child: Text(
                      selectedLogTypes.isEmpty
                          ? "Select Log Types"
                          : "Selected (${selectedLogTypes.length})",
                    ),
                  ),

                    if (isFilterActive)
                      ElevatedButton(
                        onPressed: _resetFilters,
                        child: const Text('Reset Filters'),
                      ),
                  ],
                ),
              ),
            ),
            if (isFilterActive)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate PDF'),
                  onPressed: _generatePdf,
                ),
              ),
            if (_pdfBytes != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                            onPressed: () => Navigator.pop(context),
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
                          const Text('No logs found. Try adjusting the filters.'),
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
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            title: Text(
                              "${log.logEntryType?.toString().split(".")[1] ?? 'Unknown'} Log by ${log.user?.firstName ?? widget.userDto!.firstName} ${log.user?.lastName ?? widget.userDto!.lastName}",
                            ),
                            subtitle: log.logEntryType == LogEntryType.Driving
                                ? _buildDrivingLogInfo(log)
                                : _buildNonDrivingLogInfo(log),
                            trailing: Text(
                              log.user?.email ?? widget.userDto!.email,
                              style: const TextStyle(fontSize: 12),
                            ),
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
        floatingActionButton: isGeneratingPdf
            ? const CircularProgressIndicator()
            : null,
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
