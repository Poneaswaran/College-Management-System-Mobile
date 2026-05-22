import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../services/academic_service.dart';
import '../../../../core/attendance_models.dart';
import '../../theme/vels_theme.dart';
import '../../widgets/vels_header.dart';
import '../../widgets/custom_button.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  int _activeTab = 0; // 0 = Overview, 1 = History

  List<StudentAttendanceReport> _reports = [];
  List<ActiveAttendanceSession> _activeSessions = [];
  List<AttendanceHistoryItem> _history = [];
  String? _errorMessage;

  // Active Session Self-Marking State
  ActiveAttendanceSession? _selectedSession;
  bool _isMarkingMode = false;
  bool _isCameraReady = false;
  bool _isLocating = false;
  bool _isSubmitting = false;
  String _simulatedLocation = "Locking GPS...";
  double _simulatedLat = 0.0;
  double _simulatedLng = 0.0;
  String _simulatedDeviceInfo = "Detecting Device...";

  // Native camera state
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitializing = false;

  // Animation controllers
  late AnimationController _scanningController;
  late AnimationController _pulseController;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _scanningController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _loadAttendanceData();
    _countdownTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _activeSessions.isNotEmpty && !_isMarkingMode) {
        _loadActiveSessionsOnly();
      }
    });
  }

  @override
  void dispose() {
    _scanningController.dispose();
    _pulseController.dispose();
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _loadAttendanceData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reports = await AcademicService.getStudentAttendanceReports();
      final sessions = await AcademicService.getActiveAttendanceSessions();
      final history = await AcademicService.getStudentAttendanceHistory();

      if (mounted) {
        setState(() {
          _reports = reports;
          _activeSessions = sessions;
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to sync attendance details: $e";
        });
      }
    }
  }

  Future<void> _loadActiveSessionsOnly() async {
    try {
      final sessions = await AcademicService.getActiveAttendanceSessions();
      if (mounted) {
        setState(() {
          _activeSessions = sessions;
        });
      }
    } catch (_) {}
  }

  // Calculate overall average attendance
  double get _overallAttendancePercentage {
    if (_reports.isEmpty) return 0.0;
    double sum = 0;
    for (var r in _reports) {
      sum += r.attendancePercentage;
    }
    return sum / _reports.length;
  }

  // Initialize native Camera
  Future<void> _initializeCamera() async {
    if (_isCameraInitializing) return;
    setState(() {
      _isCameraInitializing = true;
      _isCameraReady = false;
    });

    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Try to find the front-facing camera for selfies
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      } else {
        print("No camera devices available.");
      }
    } catch (e) {
      print("Error initializing camera: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
      }
    }
  }

  // Dispose native Camera
  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
    setState(() {
      _isCameraReady = false;
    });
  }

  // Retrieve native GPS coordinates
  Future<void> _determinePosition() async {
    setState(() {
      _isLocating = true;
      _simulatedLocation = "Requesting GPS link...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _simulatedLocation = "Location services disabled.";
          _isLocating = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _simulatedLocation = "Location permission denied.";
            _isLocating = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _simulatedLocation = "Location permission permanently denied.";
          _isLocating = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _simulatedLat = position.latitude;
          _simulatedLng = position.longitude;
          _simulatedLocation = "GPS Verified: (${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)})";
          _simulatedDeviceInfo = "Mobile App (Native, ${Theme.of(context).platform.name})";
          _isLocating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _simulatedLocation = "GPS lock failed: $e";
          _isLocating = false;
        });
      }
    }
  }

  void _startAttendanceMarkingFlow(ActiveAttendanceSession session) {
    setState(() {
      _selectedSession = session;
      _isMarkingMode = true;
      _isCameraReady = false;
      _isLocating = true;
    });

    _scanningController.repeat(reverse: true);

    _determinePosition();
    _initializeCamera();
  }

  Future<void> _captureAndMarkAttendance() async {
    if (_selectedSession == null || _isSubmitting) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera is not ready yet."),
          backgroundColor: VelsTheme.overdueRed,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Screen Flash effect
    Navigator.of(context).overlay?.insert(
      OverlayEntry(
        builder: (context) => const CameraFlashOverlay(),
      ),
    );

    try {
      final XFile photo = await _cameraController!.takePicture();

      final deviceInfo = {
        "model": "Mobile Device",
        "os": Theme.of(context).platform.name,
        "app_version": "1.0.0",
        "timestamp": DateTime.now().toIso8601String()
      };

      final result = await AcademicService.markStudentAttendance(
        sessionId: _selectedSession!.id,
        imagePath: photo.path,
        latitude: _simulatedLat,
        longitude: _simulatedLng,
        deviceInfo: deviceInfo,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (result['success'] == true) {
          await _disposeCamera();
          _showSuccessDialog();
          setState(() {
            _isMarkingMode = false;
            _selectedSession = null;
          });
          _loadAttendanceData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? "Failed to mark attendance"),
              backgroundColor: VelsTheme.overdueRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Capture failed: $e"),
            backgroundColor: VelsTheme.overdueRed,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: VelsTheme.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: VelsTheme.successGreen,
                  size: 44,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Attendance Marked!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: VelsTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Successfully registered present at ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} for ${_selectedSession?.subjectName ?? 'your class'}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: VelsTheme.textLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Got it',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isMarkingMode && _selectedSession != null) {
      return _buildMarkingCameraOverlay();
    }

    return Column(
      children: [
        const VelsHeader(
          title: 'Attendance Desk',
          subtitle: 'VELS Self-Marking & Logs',
          avatarIcon: Icons.fingerprint,
        ),
        _buildTabs(),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: VelsTheme.primaryBlue),
                )
              : _errorMessage != null
                  ? _buildErrorView()
                  : RefreshIndicator(
                      onRefresh: _loadAttendanceData,
                      color: VelsTheme.primaryBlue,
                      child: _activeTab == 0 ? _buildOverviewTab() : _buildHistoryTab(),
                    ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: VelsTheme.backgroundGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _activeTab = 0),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _activeTab == 0 ? VelsTheme.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Overview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _activeTab == 0 ? Colors.white : VelsTheme.textLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _activeTab = 1),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _activeTab == 1 ? VelsTheme.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'History Log',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _activeTab == 1 ? Colors.white : VelsTheme.textLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.sync_problem, color: VelsTheme.overdueRed, size: 50),
            const SizedBox(height: 16),
            const Text(
              'Sync Error',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelsTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Connection lost.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: VelsTheme.textLight),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAttendanceData,
              style: ElevatedButton.styleFrom(
                backgroundColor: VelsTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Try Syncing Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final avg = _overallAttendancePercentage;
    final isBelow = avg < 75.0 && _reports.isNotEmpty;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attendance summary ring card
          _buildSummaryStatsCard(avg, isBelow),
          const SizedBox(height: 20),

          // Active sessions checklist
          _buildActiveSessionsHeader(),
          const SizedBox(height: 10),
          _buildActiveSessionsList(),
          const SizedBox(height: 24),

          // Subject reports breakdown list
          const Text(
            'Subject Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: VelsTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildReportsBreakdown(),
        ],
      ),
    );
  }

  Widget _buildSummaryStatsCard(double avg, bool isBelow) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VelsTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: _reports.isEmpty ? 0.0 : avg / 100,
                  strokeWidth: 8,
                  backgroundColor: VelsTheme.backgroundGray,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isBelow ? VelsTheme.overdueRed : VelsTheme.successGreen,
                  ),
                ),
              ),
              Text(
                _reports.isEmpty ? 'N/A' : '${avg.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isBelow ? VelsTheme.overdueRed : VelsTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Average Attendance',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: VelsTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isBelow
                      ? 'Action Required: Your attendance is below the 75% university requirement.'
                      : 'Excellent! Your attendance is above the 75% required threshold.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isBelow ? VelsTheme.overdueRed : VelsTheme.textLight,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActiveSessionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Active Classes Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: VelsTheme.textDark,
              ),
            ),
            if (_activeSessions.isNotEmpty) ...[
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: VelsTheme.overdueRed.withOpacity(_pulseController.value),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            ]
          ],
        ),
        TextButton.icon(
          onPressed: _loadActiveSessionsOnly,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh', style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
            foregroundColor: VelsTheme.secondaryBlue,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionsList() {
    if (_activeSessions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VelsTheme.borderLight),
        ),
        child: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: VelsTheme.textLight, size: 36),
            SizedBox(height: 12),
            Text(
              'No active classes open for self-marking',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: VelsTheme.textLight,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'They will appear here once faculty opens them.',
              style: TextStyle(
                fontSize: 11,
                color: VelsTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activeSessions.length,
      itemBuilder: (context, index) {
        final session = _activeSessions[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: session.canMarkAttendance ? VelsTheme.secondaryBlue.withOpacity(0.5) : VelsTheme.borderLight,
              width: session.canMarkAttendance ? 1.5 : 1,
            ),
            boxShadow: session.canMarkAttendance
                ? [
                    BoxShadow(
                      color: VelsTheme.secondaryBlue.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: VelsTheme.primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        session.periodInfo,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: VelsTheme.primaryBlue,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: session.canMarkAttendance
                            ? VelsTheme.successGreen.withOpacity(0.1)
                            : VelsTheme.overdueRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        session.canMarkAttendance
                            ? 'Open (${session.timeRemaining}m left)'
                            : 'Closed/Expired',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: session.canMarkAttendance ? VelsTheme.successGreen : VelsTheme.overdueRed,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  session.subjectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: VelsTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: VelsTheme.textLight),
                    const SizedBox(width: 4),
                    Text(
                      session.facultyName,
                      style: const TextStyle(fontSize: 12, color: VelsTheme.textLight),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.room_outlined, size: 14, color: VelsTheme.textLight),
                    const SizedBox(width: 4),
                    Text(
                      session.sectionsName,
                      style: const TextStyle(fontSize: 12, color: VelsTheme.textLight),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (session.canMarkAttendance)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _startAttendanceMarkingFlow(session),
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text(
                        'Punch Attendance Now',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelsTheme.secondaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  )
                else
                  const Row(
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: VelsTheme.textLight),
                      SizedBox(width: 4),
                      Text(
                        'Marking time is no longer available.',
                        style: TextStyle(fontSize: 11, color: VelsTheme.textLight),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
    }

  Widget _buildReportsBreakdown() {
    if (_reports.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VelsTheme.borderLight),
        ),
        child: const Center(
          child: Text(
            'No subject reports generated yet.',
            style: TextStyle(color: VelsTheme.textLight),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        final isLow = report.isBelowThreshold;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VelsTheme.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.subjectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: VelsTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          report.subjectCode,
                          style: const TextStyle(fontSize: 11, color: VelsTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLow ? VelsTheme.overdueRed.withOpacity(0.08) : VelsTheme.successGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.percentageDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isLow ? VelsTheme.overdueRed : VelsTheme.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildReportStat('Present', '${report.presentCount}'),
                  _buildReportStat('Absent', '${report.absentCount}'),
                  _buildReportStat('Late', '${report.lateCount}'),
                  _buildReportStat('Total classes', '${report.totalClasses}'),
                ],
              ),
              if (isLow && report.classesNeededFor75 > 0) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: VelsTheme.pendingYellow.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: VelsTheme.pendingYellow, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Must attend next ${report.classesNeededFor75} classes consecutively to reach 75%.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: VelsTheme.pendingYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: VelsTheme.textLight)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelsTheme.textDark)),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        children: const [
          Center(
            child: Column(
              children: [
                Icon(Icons.history, color: VelsTheme.textLight, size: 40),
                SizedBox(height: 12),
                Text(
                  'No attendance logs available',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: VelsTheme.textLight,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your daily attendance details will be logged here.',
                  style: TextStyle(fontSize: 12, color: VelsTheme.textLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final isPresent = item.status == 'PRESENT';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VelsTheme.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.date,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: VelsTheme.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPresent ? VelsTheme.successGreen.withOpacity(0.1) : VelsTheme.overdueRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPresent ? VelsTheme.successGreen : VelsTheme.overdueRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.subjectName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: VelsTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined, size: 14, color: VelsTheme.textLight),
                  const SizedBox(width: 4),
                  Text(
                    item.periodInfo,
                    style: const TextStyle(fontSize: 12, color: VelsTheme.textLight),
                  ),
                  if (item.markedAt.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.fingerprint_outlined, size: 14, color: VelsTheme.textLight),
                    const SizedBox(width: 4),
                    Text(
                      'Punched: ${item.markedAt.split("T").last.substring(0, 5)}',
                      style: const TextStyle(fontSize: 12, color: VelsTheme.textLight),
                    ),
                  ]
                ],
              ),
              if (item.latitude != null && item.longitude != null) ...[
                const Divider(height: 20),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: VelsTheme.textLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Location Verified: ${item.latitude!.toStringAsFixed(6)}, ${item.longitude!.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 11, color: VelsTheme.textLight),
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  // Simulated camera layout when student clicks "Mark Attendance"
  Widget _buildMarkingCameraOverlay() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _disposeCamera();
                      setState(() {
                        _isMarkingMode = false;
                        _selectedSession = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Self Face Verification',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedSession?.subjectName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Viewfinder Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Viewfinder background simulation
                      Container(
                        color: const Color(0xFF1E293B),
                        width: double.infinity,
                        height: double.infinity,
                        child: _isCameraReady && _cameraController != null && _cameraController!.value.isInitialized
                            ? CameraPreview(_cameraController!)
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Colors.white),
                                    SizedBox(height: 12),
                                    Text(
                                      'Connecting Secure Camera Feed...',
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    )
                                  ],
                                ),
                              ),
                      ),

                      // Face tracking overlay grid
                      if (_isCameraReady) ...[
                        // Corners
                        Positioned(
                          top: 40,
                          left: 40,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: VelsTheme.accentTeal, width: 3),
                                left: BorderSide(color: VelsTheme.accentTeal, width: 3),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          right: 40,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: VelsTheme.accentTeal, width: 3),
                                right: BorderSide(color: VelsTheme.accentTeal, width: 3),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          left: 40,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: VelsTheme.accentTeal, width: 3),
                                left: BorderSide(color: VelsTheme.accentTeal, width: 3),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          right: 40,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: VelsTheme.accentTeal, width: 3),
                                right: BorderSide(color: VelsTheme.accentTeal, width: 3),
                              ),
                            ),
                          ),
                        ),

                        // Face contour outline
                        Center(
                          child: CustomPaint(
                            size: const Size(200, 260),
                            painter: FaceContourPainter(),
                          ),
                        ),

                        // Scan Animation Line
                        AnimatedBuilder(
                          animation: _scanningController,
                          builder: (context, child) {
                            return Positioned(
                              top: 60 + (_scanningController.value * 280),
                              left: 50,
                              right: 50,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: VelsTheme.accentTeal.withOpacity(0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ],
                                  color: VelsTheme.accentTeal,
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      // GPS Loading Overlay
                      if (_isLocating)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.gps_fixed, color: VelsTheme.accentTeal, size: 36),
                                SizedBox(height: 12),
                                Text(
                                  'Verifying Location Coordinates...',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),

            // Metadata info & controls
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isLocating ? Icons.gps_not_fixed : Icons.gps_fixed,
                              color: _isLocating ? Colors.white54 : VelsTheme.successGreen,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _simulatedLocation,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!_isLocating) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.phone_android, color: Colors.white54, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Device: $_simulatedDeviceInfo',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Shutter button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (_isCameraReady && !_isLocating && !_isSubmitting)
                            ? _captureAndMarkAttendance
                            : null,
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: (_isCameraReady && !_isLocating)
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Position face in frame and press capture',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simulated Video Feed removed

// Custom Painter to draw a high-tech face shape alignment overlay
class FaceContourPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VelsTheme.accentTeal.withOpacity(0.35)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Draw an egg/oval shape representing a face guide
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Draw eye level guideline
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      paint,
    );

    // Draw vertical center level guideline
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      paint,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Shutter Flash Screen Overlay
class CameraFlashOverlay extends StatefulWidget {
  const CameraFlashOverlay({super.key});

  @override
  State<CameraFlashOverlay> createState() => _CameraFlashOverlayState();
}

class _CameraFlashOverlayState extends State<CameraFlashOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 0.9).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      ),
      child: Container(
        color: Colors.white,
      ),
    );
  }
}
