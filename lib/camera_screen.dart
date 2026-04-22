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

  Widget _buildResultCard() {
    final hasTrash = _analysisResult!['has_trash'] as bool;
    final category = _analysisResult!['trash_category'] as String;
    final confidence = (_analysisResult!['confidence'] as num).toDouble();
    final confidencePercent = (confidence * 100).toStringAsFixed(0);

    // Color logic
    final bgColor = hasTrash ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    final primaryColor = hasTrash ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final icon = hasTrash ? Icons.delete_sweep_rounded : Icons.eco_rounded;
    final titleText = hasTrash ? 'Trash Detected' : 'Clean Area';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            titleText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          if (hasTrash)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: primaryColor,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_rounded, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Confidence: $confidencePercent%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
