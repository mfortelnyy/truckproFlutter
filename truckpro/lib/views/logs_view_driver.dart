import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truckpro/models/log_entry.dart';
import 'package:truckpro/models/log_entry_type.dart';
import 'package:truckpro/models/userDto.dart';
import '../utils/report_api_service.dart';
import 'logEntryDetailPage.dart';
import 'pdf_view_widget.dart';

class LogsViewDriver extends StatefulWidget {
  final Future<List<LogEntry>> logsFuture;
  final String token;
  final int driverId;
  final UserDto? userDto;
  final bool? approve;
  final void Function()? onApprove;

  const LogsViewDriver({
    super.key,
    required this.logsFuture,
    required this.token,    
    this.userDto,
    required this.driverId,
    this.approve,
    this.onApprove,
  });

  @override
  _LogsViewDriverState createState() => _LogsViewDriverState();
}

class _LogsViewDriverState extends State<LogsViewDriver> {
  DateTime? startDate;
  DateTime? endDate;
  List<LogEntryType> selectedLogTypes =[
    LogEntryType.OffDuty, 
    LogEntryType.OnDuty
  ];
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
        const SnackBar(content: Text('Please select both start and end dates!'), backgroundColor: Color.fromARGB(236, 251, 163, 69),),
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
        const SnackBar(content: Text('Failed to generate PDF.'), backgroundColor:  Color.fromARGB(230, 247, 42, 66),),
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
      title: const Text('History Overview', style: TextStyle(fontWeight: FontWeight.w700),),
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
    body: SingleChildScrollView(
      child: Column(
        children: [
          Visibility(
            visible: showFilters,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Pickers - Start and End Date buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Start Date Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
                        onPressed: () => _selectDate(context, true),
                        child: Text(
                          startDate == null
                              ? 'Select Min Start Date'
                              : DateFormat('MMMM dd, yyyy').format(startDate!),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      // End Date Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
                        onPressed: () => _selectDate(context, false),
                        child: Text(
                          endDate == null
                              ? 'Select Max Start Date'
                              : DateFormat('MMMM dd, yyyy').format(endDate!),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // New Row for 'Select Log Types' and 'Reset Filters' buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Select Log Types Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
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
                                              },
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
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),

                      // Reset Filters Button
                      if (isFilterActive)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                          ),
                          onPressed: _resetFilters,
                          child: const Text('Reset Filters', style: TextStyle(fontSize: 14)),
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                icon: const Icon(Icons.picture_as_pdf, size: 20),
                label: const Text('Generate PDF', style: TextStyle(fontSize: 14)),
                onPressed: _generatePdf,
              ),
            ),
          if (_pdfBytes != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 20),
                    label: const Text('View PDF', style: TextStyle(fontSize: 14)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          // Get the screen height
                          double height = MediaQuery.of(context).size.height;

                          return Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Container(
                              height: height * 0.8, // 80% of the screen
                              width: double.infinity, // width-> full screen width
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center, // center the content
                                children: [
                                  Expanded(
                                    child: PDFViewerWidget(pdfBytes: _pdfBytes!), //PDF widget
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    icon: const Icon(Icons.download, size: 20),
                    label: const Text('Download PDF', style: TextStyle(fontSize: 14)),
                    onPressed: _downloadPdf,
                  ),
                ],
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
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    var log = logs[index];

                    //Create stats for the child logs (log types and hours)
                    Map<String, Map<String, dynamic>> childLogStats = _calculateChildLogStats(log.childLogEntries);

                    return Card(
                      borderOnForeground: true,
                      surfaceTintColor: isDarkTheme ? Color.fromARGB(255, 255, 252, 252) : Color.fromARGB(255, 2, 2, 2),
                      shadowColor: isDarkTheme ? Color.fromARGB(255, 255, 252, 252) : Color.fromARGB(255, 2, 2, 2),
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      color: isDarkTheme ? Color.fromARGB(255, 15, 13, 13) : Colors.white,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => 
                            widget.approve != null && widget.approve! 
                            ? LogEntryDetailPage(
                              parentLog: log,
                              childrenLogs: log.childLogEntries,
                              token: widget.token,
                            )
                            : LogEntryDetailPage(
                              parentLog: log,
                              childrenLogs: log.childLogEntries,
                              token: widget.token,
                              approve: widget.approve,
                              onApprove: widget.onApprove,
                            )
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${getLogTypeLabel(log.logEntryType)} Log',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),                          
                              Text(
                                'Start: ${formatDateTime(log.startTime)}\nEnd: ${formatDateTime(log.endTime)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkTheme ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              //display statistics for child logs
                              if (log.childLogEntries != null && log.childLogEntries!.isNotEmpty) ...[
                                Text(
                                  'Events Statistics:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkTheme ? Colors.white : Colors.black,
                                  ),
                                ),
                                for (var entry in childLogStats.entries)
                                  Text(
                                    '${entry.key}: ${entry.value['count']} logs, ${entry.value['totalHours']} hours',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
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

  Future<void> _downloadPdf() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Generated_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      final file = File(filePath);
      await file.writeAsBytes(_pdfBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to $filePath'), backgroundColor: Color.fromARGB(219, 79, 194, 70) ,),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e',), backgroundColor: Color.fromARGB(230, 247, 42, 66),),
      );
    }
  }

   String formatDateTime(DateTime? dateTime) {
    if (dateTime != null) {
      DateFormat formatter = DateFormat('MMMM dd, yyyy \'at\' hh:mm a');
      return formatter.format(dateTime); 
    } 
    //DateTime is null -> it's in progress
    else {
      return 'In progress'; 
    }
  }

  //helper function to calculate statistics for child logs
  Map<String, Map<String, dynamic>> _calculateChildLogStats(List<LogEntry>? childLogEntries) {
    Map<String, Map<String, dynamic>> stats = {};

    if (childLogEntries != null) {
      for (var child in childLogEntries) {
        
        String logType = child.logEntryType.toString().split('.').last;

        // If the log type doesn't exist in the stats map, initialize it
        if (!stats.containsKey(logType)) {
          stats[logType] = {
            'count': 0, //# of occurrences of this log type
            'totalHours': 0.0, //total hours for this log type
          };
        }

        // ++ the count and add to total hours
        stats[logType]?['count'] = stats[logType]?['count'] + 1 ?? 1;
        
        //find the difference between start and end time to get the hours
        if (child.endTime != null) {
          Duration logDuration = child.endTime!.difference(child.startTime);
          stats[logType]?['totalHours'] = stats[logType]?['totalHours'] + logDuration.inHours.toDouble();
        }
      }
    }
    return stats;
  }

  String getLogTypeLabel(LogEntryType logType) {
  if (logType == LogEntryType.Break) {
    return "Sleep Log"; //rename break to sleep for user display
  } else {
    return logType.toString().split('.').last; //def for other log types
  }
}


}
