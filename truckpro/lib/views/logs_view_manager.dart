import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/models/userDto.dart';
import 'package:truckpro/views/manager_approve_view.dart';
import '../utils/report_api_service.dart';
import 'pdf_view_widget.dart';

class LogsViewManager extends StatefulWidget {
  final Future<List<LogEntry>> logsFuture;
  final String token;
  final int driverId;
  final bool approve;
  final void Function()? onApprove;
  final UserDto? userDto;

  const LogsViewManager({
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

class _LogsViewState extends State<LogsViewManager> {
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
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates!'), backgroundColor: Color.fromARGB(236, 251, 163, 69)),
      );
      setState(() {
        isGeneratingPdf = false;
      });
      return;
    }

    ReportApiService apiService = ReportApiService();
    Uint8List? pdfBytes = await apiService.generatePDF(startDate!, endDate!, widget.token, widget.driverId, selectedLogTypes);

    if (pdfBytes != null) {
      setState(() {
        _pdfBytes = pdfBytes;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate PDF.'), backgroundColor:  Color.fromARGB(230, 247, 42, 66)),
      );
    }

    setState(() {
      isGeneratingPdf = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
    appBar: AppBar(
      title: const Text('Logs'),
      backgroundColor: const Color.fromARGB(255, 241, 158, 89),
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
    body: SingleChildScrollView( // Added to make the entire screen scrollable
      child: Column(
        children: [
          Visibility(
            visible: showFilters,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Pickers Row (Start Date and End Date)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => _selectDate(context, true),
                        child: Text(
                          startDate == null
                              ? 'Select Start Date'
                              : DateFormat('MMMM dd, yyyy').format(startDate!),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDate(context, false),
                        child: Text(
                          endDate == null
                              ? 'Select End Date'
                              : DateFormat('MMMM dd, yyyy').format(endDate!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Log Types and Reset Filters Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                          TextButton(
                                            onPressed: () {
                                              setStateDialog(() {
                                                if (tempSelected.length == LogEntryType.values.length) {
                                                  tempSelected.clear();
                                                } else {
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
                                              }
                                            );
                                          }),
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
                              selectedLogTypes = selected;
                              _applyFilters();
                            });
                          }
                        },
                        child: Text(
                          selectedLogTypes.isEmpty
                              ? "Select Log Types"
                              : "Selected Log Types (${selectedLogTypes.length})",
                        ),
                      ),

                      // Conditional Reset Filters Button
                      if (isFilterActive)
                        ElevatedButton(
                          onPressed: _resetFilters,
                          child: const Text('Reset Filters'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (showFilters)
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
          FutureBuilder<List<LogEntry>>(
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
                  shrinkWrap: true, // Ensure the ListView doesn't take up all space
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling for this ListView
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    var log = logs[index];
                    return Card(
                      borderOnForeground: true,
                      surfaceTintColor:  isDarkTheme ? Color.fromARGB(255, 255, 252, 252) : Color.fromARGB(255, 2, 2, 2),
                      shadowColor:  isDarkTheme ? Color.fromARGB(255, 255, 252, 252) : Color.fromARGB(255, 2, 2, 2),
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text(
                          "${log.logEntryType.toString().split(".")[1] ?? 'Unknown'} Log by ${log.user?.firstName ?? widget.userDto!.firstName} ${log.user?.lastName ?? widget.userDto!.lastName}",
                        ),
                        subtitle: log.logEntryType == LogEntryType.Driving
                            ? _buildDrivingLogInfo(log)
                            : _buildNonDrivingLogInfo(log),
                        trailing: Text(
                          log.user?.email ?? widget.userDto!.email,
                          style: const TextStyle(fontSize: 12),
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
                                    const SnackBar(content: Text('This is not a driving log!'), backgroundColor:  Color.fromARGB(230, 247, 42, 66) ),
                                  );
                                }
                              }
                            : () async {
                              },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
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
        Text('Approved: ${boolToString(log.isApprovedByManager)}'),
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
