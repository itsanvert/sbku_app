import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sbku_app/providers/auth_provider.dart';
import 'package:sbku_app/service/attendance_service.dart';
import 'package:sbku_app/presentation/screens/attendance/student_attendance_status_screen.dart';
import 'package:sbku_app/presentation/widgets/shimmer_widget.dart';

/// Modern QR Scan Attendance Screen
/// Supports: live camera scan | pick QR image from gallery
/// When navigated from a push notification, [sessionId] and [qrToken]
/// can be provided to auto-initiate the check-in without scanning.
class QrScanAttendanceScreen extends StatefulWidget {
  final String? sessionId;
  final String? qrToken;

  const QrScanAttendanceScreen({super.key, this.sessionId, this.qrToken});

  @override
  State<QrScanAttendanceScreen> createState() => _QrScanAttendanceScreenState();
}

enum _ScanMode { camera, gallery }

class _QrScanAttendanceScreenState extends State<QrScanAttendanceScreen>
    with TickerProviderStateMixin {
  final AttendanceService _attendanceService = AttendanceService();
  final ImagePicker _imagePicker = ImagePicker();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  _ScanMode _mode = _ScanMode.camera;
  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _resultMessage;
  bool _isSuccess = false;
  String _verifyStatus = 'pending';
  bool _torchOn = false;

  // Gallery mode state
  File? _pickedImage;
  String? _galleryError;
  bool _isAnalyzingImage = false;

  // ── Animations ──────────────────────────────────────────────────
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _resultController;
  late AnimationController _modeTabController;
  late Animation<double> _scanLineAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _resultScaleAnim;
  late Animation<double> _resultFadeAnim;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _resultScaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );

    _resultFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeIn),
    );

    _modeTabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // If navigated from a push notification with session params, auto-check-in
    if (widget.sessionId != null && widget.qrToken != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final qrPayload = jsonEncode({
          'session_id': widget.sessionId,
          'qr_token': widget.qrToken,
        });
        _processRawValue(qrPayload);
      });
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    _resultController.dispose();
    _modeTabController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  // ── QR Processing ────────────────────────────────────────────────

  Future<void> _processRawValue(String rawValue) async {
    if (_isProcessing || _hasScanned) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    try {
      final qrData = jsonDecode(rawValue);
      final sessionId = qrData['session_id'];
      final qrToken = qrData['qr_token'];

      if (sessionId == null || qrToken == null) {
        throw Exception(
            'QR code មិនត្រឹមត្រូវ — Missing session_id or qr_token');
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user == null) throw Exception('សូមចូលគណនីជាមុន');

      final result = await _attendanceService.checkInWithQr(
        sessionId: sessionId.toString(),
        studentId: user.id.toString(),
        qrToken: qrToken.toString(),
      );

      HapticFeedback.heavyImpact();

      if (mounted) {
        setState(() {
          _resultMessage = result['message'] ?? 'ចុះវត្តមានជោគជ័យ!';
          _isSuccess = true;
          _isProcessing = false;
          _verifyStatus =
              result['attendance']?['verify_status']?.toString() ?? 'pending';
        });
        _resultController.forward();
      }
    } catch (e) {
      HapticFeedback.vibrate();
      if (mounted) {
        setState(() {
          _resultMessage = e.toString().replaceAll('Exception: ', '');
          _isSuccess = false;
          _isProcessing = false;
        });
        _resultController.forward();
      }
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    await _processRawValue(raw);
  }

  // ── Gallery QR Scan ──────────────────────────────────────────────

  Future<void> _pickAndScanImage() async {
    setState(() {
      _galleryError = null;
      _isAnalyzingImage = false;
    });

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _pickedImage = file;
      _isAnalyzingImage = true;
    });

    try {
      // Use MobileScanner's analyzeImage to decode QR from the file
      final capture = await _scannerController.analyzeImage(picked.path);

      if (!mounted) return;

      final raw = capture?.barcodes.firstOrNull?.rawValue;

      if (raw == null) {
        setState(() {
          _isAnalyzingImage = false;
          _galleryError =
              'រកមិនឃើញ QR code ក្នុងរូបភាព។\nសូមប្រើរូបភាពដែលមាន QR code ច្បាស់ល្អ។';
        });
        HapticFeedback.vibrate();
        return;
      }

      setState(() => _isAnalyzingImage = false);
      await _processRawValue(raw);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzingImage = false;
          _galleryError =
              'មិនអាចអានរូបភាព: ${e.toString().replaceAll("Exception: ", "")}';
        });
      }
    }
  }

  void _resetScanner() {
    _resultController.reset();
    setState(() {
      _hasScanned = false;
      _resultMessage = null;
      _isSuccess = false;
      _verifyStatus = 'pending';
      _pickedImage = null;
      _galleryError = null;
      _isAnalyzingImage = false;
    });
  }

  void _toggleTorch() {
    _scannerController.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  void _switchMode(_ScanMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _pickedImage = null;
      _galleryError = null;
      _isAnalyzingImage = false;
    });
    if (mode == _ScanMode.gallery) {
      _modeTabController.forward();
    } else {
      _modeTabController.reverse();
    }
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _hasScanned ? null : _buildAppBar(),
      body: _hasScanned ? _buildResultOverlay() : _buildScanBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: _iconPill(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'ស្កេន QR វត្តមាន',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_mode == _ScanMode.camera) ...[
          IconButton(
            icon: _iconPill(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              activeColor: _torchOn ? Colors.orange : null,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Flash',
          ),
          IconButton(
            icon: _iconPill(Icons.flip_camera_ios_outlined),
            onPressed: () => _scannerController.switchCamera(),
            tooltip: 'Flip',
          ),
        ],
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _iconPill(IconData icon, {Color? activeColor}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (activeColor ?? Colors.black)
            .withOpacity(activeColor != null ? 0.85 : 0.4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildScanBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Background ────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _mode == _ScanMode.camera
              ? MobileScanner(
                  key: const ValueKey('camera'),
                  controller: _scannerController,
                  onDetect: _onDetect,
                )
              : Container(
                  key: const ValueKey('gallery'),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0D0D1A), Color(0xFF111122)],
                    ),
                  ),
                ),
        ),

        // ── Overlay / scan frame (camera only) ────────────────────
        if (_mode == _ScanMode.camera) ...[
          _buildOverlay(),
          Center(child: _buildScanFrame()),
        ],

        // ── Gallery content ───────────────────────────────────────
        if (_mode == _ScanMode.gallery) _buildGalleryContent(),

        // ── Mode switcher tab bar ─────────────────────────────────
        Positioned(
          bottom: 32,
          left: 32,
          right: 32,
          child: _buildModeTab(),
        ),

        // ── Bottom instruction pill (camera only) ─────────────────
        if (_mode == _ScanMode.camera)
          Positioned(
            bottom: 108,
            left: 50,
            right: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner,
                      color: Colors.orange.shade300, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'ដាក់ QR កូដនៅក្នុងប្រអប់',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Processing overlay ────────────────────────────────────
        if (_isProcessing) _buildProcessingOverlay(),
      ],
    );
  }

  // ── Mode tab switcher ────────────────────────────────────────────
  Widget _buildModeTab() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          _modeTabButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'ស្កេន',
            selected: _mode == _ScanMode.camera,
            onTap: () => _switchMode(_ScanMode.camera),
          ),
          _modeTabButton(
            icon: Icons.photo_library_rounded,
            label: 'ពីរូបភាព',
            selected: _mode == _ScanMode.gallery,
            onTap: () => _switchMode(_ScanMode.gallery),
          ),
        ],
      ),
    );
  }

  Widget _modeTabButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Gallery pick content ─────────────────────────────────────────
  Widget _buildGalleryContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 100, 24, 110),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_pickedImage == null && !_isAnalyzingImage) ...[
              // ── Empty state — tap to pick ──────────────────────
              GestureDetector(
                onTap: _pickAndScanImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.35),
                      width: 1.5,
                      // Dashed effect via gradient border isn't native,
                      // so we use a styled solid border + dashed hint icon
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_rounded,
                          color: Colors.orange,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ជ្រើសរើសរូបភាព QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ចុចដើម្បីជ្រើសរើសរូបភាព\nដែលមាន QR code វត្តមាន',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tips row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _tipChip(Icons.brightness_high_outlined, 'ច្បាស់'),
                            const SizedBox(width: 8),
                            _tipChip(Icons.crop_free_outlined, 'ពេញ'),
                            const SizedBox(width: 8),
                            _tipChip(
                                Icons.do_not_disturb_alt_outlined, 'មិនព្ព'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_galleryError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _galleryError!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _pickAndScanImage,
                  icon: const Icon(Icons.refresh_rounded,
                      color: Colors.orange, size: 18),
                  label: const Text(
                    'ព្យាយាមម្ដងទៀត',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ] else if (_isAnalyzingImage) ...[
              // ── Analyzing state ────────────────────────────────
              if (_pickedImage != null) _buildImagePreview(analyzing: true),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: ShimmerWidget(width: 20, height: 20, borderRadius: 10),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'កំពុងស្កេន QR ពីរូបភាព...',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ] else if (_pickedImage != null) ...[
              // ── Image preview (after failed scan — shouldn't normally
              //    reach here since success goes to result screen)
              _buildImagePreview(analyzing: false),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _pickAndScanImage,
                icon: const Icon(Icons.photo_library_rounded,
                    color: Colors.orange, size: 18),
                label: const Text(
                  'ជ្រើសរើសរូបភាពផ្សេង',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview({required bool analyzing}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            _pickedImage!,
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
          ),
        ),
        if (analyzing)
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: ShimmerWidget(width: 36, height: 36, borderRadius: 18),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'កំពុងស្វែងរក QR...',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Corner brackets overlay on image
        if (!analyzing)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            bottom: 12,
            child: CustomPaint(
              painter: _ScanOverlayPainter(cutoutSize: 160, dimOpacity: 0),
            ),
          ),
      ],
    );
  }

  Widget _tipChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white38, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  // ── Processing overlay ───────────────────────────────────────────
  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C2E),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: ShimmerWidget(width: 48, height: 48, borderRadius: 24),
              ),
              const SizedBox(height: 16),
              const Text(
                'កំពុងចុះវត្តមាន...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Camera scan overlays ─────────────────────────────────────────
  Widget _buildOverlay() {
    return CustomPaint(
      painter: _ScanOverlayPainter(cutoutSize: 260),
    );
  }

  Widget _buildScanFrame() {
    const frameSize = 260.0;
    const cornerLen = 28.0;
    const cornerW = 4.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _scanLineAnim]),
      builder: (_, __) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: SizedBox(
            width: frameSize,
            height: frameSize,
            child: Stack(
              children: [
                Positioned(
                    top: 0,
                    left: 0,
                    child: _corner(
                        topLeft: true, size: cornerLen, width: cornerW)),
                Positioned(
                    top: 0,
                    right: 0,
                    child: _corner(
                        topRight: true, size: cornerLen, width: cornerW)),
                Positioned(
                    bottom: 0,
                    left: 0,
                    child: _corner(
                        bottomLeft: true, size: cornerLen, width: cornerW)),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: _corner(
                        bottomRight: true, size: cornerLen, width: cornerW)),

                // Scan line
                Positioned(
                  top: _scanLineAnim.value * (frameSize - 4),
                  left: cornerLen,
                  right: cornerLen,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0),
                          Colors.orange.shade400,
                          Colors.orange.withOpacity(0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _corner({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
    required double size,
    required double width,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CornerPainter(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
        color: Colors.orange.shade400,
        strokeWidth: width,
      ),
    );
  }

  // ── Result Screen ────────────────────────────────────────────────
  Widget _buildResultOverlay() {
    final isApproved = _verifyStatus == 'approved';
    final isPending = _verifyStatus == 'pending';

    final Color statusColor =
        isPending ? Colors.orange : (isApproved ? Colors.green : Colors.red);
    final IconData statusIcon = isPending
        ? Icons.pending_actions_rounded
        : (isApproved ? Icons.verified_rounded : Icons.cancel_rounded);
    final String statusLabel = isPending
        ? 'រង់ចាំការអនុម័ត'
        : (isApproved ? 'បានអនុម័ត' : 'បានបដិសេធ');

    final Color resultColor = _isSuccess ? Colors.green : Colors.red;
    final IconData resultIcon =
        _isSuccess ? Icons.check_circle_rounded : Icons.error_rounded;
    final String resultTitle = _isSuccess ? 'ជោគជ័យ!' : 'មានបញ្ហា';

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        gradient: isDarkMode
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E)],
              )
            : null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: isDarkMode ? Colors.white70 : Colors.black87, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'ផ្ទៀងផ្ទាត់វត្តមាន',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: FadeTransition(
                opacity: _resultFadeAnim,
                child: ScaleTransition(
                  scale: _resultScaleAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        // Result icon with glow
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: resultColor.withOpacity(0.12),
                            boxShadow: [
                              BoxShadow(
                                color: resultColor.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(resultIcon, size: 64, color: resultColor),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          resultTitle,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: resultColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Scan mode badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _mode == _ScanMode.camera
                                    ? Icons.qr_code_scanner_rounded
                                    : Icons.photo_library_rounded,
                                color: isDarkMode ? Colors.white38 : Colors.black54,
                                size: 12,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _mode == _ScanMode.camera
                                    ? 'Camera Scan'
                                    : 'Image Upload',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white38 : Colors.black54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // If gallery mode, show picked image thumbnail
                        if (_mode == _ScanMode.gallery &&
                            _pickedImage != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _pickedImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        Text(
                          _resultMessage ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white60 : Colors.black87,
                            height: 1.5,
                          ),
                        ),

                        // Verify status card
                        if (_isSuccess) ...[
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: statusColor.withOpacity(0.15),
                                  ),
                                  child: Icon(statusIcon,
                                      color: statusColor, size: 28),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isPending) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'គ្រូបង្រៀននឹងត្រួតពិនិត្យ\nហើយអនុម័ត ឬ បដិសេធ ការចូលរួមរបស់អ្នក',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black45,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 36),

                        // Action buttons
                        if (_isSuccess) ...[
                          _ActionButton(
                            onPressed: () => Navigator.pop(context, true),
                            icon: Icons.check_rounded,
                            label: 'រួចរាល់',
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _ActionButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const StudentAttendanceStatusScreen(),
                              ),
                            ),
                            icon: Icons.fact_check_outlined,
                            label: 'មើលស្ថានភាពវត្តមានរបស់ខ្ញុំ',
                            color: Colors.orange,
                            outlined: true,
                          ),
                        ] else ...[
                          _ActionButton(
                            onPressed: _resetScanner,
                            icon: Icons.qr_code_scanner_rounded,
                            label: 'ព្យាយាមម្ដងទៀត',
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'ថយក្រោយ',
                              style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
                            ),
                          ),
                        ],
                      ],
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
}

