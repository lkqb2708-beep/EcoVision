import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'api_service.dart';
import 'app_theme.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  int _selectedCameraIndex = 0;

  // Capture & analysis state
  File? _capturedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _initCamera(widget.cameras[_selectedCameraIndex]);
    }
  }

  void _initCamera(CameraDescription cameraDescription) {
    _controller = CameraController(cameraDescription, ResolutionPreset.high);
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _switchCamera() {
    if (widget.cameras.length > 1) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
      _initCamera(widget.cameras[_selectedCameraIndex]);
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _initializeControllerFuture;
      final XFile photo = await _controller!.takePicture();
      setState(() {
        _capturedImage = File(photo.path);
        _analysisResult = null;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = "Failed to capture image: $e");
    }
  }

  Future<void> _analyzeImage() async {
    if (_capturedImage == null) return;
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    try {
      final result = await ApiService.analyzeImage(_capturedImage!);
      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
        if (result.containsKey('error') && result['error'] == true) {
          _errorMessage = result['message'] ?? 'Unknown error';
        }
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = "Analysis failed: $e";
      });
    }
  }

  void _resetToCamera() {
    setState(() {
      _capturedImage = null;
      _analysisResult = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.no_photography, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No camera found', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      );
    }

    if (_capturedImage != null) {
      return _buildPreviewScreen();
    }
    return _buildCameraScreen();
  }

  /// 📸 MODERN CAMERA VIEWFINDER
  Widget _buildCameraScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && _controller != null) {
            return Stack(
              children: [
                // Full screen camera preview
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.previewSize?.height ?? 1,
                      height: _controller!.value.previewSize?.width ?? 1,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
                
                // Top gradient for status bar visibility
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: AppTheme.topGradient,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text('Trashy', style: AppTheme.titleStyle),
                            ),
                            if (widget.cameras.length > 1)
                              IconButton(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
                                onPressed: _switchCamera,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom controls gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 160,
                    decoration: AppTheme.bottomGradient,
                    child: Center(
                      child: GestureDetector(
                        onTap: _captureImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: AppTheme.captureButtonOuterRing,
                          child: Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: AppTheme.captureButtonInnerCircle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Camera error', style: TextStyle(color: Colors.white)));
          } else {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
        },
      ),
    );
  }

  /// 📱 MODERN PREVIEW & RESULT SCREEN
  Widget _buildPreviewScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _resetToCamera,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Captured image with rounded corners & shadow
              Hero(
                tag: 'captured_image',
                child: Container(
                  height: 380,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.file(
                      _capturedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Dynamic state area (Button / Loading / Result)
              if (_isAnalyzing)
                _buildLoadingState()
              else if (_analysisResult != null && _errorMessage == null && _analysisResult!['error'] != true)
                _buildResultCard()
              else if (_errorMessage != null)
                _buildErrorCard()
              else
                _buildAnalyzeButton(),

              const SizedBox(height: 24),
              
              // ── Secondary Action
              if (_analysisResult != null || _errorMessage != null)
                FilledButton.tonal(
                  onPressed: _resetToCamera,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Scan Another Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return FilledButton.icon(
      onPressed: _analyzeImage,
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Analyze with Trashy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            strokeWidth: 4,
            strokeCap: StrokeCap.round,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Trashy is inspecting...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.error_rounded, color: Theme.of(context).colorScheme.onErrorContainer, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── helpers ─────────────────────────────────────────────────

  /// Returns visual style for each HCMC waste type.
  Map<String, dynamic> _styleForType(String trashType) {
    switch (trashType) {
      case 'tai_che':
        return {
          'label':   'Rác Tái Chế',
          'sublabel': 'Recyclable Waste',
          'icon':    Icons.recycling_rounded,
          'bg':      const Color(0xFFEFF6FF),
          'color':   const Color(0xFF1D4ED8),
          'binHint': 'Thu gom riêng – bán hoặc cho ve chai',
          'binIcon': Icons.sell_rounded,
        };
      case 'huu_co':
        return {
          'label':   'Rác Hữu Cơ',
          'sublabel': 'Organic / Food Waste',
          'icon':    Icons.eco_rounded,
          'bg':      const Color(0xFFF0FDF4),
          'color':   const Color(0xFF15803D),
          'binHint': 'Thùng màu XANH',
          'binIcon': Icons.delete_outline_rounded,
        };
      case 'vo_co':
        return {
          'label':   'Rác Vô Cơ',
          'sublabel': 'Non-Recyclable Waste',
          'icon':    Icons.delete_sweep_rounded,
          'bg':      const Color(0xFFFFF7ED),
          'color':   const Color(0xFFC2410C),
          'binHint': 'Thùng màu CAM',
          'binIcon': Icons.delete_rounded,
        };
      case 'nguy_hai':
        return {
          'label':   'Rác Nguy Hại',
          'sublabel': 'Hazardous Waste',
          'icon':    Icons.warning_amber_rounded,
          'bg':      const Color(0xFFFEF2F2),
          'color':   const Color(0xFFB91C1C),
          'binHint': 'Để RIÊNG – không trộn rác sinh hoạt',
          'binIcon': Icons.report_problem_rounded,
        };
      default: // no trash
        return {
          'label':   'Sạch',
          'sublabel': 'No Trash Detected',
          'icon':    Icons.check_circle_outline_rounded,
          'bg':      const Color(0xFFF0FDF4),
          'color':   const Color(0xFF16A34A),
          'binHint': '',
          'binIcon': Icons.check_rounded,
        };
    }
  }

  Widget _buildResultCard() {
    final hasTrash  = _analysisResult!['has_trash'] as bool;
    final trashType = (_analysisResult!['trash_type'] as String?) ?? 'none';
    final category  = (_analysisResult!['trash_category'] as String?) ?? '';
    final confidence = (_analysisResult!['confidence'] as num).toDouble();
    final instruction = (_analysisResult!['instruction'] as String?) ?? '';
    final confidencePercent = (confidence * 100).toStringAsFixed(0);

    final style = _styleForType(hasTrash ? trashType : 'none');
    final Color primaryColor = style['color'] as Color;
    final Color bgColor      = style['bg']    as Color;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: primaryColor.withOpacity(0.25), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── STEP 1: Has Trash? ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(style['icon'] as IconData, size: 36, color: primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasTrash ? 'Phát hiện rác!' : 'Không có rác',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        hasTrash ? 'Trash detected' : 'Clean area',
                        style: TextStyle(fontSize: 13, color: primaryColor.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                // Confidence badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.analytics_rounded, size: 14, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '$confidencePercent%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (hasTrash) ...[
            const SizedBox(height: 16),
            Divider(color: primaryColor.withOpacity(0.15), height: 1, indent: 24, endIndent: 24),

            // ── STEP 2: Waste Classification ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type label
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              style['label'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              style['sublabel'] as String,
                              style: TextStyle(fontSize: 12, color: primaryColor.withOpacity(0.65)),
                            ),
                          ],
                        ),
                      ),
                      // Specific item chip
                      if (category.isNotEmpty && category != 'none')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bin hint row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(style['binIcon'] as IconData, size: 18, color: primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            style['binHint'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Instruction box
                  if (instruction.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primaryColor.withOpacity(0.15)),
                      ),
                      child: Text(
                        instruction,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