// ── Reusable action button ────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final bool outlined;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.7)),
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        shadowColor: color.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Dark overlay with cutout ──────────────────────────────────────
class _ScanOverlayPainter extends CustomPainter {
  final double cutoutSize;
  final double dimOpacity;

  _ScanOverlayPainter({required this.cutoutSize, this.dimOpacity = 0.62});

  @override
  void paint(Canvas canvas, Size size) {
    if (dimOpacity <= 0) return;

    final paint = Paint()..color = Colors.black.withOpacity(dimOpacity);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = cutoutSize / 2;

    final outer = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - half, cy - half, cx + half, cy + half),
        const Radius.circular(16),
      ));

    canvas.drawPath(
        Path.combine(PathOperation.difference, outer, inner), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter old) =>
      old.dimOpacity != dimOpacity || old.cutoutSize != cutoutSize;
}

// ── Corner bracket painter ────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  final bool topLeft, topRight, bottomLeft, bottomRight;
  final Color color;
  final double strokeWidth;

  _CornerPainter({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    if (topLeft) {
      canvas.drawLine(Offset(0, h), const Offset(0, 0), paint);
      canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint);
    }
    if (topRight) {
      canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
    }
    if (bottomLeft) {
      canvas.drawLine(const Offset(0, 0), Offset(0, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    }
    if (bottomRight) {
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
      canvas.drawLine(Offset(w, h), Offset(0, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}


